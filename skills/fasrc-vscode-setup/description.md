# FASRC VS Code Setup

Installs or updates the shared `fasrc` utility for opening VS Code on FASRC
SLURM compute nodes.

## What it does

This skill guides an agent through installing `utilities/fasrc-vscode`, verifying
that only the `fasrc` command is exposed, and running the local VS Code setup.
The utility configures Remote-SSH aliases, a persistent VS Code server path,
default remote extensions, and LaTeX Workshop defaults for PDF rendering and
SyncTeX navigation.

## How to use it

Copy `fasrc-vscode-setup.md` to `.claude/agents/` in your project, then say:

```text
run the fasrc-vscode-setup agent and install the FASRC VS Code workflow
```

The agent will ask for your FASRC username if it cannot infer it.

## Options

- Provide a username explicitly: "install it for FASRC username abc123".
- Ask for local-only setup: "configure VS Code settings but do not test FASRC
  login."
