#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/fasrc smoke.XXXXXX")"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/shell config"
printf '%s\n' '# existing shell setup' >"$TEST_HOME/shell config/zshrc"
ln -s "$TEST_HOME/shell config/zshrc" "$TEST_HOME/.zshrc"

fail() {
  printf 'smoke test failed: %s\n' "$*" >&2
  exit 1
}

HOME="$TEST_HOME" \
PREFIX="$TEST_HOME/.local" \
SHELL=/bin/zsh \
FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
"$ROOT_DIR/install.sh" --user fasrc-smoke-user >/dev/null

cat >>"$TEST_HOME/.ssh/config" <<EOF
Include fasrc_compute_config
Include ~/.ssh/fasrc_compute_config
Include "\$HOME/.ssh/fasrc_compute_config" # legacy equivalent
Include "$TEST_HOME/.ssh/fasrc_compute_config" # absolute equivalent
Include ~/.ssh/unrelated_config
EOF

cat >>"$TEST_HOME/.ssh/fasrc_compute_config" <<'EOF'

Host fasrc-compute
  HostName fasrc-compute
  ProxyCommand /tmp/retired-fasrc-proxy
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host fasrc-compute-12345
  HostName compute.example.edu
  HostKeyAlias compute.example.edu
  StrictHostKeyChecking accept-new
EOF

HOME="$TEST_HOME" \
PREFIX="$TEST_HOME/.local" \
SHELL=/bin/zsh \
FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
"$ROOT_DIR/install.sh" --user fasrc-smoke-user-2 >/dev/null

FASRC_BIN="$TEST_HOME/.local/bin/fasrc"
test -x "$FASRC_BIN" || fail "fasrc was not installed"
test ! -e "$TEST_HOME/.local/bin/fasrc-proxy" || fail "retired fasrc-proxy command remains"
test ! -e "$TEST_HOME/.local/bin/fasrc-code" || fail "retired fasrc-code command remains"
test -f "$TEST_HOME/.ssh/config" || fail "SSH config was not created"
test -f "$TEST_HOME/.ssh/fasrc_compute_config" || fail "compute SSH include was not created"
test -f "$TEST_HOME/.ssh/id_ed25519" || fail "ed25519 key was not created"
test -L "$TEST_HOME/.zshrc" || fail "shell rc symlink was replaced"
[[ "$(readlink "$TEST_HOME/.zshrc")" == "$TEST_HOME/shell config/zshrc" ]] || fail "shell rc symlink target changed"
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$TEST_HOME/shell config/zshrc" || fail "PATH was not added through the shell rc symlink"

grep -qxF "Include \"$TEST_HOME/.ssh/fasrc_compute_config\"" "$TEST_HOME/.ssh/config" || fail "SSH include is missing"
[[ "$(grep -cFx "Include \"$TEST_HOME/.ssh/fasrc_compute_config\"" "$TEST_HOME/.ssh/config")" -eq 1 ]] || fail "SSH include was duplicated"
! grep -Eq '^[[:space:]]*Include[[:space:]]+(fasrc_compute_config|~/.ssh/fasrc_compute_config|"\$HOME/.ssh/fasrc_compute_config")([[:space:]]|$)' "$TEST_HOME/.ssh/config" || fail "equivalent SSH include was preserved"
grep -qxF 'Include ~/.ssh/unrelated_config' "$TEST_HOME/.ssh/config" || fail "unrelated SSH include was removed"
grep -qxF 'Host fasrc' "$TEST_HOME/.ssh/config" || fail "FASRC login host is missing"
grep -qxF '  User fasrc-smoke-user-2' "$TEST_HOME/.ssh/config" || fail "updated FASRC username is missing"
[[ "$(grep -cFx '# BEGIN fasrc-vscode managed login' "$TEST_HOME/.ssh/config")" -eq 1 ]] || fail "managed SSH block was duplicated"
! grep -q 'StrictHostKeyChecking no' "$TEST_HOME/.ssh/fasrc_compute_config" || fail "host verification was disabled"
grep -qxF 'Host fasrc-compute-12345' "$TEST_HOME/.ssh/fasrc_compute_config" || fail "live job alias was not preserved"
! grep -qxF 'Host fasrc-compute' "$TEST_HOME/.ssh/fasrc_compute_config" || fail "insecure legacy generic alias was preserved"

HOME="$TEST_HOME" FASRC_SOURCE_ONLY=1 bash -c 'source "$1"; REMOTE_USER=fasrc-smoke-user-2; write_compute_include "12345|compute.example.edu" 12345' _ "$FASRC_BIN"

effective_user="$(HOME="$TEST_HOME" ssh -F "$TEST_HOME/.ssh/config" -G fasrc 2>/dev/null | awk '/^user / { print $2; exit }')"
[[ "$effective_user" == 'fasrc-smoke-user-2' ]] || fail "effective SSH username was not updated"

effective_compute="$(HOME="$TEST_HOME" ssh -F "$TEST_HOME/.ssh/config" -G fasrc-compute-12345 2>/dev/null)"
[[ "$(printf '%s\n' "$effective_compute" | awk '$1 == "hostname" { print $2; exit }')" == 'compute.example.edu' ]] || fail "compute include was not active"
[[ "$(printf '%s\n' "$effective_compute" | awk '$1 == "user" { print $2; exit }')" == 'fasrc-smoke-user-2' ]] || fail "compute alias user was not applied"
[[ "$(printf '%s\n' "$effective_compute" | awk '$1 == "proxyjump" { print $2; exit }')" == 'fasrc' ]] || fail "compute ProxyJump was not applied"
[[ "$(printf '%s\n' "$effective_compute" | awk '$1 == "identitiesonly" { print $2; exit }')" == 'yes' ]] || fail "compute identity policy was not applied"
[[ "$(printf '%s\n' "$effective_compute" | awk '$1 == "stricthostkeychecking" { print $2; exit }')" == 'accept-new' ]] || fail "compute host-key policy was not applied"

ALIAS_HOME="$TEST_HOME/custom alias"
HOME="$ALIAS_HOME" \
PREFIX="$ALIAS_HOME/.local" \
FASRC_ALIAS=harvard-fasrc \
FASRC_ALLOW_UNSUPPORTED_PLATFORM=1 \
"$ROOT_DIR/install.sh" --user fasrc-alias-user >/dev/null
runtime_login_host="$(HOME="$ALIAS_HOME" FASRC_SOURCE_ONLY=1 bash -c 'source "$1"; printf "%s\n" "$LOGIN_HOST"' _ "$ALIAS_HOME/.local/bin/fasrc")"
[[ "$runtime_login_host" == 'harvard-fasrc' ]] || fail "custom installer login alias was not persisted"

printf '%s\n' 'FASRC_VSCODE_SERVER_INSTALL_ROOT=/scratch/fasrc-smoke-user/vscode-server' >"$TEST_HOME/.config/fasrc/defaults.env"
runtime_server_root="$(HOME="$TEST_HOME" FASRC_SOURCE_ONLY=1 bash -c 'source "$1"; printf "%s\n" "$VSCODE_SERVER_INSTALL_ROOT_OVERRIDE"' _ "$FASRC_BIN")"
[[ "$runtime_server_root" == '/scratch/fasrc-smoke-user/vscode-server' ]] || fail "VS Code server root was not loaded from defaults"

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
