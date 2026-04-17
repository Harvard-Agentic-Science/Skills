# Harvard Agentic Science — Shared Skills

Skills are reusable agent files that give Claude Code or Codex a specific role and set of instructions. Each skill has two files:

- **`skill-name.md`** — The agent file. This is what Claude reads. It contains frontmatter (name, description, model) and the agent's instructions. You drop this into `.claude/agents/` in your project.
- **`description.md`** — A human-readable description. This explains what the skill does, how to use it, and what options it has. This is what you read when deciding whether to download it.

Browse the `skills/` directory to see what is available.

## Using a skill

1. Find a skill in `skills/` that fits your task.
2. Read the `description.md` to see what it does.
3. Copy the agent `.md` file to `.claude/agents/` in your project.
4. Run it by name: "run the paper-reviewer agent."

Or just ask Claude to do it:

```
Go to https://github.com/Harvard-Agentic-Science/Skills and download the paper-reviewer skill. Save it to .claude/agents/paper-reviewer.md in my project.
```

## Contributing

Each skill needs both files: the agent file and the description. Fork the repo, add a folder under `skills/` with both, and open a pull request. Use the templates in `template/` as a starting point:

- `template/skill-template.md` — Template for the agent file
- `template/description-template.md` — Template for the description

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full walkthrough.

## More context

For background on agentic workflows and how skills fit into a research workflow, visit **https://ai.physics.harvard.edu**
