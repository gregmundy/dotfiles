# Go (Golang)

## Quick Start

```bash
# Create a new project
mkdir myproject && cd myproject
go mod init myproject

# Create main.go
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# Run it
go run main.go

# Build binary
go build -o myproject
```

## Common Commands

| Command | Description |
|---------|-------------|
| `go run main.go` | Run without compiling |
| `go build` | Compile to binary |
| `go mod init <name>` | Initialize new module |
| `go get <pkg>` | Add dependency to project |
| `go mod tidy` | Clean up dependencies |
| `go install <pkg>@latest` | Install CLI tool globally |
| `go fmt ./...` | Format all code |
| `go test ./...` | Run all tests |
| `go vet ./...` | Check for common mistakes |

## Project Structure

```
myproject/
├── go.mod          # Module definition & dependencies
├── go.sum          # Dependency checksums
├── main.go         # Entry point
├── internal/       # Private packages
│   └── config/
│       └── config.go
├── pkg/            # Public packages (optional)
│   └── utils/
│       └── utils.go
└── cmd/            # Multiple entry points (optional)
    └── server/
        └── main.go
```

## Installing Tools

Go tools are installed to `~/go/bin` (added to PATH):

```bash
# Popular tools
go install golang.org/x/tools/gopls@latest          # LSP server
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest  # Linter
go install github.com/air-verse/air@latest          # Live reload
```

## Useful Patterns

### Error Handling
```go
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

### HTTP Server
```go
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello!")
})
http.ListenAndServe(":8080", nil)
```

## Links

- [Go Documentation](https://go.dev/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
