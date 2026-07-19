#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$TEST_DIR/smoke.sh"
bash "$TEST_DIR/security.sh"
