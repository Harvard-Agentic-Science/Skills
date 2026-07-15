#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/fasrc-smoke.XXXXXX")"
trap 'rm -rf "$TEST_HOME"' EXIT

fail() {
  printf 'smoke test failed: %s\n' "$*" >&2
  exit 1
}

HOME="$TEST_HOME" \
PREFIX="$TEST_HOME/.local" \
FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
"$ROOT_DIR/install.sh" --user fasrc-smoke-user >/dev/null

HOME="$TEST_HOME" \
PREFIX="$TEST_HOME/.local" \
FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
"$ROOT_DIR/install.sh" --user fasrc-smoke-user >/dev/null

FASRC_BIN="$TEST_HOME/.local/bin/fasrc"
test -x "$FASRC_BIN" || fail "fasrc was not installed"
test -x "$TEST_HOME/.local/bin/fasrc-proxy" || fail "fasrc-proxy was not installed"
test ! -e "$TEST_HOME/.local/bin/fasrc-code" || fail "retired fasrc-code command remains"
test -f "$TEST_HOME/.ssh/config" || fail "SSH config was not created"
test -f "$TEST_HOME/.ssh/fasrc_compute_config" || fail "compute SSH include was not created"
test -f "$TEST_HOME/.ssh/id_ed25519" || fail "ed25519 key was not created"

grep -qxF "Include $TEST_HOME/.ssh/fasrc_compute_config" "$TEST_HOME/.ssh/config" || fail "SSH include is missing"
[[ "$(grep -cFx "Include $TEST_HOME/.ssh/fasrc_compute_config" "$TEST_HOME/.ssh/config")" -eq 1 ]] || fail "SSH include was duplicated"
grep -qxF 'Host fasrc' "$TEST_HOME/.ssh/config" || fail "FASRC login host is missing"
grep -qxF '  User fasrc-smoke-user' "$TEST_HOME/.ssh/config" || fail "FASRC username is missing"

HOME="$TEST_HOME" "$FASRC_BIN" help env >"$TEST_HOME/help.txt"
grep -q 'Default: fasrc-vscode' "$TEST_HOME/help.txt" || fail "job-name default is undocumented"
grep -q 'Default: shared' "$TEST_HOME/help.txt" || fail "shared partition default is undocumented"
grep -q 'DEFAULT_PARTITION="${FASRC_DEFAULT_PARTITION:-shared}"' "$ROOT_DIR/bin/fasrc" || fail "shared partition is not the runtime default"
grep -q 'job_name="${FASRC_JOB_NAME:-fasrc-vscode}"' "$ROOT_DIR/bin/fasrc" || fail "allocator job-name default is inconsistent"
grep -q 'poll_seconds="${FASRC_POLL_SECONDS:-60}"' "$ROOT_DIR/bin/fasrc" || fail "allocator polling interval is inconsistent"

if HOME="$TEST_HOME" PREFIX="$TEST_HOME/bad-prefix" FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
  "$ROOT_DIR/install.sh" --user 'invalid user' >/dev/null 2>&1; then
  fail "unsafe username was accepted"
fi

printf 'fasrc smoke test passed\n'
