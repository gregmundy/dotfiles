#!/usr/bin/env bash
# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

brew_ensure
brew_install_formula jq
brew_install_formula aria2
brew_install_formula autoconf
brew_install_formula openssl
brew_install_formula wxwidgets
brew_install_formula libxslt
brew_install_formula fop

