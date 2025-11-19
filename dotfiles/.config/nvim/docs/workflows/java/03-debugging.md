# Java Debugging in Neovim

## Setup nvim-dap for Java

### 1. Install Required Plugins

Add to your plugin configuration:

```lua
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    require('dapui').setup()
    require('nvim-dap-virtual-text').setup()
  end
}
```

### 2. Configure Debug Adapter

Create `~/.config/nvim/after/ftplugin/java.lua` (extend existing):

```lua
local dap = require('dap')

-- DAP configuration for Java
dap.configurations.java = {
  {
    type = 'java',
    request = 'attach',
    name = "Debug (Attach) - Remote",
    hostName = "127.0.0.1",
    port = 5005,
  },
  {
    type = 'java',
    request = 'launch',
    name = "Debug (Launch) - Current File",
    mainClass = "${file}",
  },
}

-- Keybindings
local keymap = vim.keymap.set
keymap('n', '<leader>db', '<cmd>DapToggleBreakpoint<cr>', { desc = 'Toggle Breakpoint' })
keymap('n', '<leader>dc', '<cmd>DapContinue<cr>', { desc = 'Start/Continue Debugging' })
keymap('n', '<leader>di', '<cmd>DapStepInto<cr>', { desc = 'Step Into' })
keymap('n', '<leader>do', '<cmd>DapStepOut<cr>', { desc = 'Step Out' })
keymap('n', '<leader>ds', '<cmd>DapStepOver<cr>', { desc = 'Step Over' })
keymap('n', '<leader>dt', '<cmd>DapTerminate<cr>', { desc = 'Terminate Debug' })
keymap('n', '<leader>du', "<cmd>lua require('dapui').toggle()<cr>", { desc = 'Toggle Debug UI' })
keymap('n', '<leader>de', "<cmd>lua require('dapui').eval()<cr>", { desc = 'Evaluate Expression' })
```

### 3. Install Debug Extensions via Mason
```vim
:Mason
```
Install:
- `java-debug-adapter`
- `java-test`

## Basic Debugging Workflow

### Start Debugging Session

#### Method 1: Attach to Running Application
1. **Start your app with debug enabled:**
```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

2. **In Neovim:**
```vim
<leader>db  " Set breakpoint
<leader>dc  " Start debugging (select "Debug (Attach)")
```

#### Method 2: Launch from Neovim
```vim
<leader>db  " Set breakpoint on line
<leader>dc  " Start debugging (select "Debug (Launch)")
```

### Breakpoint Management

#### Set/Remove Breakpoints
```vim
<leader>db  " Toggle breakpoint at current line
```

Visual indicators:
- 🔴 Red dot in gutter = active breakpoint
- Breakpoint persists across sessions

#### Conditional Breakpoints
```vim
:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
```

Example conditions:
- `userId == 123`
- `items.size() > 10`
- `status.equals("ACTIVE")`

#### Log Points
```vim
:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log message: '))
```

### Stepping Through Code

```vim
<leader>dc  " Continue execution (F5 equivalent)
<leader>ds  " Step over (F10 equivalent)
<leader>di  " Step into (F11 equivalent)
<leader>do  " Step out (Shift+F11 equivalent)
<leader>dt  " Stop debugging
```

**When to use each:**
- **Step Over**: Execute current line, don't enter method calls
- **Step Into**: Enter method calls to debug them
- **Step Out**: Complete current method and return to caller

### Inspect Variables

#### Hover Information
Position cursor over variable and wait 250ms (configured in options.lua).

Shows:
- Current value
- Type information
- Object properties

#### Debug UI - Variables Panel
```vim
<leader>du  " Toggle Debug UI
```

Panels shown:
1. **Variables**: Local variables, `this`, static fields
2. **Watch**: Custom expressions
3. **Call Stack**: Current execution path
4. **Breakpoints**: All breakpoints in project

#### Evaluate Expressions
```vim
<leader>de  " Evaluate expression under cursor
```

Or in visual mode:
1. Select expression: `vip` or `v` + motion
2. `<leader>de`

Examples:
- `user.getName()`
- `items.stream().filter(i -> i.isActive()).count()`
- `new SimpleDateFormat("yyyy-MM-dd").format(date)`

#### Watch Expressions
In Debug UI Variables panel:
1. Press `a` to add watch
2. Enter expression: `user.email`
3. Watch updates on each step

### Call Stack Navigation

In Debug UI:
1. View call stack panel
2. Navigate with `j`/`k`
3. Press `<CR>` to jump to that frame
4. Inspect variables at that point

Useful for:
- Understanding execution flow
- Finding where exception originated
- Inspecting state at different levels

## Advanced Debugging

### Exception Breakpoints

Break when exception is thrown:
```lua
-- Add to your config
dap.set_exception_breakpoints({"all"})
```

Or specific exceptions:
```lua
dap.set_exception_breakpoints({"NullPointerException", "IllegalArgumentException"})
```

### Remote Debugging

#### Debug Production-like Environment

1. **Start remote app with debug port:**
```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar myapp.jar
```

2. **Configure remote debug:**
```lua
dap.configurations.java = {
  {
    type = 'java',
    request = 'attach',
    name = "Debug Production",
    hostName = "192.168.1.100",  -- Remote server IP
    port = 5005,
  }
}
```

3. **Connect:**
```vim
<leader>dc  " Select "Debug Production"
```

### Multi-threaded Debugging

When breakpoint hits:
1. Debug UI shows all threads
2. Select thread to inspect
3. View thread-specific call stack
4. Switch between threads seamlessly

#### Freeze Other Threads
```vim
:lua require('dap').set_breakpoint(nil, nil, nil, {freeze_other_threads = true})
```

### Debug Tests

#### JUnit Test Debugging

1. **Open test class:**
```java
@Test
public void testCalculation() {
    int result = calculator.add(2, 3);
    assertEquals(5, result);
}
```

2. **Set breakpoint in test:**
```vim
<leader>db  " On assert line or in method
```

3. **Debug test:**
```vim
:lua require('jdtls').test_nearest_method()
```

Or with DAP:
```vim
<leader>dc  " Select test configuration
```

#### Debug Spring Boot Tests
```java
@SpringBootTest
public class UserServiceTest {
    @Test
    public void testUserCreation() {
        // Set breakpoint here
    }
}
```

Same workflow - JDTLS handles Spring context!

### Debug Maven/Gradle Builds

#### Maven
```bash
mvn clean install -Dmaven.surefire.debug
# Waits for debugger on port 5005
```

Then attach from Neovim.

#### Gradle
```bash
gradle test --debug-jvm
```

## Debug UI Panels

### Variables Panel
```
▼ Local Variables
  ├─ user: User
  │  ├─ id: 123
  │  ├─ name: "John Doe"
  │  └─ email: "john@example.com"
  ├─ items: ArrayList (size=5)
  └─ status: "ACTIVE"
```

Actions:
- `<CR>` - Expand/collapse
- `e` - Edit value (for primitives)
- `c` - Copy value
- `a` - Add to watch

### Watch Panel
Add complex expressions:
```
user.orders.stream().filter(o -> o.total > 100).count()
status.equals("ACTIVE") ? "Yes" : "No"
System.currentTimeMillis() - startTime
```

Updates after each step!

### Call Stack
```
UserController.getUser() line: 45
DispatcherServlet.doDispatch() line: 1040
FrameworkServlet.service() line: 882
```

Navigate to any frame to inspect state.

### Breakpoints Panel
```
☑ UserService.java:23
☑ OrderController.java:67 (condition: total > 100)
☐ PaymentService.java:89 (disabled)
```

Actions:
- `<Space>` - Enable/disable
- `d` - Delete
- `e` - Edit condition

## Debugging Scenarios

### Scenario 1: NullPointerException

**Problem:** NPE somewhere in call chain

**Solution:**
1. Enable exception breakpoints:
```lua
dap.set_exception_breakpoints({"NullPointerException"})
```

2. Run code → breaks at throw point
3. Inspect call stack
4. Check all variables in Variables panel
5. Navigate up call stack to find null source

### Scenario 2: Logic Bug in Loop

```java
for (Order order : orders) {
    if (order.getTotal() > threshold) {
        // Bug: not updating correctly
        processOrder(order);
    }
}
```

**Debug approach:**
1. Set breakpoint on `if` statement
2. Use conditional breakpoint: `order.getId() == problematicId`
3. Step through with `<leader>ds`
4. Watch `threshold` value
5. Evaluate expressions: `<leader>de` on `order.getTotal()`

### Scenario 3: Race Condition

**Problem:** Multi-threaded bug

**Solution:**
1. Set breakpoint in suspicious method
2. When hit, check Debug UI threads panel
3. Freeze other threads on breakpoint
4. Step through one thread's execution
5. Release, then debug other thread

### Scenario 4: Performance Issue

**Problem:** Method takes too long

**Solution:**
1. Set breakpoint at method start
2. Add watch: `System.currentTimeMillis()`
3. Step through each line
4. Watch time increase per line
5. Identify slow operation

Use evaluate to test alternatives:
```vim
<leader>de
# Type: items.parallelStream().filter(...).count()
```

## Tips & Tricks

### 1. Quick Restart
```vim
<leader>dt  " Terminate
<leader>dc  " Start again
```

### 2. Save Debug Configuration
Create `.vscode/launch.json` (compatible!):
```json
{
  "configurations": [
    {
      "type": "java",
      "name": "Debug User Service",
      "request": "attach",
      "hostName": "localhost",
      "port": 5005,
      "projectName": "myapp"
    }
  ]
}
```

JDTLS automatically reads this!

### 3. Persistent Breakpoints
Breakpoints saved in session - survive Neovim restart.

View all:
```vim
:lua require('dap').list_breakpoints()
```

### 4. Log Without Stopping
Use log points instead of breakpoints:
```vim
:lua require('dap').set_breakpoint(nil, nil, 'User ID: {userId}, Status: {status}')
```

Messages appear in Debug Console without stopping execution!

### 5. Quick Variable Inspection
Visual select → `<leader>de` → instant evaluation

No need to add watches for one-time checks.

## Keyboard Shortcuts Summary

```
<leader>db  - Toggle breakpoint
<leader>dc  - Continue/Start
<leader>di  - Step into
<leader>do  - Step out  
<leader>ds  - Step over
<leader>dt  - Terminate
<leader>du  - Toggle Debug UI
<leader>de  - Evaluate expression
```

## Troubleshooting

### Debugger Won't Attach
```vim
:lua print(vim.inspect(require('dap').configurations.java))
```
Verify configuration is loaded.

Check app listening:
```bash
netstat -an | grep 5005
```

### Breakpoints Not Hitting
1. Verify code compiled: `:!mvn compile`
2. Check source matches running code
3. Restart debug session

### No Variables Shown
1. Compile with debug info:
```xml
<plugin>
  <artifactId>maven-compiler-plugin</artifactId>
  <configuration>
    <debug>true</debug>
  </configuration>
</plugin>
```

### Performance Issues
Disable virtual text for large objects:
```lua
require('nvim-dap-virtual-text').setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  all_frames = false,  -- Only show for current frame
})
```

## Next Steps
- [04-best-practices.md](./04-best-practices.md) - Best practices
- [05-spring-boot.md](./05-spring-boot.md) - Spring Boot debugging tips
