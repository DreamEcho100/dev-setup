# Java Development Setup in Neovim

## Overview
This guide covers setting up a complete Java development environment in Neovim that rivals VSCode's Java extension pack.

## Required LSP and Tools

### Language Server
```lua
-- Already configured in mason.lua (uncomment if needed):
-- "java_language_server"  -- Basic Java LSP
```

### Recommended: Eclipse JDT.LS Setup
For enterprise-level Java development, use `nvim-jdtls`:

```lua
-- Add to your plugins:
{
  'mfussenegger/nvim-jdtls',
  ft = 'java',
}
```

## Installation Steps

### 1. Install Java LSP via Mason
```vim
:Mason
```
Search and install:
- `jdtls` (Eclipse JDT Language Server)
- `java-debug-adapter` (for debugging)
- `java-test` (for testing)

### 2. Install External Tools
```bash
# Install Maven
sudo apt install maven  # Ubuntu/Debian
brew install maven      # macOS

# Install Gradle
sdk install gradle      # Using SDKMAN
brew install gradle     # macOS

# Install JDK (if not already)
sdk install java 17.0.8-tem  # Using SDKMAN
```

### 3. Configure JDTLS

Create `~/.config/nvim/after/ftplugin/java.lua`:

```lua
local jdtls = require('jdtls')

-- Determine OS
local home = os.getenv('HOME')
local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

-- LSP settings
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    
    '-jar', vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
    '-data', workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),
  
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = home .. "/.sdkman/candidates/java/17.0.8-tem",
          },
        }
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
    },
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  init_options = {
    bundles = {},
  },
}

-- Start or attach to LSP
jdtls.start_or_attach(config)
```

## Project Structure Support

### Maven Projects
```xml
<!-- pom.xml -->
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>my-app</artifactId>
  <version>1.0-SNAPSHOT</version>
</project>
```

**Keybindings:**
- `<leader>rc` - Run Maven compile
- `<leader>rt` - Run Maven test

### Gradle Projects
```groovy
// build.gradle
plugins {
    id 'java'
}

group = 'com.example'
version = '1.0-SNAPSHOT'
```

## Features Enabled

### ✅ Code Completion
- Intelligent context-aware completion
- Import suggestions
- Method parameter hints

### ✅ Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Show references
- `<C-o>` / `<C-i>` - Navigate back/forward

### ✅ Refactoring
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions (extract variable, method, etc.)
- Organize imports automatically

### ✅ Code Actions
- Extract to method/variable/constant
- Generate getters/setters
- Implement interface methods
- Generate constructors

### ✅ Diagnostics
- Real-time error checking
- Warning indicators
- Quick fixes via code actions

## Testing Support

### JUnit Integration
```lua
-- Add to your config:
{
  'mfussenegger/nvim-jdtls',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    -- Test commands
    vim.keymap.set('n', '<leader>tm', "<cmd>lua require('jdtls').test_nearest_method()<cr>", { desc = "Test Method" })
    vim.keymap.set('n', '<leader>tc', "<cmd>lua require('jdtls').test_class()<cr>", { desc = "Test Class" })
  end
}
```

### Running Tests
- `<leader>tm` - Run test at cursor
- `<leader>tc` - Run all tests in class
- See results in floating window

## Spring Boot Support

### Features
- Spring Boot application detection
- Bean navigation
- Request mapping navigation
- Application properties completion

### Running Spring Boot Apps
```vim
:!mvn spring-boot:run
```

Or create a terminal split:
```vim
<leader>v          " Split vertical
:terminal mvn spring-boot:run
```

## Debugging

See [03-debugging.md](./03-debugging.md) for complete debugging setup with nvim-dap.

## Common Tasks

### Create New Class
```vim
:!mkdir -p src/main/java/com/example
:e src/main/java/com/example/MyClass.java
```

Type `class` and use completion to generate class skeleton.

### Add Dependency (Maven)
Edit `pom.xml` and add:
```xml
<dependencies>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>
</dependencies>
```

Reload: `:JdtUpdateConfig`

### Format Code
- `<leader>f` - Format current file
- Respects Google Java Style (configured above)

## Troubleshooting

### LSP Not Starting
```vim
:LspInfo
:JdtRestart
```

### Workspace Issues
```bash
rm -rf ~/.local/share/nvim/jdtls-workspace/
```

### Update JDTLS
```vim
:Mason
# Update jdtls
```

## Additional Plugins

### Syntax Highlighting
Already configured via Treesitter:
```lua
ensure_installed = { 'java', 'groovy' }
```

### Code Snippets
LuaSnip includes Java snippets for:
- Class templates
- Main method
- Common patterns

## Performance Tips

1. **Increase memory for large projects:**
```lua
'-Xmx4g',  -- Increase from 1g to 4g
```

2. **Exclude unnecessary directories:**
```lua
-- Add to root_dir patterns
patterns = {'.git', 'mvnw', 'gradlew'}
```

3. **Disable features for huge codebases:**
```lua
referencesCodeLens = { enabled = false }
```

## Next Steps
- [02-workflow.md](./02-workflow.md) - Daily development workflow
- [03-debugging.md](./03-debugging.md) - Debugging configuration
- [04-best-practices.md](./04-best-practices.md) - Java best practices in Neovim
