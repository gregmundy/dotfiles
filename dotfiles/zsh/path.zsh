# Additional PATH entries

# Keep PATH free of duplicates. Nested shells (tmux, `exec zsh`, VS Code
# terminals) re-source this file; -U makes the array unique so repeated
# prepends collapse instead of piling up.
typeset -U path PATH

# uv-managed Python binaries
export PATH="${HOME}/.local/bin:${PATH}"

# Go binaries (go install puts binaries here)
export PATH="${HOME}/go/bin:${PATH}"

# Rust/Cargo binaries
export PATH="${HOME}/.cargo/bin:${PATH}"

# llamavm shims (per-version llama.cpp builds)
export PATH="${HOME}/.llamavm/shims:${PATH}"

# libpq (keg-only Postgres client tools: psql, pg_dump)
for _libpq_prefix in /opt/homebrew/opt/libpq /usr/local/opt/libpq; do
  if [[ -d "$_libpq_prefix/bin" ]]; then
    export PATH="$_libpq_prefix/bin:${PATH}"
    break
  fi
done
unset _libpq_prefix
