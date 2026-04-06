# Harvard Agentic Science — Shared Skills

Skills are reusable agent files (`.md`) that give Claude Code or Codex a specific role and set of instructions. Drop a skill into your project's `.claude/agents/` folder and the agent picks up the persona, workflow, and output format defined in the file.

Browse the `skills/` directory to see what is available.

## Using a skill

1. Find a skill in `skills/` that fits your task.
2. Copy the `.md` file to `.claude/agents/` in your project.
3. Run it by name: "run the paper-reviewer agent."

Or just ask Claude to do it for you:

```
Go to https://github.com/Harvard-Agentic-Science/Skills and download the paper-reviewer skill. Save it to .claude/agents/paper-reviewer.md in my project.
```

## Contributing

Anyone can contribute a skill. Fork the repo, add a folder under `skills/` with your `.md` file, and open a pull request. Use the template in `template/skill-template.md` as a starting point.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full walkthrough.

## More context

For background on agentic workflows and how skills fit into a research workflow, visit **https://sciencewithagents.com**
