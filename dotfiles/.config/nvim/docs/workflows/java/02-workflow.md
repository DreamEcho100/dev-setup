# Java Daily Development Workflow

## Morning Setup

### 1. Open Project
```bash
cd ~/projects/my-java-app
nvim .
```

### 2. Check LSP Status
```vim
:LspInfo
:JdtLs
```

### 3. Pull Latest Changes
```vim
<leader>gg  " Open LazyGit
```

## Development Cycle

### Creating New Features

#### 1. Create New Class
```vim
:Neotree reveal
```
Navigate to package, press `a` to create file:
```
src/main/java/com/example/service/UserService.java
```

#### 2. Generate Class Skeleton
Type and trigger completion:
```java
public class UserService {
  // Cursor here
}
```

Use code actions:
- `<leader>ca` → "Generate Constructor"
- `<leader>ca` → "Generate Getters/Setters"

#### 3. Implement Interface
```java
public class UserService implements CrudService<User> {
  // Cursor on class name
}
```
- `<leader>ca` → "Implement Interface Methods"

### Navigation Workflow

#### Jump to Definition
```vim
gd          " Go to definition (local)
gD          " Go to declaration
gi          " Go to implementation
gR          " Show all references
```

#### Find Usages
```vim
<leader>sf  " Search files
<leader>sg  " Search by grep (find text in project)
<leader>sw  " Search word under cursor
```

#### Navigate Class Structure
```vim
:Telescope lsp_document_symbols
```
Filter by:
- `class`
- `method`
- `field`

### Code Editing

#### Smart Completion
In insert mode:
```java
List<String> names = new Array|  // Trigger completion
```
- `<C-j>` / `<C-k>` - Navigate suggestions
- `<CR>` - Accept completion
- `<C-Space>` - Trigger manually

#### Snippets
Type and expand:
```
sout<Tab>     → System.out.println();
psvm<Tab>     → public static void main(String[] args) {}
fori<Tab>     → for(int i = 0; i < ; i++) {}
```

#### Extract Refactoring
1. Select code in visual mode: `V` (lines) or `v` (characters)
2. `<leader>ca` → "Extract to method"
3. Enter method name
4. Code is extracted with proper parameters

#### Rename Symbol
```vim
<leader>rn  " Rename symbol under cursor
```
- Renames across entire project
- Updates all references
- Safe refactoring

### Import Management

#### Auto-Import
```java
List<String> names;  // List is unresolved
```
- `<leader>ca` → "Import class java.util.List"

#### Organize Imports
Automatically organized on save (configured in formatting.lua).

Manual trigger:
```vim
:lua require('jdtls').organize_imports()
```

### Code Quality

#### Show Diagnostics
```vim
[d          " Previous diagnostic
]d          " Next diagnostic
<leader>d   " Show diagnostic in float
<leader>D   " Show all buffer diagnostics
<leader>sd  " Search all diagnostics (Telescope)
```

#### Quick Fixes
Position cursor on error/warning:
```vim
<leader>ca  " Show code actions
```
Common quick fixes:
- Add missing import
- Create missing method
- Fix unused variable
- Suppress warning

### Testing Workflow

#### Run Single Test
```java
@Test
public void testUserCreation() {
  // Cursor here
}
```
```vim
<leader>tm  " Test method at cursor
```

#### Run All Tests in Class
```vim
<leader>tc  " Test class
```

#### View Test Results
Results appear in:
1. Floating window (immediate)
2. Quickfix list `:copen`
3. Status line indicator

#### TDD Cycle
1. Write failing test → `<leader>tm`
2. Implement feature
3. Run test → `<leader>tm`
4. Refactor
5. Run all tests → `<leader>tc`

### Building & Running

#### Maven Commands
```vim
:!mvn clean install
:!mvn test
:!mvn spring-boot:run
```

#### Terminal Integration
```vim
<leader>v   " Split vertical
<Ctrl-w>w   " Switch to split
:terminal
mvn clean install
```
Exit terminal: `<C-\><C-n>` then navigate normally

#### Quick Run Config
Create `run.sh` in project root:
```bash
#!/bin/bash
mvn clean install && java -jar target/myapp.jar
```

Run from Neovim:
```vim
:!./run.sh
```

### Git Integration

#### View Changes
```vim
]h          " Next git hunk
[h          " Previous git hunk
<leader>hp  " Preview hunk
<leader>hb  " Blame line
<leader>hd  " Diff this
```

#### Stage Changes
```vim
<leader>hs  " Stage hunk
<leader>hS  " Stage entire buffer
<leader>hu  " Undo stage
```

#### Commit Workflow
```vim
<leader>gg  " Open LazyGit
```
In LazyGit:
- `space` - Stage file
- `c` - Commit
- `P` - Push

### Documentation

#### View Javadoc
```vim
K           " Show hover documentation
```
Hover over:
- Class names
- Method names
- Field names

Shows:
- Javadoc comments
- Method signatures
- Type information

#### Go to Source
With cursor on library class/method:
```vim
gd          " Jump to source (if available)
```

### Debugging

#### Set Breakpoint
```vim
<leader>db  " Toggle breakpoint
```

#### Start Debug Session
```vim
<leader>dc  " Continue/Start debugging
```

See [03-debugging.md](./03-debugging.md) for complete debugging workflow.

## Real-World Scenarios

### Scenario 1: Fix Bug in Service Layer

1. **Find the bug location:**
```vim
<leader>sg  " Live grep
# Search for error message or method name
```

2. **Set breakpoint:**
```vim
<leader>db
```

3. **Run debug:**
```vim
<leader>dc
```

4. **Step through code:**
```vim
<leader>ds  " Step over
<leader>di  " Step into
<leader>do  " Step out
```

5. **Fix and verify:**
```vim
<leader>f   " Format
<leader>tm  " Run test
```

### Scenario 2: Implement New REST Endpoint

1. **Open controller:**
```vim
<leader>sf
# Type: UserController
```

2. **Create method:**
```java
@GetMapping("/users/{id}")
public ResponseEntity<User> getUser(@PathVariable Long id) {
  // Implement
}
```

3. **Extract service logic:**
- Select business logic in visual mode
- `<leader>ca` → "Extract to method"
- Move to service layer

4. **Test endpoint:**
```vim
:terminal
curl http://localhost:8080/users/1
```

### Scenario 3: Refactor Package Structure

1. **Use file explorer:**
```vim
:Neotree
```

2. **Move files:**
- Navigate to file
- `m` - Mark for move
- Navigate to destination
- `p` - Paste

3. **Update imports:**
LSP automatically updates import statements!

4. **Verify no errors:**
```vim
<leader>sd  " Search diagnostics
```

## Productivity Tips

### 1. Use Marks for Common Files
```vim
mC          " Mark Controller
mS          " Mark Service
mR          " Mark Repository

'C          " Jump to Controller mark
'S          " Jump to Service mark
```

### 2. Buffer Management
```vim
<leader><leader>  " Quick switch buffers
<Tab>             " Next buffer
<S-Tab>           " Previous buffer
<leader>bx        " Close buffer
```

### 3. Multiple Files Side-by-Side
```vim
:Neotree
# Open file
<leader>v         " Vertical split
# In file tree, select another file
<CR>              " Opens in new split
```

### 4. Quick File Creation
```vim
:e src/main/java/com/example/model/%:t:r.java
```
Creates file with same name in model package.

### 5. Search and Replace Across Project
```vim
<leader>sg        " Grep for text
# Find the text
<C-q>             " Send to quickfix
:cdo s/oldText/newText/g | update
```

## Performance Optimization

### Large Projects
```vim
" Increase LSP timeout
vim.lsp.buf_request_timeout = 5000

" Disable code lens for performance
referencesCodeLens = { enabled = false }
```

### Memory Management
```vim
:JdtRestart       " Restart language server if slow
```

## Troubleshooting

### Completion Not Working
```vim
:LspInfo          " Check if LSP attached
<C-Space>         " Manually trigger completion
```

### Import Not Found
```vim
:JdtUpdateConfig  " Refresh project config
```

### Tests Not Running
```vim
:lua vim.notify(vim.inspect(require('jdtls.dap').test_nearest_method()))
```

## Next Steps
- [03-debugging.md](./03-debugging.md) - Advanced debugging
- [04-best-practices.md](./04-best-practices.md) - Best practices
- [05-spring-boot.md](./05-spring-boot.md) - Spring Boot specific workflow
