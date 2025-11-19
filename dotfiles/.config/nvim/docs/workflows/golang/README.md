# Go Development Workflow in Neovim

Complete guide for Go development with LSP, debugging, testing, and Go-specific tooling.

## What's Covered

✅ **gopls LSP** - Official Go language server
✅ **Debugging** - Delve debugger integration
✅ **Testing** - go test with neotest
✅ **Formatting** - gofmt, goimports
✅ **Linting** - golangci-lint, staticcheck
✅ **Code Generation** - go generate, struct tags
✅ **Module Management** - go mod workflows
✅ **Benchmarking** - Performance testing
✅ **Documentation** - godoc integration

## Prerequisites

```bash
# Go itself
sudo apt install golang-go
# Or download from golang.org

# Language Server (automatically via Mason)
:Mason
# gopls should already be there

# Tools
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/go-delve/delve/cmd/dlv@latest

# Add to PATH
export PATH=$PATH:$(go env GOPATH)/bin
```

## Your Current Config Status

✅ **Already Configured**:
- gopls LSP (via Mason)
- gofmt, goimports (via conform.nvim)
- Treesitter (Go syntax)
- File navigation

⚠️ **Needs Setup**:
- Debugging (Delve with DAP)
- Testing (neotest-go)
- Advanced linting (golangci-lint)

## Quick Start

1. **Install gopls**: `:Mason` → `gopls` (should be installed)
2. **Create Go file**: `nvim main.go`
3. **Type**: `fmt.` → see package methods!
4. **Format**: `<leader>f` (runs gofmt + goimports)
5. **Run**: `:!go run %`

## LSP Features (gopls)

### Code Intelligence

```go
package main

import "fmt"

// Struct with autocomplete
type User struct {
    Name string
    Age  int
}

func main() {
    user := User{
        Name: "John",
        Age:  30,
    }
    
    // Autocomplete
    user.  // Shows: Name, Age with types!
    
    // Hover documentation
    // Hover over fmt
    fmt.  // Shows all fmt functions
    
    // Go to definition
    // Cursor on User, gd → jump to type definition
}
```

### Import Management

```go
// Auto-import
// Just type the symbol
json.Marshal()
// LSP suggests: "Import encoding/json"
// → Auto-adds import!

// Remove unused imports
<leader>f  // goimports removes unused automatically
```

### Code Actions

```go
// Fill struct
user := User{
    // Incomplete struct
}

// <leader>ca → "Fill struct"
// Adds all fields!

// Generate interface stub
func (u *User) Reader() io.Reader {
}

// <leader>ca → "Implement io.Reader"
```

## Formatting

### gofmt (Built-in)

**Already in your config!**

```lua
-- conform.nvim
go = { "gofmt", "goimports" },
```

**What it does**:
- Standard formatting
- Organize imports
- Remove unused imports
- Add missing imports

### Format on Save

```vim
# Already works!
<leader>f  // Formats Go code
```

### Manual Formatting

```bash
# In terminal
gofmt -w main.go
goimports -w main.go
```

## Linting

### golangci-lint (Recommended)

```lua
-- Add to nvim-lint config
require("lint").linters_by_ft = {
    go = { "golangci_lint" },
}
```

**Configuration**: `.golangci.yml`

```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports
  
linters-settings:
  gofmt:
    simplify: true
  
run:
  timeout: 5m
```

### Built-in Checks

```go
// gopls shows errors automatically

// Unused variable
x := 10  // ❌ x declared but not used

// Type mismatch
var s string = 42  // ❌ cannot use 42 as string

// Missing return
func add(a, b int) int {
    // ❌ missing return statement
}
```

## Debugging with Delve

### DAP Configuration

```lua
-- Add to DAP setup
local dap = require("dap")

dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
    }
}

dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}",
    },
    {
        type = "delve",
        name = "Debug test",
        request = "launch",
        mode = "test",
        program = "${file}",
    },
    {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
    },
}
```

### Debug Workflow

```go
// main.go
package main

import "fmt"

func main() {
    numbers := []int{1, 2, 3, 4, 5}
    sum := 0
    
    for _, n := range numbers {
        sum += n  // Set breakpoint here
    }
    
    fmt.Println("Sum:", sum)
}
```

```vim
# 1. Set breakpoint
<leader>db       " On sum += n line

# 2. Start debugging
<F5>

# 3. Step through
<F10>            " Step over
<F11>            " Step into

# 4. Inspect
K                " Hover over 'sum' to see value

# 5. Continue
<F5>
```

## Testing Integration

### Basic Go Testing

```go
// user_test.go
package main

import "testing"

func TestCreateUser(t *testing.T) {
    user := CreateUser("John", 30)
    
    if user.Name != "John" {
        t.Errorf("Expected John, got %s", user.Name)
    }
    
    if user.Age != 30 {
        t.Errorf("Expected 30, got %d", user.Age)
    }
}

func BenchmarkCreateUser(b *testing.B) {
    for i := 0; i < b.N; i++ {
        CreateUser("John", 30)
    }
}
```

### neotest-go Setup

```lua
require("neotest").setup({
  adapters = {
    require("neotest-go")({
      experimental = {
        test_table = true,
      },
      args = { "-count=1", "-timeout=60s" }
    }),
  },
})
```

### Test Workflow

```vim
# Run test under cursor
<leader>tt

# Run all tests in file
<leader>tf

# Run all tests in package
<leader>ta

# Debug test
<leader>td       " Runs test with debugger

# Show test output
<leader>to

# Run benchmarks
:!go test -bench=. -benchmem
```

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive", 2, 3, 5},
        {"negative", -1, -1, -2},
        {"zero", 0, 0, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("got %d, want %d", got, tt.want)
            }
        })
    }
}
```

```vim
# With neotest-go
# Can run individual subtests!
<leader>tt       " Run specific test case
```

## Go Modules

### Initialize Module

```bash
go mod init github.com/username/project
```

### Add Dependencies

```go
// Just import in code
import "github.com/gorilla/mux"

// Then tidy
go mod tidy
```

```vim
# Or from Neovim
:!go get github.com/gorilla/mux
:!go mod tidy
```

### Update Dependencies

```vim
:!go get -u ./...
:!go mod tidy
```

## Typical Workflow

```vim
# 1. Create new project
:!go mod init myproject

# 2. Create main.go
<leader>e
a
main.go

# 3. Write code with LSP
package main

import "fmt"

func main() {
    // Autocomplete works!
    fmt.Println("Hello")
}

# 4. Add dependencies
// Import package
import "github.com/gin-gonic/gin"

# 5. Tidy modules
:!go mod tidy

# 6. Format
<leader>f

# 7. Run
:!go run .

# 8. Write tests
<leader>sf
main_test.go

# 9. Run tests
<leader>tt

# 10. Build
:!go build -o myapp

# 11. Commit
<leader>lg
```

## Code Generation

### Struct Tags

```go
type User struct {
    Name string
    Age  int
}
```

```vim
# Add JSON tags
<leader>ca       " Code actions
# Select "Add JSON tags"
```

Result:
```go
type User struct {
    Name string `json:"name"`
    Age  int    `json:"age"`
}
```

### Generate Interface Implementation

```go
type Writer interface {
    Write([]byte) (int, error)
}

type MyWriter struct{}
```

```vim
# Cursor on MyWriter
<leader>ca
# "Implement Writer"
```

Result:
```go
func (m *MyWriter) Write(b []byte) (int, error) {
    // TODO: Implement
    panic("not implemented")
}
```

### go generate

```go
//go:generate stringer -type=Status

type Status int

const (
    Pending Status = iota
    Success
    Error
)
```

```vim
:!go generate ./...
```

## Common Go Patterns

### Error Handling

```go
func readFile(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("reading file: %w", err)
    }
    return data, nil
}

// Usage
data, err := readFile("file.txt")
if err != nil {
    log.Fatal(err)
}
```

### Goroutines

```go
func main() {
    ch := make(chan string)
    
    go func() {
        ch <- "Hello from goroutine"
    }()
    
    msg := <-ch
    fmt.Println(msg)
}
```

### Defer

```go
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()  // Closes when function returns
    
    // Process file...
    return nil
}
```

## Project Structure

```
my-go-project/
├── go.mod
├── go.sum
├── main.go
├── cmd/
│   └── myapp/
│       └── main.go
├── internal/
│   ├── server/
│   │   └── server.go
│   └── database/
│       └── db.go
├── pkg/
│   └── utils/
│       └── utils.go
└── tests/
    └── integration_test.go
```

## Performance & Profiling

### CPU Profile

```go
import "runtime/pprof"

f, _ := os.Create("cpu.prof")
pprof.StartCPUProfile(f)
defer pprof.StopCPUProfile()

// Code to profile
```

```bash
go tool pprof cpu.prof
```

### Benchmarking

```go
func BenchmarkMyFunction(b *testing.B) {
    for i := 0; i < b.N; i++ {
        MyFunction()
    }
}
```

```vim
:!go test -bench=. -benchmem
```

## Common Problems & Solutions

### Problem: Import not working

**Solution**: Run go mod tidy

```vim
:!go mod tidy
# Restart LSP
:LspRestart
```

### Problem: gopls using too much memory

**Solution**: Limit memory

```lua
-- In gopls config
settings = {
    gopls = {
        memoryMode = "DegradeClosed",
    }
}
```

### Problem: Slow autocomplete

**Solution**: Enable placeholders

```lua
settings = {
    gopls = {
        usePlaceholders = true,
        completionBudget = "100ms",
    }
}
```

## Keybindings Summary

```vim
# LSP
gd               " Go to definition
gD               " Go to type definition
gR               " Find references
gi               " Go to implementation
K                " Documentation
<leader>ca       " Code actions
<leader>rn       " Rename

# Testing
<leader>tt       " Run test
<leader>tf       " Run file tests
<leader>td       " Debug test

# Running
:!go run .       " Run package
:!go run %       " Run file
:!go build       " Build binary
:!go test ./...  " Test all

# Debugging
<leader>db       " Breakpoint
<F5>             " Start/continue
<F10>            " Step over

# Formatting
<leader>f        " Format (gofmt + goimports)
```

---

**Go development in Neovim is productive and fast! 🚀**
