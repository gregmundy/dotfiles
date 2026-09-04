#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

ZSHRC="${HOME}/.zshrc"

log "Installing direnv..."

brew_install_formula direnv

log "Ensuring Oh My Zsh direnv plugin is enabled..."

if [[ ! -f "${ZSHRC}" ]]; then
  log "ERROR: ${ZSHRC} not found. Install Oh My Zsh first."
  return 1
fi

# If already present anywhere in the plugins block, do nothing.
if grep -Eq '^[[:space:]]*plugins=\([^)]*\bdirenv\b' "${ZSHRC}"; then
  log "✓ direnv already present in plugins list"
  return 0
fi

# If no plugins block exists, add one (conservative default).
if ! grep -Eq '^[[:space:]]*plugins=\(' "${ZSHRC}"; then
  {
    echo ""
    echo "# Oh My Zsh plugins"
    echo "plugins=(git direnv)"
  } >> "${ZSHRC}"
  log "✓ Added plugins block with direnv"
  return 0
fi

# Otherwise, insert 'direnv' into the first plugins=(...) block.
# This handles typical OMZ single-line and multi-line plugins blocks.
perl -0777 -i -pe '
  my $done = 0;
  s{
    (^[ \t]*plugins=\()      # start of plugins block
    (.*?)                    # contents (including newlines)
    (\)[ \t]*$)              # closing paren
  }{
    my ($start,$body,$end)=($1,$2,$3);
    if ($done) { "$start$body$end" }
    else {
      # If direnv is already there, leave unchanged (extra safety)
      if ($body =~ /\bdirenv\b/) { $done=1; "$start$body$end" }
      else {
        # Insert direnv near the front: after git if present, else at start.
        my $new = $body;
        if ($new =~ /\bgit\b/) {
          $new =~ s/\bgit\b/git direnv/;
        } else {
          $new =~ s/^\s*/direnv\n/;
        }
        $done=1;
        "$start$new$end"
      }
    }
  }gmesx;
' "${ZSHRC}"

log "✓ Enabled direnv plugin in ${ZSHRC}"
log "NOTE: Restart your shell (or run: exec zsh)"
