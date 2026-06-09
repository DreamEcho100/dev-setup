# Tutorial Series

This directory is the hands-on learning path for the current Neovim setup.

Read in order if you are transitioning from VS Code:

1. `01-vim-neovim-foundations.md`
2. `02-vscode-transition-bindings.md`
3. `03-project-navigation-search.md`
4. `04-code-intelligence-languages.md`
5. `05-debug-test-task-git.md`
6. `06-remote-tmux-docs-ai.md`
7. `07-plugin-catalog.md`
8. `08-maintenance-health.md`

The intent is practical:

- Keep the VS Code muscle memory that helps you stay productive.
- Teach Vim and Neovim primitives that replace whole categories of plugins.
- Explain every current plugin by purpose, trigger, common commands, and when not to use it.
- Document install-time choices, especially heavyweight runtimes.

## Learning Map

```text
VS Code habits
     |
     v
familiar keys + pickers + explorer + tasks
     |
     v
motions + text objects + operators + quickfix
     |
     v
LSP + DAP + tests + Git + tmux + remote
     |
     v
Neovim power-user workflows
```

## Current Policy

- Snacks owns user-facing picker workflows.
- Telescope is compatibility-only and available through `:Telescope` when an extension needs it.
- Multicursor remains enabled because it is useful for VS Code users.
- Vim-native alternatives to multicursor are documented and should be learned.
- CodeCompanion is the documented default AI chat/edit integration, but AI plugins are disabled by default.
- Copilot and Avante remain disabled optional hooks.
- LaTeX, Mermaid, and Docker are default-installed.
- Java and .NET are opt-in runtime stacks.
