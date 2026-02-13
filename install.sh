#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_URL="https://raw.githubusercontent.com/kywch/cc-code-query-cli/main"
INSTALL_DIR="${HOME}/.local/bin"

# Check dependencies
if ! command -v bash &>/dev/null; then
  echo "Error: bash is required but not found." >&2
  echo "  apk add bash       (Alpine)"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "Warning: claude CLI not found. Install it before using cq."
  echo "  https://docs.anthropic.com/en/docs/claude-code"
fi

if ! command -v jq &>/dev/null; then
  echo "Warning: jq not found. Install it before using cq."
  echo "  sudo apt install jq  (Debian/Ubuntu)"
  echo "  brew install jq       (macOS)"
fi

# Download and install
mkdir -p "$INSTALL_DIR"
echo "Downloading cq..."
curl -fsSL "${REPO_RAW_URL}/cq" -o "${INSTALL_DIR}/cq"
chmod +x "${INSTALL_DIR}/cq"

echo "Installed: ${INSTALL_DIR}/cq"

# Check PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  echo ""
  echo "Add ${INSTALL_DIR} to your PATH:"
  echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
  echo "  source ~/.bashrc"
fi

echo ""
echo "Usage: cq \"how does the auth middleware work?\""
echo "Run 'cq -h' for all options."
