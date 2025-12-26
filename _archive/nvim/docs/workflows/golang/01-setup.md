# Go Development Complete Setup

## Everything You Need for Go in Neovim

Your config is already 80% ready for Go! Let's complete the setup.

## Prerequisites

### Install Go

```bash
# Ubuntu/Debian
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# macOS
brew install go

# Add to PATH (~/.bashrc or ~/.zshrc)
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin

# Verify
go version
```

## LSP Setup (Already Configured!)

Your Mason should have `gopls`. Verify:

```vim
:Mason
# Look for 'gopls' - should be installed
```

### Install Go Tools

```bash
# Language server (if not via Mason)
go install golang.org/x/tools/gopls@latest

# Formatter
go install golang.org/x/tools/cmd/goimports@latest

# Linter
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Debugger
go install github.com/go-delve/delve/cmd/dlv@latest

# Testing tools
go install gotest.tools/gotestsum@latest
```

## Formatter Configuration

Update `formatting.lua` to include:

```lua
formatters_by_ft = {
    go = { "gofmt", "goimports" },
}
```

Then install:
```vim
:Mason
# Install: goimports
```

## Project Setup

### Initialize Go Module

```bash
mkdir my-go-project && cd my-go-project
go mod init github.com/username/my-go-project

# Create structure
mkdir -p cmd/app internal/{handlers,models} pkg/utils
touch cmd/app/main.go

nvim .
```

### Directory Structure

```
my-go-project/
├── go.mod
├── go.sum
├── cmd/
│   └── app/
│       └── main.go          # Application entry point
├── internal/                # Private application code
│   ├── handlers/
│   │   └── user.go
│   └── models/
│       └── user.go
├── pkg/                     # Public libraries
│   └── utils/
│       └── helper.go
├── tests/
│   └── integration_test.go
└── README.md
```

## Verify LSP Features

### Create Test File

```go
// cmd/app/main.go
package main

import (
    "fmt"
    "net/http"
    "encoding/json"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func main() {
    http.HandleFunc("/users", handleUsers)
    fmt.Println("Server starting on :8080")
    http.ListenAndServe(":8080", nil)
}

func handleUsers(w http.ResponseWriter, r *http.Request) {
    users := []User{
        {ID: 1, Name: "John", Email: "john@example.com"},
        {ID: 2, Name: "Jane", Email: "jane@example.com"},
    }
    
    // Test autocomplete
    json.NewEncoder(w).  // Shows: Encode method!
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}
```

### Test LSP

```vim
nvim cmd/app/main.go

# 1. Check LSP
:LspInfo
# Should show: gopls

# 2. Autocomplete
# Type: fmt.
# Shows: Println, Printf, etc.

# 3. Hover
K  # On 'http.HandleFunc'
# Shows documentation!

# 4. Go to definition
gd  # On 'User'

# 5. Find references
gR  # On 'handleUsers'

# 6. Format
<leader>f
# Runs gofmt + goimports!
```

## Go Module Management

### Add Dependencies

```bash
# Add dependency
go get github.com/gorilla/mux

# Or in go.mod
require github.com/gorilla/mux v1.8.1

# Then
go mod tidy
```

### From Neovim

```vim
:!go get github.com/gin-gonic/gin
:!go mod tidy
:LspRestart
```

### Common Packages

```bash
# Web frameworks
go get github.com/gin-gonic/gin
go get github.com/gorilla/mux
go get github.com/labstack/echo/v4

# Database
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/jmoiron/sqlx

# Testing
go get github.com/stretchr/testify
go get github.com/onsi/ginkgo/v2
go get github.com/onsi/gomega

# Utilities
go get github.com/spf13/viper  # Configuration
go get github.com/sirupsen/logrus  # Logging
go get gopkg.in/yaml.v3  # YAML
```

## Configuration Files

### .golangci.yml

```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - errcheck      # Check error handling
    - gosimple      # Simplify code
    - govet         # Vet examination
    - ineffassign   # Detect ineffectual assignments
    - staticcheck   # Static analysis
    - unused        # Unused code
    - gofmt         # Formatting
    - goimports     # Import management
    - misspell      # Spelling
    - revive        # Fast linter

linters-settings:
  gofmt:
    simplify: true
  
  goimports:
    local-prefixes: github.com/username/my-go-project
  
  revive:
    rules:
      - name: var-naming
      - name: package-comments
      - name: error-return
      - name: error-strings

issues:
  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
```

### Makefile

```makefile
.PHONY: build run test lint clean

# Build the application
build:
	go build -o bin/app cmd/app/main.go

# Run the application
run:
	go run cmd/app/main.go

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Run linter
lint:
	golangci-lint run

# Format code
fmt:
	gofmt -s -w .
	goimports -w .

# Tidy dependencies
tidy:
	go mod tidy

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f coverage.out
```

Usage in Neovim:
```vim
:!make build
:!make run
:!make test
```

## Testing Setup

### Basic Test

```go
// internal/utils/math_test.go
package utils

import (
    "testing"
)

func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -1, -2},
        {"zero", 0, 0, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", 
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}
```

### Run Tests

```vim
# Run all tests
:!go test ./...

# Run specific package
:!go test ./internal/utils

# With coverage
:!go test -cover ./...

# Verbose
:!go test -v ./...

# Benchmarks
:!go test -bench=. ./...
```

## Debugging Setup

### Install Delve

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

### DAP Configuration

Add to your Neovim plugins:

```lua
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'leoluz/nvim-dap-go',
  },
}
```

Configure:

```lua
-- In dap config file
require('dap-go').setup()

-- Keybindings
vim.keymap.set('n', '<leader>dt', ':lua require("dap-go").debug_test()<CR>', 
    { desc = 'Debug Go test' })
```

## Environment Setup

### .env File

```bash
# .env
DATABASE_URL=postgres://user:pass@localhost/dbname
API_KEY=your-api-key
PORT=8080
```

### Load in Go

```go
// Using godotenv
import "github.com/joho/godotenv"

func main() {
    godotenv.Load()
    port := os.Getenv("PORT")
}
```

## Build & Run

### Development

```vim
# Run directly
:!go run cmd/app/main.go

# With hot reload (using air)
# Install: go install github.com/cosmtrek/air@latest
:!air

# In terminal split
<leader>v
:terminal
go run cmd/app/main.go
```

### Production Build

```bash
# Build
go build -o bin/app cmd/app/main.go

# Build for Linux
GOOS=linux GOARCH=amd64 go build -o bin/app-linux cmd/app/main.go

# Build for Windows
GOOS=windows GOARCH=amd64 go build -o bin/app.exe cmd/app/main.go

# With optimizations
go build -ldflags="-s -w" -o bin/app cmd/app/main.go
```

From Neovim:
```vim
:!go build -o bin/app cmd/app/main.go
:!./bin/app
```

## Code Generation

### Generate Interface Implementation

```go
type Writer interface {
    Write([]byte) (int, error)
    Close() error
}

type FileWriter struct{}
```

```vim
# Cursor on FileWriter
<leader>ca
# "Implement Writer"
```

Result:
```go
func (f *FileWriter) Write(b []byte) (int, error) {
    panic("not implemented")
}

func (f *FileWriter) Close() error {
    panic("not implemented")
}
```

### Fill Struct

```go
user := User{
    // Cursor here
}
```

```vim
<leader>ca
# "Fill struct"
```

Result:
```go
user := User{
    ID:    0,
    Name:  "",
    Email: "",
}
```

## Keybindings for Go

Add to `keymaps.lua`:

```lua
-- Go specific commands
vim.keymap.set('n', '<leader>gr', ':!go run %<CR>', 
    { desc = '[G]o [R]un current file' })

vim.keymap.set('n', '<leader>gb', ':!go build<CR>', 
    { desc = '[G]o [B]uild' })

vim.keymap.set('n', '<leader>gt', ':!go test ./...<CR>', 
    { desc = '[G]o [T]est all' })

vim.keymap.set('n', '<leader>gf', ':!go fmt ./...<CR>', 
    { desc = '[G]o [F]ormat' })

vim.keymap.set('n', '<leader>gm', ':!go mod tidy<CR>', 
    { desc = '[G]o [M]od tidy' })
```

## Troubleshooting

### gopls Not Working

```vim
:LspInfo
:LspLog
:LspRestart

# Reinstall gopls
:!go install golang.org/x/tools/gopls@latest
```

### Import Not Resolving

```vim
:!go mod tidy
:LspRestart
```

### Module Cache Issues

```bash
go clean -modcache
go mod download
```

## Next Steps

- [README.md](./README.md) - Go workflows & patterns
- Check official gopls docs
- Explore Go standard library

---

**Go development ready! 🚀**
