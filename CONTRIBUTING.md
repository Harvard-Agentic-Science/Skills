# Contributing

Thanks for contributing! This repository contains both agent skills and shared
workflow utilities.

## Contributing a skill

1. **Fork** this repository.
2. **Create a folder** under `skills/` with your skill name. Use lowercase letters and hyphens (e.g., `skills/my-new-skill/`).
3. **Add a `.md` file** inside the folder with your skill definition (e.g., `skills/my-new-skill/my-new-skill.md`). You can copy `template/skill-template.md` as a starting point.
4. At the top of your file, include:
   - A **name** (the `# Heading`).
   - A **1-2 paragraph description** explaining what the skill does, when to use it, and what kind of output it produces.
5. **Open a pull request** against `main`.
6. A maintainer will review your submission and merge it.

## Guidelines

- Keep instructions concrete and actionable.
- Prefer short, structured output formats over open-ended prose.
- One skill per folder.
- If your skill builds on an existing one, mention it in the description.

## Contributing a utility

Utilities live under `utilities/` and should be self-contained.

1. Create a folder under `utilities/` with a lowercase hyphenated name.
2. Include a `README.md` explaining what the utility changes, how to install it,
   how to uninstall or clean up, and how to verify the install.
3. Include an installer script only when installation is actually needed.
4. Avoid hardcoded personal paths, usernames, tokens, or machine-specific
   configuration.
5. Make installers idempotent: re-running them should update the utility safely.
6. Document every user-owned file the utility edits.

## Questions?

Open an issue or visit **https://harvardai.pages.dev** for more context on agentic workflows.
