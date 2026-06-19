-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/18-cpp-development.md
-- VS Code cmake-tools equivalent for Neovim. Manages configure / build / run / test.
-- Integrates with overseer (already installed) for task execution.
-- Requires a CMakeLists.txt in the project root.
-- https://github.com/Civitasv/cmake-tools.nvim
return {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/overseer.nvim", -- already in config; used as build executor
    },
    opts = {
        cmake_command = "cmake",
        ctest_command = "ctest",
        cmake_use_preset = true,
        cmake_regenerate_on_save = true, -- auto-updates compile_commands.json on CMakeLists.txt save
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
        cmake_build_options = {},
        cmake_build_directory = "build",
        cmake_soft_link_compile_commands = true, -- symlink compile_commands.json to project root
        cmake_executor = {
            name = "overseer",
            opts = {},
        },
        cmake_runner = {
            name = "terminal",
            opts = {},
        },
        cmake_console_size = 10,
        cmake_console_position = "belowright",
        cmake_show_console = "always",
        cmake_virtual_text_support = true,
    },
    keys = {
        { "<leader>mg", "<cmd>CMakeGenerate<CR>",           desc = "CMake: configure" },
        { "<leader>mb", "<cmd>CMakeBuild<CR>",              desc = "CMake: build" },
        { "<leader>mr", "<cmd>CMakeRun<CR>",                desc = "CMake: run target" },
        { "<leader>mt", "<cmd>CMakeTest<CR>",               desc = "CMake: run tests" },
        { "<leader>mc", "<cmd>CMakeClean<CR>",              desc = "CMake: clean" },
        { "<leader>ms", "<cmd>CMakeSelectBuildTarget<CR>",  desc = "CMake: select build target" },
        { "<leader>mT", "<cmd>CMakeSelectBuildType<CR>",    desc = "CMake: select build type" },
        { "<leader>mo", "<cmd>CMakeOpen<CR>",               desc = "CMake: open panel" },
    },
}
