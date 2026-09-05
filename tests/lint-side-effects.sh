#!/usr/bin/env bash
# Flags side-effecting commands in install/*.sh that bypass the dry-run
# helpers (run, deploy_file, append_line, write_file, defaults_write,
# brew_install_*, ensure_dir, ui_spin*). Every hit must be either routed
# through a helper or explicitly marked with  # dry-run: safe  (read-only).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

PATTERN='^[[:space:]]*(cp|mv|rm|mkdir|chmod|chown|ln|touch|tee|sed -i|perl -[a-z0-9]*i|defaults write|defaults delete|brew (install|tap|trust|update|upgrade|uninstall)|git (clone|lfs install|config --(global|file))|xcodes install|mas (install|get)|nvm (install|alias|use|uninstall)|npm install|corepack|asdf (install|plugin (add|update)|set|reshim)|uv python install|rustup|xcode-select --(switch|install)|xcodebuild|open -a|osascript|killall|softwareupdate|code --install|curl[^|]*\|[[:space:]]*(ba)?sh|sudo )'

status=0
while IFS= read -r line; do
  file="${line%%:*}"; rest="${line#*:}"; lineno="${rest%%:*}"; text="${rest#*:}"
  # Allowed: routed through run / conditional run, or explicitly marked.
  [[ "$text" =~ ^[[:space:]]*(run|elif[[:space:]]+run|if[[:space:]]+run|\!?[[:space:]]*run)[[:space:]] ]] && continue
  [[ "$text" == *"# dry-run: safe"* ]] && continue
  # Allowed: inside a function whose body is only ever invoked via `run`.
  echo "  $file:$lineno: $text"
  status=1
done < <(grep -nE "$PATTERN" install/*.sh uninstall.sh || true)

# Redirections that write files: `>>` and `> "` outside helpers/functions.
while IFS= read -r line; do
  text="${line#*:*:}"
  [[ "$text" == *"# dry-run: safe"* ]] && continue
  [[ "$text" =~ ^[[:space:]]*run[[:space:]] ]] && continue
  echo "  $line"
  status=1
done < <(grep -nE '(>>|[^&2]>[[:space:]]*"\$)' install/*.sh uninstall.sh | grep -vE '2>&1|>/dev/null|2>/dev/null' || true)

if [[ $status -eq 0 ]]; then
  echo "lint: no unguarded side effects in install/*.sh or uninstall.sh"
else
  echo "lint: unguarded side effects found (route through run/deploy_file/... or mark '# dry-run: safe')"
fi
exit $status
