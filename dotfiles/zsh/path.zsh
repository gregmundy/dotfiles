# Additional PATH entries

# uv-managed Python binaries
export PATH="${HOME}/.local/bin:${PATH}"

# Go binaries (go install puts binaries here)
export PATH="${HOME}/go/bin:${PATH}"

# Rust/Cargo binaries
export PATH="${HOME}/.cargo/bin:${PATH}"

# llamavm shims (per-version llama.cpp builds)
export PATH="${HOME}/.llamavm/shims:${PATH}"
