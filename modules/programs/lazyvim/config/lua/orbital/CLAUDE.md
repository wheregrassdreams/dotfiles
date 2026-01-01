# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Orbital is a unified backend system for Neovim that provides seamless file operations across multiple environments (local, remote via Neovim server). It intercepts standard Neovim commands (`:e`, `:w`, `:cd`, etc.) and routes them through pluggable provider backends.

The system consists of two main components:
- **orbital** (Neovim client plugin): Handles command interception and provider management
- **orbital_server** (Neovim server plugin): Runs on remote Neovim instances to handle file operations

## Architecture

The system follows a **true client/server architecture** with two separate projects:

### Orbital Client (`orbital/`)
```
orbital/
├── init.lua                    # Main entry point & coordination
├── setup.lua                   # Commands, autocommands, initialization
├── client/                     # Client-side functionality
│   ├── buffer/                 # Buffer management
│   │   └── init.lua           # Buffer operations and state
│   ├── command/               # Command system
│   │   ├── interceptor.lua    # Command interception
│   │   ├── handlers.lua       # Command processing
│   │   └── router.lua         # Command routing
│   ├── lsp/                   # LSP client integration
│   └── terminal/              # Terminal integration
├── providers/                  # Provider backends
│   ├── interfaces/            # Interface definitions
│   │   ├── filesystem.lua     # File/directory operations interface
│   │   ├── connection.lua     # Network connection interface
│   │   ├── command.lua        # Command execution interface
│   │   └── lsp.lua            # LSP interface (future)
│   ├── manager.lua            # Provider registry & switching
│   ├── local/                 # Local provider
│   │   └── init.lua          # Local provider implementation
│   └── remote/                # Remote provider (modular)
│       ├── init.lua           # Remote provider orchestrator
│       ├── connection.lua     # Connection management module
│       ├── rpc.lua            # RPC communication module
│       ├── filesystem.lua     # Filesystem operations module
│       ├── commands.lua       # Command execution module
│       └── cache.lua          # Cache management module
├── infra/                     # Infrastructure utilities
│   ├── cache.lua              # General caching infrastructure
│   ├── connection.lua         # Connection utilities
│   └── ssh_conf.lua           # SSH configuration parsing
├── utils/                     # Shared utilities
│   ├── utils.lua              # General utilities
│   ├── log.lua                # Logging utilities
│   └── debug.lua              # Debug helpers
├── extensions/                # External integrations
│   ├── neotree/               # Neo-tree file explorer integration
│   │   └── sources/filesystem/ # Custom filesystem source
│   ├── search/                # Search integration
│   └── git/                   # Git integration
└── usercmds/                  # User command definitions
```

### Orbital Server (`orbital_server/`)
```
orbital_server/
├── init.lua                    # Server plugin entry point
├── rpc/
│   ├── server.lua             # RPC server implementation
│   └── handlers.lua           # File operation handlers
├── filesystem/
│   ├── operations.lua         # File/directory operations using Neovim APIs
│   └── buffer_manager.lua     # Server-side buffer handling
└── config/
    └── config.lua             # Server configuration
```

## Updated Architecture Overview

The codebase has been significantly restructured for better organization and maintainability:

### Key Structural Changes

#### 1. Client-Side Reorganization (`client/`)
- **`client/buffer/`**: Centralized buffer management and state tracking
- **`client/command/`**: Complete command system (interceptor, handlers, router)
- **`client/lsp/`**: LSP client integration (future expansion)
- **`client/terminal/`**: Terminal integration capabilities

#### 2. Infrastructure Layer (`infra/`)
Shared infrastructure components that can be used across providers:
- **`infra/cache.lua`**: General-purpose caching infrastructure
- **`infra/connection.lua`**: Common connection utilities and patterns
- **`infra/ssh_conf.lua`**: SSH configuration parsing and management

#### 3. Modular Utilities (`utils/`)
Specialized utility modules for different concerns:
- **`utils/utils.lua`**: General-purpose utilities
- **`utils/log.lua`**: Dedicated logging system
- **`utils/debug.lua`**: Debug helpers and development tools

#### 4. Extensions System (`extensions/`)
Plugin integrations and external tool support:
- **`extensions/neotree/`**: Neo-tree file explorer integration with custom sources
- **`extensions/search/`**: Search functionality and indexing
- **`extensions/git/`**: Git integration and version control features

#### 5. User Commands (`usercmds/`)
Centralized user command definitions and management

### Benefits of New Structure

1. **Clear Separation of Concerns**: Each directory has a specific responsibility
2. **Scalable Extensions**: Easy to add new integrations in `extensions/`
3. **Reusable Infrastructure**: `infra/` components can be shared across providers
4. **Modular Utilities**: Specialized utils prevent bloated single utility files
5. **Client-Side Organization**: Clear distinction between client functionality and provider backends
6. **Future-Proof**: Structure supports planned features (LSP, terminal, search, git)

### Import Path Updates

With the new structure, import paths have been updated:
```lua
-- Old paths (deprecated)
local Utils = require("orbital.utils")
local BackendManager = require("orbital.backend_manager")

-- New paths
local Utils = require("orbital.utils.utils")
local Log = require("orbital.utils.log")
local BackendManager = require("orbital.providers.manager")
local CommandInterceptor = require("orbital.client.command.interceptor")
local CacheInfra = require("orbital.infra.cache")
```

## Key Concepts

### Interface-Based Provider Architecture

The system is organized around **grouped interfaces** that providers can implement based on their capabilities:

#### Core Interfaces

##### FileSystemInterface
```lua
-- File operations
read_file(path, callback)
write_file(path, content, callback)
list_files(path, callback)
get_cwd(callback)
change_dir(path, callback)
watch_file(path, callback)  -- future
```

##### ConnectionInterface  
```lua
-- Connection management
connect(uri, callback)
disconnect(callback)
is_connected()
get_connection_info()
ping(callback)  -- health check
reconnect(callback)  -- auto-recovery
```

##### CommandInterface
```lua
-- Command execution
execute_command(cmd, args, callback)
execute_async(cmd, args, callback)
get_command_history()
cancel_command(id)  -- future
```

##### LSPInterface (Future)
```lua
-- Language server integration
start_lsp_server(language, callback)
lsp_request(method, params, callback)
get_lsp_capabilities()
stop_lsp_server(language, callback)
```

##### TerminalInterface (Futrue)
```lua
-- ...
```


##### SearchInterface (Futrue)
```lua
-- ...
```

#### Provider Implementations

##### Local Provider
- **Implements**: `FileSystemInterface`, `CommandInterface`
- **Connection**: Direct (no network)
- **Capabilities**: Local filesystem, local command execution

##### Remote Provider  
- **Implements**: `FileSystemInterface`, `ConnectionInterface`, `CommandInterface`, `LSPInterface`
- **Connection**: RPC to `orbital_server`
- **Architecture**: Modular composition-based design
- **Capabilities**: Remote filesystem, remote commands, distributed LSP, intelligent caching, connection resilience

#### Modular Remote Provider Architecture

The remote provider uses a **composition-based architecture** with specialized modules for maintainability and extensibility:

##### Core Modules

**`connection.lua` - Connection Management**
- Health monitoring with automatic ping checks (configurable intervals)
- Auto-reconnect with exponential backoff and max attempt limits
- Event system for connection state changes (connected, disconnected, reconnecting)
- Comprehensive connection statistics and monitoring

**`rpc.lua` - RPC Communication**  
- Request tracking with unique IDs and timeout management
- Request batching for performance optimization (configurable batch size/delay)
- Automatic retry logic with configurable policies
- Performance monitoring (response times, success rates, throughput)

**`filesystem.lua` - Filesystem Operations**
- Intelligent caching with TTL and multiple eviction policies (LRU, LFU, FIFO)
- Batch file operations for efficiency (read/write multiple files)
- Cache invalidation strategies (pattern-based, directory-aware)
- File watching capabilities (future-ready)

**`commands.lua` - Command Execution**
- Async job tracking with real-time status monitoring
- Command and job history management with configurable limits
- Concurrent job limits and streaming output support
- Batch command execution with fail-fast and parallel options

**`cache.lua` - General Cache Management**
- Multiple eviction policies with memory usage monitoring
- TTL management with automatic cleanup timers
- Pattern-based cache invalidation and statistics
- Configurable size and memory limits

##### Orchestration Pattern

The main remote provider (`init.lua`) acts as an **orchestrator** that:
- **Delegates** all operations to specialized modules
- **Composes** functionality rather than implementing directly
- **Coordinates** module interactions and event handling
- **Provides** unified configuration and cleanup
- **Maintains** backward compatibility with existing interfaces

##### Configuration and Monitoring

```lua
-- Comprehensive configuration support
provider:configure({
  connection = { ping_interval = 60000, max_reconnect_attempts = 5 },
  rpc = { batch_delay = 100, max_retries = 3 },
  filesystem = { cache_ttl = 600000, enable_caching = true },
  command = { max_concurrent_jobs = 15, enable_job_streaming = true },
  cache = { max_memory_mb = 100, eviction_policy = "lru" }
})

-- Rich monitoring and statistics
local stats = provider:get_connection_info()
-- Returns: connection stats, cache stats, RPC stats, filesystem stats, command stats
```

### Command Interception
The command interceptor system intercepts Neovim commands via keymap overrides and routes them to the active provider. Managed buffers are tracked in `command_interceptor.handlers.intercepted_commands` table.

### URI-based Provider Switching
Providers are specified via simple URI schemes:
- `local://` - Local filesystem access
- `orbital://user@host:port/path` - Remote Neovim server via RPC

## Common Development Tasks

### Testing the System
```vim
:OrbitalBackend local://
:OrbitalBackend orbital://user@host:6666/path
:OrbitalStatus
:OrbitalPerformanceTest
```

## Orbital Server Project

### Overview
`orbital_server` is a separate Neovim plugin designed to run on remote Neovim instances in headless mode. It provides file operation services via Neovim's built-in RPC system.

### Key Benefits
- **Native Neovim APIs**: Uses `vim.fn.readfile()`, `vim.fn.writefile()`, etc.
- **LSP Integration**: Can run language servers and provide results to client
- **Plugin Ecosystem**: Access to formatters, linters, and other Neovim plugins
- **Zero Adaptation**: Same APIs as client, no translation layer needed

### Server Deployment
```bash
# Start orbital_server on remote machine
nvim --headless --listen 0.0.0.0:6666 +OrbitalServer

# Client connects from local machine
:OrbitalBackend orbital://user@remotehost:6666/path
```

### Server Capabilities
- File operations using Neovim's native functions
- Directory traversal and management
- Real-time file watching capabilities
- Plugin-based processing (formatting, linting)
- LSP integration for code intelligence

### Adding a New Provider

#### Monolithic Provider Pattern
For simple providers, implement interfaces directly in the main provider file:

1. **Define Capabilities**: Decide which interfaces your provider will implement
   - `FileSystemInterface`: For file/directory operations
   - `ConnectionInterface`: For network-based providers
   - `CommandInterface`: For command execution
   - `LSPInterface`: For language server features

2. **Implement Interfaces**: 
   ```lua
   local NewProvider = {}
   NewProvider.__index = NewProvider
   
   -- Implement required interfaces
   function NewProvider:read_file(path, callback)
     -- FileSystemInterface implementation
   end
   
   function NewProvider:connect(uri, callback) 
     -- ConnectionInterface implementation
   end
   ```

#### Modular Provider Pattern (Recommended for Complex Providers)
For complex providers with multiple capabilities, use the composition pattern:

1. **Create Modular Structure**:
   ```
   providers/new_provider/
   ├── init.lua              # Main orchestrator (composition pattern)
   ├── connection.lua        # Connection management module
   ├── rpc.lua              # Communication layer module  
   ├── filesystem.lua        # Filesystem operations module
   ├── command.lua          # Command execution module
   ├── cache.lua            # Cache management module
   └── config.lua           # Provider-specific configuration
   ```

2. **Implement Orchestrator Pattern**:
   ```lua
   local NewProvider = setmetatable({}, { __index = Provider })
   
   function NewProvider.new(uri)
     local self = setmetatable(Provider.new(uri), NewProvider)
     
     -- Initialize specialized modules
     self.connection_manager = ConnectionModule.new(config)
     self.rpc_client = RPCModule.new(self.connection_manager)
     self.filesystem_ops = FilesystemModule.new(self.rpc_client)
     -- ... other modules
     
     return self
   end
   
   -- Delegate to modules
   function NewProvider:read_file(path, callback, options)
     self.filesystem_ops:read_file(path, callback, options)
   end
   ```

3. **Benefits of Modular Pattern**:
   - **Separation of Concerns**: Each module handles one responsibility
   - **Maintainability**: Easier to modify and extend individual components
   - **Testability**: Modules can be tested independently
   - **Reusability**: Modules can be shared across providers
   - **Future-Proofing**: Easy to add features like caching, monitoring, etc.

4. **Register Provider**: Add to `BackendManager.providers` table
5. **Add URI Scheme**: Update `BackendManager.get_provider_completions()`

### Development Workflow

#### Interface Testing
```vim
# Test FileSystemInterface
:OrbitalBackend local://
:e test.txt
:w
:OrbitalList

# Test ConnectionInterface + FileSystemInterface
:OrbitalBackend orbital://user@host:6666/path
:OrbitalStatus  # Check connection health

# Test CommandInterface
:!ls -la  # Should route through provider if supported
```

#### Provider Capability Discovery
```lua
-- Check what interfaces a provider supports
local provider = orbital.current_provider
print("FileSystem:", provider.supports_filesystem)
print("Connection:", provider.supports_connection) 
print("Command:", provider.supports_command)
print("LSP:", provider.supports_lsp)
```

#### Interface-Specific Testing
- **FileSystemInterface**: `:e`, `:w`, `:OrbitalList`
- **ConnectionInterface**: `:OrbitalStatus`, connection reliability
- **CommandInterface**: Shell command execution
- **LSPInterface**: Language server operations (future)

#### Working with New Architecture

##### Client-Side Development
```lua
-- Buffer management
local BufferManager = require("orbital.client.buffer")
buffer_manager:track_buffer(bufnr, metadata)

-- Command system
local CommandInterceptor = require("orbital.client.command.interceptor")
interceptor:setup_interception()

-- Command routing
local CommandRouter = require("orbital.client.command.router")
router:route_command(cmd, args, callback)
```

##### Infrastructure Usage
```lua
-- Use shared caching infrastructure
local Cache = require("orbital.infra.cache")
local cache = Cache.new({ max_size = 100, ttl = 300000 })

-- SSH configuration parsing
local SSHConfig = require("orbital.infra.ssh_conf")
local ssh_hosts = SSHConfig.parse_config()

-- Connection utilities
local ConnUtils = require("orbital.infra.connection")
local conn_info = ConnUtils.parse_uri(uri)
```

##### Extension Development
```lua
-- Adding Neo-tree integration
local NeotreeExt = require("orbital.extensions.neotree")
NeotreeExt.register_filesystem_source(provider)

-- Search extension
local SearchExt = require("orbital.extensions.search")
SearchExt.index_provider_files(provider)
```

##### Utility Organization
```lua
-- General utilities
local Utils = require("orbital.utils.utils")
Utils.deep_merge(table1, table2)

-- Logging system
local Log = require("orbital.utils.log")
Log.info("Operation completed")
Log.error("Failed to connect", { uri = uri })

-- Debug helpers
local Debug = require("orbital.utils.debug")
Debug.profile_function(expensive_operation)
```

##### Provider Development Patterns
```lua
-- Use modular pattern for complex providers
local Provider = require("orbital.providers.provider")
local ConnectionInfra = require("orbital.infra.connection")
local CacheInfra = require("orbital.infra.cache")

local MyProvider = setmetatable({}, { __index = Provider })

function MyProvider.new(uri)
  local self = setmetatable(Provider.new(uri), MyProvider)
  
  -- Leverage infrastructure
  self.cache = CacheInfra.new(config)
  self.connection_utils = ConnectionInfra
  
  return self
end
```

## Code Patterns

### Async Callback Pattern
All provider methods use Node.js-style callbacks:
```lua
provider:read_file(path, function(success, content_or_error)
  if success then
    -- Handle content
  else
    -- Handle error message
  end
end)
```

### Error Handling
- Use `pcall()` for operations that might fail
- Always provide meaningful error messages to callbacks
- Log operations with appropriate levels (INFO, WARN, ERROR)

### Buffer Management
- Prefix provider-managed buffers with `[provider_type]`
- Store metadata in `command_interceptor.handlers.intercepted_commands[bufnr]`
- Clean up on buffer delete via autocmd in root `Setup.setup_autocommands()`

## Integration Points

### Neo-tree Integration
- Custom source for backend file browsing
- Placeholder file system for non-local backends
- File interception for seamless editing

### Command Integration  
- All standard Neovim file commands are intercepted
- Fallback to default behavior when no provider active
- Special handling for compound commands (`:wq`)

## Client/Server Architecture Benefits

### True Client/Server Separation
- **orbital**: Pure Neovim client plugin focused on command interception and UI
- **orbital_server**: Separate Neovim-based server handling file operations
- **Clean Protocol**: RPC communication with well-defined boundaries
- **Independent Development**: Client and server can evolve separately

### Neovim Server Advantages
- **Native Integration**: Server uses identical Neovim APIs as client
- **Zero Adaptation**: No translation layer between client and server operations
- **Plugin Ecosystem**: Full access to Neovim plugins on server side
- **LSP Integration**: Language servers run on server, results shared with client
- **Familiar Environment**: Server configuration and behavior identical to client

### Scalability & Performance
- **Distributed Operations**: Multiple clients can connect to one server
- **Resource Optimization**: Heavy operations run on server with better resources
- **Network Efficiency**: RPC protocol minimizes network overhead
- **Caching Opportunities**: Server can cache files and LSP results

### Development & Deployment
- **Simple Deployment**: Server is just a headless Neovim instance
- **Easy Testing**: Both client and server use same Neovim testing patterns
- **Configuration Reuse**: Server can use same init.lua and plugins as client
- **Version Compatibility**: Both sides use same Neovim version and APIs

## Future Extensibility

### Interface-Based Growth
The interface-based architecture enables clean extensibility:

#### Planned Interfaces
- **LSPInterface**: Distributed language server operations
- **DebugInterface**: Remote debugging capabilities  
- **GitInterface**: Version control operations
- **TerminalInterface**: Remote terminal access
- **SearchInterface**: Code search and indexing

#### Mixed-Capability Providers
Providers can implement any combination of interfaces:
```lua
-- Example: Specialized providers
CloudProvider = {
  implements = {"FileSystemInterface", "LSPInterface"}  -- Cloud storage + serverless LSP
}

DevContainerProvider = {
  implements = {"FileSystemInterface", "CommandInterface", "TerminalInterface"}  -- Full dev environment
}

DatabaseProvider = {
  implements = {"FileSystemInterface", "SearchInterface"}  -- Treat DB as filesystem with search
}
```

#### Interface Evolution
- **Backward Compatibility**: Old providers continue working
- **Gradual Migration**: Providers can add interfaces incrementally  
- **Feature Detection**: Client can discover provider capabilities dynamically
- **Graceful Degradation**: Features unavailable on some providers fail gracefully

#### Ecosystem Integration
- **Plugin Compatibility**: Interfaces map cleanly to Neovim plugin APIs
- **Standard Protocols**: LSP, DAP, and other protocols fit naturally
- **Third-Party Providers**: External tools can implement orbital interfaces

## Testing & Deployment

### Manual Testing
```vim
# Test local provider
:OrbitalBackend local://
:e test.txt
:w

# Test remote provider (requires orbital_server running)
:OrbitalBackend orbital://user@host:6666/path
:OrbitalStatus
:OrbitalPerformanceTest
```

### Server Deployment
```bash
# On remote machine - start orbital_server
nvim --headless --listen 0.0.0.0:6666 +"lua require('orbital_server').start()"

# On client machine - connect to server
nvim +"OrbitalBackend orbital://user@remotehost:6666/workspace"
```

### Testing Scenarios
- **Interface Testing**: Test each interface independently
- **Provider Combinations**: Test different interface combinations
- **Capability Discovery**: Test dynamic feature detection
- **Graceful Degradation**: Test behavior when interfaces unavailable
- **Performance**: Benchmark each interface type
- **Backward Compatibility**: Ensure old providers still work
