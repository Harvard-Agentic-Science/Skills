#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/fasrc-security.XXXXXX")"
trap 'rm -rf "$TEST_HOME"' EXIT

fail() {
  printf 'security test failed: %s\n' "$*" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "jq is required"

export HOME="$TEST_HOME"
export FASRC_SOURCE_ONLY=1
export FASRC_CONFIG_DIR="$TEST_HOME/.config/fasrc"
export FASRC_STATE_DIR="$TEST_HOME/.local/state/fasrc"
export FASRC_SSH_INCLUDE_FILE="$TEST_HOME/.ssh/fasrc_compute_config"
export FASRC_VSCODE_USER_SETTINGS="$TEST_HOME/settings.json"

mkdir -p "$FASRC_CONFIG_DIR"
printf '%s\n' 'UNSUPPORTED=$(touch "$HOME/defaults-were-executed")' >"$FASRC_CONFIG_DIR/defaults.env"
if HOME="$TEST_HOME" FASRC_SOURCE_ONLY=1 FASRC_CONFIG_DIR="$FASRC_CONFIG_DIR" \
  bash -c 'source "$1"' _ "$ROOT_DIR/bin/fasrc" >/dev/null 2>&1; then
  fail "unsafe defaults file was accepted"
fi
test ! -e "$TEST_HOME/defaults-were-executed" || fail "defaults file was executed"
rm -f "$FASRC_CONFIG_DIR/defaults.env"

# shellcheck source=../bin/fasrc
source "$ROOT_DIR/bin/fasrc"

encoded="$(encode_remote_arg 'value; touch /tmp/should-not-run')"
decoded="$(printf '%s' "$encoded" | base64 -d)"
[[ "$decoded" == 'value; touch /tmp/should-not-run' ]] || fail "remote argument encoding did not round-trip"
[[ "$encoded" =~ ^[A-Za-z0-9+/=]+$ ]] || fail "encoded remote argument contains shell syntax"

mkdir -p "$STATE_DIR"
printf '%s\n' 'CURRENT_JOB=$(touch "$HOME/state-was-executed")' >"$STATE_FILE"
[[ -z "$(load_saved_job || true)" ]] || fail "malformed state was accepted"
test ! -e "$TEST_HOME/state-was-executed" || fail "state file was executed"

uri="$(build_remote_uri fasrc-compute-123 "$TEST_HOME" 'folder with spaces/100%#done')"
[[ "$uri" == *'/folder%20with%20spaces/100%25%23done' ]] || fail "VS Code URI path was not encoded"

write_compute_include '12345|compute.example.edu' 12345
grep -qxF '  HostName compute.example.edu' "$SSH_INCLUDE" || fail "current alias does not target the concrete node"
grep -qxF '  HostKeyAlias compute.example.edu' "$SSH_INCLUDE" || fail "compute host-key identity is missing"
grep -qxF '  StrictHostKeyChecking accept-new' "$SSH_INCLUDE" || fail "compute host verification is not enabled"

cat >"$CODE_USER_SETTINGS" <<'JSONC'
{
  // Existing user choices must survive setup.
  "custom.setting": true,
  "latex-workshop.view.pdf.viewer": "external",
  "latex-workshop.latex.recipes": [
    { "name": "custom-recipe", "tools": ["custom-tool"] },
  ],
  "latex-workshop.latex.tools": [
    { "name": "custom-tool", "command": "true", "args": [] },
  ],
  "workbench.editorAssociations": {
    "*.pdf": "custom-pdf-viewer",
  },
}
JSONC

ensure_vscode_base_settings 1
jq -e '."custom.setting" == true' "$CODE_USER_SETTINGS" >/dev/null || fail "custom setting was lost"
jq -e '."latex-workshop.view.pdf.viewer" == "external"' "$CODE_USER_SETTINGS" >/dev/null || fail "existing PDF viewer was overwritten"
jq -e '."workbench.editorAssociations"."*.pdf" == "custom-pdf-viewer"' "$CODE_USER_SETTINGS" >/dev/null || fail "existing PDF association was overwritten"
jq -e 'any(."latex-workshop.latex.recipes"[]; .name == "custom-recipe")' "$CODE_USER_SETTINGS" >/dev/null || fail "custom LaTeX recipe was lost"
jq -e 'any(."latex-workshop.latex.recipes"[]; .name == "latexmk-fasrc")' "$CODE_USER_SETTINGS" >/dev/null || fail "managed LaTeX recipe was not added"
jq -e 'any(."latex-workshop.latex.tools"[];
  .name == "latexmk-fasrc" and
  .command == "bash" and
  (.args[1] | contains("$HOME/.local/share/fasrc/bin/latexmk")))' \
  "$CODE_USER_SETTINGS" >/dev/null || fail "managed LaTeX recipe does not target the provisioned binary"
test -f "$CODE_USER_SETTINGS.fasrc-backup" || fail "settings backup was not created"
grep -q 'Existing user choices' "$CODE_USER_SETTINGS.fasrc-backup" || fail "JSONC backup did not preserve comments"

ensure_vscode_remote_settings fasrc-compute-12345 /shared/vscode-server 1
ensure_vscode_base_settings 1
jq -e '.["remote.SSH.serverInstallPath"]["fasrc-compute"] == "/shared/vscode-server"' "$CODE_USER_SETTINGS" >/dev/null || fail "local-only setup removed the generic server path"
jq -e '.["remote.SSH.serverInstallPath"]["fasrc-compute-12345"] == "/shared/vscode-server"' "$CODE_USER_SETTINGS" >/dev/null || fail "local-only setup removed a job server path"

REMOTE_ALIAS=custom-compute
CODE_USER_SETTINGS="$TEST_HOME/custom-settings.json"
ensure_vscode_remote_settings "$(job_alias 67890)" /shared/custom-vscode-server 0
jq -e '.["remote.SSH.serverInstallPath"]["custom-compute"] == "/shared/custom-vscode-server"' "$CODE_USER_SETTINGS" >/dev/null || fail "custom generic compute alias was not configured"
jq -e '.["remote.SSH.remotePlatform"]["custom-compute"] == "linux"' "$CODE_USER_SETTINGS" >/dev/null || fail "custom generic compute platform was not configured"
jq -e '.["remote.SSH.serverInstallPath"] | has("fasrc-compute") | not' "$CODE_USER_SETTINGS" >/dev/null || fail "hard-coded generic compute alias remains"
ensure_vscode_base_settings 0
jq -e '.["remote.SSH.serverInstallPath"]["custom-compute-67890"] == "/shared/custom-vscode-server"' "$CODE_USER_SETTINGS" >/dev/null || fail "base setup removed a custom job server path"

test_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

FAKE_REMOTE_BIN="$TEST_HOME/fake-remote-bin"
FAKE_REMOTE_HOME="$TEST_HOME/remote home"
FAKE_LATEXMK_FIXTURE="$TEST_HOME/fixture-latexmk.pl"
FAKE_LATEXMK_ARCHIVE="$TEST_HOME/fixture-latexmk.zip"
FAKE_CURL_LOG="$TEST_HOME/fake-curl.log"
mkdir -p "$FAKE_REMOTE_BIN" "$FAKE_REMOTE_HOME"

cat >"$FAKE_LATEXMK_FIXTURE" <<'PERL'
#!/usr/bin/env perl
use strict;
use warnings;

if (grep { $_ eq '-v' } @ARGV) {
    print "Latexmk test fixture. Version 9.99\n";
}
PERL
printf 'archive fixture\n' >"$FAKE_LATEXMK_ARCHIVE"

cat >"$FAKE_REMOTE_BIN/ssh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

shift
[[ "${1:-}" == "bash -s" ]] || exit 64
shift
[[ "${1:-}" == "--" ]] && shift
exec bash -s -- "$@"
SH

cat >"$FAKE_REMOTE_BIN/curl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

output=''
while (($#)); do
  case "$1" in
    -o)
      output="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
[[ -n "$output" ]]
cp "$FASRC_TEST_LATEXMK_ARCHIVE" "$output"
printf 'download\n' >>"$FASRC_TEST_CURL_LOG"
SH

cat >"$FAKE_REMOTE_BIN/unzip" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

[[ "$1" == "-p" ]]
cat "$FASRC_TEST_LATEXMK_FIXTURE"
SH
chmod 755 "$FAKE_REMOTE_BIN/ssh" "$FAKE_REMOTE_BIN/curl" "$FAKE_REMOTE_BIN/unzip"

export FASRC_TEST_LATEXMK_ARCHIVE="$FAKE_LATEXMK_ARCHIVE"
export FASRC_TEST_LATEXMK_FIXTURE="$FAKE_LATEXMK_FIXTURE"
export FASRC_TEST_CURL_LOG="$FAKE_CURL_LOG"
LOGIN_HOST=fasrc-test
LATEXMK_VERSION=9.99
LATEXMK_ARCHIVE_URL=https://example.invalid/latexmk-999.zip
LATEXMK_ARCHIVE_SHA256="$(test_sha256 "$FAKE_LATEXMK_ARCHIVE")"
LATEXMK_SCRIPT_SHA256="$(test_sha256 "$FAKE_LATEXMK_FIXTURE")"

PATH="$FAKE_REMOTE_BIN:$PATH" HOME="$FAKE_REMOTE_HOME" install_remote_latexmk >/dev/null
MANAGED_LATEXMK="$FAKE_REMOTE_HOME/.local/share/fasrc/bin/latexmk"
test -x "$MANAGED_LATEXMK" || fail "managed latexmk was not installed"
"$MANAGED_LATEXMK" -v | grep -q 'Version 9.99' || fail "managed latexmk has the wrong version"
[[ "$(wc -l <"$FAKE_CURL_LOG" | tr -d ' ')" -eq 1 ]] || fail "latexmk download count is wrong after initial install"

PATH="$FAKE_REMOTE_BIN:$PATH" HOME="$FAKE_REMOTE_HOME" install_remote_latexmk >/dev/null
[[ "$(wc -l <"$FAKE_CURL_LOG" | tr -d ' ')" -eq 1 ]] || fail "idempotent latexmk check downloaded again"

printf 'tampered\n' >"$MANAGED_LATEXMK"
PATH="$FAKE_REMOTE_BIN:$PATH" HOME="$FAKE_REMOTE_HOME" install_remote_latexmk >/dev/null
[[ "$(wc -l <"$FAKE_CURL_LOG" | tr -d ' ')" -eq 2 ]] || fail "tampered latexmk was not replaced"
"$MANAGED_LATEXMK" -v | grep -q 'Version 9.99' || fail "repaired latexmk has the wrong version"

printf 'preserve-on-failure\n' >"$MANAGED_LATEXMK"
LATEXMK_ARCHIVE_SHA256=0000000000000000000000000000000000000000000000000000000000000000
if PATH="$FAKE_REMOTE_BIN:$PATH" HOME="$FAKE_REMOTE_HOME" install_remote_latexmk >/dev/null 2>&1; then
  fail "latexmk checksum mismatch unexpectedly succeeded"
fi
grep -qxF 'preserve-on-failure' "$MANAGED_LATEXMK" || fail "failed latexmk update replaced the prior installation"
if compgen -G "$MANAGED_LATEXMK.new.*" >/dev/null; then
  fail "failed latexmk update left a partial installation"
fi

allocation_claim="$TEST_HOME/allocation-claim"
cancelled_entries="$TEST_HOME/cancelled-entries"
allocate_new_job() {
  if mkdir "$allocation_claim" 2>/dev/null; then
    printf '12345|compute.example.edu\n'
    return 0
  fi
  printf 'simulated allocation failure\n' >&2
  return 1
}
cancel_job_entries() {
  printf '%s\n' "$1" >"$cancelled_entries"
}
SUBMIT_INTERVAL=0.5
if allocate_new_jobs 2 >/dev/null 2>&1; then
  fail "partial batch unexpectedly succeeded"
fi
grep -qxF '12345|compute.example.edu' "$cancelled_entries" || fail "successful partial allocation was not cancelled"

if grep -R -E 'StrictHostKeyChecking no|UserKnownHostsFile /dev/null|source "\$STATE_FILE"' \
  "$ROOT_DIR/bin" "$ROOT_DIR/install.sh" >/dev/null; then
  fail "known insecure SSH/state pattern remains"
fi

printf 'fasrc security tests passed\n'
