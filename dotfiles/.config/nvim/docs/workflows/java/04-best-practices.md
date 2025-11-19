# Java Best Practices in Neovim

## Code Organization

### Package Structure
Follow standard Maven/Gradle structure:
```
src/
├── main/
│   ├── java/
│   │   └── com/example/myapp/
│   │       ├── controller/
│   │       ├── service/
│   │       ├── repository/
│   │       ├── model/
│   │       ├── dto/
│   │       ├── config/
│   │       └── exception/
│   └── resources/
│       ├── application.properties
│       └── static/
└── test/
    └── java/
        └── com/example/myapp/
```

**Navigate quickly:**
```vim
<leader>sf  " Find files
# Type: Controller, Service, etc.
```

### File Naming Conventions
- Controllers: `*Controller.java`
- Services: `*Service.java` + `*ServiceImpl.java`
- Repositories: `*Repository.java`
- DTOs: `*DTO.java` or `*Request.java`, `*Response.java`
- Tests: `*Test.java`

## Code Style

### Auto-formatting on Save
Already configured in `formatting.lua`:
```lua
format_on_save = { lsp_fallback = true, timeout_ms = 3000 }
```

### Manual Format
```vim
<leader>f   " Format current file
```

### Google Java Style Guide
Configure in JDTLS (see 01-setup.md):
```lua
format = {
  settings = {
    url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
    profile = "GoogleStyle",
  },
}
```

Download Google Style:
```bash
wget https://raw.githubusercontent.com/google/styleguide/gh-pages/intellij-java-google-style.xml \
  -P ~/.config/nvim/lang-servers/
```

## Import Management

### Auto-organize on Save
Configured in `formatting.lua` for TypeScript, should add for Java:

```lua
-- Add to formatting.lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.java",
  callback = function()
    local params = {
      command = "java.edit.organizeImports",
      arguments = { vim.api.nvim_buf_get_name(0) }
    }
    vim.lsp.buf.execute_command(params)
  end
})
```

### Remove Unused Imports
Happens automatically on save!

### Add Missing Import
```vim
<leader>ca  " Code action → "Import class"
```

## Refactoring Best Practices

### Safe Renaming
```vim
<leader>rn  " Rename across entire project
```

**ALWAYS use LSP rename instead of search/replace!**
- Updates all references
- Preserves method overrides
- Updates comments/docs

### Extract Method
1. Select code in visual mode: `V` (lines)
2. `<leader>ca` → "Extract to method"
3. Enter descriptive name
4. Parameters auto-detected

**When to extract:**
- Code block > 10 lines
- Logic repeated > once
- Method doing multiple things

### Extract Variable
1. Select expression: `viw` or visual selection
2. `<leader>ca` → "Extract to local variable"
3. Enter name

**Example:**
```java
// Before
if (user.getOrders().stream().filter(o -> o.isActive()).count() > 5) {

// After extraction
long activeOrders = user.getOrders().stream().filter(o -> o.isActive()).count();
if (activeOrders > 5) {
```

### Extract Constant
For magic numbers:
```java
// Before
if (age > 18) {

// Extract constant
private static final int MINIMUM_AGE = 18;
if (age > MINIMUM_AGE) {
```

## Testing Best Practices

### Test Naming
```java
@Test
public void shouldReturnUserWhenValidIdProvided() {
    // Given
    Long userId = 1L;
    
    // When
    User user = userService.findById(userId);
    
    // Then
    assertNotNull(user);
}
```

### Run Tests Frequently
```vim
<leader>tm  " After writing test
<leader>tc  " After completing feature
```

### TDD Workflow
1. Write failing test: `<leader>tm` → RED
2. Implement minimal code
3. Run test: `<leader>tm` → GREEN
4. Refactor with `<leader>rn`, extract method
5. Run test: `<leader>tm` → GREEN

### Coverage-aware Development
```bash
mvn clean test jacoco:report
```

View report:
```bash
firefox target/site/jacoco/index.html
```

## Code Navigation

### Navigate by Type
```vim
:Telescope lsp_document_symbols
# Filter: @interface, @class, @method
```

### Find by Name
```vim
<leader>sf  " Find file by name
<leader>sg  " Find by content
<leader>sw  " Find word under cursor
```

### Jump to Related Files
Create custom commands:

```lua
-- Add to keymaps.lua
local function jump_to_test()
  local file = vim.fn.expand('%:t:r')  -- Get filename without extension
  local test_file = file .. 'Test.java'
  vim.cmd('find ' .. test_file)
end

vim.keymap.set('n', '<leader>jt', jump_to_test, { desc = 'Jump to test' })
```

## Documentation

### Write Meaningful Comments
```java
/**
 * Retrieves a user by ID with all associated orders.
 * 
 * @param userId the unique identifier of the user
 * @return User object with populated order collection
 * @throws UserNotFoundException if user doesn't exist
 */
public User getUserWithOrders(Long userId) {
```

### View Documentation
```vim
K  " Show Javadoc for symbol under cursor
```

### Generate Documentation
```vim
<leader>ca  " On method → "Generate Javadoc"
```

## Error Handling

### Use Code Actions for Try-Catch
```java
// Code that throws exception
FileInputStream fis = new FileInputStream("file.txt");
```

```vim
<leader>ca  " → "Surround with try-catch"
```

### Create Custom Exceptions
```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long userId) {
        super("User not found with ID: " + userId);
    }
}
```

Quick create from usage:
```java
throw new UserNotFoundException(userId);  // Red squiggle
```
```vim
<leader>ca  " → "Create class 'UserNotFoundException'"
```

## Dependency Management

### Maven Dependencies
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

After adding:
```vim
:!mvn clean install
:JdtUpdateConfig
```

### Check for Updates
```bash
mvn versions:display-dependency-updates
```

## Performance Best Practices

### Lazy Loading in Neovim Config
Only load Java plugins for `.java` files:
```lua
{
  'mfussenegger/nvim-jdtls',
  ft = 'java',  -- Only load for Java files
}
```

### Increase LSP Memory for Large Projects
In JDTLS config:
```lua
'-Xmx4g',  -- Increase heap size
```

### Exclude Generated Code
```lua
root_dir = require('jdtls.setup').find_root({
  '.git', 'mvnw', 'gradlew'
}),
-- Add to settings:
settings = {
  java = {
    sources = {
      exclude = {'**/target/**', '**/build/**', '**/.gradle/**'}
    }
  }
}
```

## Project Setup Checklist

### New Java Project
1. ✅ Create directory structure
2. ✅ Initialize Maven/Gradle
3. ✅ Create `.gitignore`:
```gitignore
target/
.idea/
*.iml
.classpath
.project
.settings/
```
4. ✅ Open in Neovim: `nvim .`
5. ✅ Verify LSP: `:LspInfo`
6. ✅ Create first class
7. ✅ Run tests: `<leader>tc`

### Existing Project
1. ✅ Clone repository
2. ✅ Build: `mvn clean install`
3. ✅ Open in Neovim: `nvim .`
4. ✅ Wait for JDTLS to index (~30 seconds)
5. ✅ Verify: `:JdtLs`
6. ✅ Navigate code: `gd`, `gi`, `gr`

## Code Review in Neovim

### Review Changes Before Commit
```vim
<leader>gg  " Open LazyGit
# Or
:Git diff
```

### Review Pull Request Locally
```bash
gh pr checkout 123  # GitHub CLI
```

Then in Neovim:
```vim
:Git diff main
```

### View Blame
```vim
<leader>hb  " Blame current line
<leader>hB  " Toggle blame for all lines
```

## Productivity Workflows

### Morning Routine
```vim
:checkhealth  " Verify setup
<leader>gg    " Pull latest
:!mvn clean install
<leader>sf    " Open file you're working on
:LspInfo      " Verify LSP running
```

### Before Commit
```vim
<leader>f     " Format all open files
:!mvn test    " Run all tests
<leader>gg    " Stage, commit, push
```

### Code Review
```vim
<leader>sd    " Check all diagnostics
<leader>sg    " Search for TODO comments
:!mvn verify  " Run full build
```

## Common Patterns

### Singleton Service
```java
@Service
public class UserService {
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```
Use constructor injection - LSP auto-generates constructor!

### Builder Pattern
```vim
<leader>ca  " On class → "Generate Builder"
```

### Lombok Integration
```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
```

JDTLS understands Lombok annotations!

## Keyboard Shortcuts Cheat Sheet

```
# Navigation
gd          - Go to definition
gD          - Go to declaration
gi          - Go to implementation
gr          - Find references
K           - Show documentation

# Editing
<leader>rn  - Rename symbol
<leader>ca  - Code actions
<leader>f   - Format file

# Testing
<leader>tm  - Test method
<leader>tc  - Test class

# Git
<leader>hs  - Stage hunk
<leader>hr  - Reset hunk
<leader>hb  - Blame line
<leader>gg  - LazyGit

# Search
<leader>sf  - Search files
<leader>sg  - Search by grep
<leader>sw  - Search word
<leader>sd  - Search diagnostics

# Debug
<leader>db  - Toggle breakpoint
<leader>dc  - Start/Continue
<leader>ds  - Step over
<leader>di  - Step into
<leader>do  - Step out
```

## Anti-patterns to Avoid

### ❌ Don't Use Mouse
Train yourself to use keyboard-only navigation.

### ❌ Don't Manual Search/Replace for Refactoring
Always use LSP rename: `<leader>rn`

### ❌ Don't Skip Tests
Run `<leader>tm` after every significant change.

### ❌ Don't Commit Without Formatting
Format-on-save handles this automatically.

### ❌ Don't Ignore Diagnostics
Fix warnings/errors immediately: `[d` `]d` to navigate.

## Resources

### Keybinding Reference
```vim
:Telescope keymaps  " Search all keybindings
```

### LSP Commands
```vim
:lua vim.lsp.buf.<Tab>  " See all LSP functions
```

### Mason Installed Tools
```vim
:Mason  " View all installed tools
```

## Next Steps
- [05-spring-boot.md](./05-spring-boot.md) - Spring Boot specifics
- [06-troubleshooting.md](./06-troubleshooting.md) - Common issues and solutions
