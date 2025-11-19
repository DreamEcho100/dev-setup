# C# Daily Development Workflow

## Real-World C# Development in Neovim

Complete guide for productive C# development matching Visual Studio capabilities.

## Project Creation Workflows

### 1. Console Application

```bash
dotnet new console -n MyConsoleApp
cd MyConsoleApp
nvim .
```

```csharp
// Program.cs
using System;
using System.Linq;

namespace MyConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
            
            // LINQ example
            var numbers = Enumerable.Range(1, 10);
            var evens = numbers.Where(n => n % 2 == 0);
            
            foreach (var num in evens)
            {
                Console.WriteLine(num);
            }
        }
    }
}
```

Run:
```vim
:!dotnet run
```

### 2. Web API Project

```bash
dotnet new webapi -n MyApi
cd MyApi
nvim .
```

```csharp
// Controllers/UsersController.cs
using Microsoft.AspNetCore.Mvc;

namespace MyApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private static List<User> _users = new();
        
        [HttpGet]
        public ActionResult<IEnumerable<User>> GetUsers()
        {
            return Ok(_users);
        }
        
        [HttpGet("{id}")]
        public ActionResult<User> GetUser(int id)
        {
            var user = _users.FirstOrDefault(u => u.Id == id);
            if (user == null)
                return NotFound();
            
            return Ok(user);
        }
        
        [HttpPost]
        public ActionResult<User> CreateUser(CreateUserDto dto)
        {
            var user = new User
            {
                Id = _users.Count + 1,
                Name = dto.Name,
                Email = dto.Email
            };
            
            _users.Add(user);
            return CreatedAtAction(nameof(GetUser), 
                new { id = user.Id }, user);
        }
    }
    
    public record User(int Id, string Name, string Email);
    public record CreateUserDto(string Name, string Email);
}
```

Run:
```vim
<leader>v
:terminal
dotnet run

# API available at http://localhost:5000
```

## Development Tasks

### 1. Creating Classes & Interfaces

```vim
# Navigate to Models folder
<leader>e
# Press 'a' for new file
User.cs
```

```csharp
// Models/User.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace MyApp.Models
{
    public class User
    {
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public UserRole Role { get; set; } = UserRole.User;
    }
    
    public enum UserRole
    {
        User,
        Admin,
        Moderator
    }
}
```

### 2. Interface & Implementation

```csharp
// Interfaces/IUserRepository.cs
using MyApp.Models;

namespace MyApp.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByIdAsync(int id);
        Task<IEnumerable<User>> GetAllAsync();
        Task<User> CreateAsync(User user);
        Task UpdateAsync(User user);
        Task DeleteAsync(int id);
    }
}
```

```vim
# Create implementation
<leader>e
Repositories/
a
UserRepository.cs
```

```csharp
// Repositories/UserRepository.cs
using MyApp.Interfaces;
using MyApp.Models;
using Microsoft.EntityFrameworkCore;

namespace MyApp.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly AppDbContext _context;
        
        public UserRepository(AppDbContext context)
        {
            _context = context;
        }
        
        // Implement interface
        // Use code action to generate stubs!
    }
}
```

```vim
# Cursor on UserRepository
<leader>ca
# "Implement interface"
```

### 3. Dependency Injection Setup

```csharp
// Program.cs (ASP.NET Core 6+)
using MyApp.Interfaces;
using MyApp.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();

// Add Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### 4. Working with Entity Framework Core

#### DbContext

```csharp
// Data/AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using MyApp.Models;

namespace MyApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }
        
        public DbSet<User> Users { get; set; }
        public DbSet<Post> Posts { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Configure entities
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            });
            
            modelBuilder.Entity<Post>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.Author)
                      .WithMany(u => u.Posts)
                      .HasForeignKey(e => e.AuthorId);
            });
        }
    }
}
```

#### Migrations

```vim
# Add migration
:!dotnet ef migrations add InitialCreate

# Update database
:!dotnet ef database update

# Generate SQL script
:!dotnet ef migrations script

# Remove last migration
:!dotnet ef migrations remove
```

### 5. LINQ Queries

```csharp
public class UserService
{
    private readonly AppDbContext _context;
    
    public async Task<List<User>> GetActiveUsersAsync()
    {
        // Method syntax
        return await _context.Users
            .Where(u => u.IsActive)
            .OrderBy(u => u.Name)
            .ToListAsync();
            
        // Query syntax
        var query = from u in _context.Users
                    where u.IsActive
                    orderby u.Name
                    select u;
                    
        return await query.ToListAsync();
    }
    
    public async Task<Dictionary<UserRole, int>> GetUserCountsByRoleAsync()
    {
        return await _context.Users
            .GroupBy(u => u.Role)
            .Select(g => new { Role = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Role, x => x.Count);
    }
    
    public async Task<User?> GetUserWithPostsAsync(int id)
    {
        return await _context.Users
            .Include(u => u.Posts)
            .ThenInclude(p => p.Comments)
            .FirstOrDefaultAsync(u => u.Id == id);
    }
}
```

### 6. Async/Await Patterns

```csharp
public class DataService
{
    private readonly HttpClient _httpClient;
    
    // Async method
    public async Task<User> FetchUserAsync(int id)
    {
        var response = await _httpClient.GetAsync($"/api/users/{id}");
        response.EnsureSuccessStatusCode();
        
        return await response.Content.ReadFromJsonAsync<User>();
    }
    
    // Parallel operations
    public async Task<(User user, List<Post> posts)> FetchUserDataAsync(int id)
    {
        var userTask = FetchUserAsync(id);
        var postsTask = FetchUserPostsAsync(id);
        
        await Task.WhenAll(userTask, postsTask);
        
        return (await userTask, await postsTask);
    }
    
    // Error handling
    public async Task<Result<User>> SafeFetchUserAsync(int id)
    {
        try
        {
            var user = await FetchUserAsync(id);
            return Result<User>.Success(user);
        }
        catch (Exception ex)
        {
            return Result<User>.Failure(ex.Message);
        }
    }
}

public record Result<T>
{
    public bool IsSuccess { get; init; }
    public T? Data { get; init; }
    public string? Error { get; init; }
    
    public static Result<T> Success(T data) => 
        new() { IsSuccess = true, Data = data };
        
    public static Result<T> Failure(string error) => 
        new() { IsSuccess = false, Error = error };
}
```

### 7. Testing with xUnit

```csharp
// Tests/UserServiceTests.cs
using Xunit;
using Moq;
using MyApp.Services;
using MyApp.Models;

namespace MyApp.Tests
{
    public class UserServiceTests
    {
        private readonly Mock<IUserRepository> _mockRepo;
        private readonly UserService _service;
        
        public UserServiceTests()
        {
            _mockRepo = new Mock<IUserRepository>();
            _service = new UserService(_mockRepo.Object);
        }
        
        [Fact]
        public async Task GetUserById_ValidId_ReturnsUser()
        {
            // Arrange
            var userId = 1;
            var expectedUser = new User 
            { 
                Id = userId, 
                Name = "John", 
                Email = "john@example.com" 
            };
            
            _mockRepo.Setup(r => r.GetByIdAsync(userId))
                     .ReturnsAsync(expectedUser);
            
            // Act
            var result = await _service.GetUserByIdAsync(userId);
            
            // Assert
            Assert.NotNull(result);
            Assert.Equal(expectedUser.Id, result.Id);
            Assert.Equal(expectedUser.Name, result.Name);
        }
        
        [Theory]
        [InlineData(0)]
        [InlineData(-1)]
        public async Task GetUserById_InvalidId_ReturnsNull(int id)
        {
            // Arrange
            _mockRepo.Setup(r => r.GetByIdAsync(id))
                     .ReturnsAsync((User?)null);
            
            // Act
            var result = await _service.GetUserByIdAsync(id);
            
            // Assert
            Assert.Null(result);
        }
    }
}
```

Run tests:
```vim
:!dotnet test
:!dotnet test --logger "console;verbosity=detailed"
:!dotnet test --filter "FullyQualifiedName~UserServiceTests"
```

## Navigation & Refactoring

### Find Usages

```vim
# Find all references to class/method
gR

# Find implementations
gi

# Go to definition
gd
```

### Rename Refactoring

```csharp
public class OldServiceName
{
    // ...
}
```

```vim
# Cursor on OldServiceName
<leader>rn
NewServiceName

# All references updated!
```

### Extract Method

```csharp
public void ProcessData()
{
    // Complex logic
    var data = GetData();
    var processed = data.Where(x => x.IsValid)
                        .Select(x => x.Value)
                        .ToList();
    SaveData(processed);
}
```

```vim
# Visual select the processing logic
V
# Select lines
<leader>ca
# "Extract method"
```

Result:
```csharp
public void ProcessData()
{
    var data = GetData();
    var processed = ProcessValidData(data);
    SaveData(processed);
}

private List<int> ProcessValidData(List<Item> data)
{
    return data.Where(x => x.IsValid)
               .Select(x => x.Value)
               .ToList();
}
```

## Building & Running

### Development

```vim
# Run with hot reload
<leader>v
:terminal
dotnet watch run

# Make changes, save
# Automatically recompiles!
```

### Release Build

```vim
:!dotnet build -c Release
:!dotnet publish -c Release -o ./publish
```

### Docker

```dockerfile
# Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

```vim
:!docker build -t myapi .
:!docker run -p 8080:80 myapi
```

## Common Patterns

### Middleware

```csharp
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<LoggingMiddleware> _logger;
    
    public LoggingMiddleware(
        RequestDelegate next, 
        ILogger<LoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        _logger.LogInformation($"Request: {context.Request.Method} {context.Request.Path}");
        
        await _next(context);
        
        _logger.LogInformation($"Response: {context.Response.StatusCode}");
    }
}

// Register in Program.cs
app.UseMiddleware<LoggingMiddleware>();
```

### Background Services

```csharp
public class EmailBackgroundService : BackgroundService
{
    private readonly ILogger<EmailBackgroundService> _logger;
    
    public EmailBackgroundService(ILogger<EmailBackgroundService> logger)
    {
        _logger = logger;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Processing emails...");
            
            // Process emails
            
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}

// Register
builder.Services.AddHostedService<EmailBackgroundService>();
```

## Keybindings Summary

```lua
-- C# keybindings (add to keymaps.lua)
vim.keymap.set('n', '<leader>cr', ':!dotnet run<CR>', { desc = '[C#] [R]un' })
vim.keymap.set('n', '<leader>cb', ':!dotnet build<CR>', { desc = '[C#] [B]uild' })
vim.keymap.set('n', '<leader>ct', ':!dotnet test<CR>', { desc = '[C#] [T]est' })
vim.keymap.set('n', '<leader>cw', ':!dotnet watch run<CR>', { desc = '[C#] [W]atch' })
```

---

**C# development is powerful and productive in Neovim! 🚀**
