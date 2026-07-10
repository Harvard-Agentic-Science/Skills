# Harvard Agentic Science — Shared Skills

Skills are reusable agent files that give Claude Code or Codex a specific role and set of instructions. Each skill has two files:

- **`skill-name.md`** — The agent file. This is what Claude reads. It contains frontmatter (name, description, model) and the agent's instructions. You drop this into `.claude/agents/` in your project.
- **`description.md`** — A human-readable description. This explains what the skill does, how to use it, and what options it has. This is what you read when deciding whether to download it.

Browse the `skills/` directory to see what is available.

This repository can also include shared workflow utilities. Utilities are not
agent prompts; they are installable scripts or configuration packages that make
research computing workflows easier to reproduce.

## Using a skill

1. Find a skill in `skills/` that fits your task.
2. Read the `description.md` to see what it does.
3. Copy the agent `.md` file to `.claude/agents/` in your project.
4. Run it by name: "run the paper-reviewer agent."

Or just ask Claude to do it:

```
Go to https://github.com/Harvard-Agentic-Science/Skills and download the paper-reviewer skill. Save it to .claude/agents/paper-reviewer.md in my project.
```

## Using a utility

Utilities live under `utilities/`. Read the utility's README before running its
installer.

Available utilities:

- [`utilities/fasrc-vscode`](utilities/fasrc-vscode/) — installs the `fasrc`
  command for opening VS Code on FASRC SLURM compute nodes, with shared
  Remote-SSH, LaTeX Workshop, Claude Code, ClaudeTeX, and OpenAI Codex setup.

Example:

```sh
cd utilities/fasrc-vscode
./install.sh --user YOUR_FASRC_USERNAME
fasrc setup
```

## Contributing

For skills, add a folder under `skills/` with both the agent file and a
description. Use the templates in `template/` as a starting point:

- `template/skill-template.md` — Template for the agent file
- `template/description-template.md` — Template for the description

For utilities, add a self-contained folder under `utilities/` with a README and
any install scripts or configuration files it needs.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full walkthrough.

## More context

For background on agentic workflows and how skills fit into a research workflow, visit **https://ai.physics.harvard.edu**
