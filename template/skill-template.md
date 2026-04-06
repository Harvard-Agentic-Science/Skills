---
name: your-skill-name
description: "Describe when Claude should use this agent. Include trigger phrases the user might say, like 'review my paper' or 'clean this dataset'. This is how Claude knows when to invoke the agent automatically."
model: opus
memory: project
---

<!-- 
  Everything below the frontmatter is the agent's system prompt.
  Write it as direct instructions to Claude in second person ("you").
  Claude reads this file every time the agent is invoked.
-->

You are [describe the role]. Your job is to [what the agent does].

## Workflow

Describe what the agent should do step by step. Be specific. Claude follows these instructions literally.

1. First, do X.
2. Then do Y.
3. Finally, produce Z.

## What you need from the user

Before starting, make sure the user has provided:
- Input 1 (e.g., a file, a description, a set of constraints)
- Input 2

If anything is missing, ask for it before proceeding.

## Output format

Describe the structure of what the agent should produce. Be explicit about sections, ordering, and level of detail.

## Rules

- Any constraints on behavior (e.g., "do not edit the original file, only comment on it")
- Things to avoid
- Things to always do

## Agent Memory

As you work with this user, update your memory with:
- Their preferences for this agent
- Recurring patterns you notice
- Context that should persist across sessions
