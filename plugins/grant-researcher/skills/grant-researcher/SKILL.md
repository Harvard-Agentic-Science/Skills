---
name: grant-researcher
description: Research a named grant or funding opportunity and build or refresh an auditable proposal workspace inside the current Git repository. Use when the user asks to investigate a grant, FOA, NOFO, RFA, call, or sponsor; identify deadlines, eligibility, requirements, prior awardees, competitors, collaborators, or internal submission limits; assess project fit; scaffold a proposal; or create a dossier under the grants directory. Do not submit applications, contact people, or make external commitments without explicit authorization.
---

# Grant Researcher

Operate end to end by default. If the user provides only a grant name, begin discovery without asking for fields that can be found from authoritative sources. Ask only when multiple live opportunities remain materially ambiguous or when a scientific choice would change the proposal direction.

## Start in the repository

1. Resolve the Git root and read applicable `AGENTS.md` files.
2. Inspect `git status`, the root README, project documentation, and relevant research artifacts. Preserve unrelated changes.
3. Infer the group capabilities, existing project, likely investigators, and constraints from repository evidence. Mark inferences as such.
4. Resolve `<skill-dir>` to the directory containing this `SKILL.md`.
5. Initialize the workspace:

```bash
python3 <skill-dir>/scripts/init_grant_workspace.py "<grant name>" --repo-root "<git root>"
```

Pass `--sponsor`, `--opportunity-id`, or `--official-url` when already known. The script is idempotent and does not overwrite existing files.

## Choose the operating mode

- **New grant:** initialize, research, and scaffold the dossier.
- **Refresh:** preserve existing analysis, verify every unstable fact, add amendments and recent awards, and update the research log.
- **Audit:** check completeness, source quality, contradictions, deadlines, and submission readiness without inventing missing facts.

If the user does not specify a mode, use **New grant** when no workspace exists and **Refresh** when it does.

## Research the opportunity

Read [references/research-playbook.md](references/research-playbook.md) before doing substantive research. Use the current date and verify time-sensitive claims online.

Research in this order:

1. Exact opportunity identity and current status.
2. Official solicitation, amendments, FAQs, webinars, templates, and submission portals.
3. Funding, award structure, deadlines, eligibility, institutional caps, teaming, cost share, compliance, data/IP terms, and review criteria.
4. Prior and adjacent awards, funded abstracts, awardees, institutions, investigators, amounts, and recurring themes.
5. Competitors, potential collaborators, relevant facilities, industry partners, and internal downselect risks.
6. Fit between the opportunity and the repository's actual capabilities.
7. Proposal framing, measurable outcomes, work packages, milestones, team gaps, and go/no-go risks.

Prefer primary sources. For each material claim, record the URL, publisher, publication or update date, access date, source type, and the claim it supports in `sources/source-index.md`. Download official artifacts into `sources/raw/` when permitted and create searchable extracts in `sources/extracted/` when useful.

Never treat a search snippet, generated summary, or secondary article as proof when an official source is available. Distinguish facts, source-backed interpretation, and strategic inference.

## Build the competitive landscape

Do not stop at the current solicitation. Search official award databases, prior program rounds, related funding programs, lab announcements, public abstracts, press releases, investigator pages, and credible project repositories.

For each relevant award or competitor, capture:

- awardee, lead institution, collaborators, principal investigator when public
- title, abstract or objective, funding amount and period when public
- program, focus area, and selection year
- technical approach, differentiator, overlap, and evidence
- whether the entity is primarily a competitor, collaborator, precedent, or all three

Do not label an organization a competitor without explaining the overlap. Do not infer confidential submissions or internal university decisions from silence.

## Convert research into proposal strategy

Use [references/workspace-contract.md](references/workspace-contract.md) as the completion contract. Populate the generated files rather than creating an unstructured pile of notes.

The proposal concept must connect:

- sponsor need -> research problem
- research problem -> proposed workflow or technical contribution
- contribution -> measurable advantage over the baseline
- deliverables -> milestones and evaluation
- team roles -> eligibility and execution needs
- evidence -> source-backed claims

Where the solicitation uses a named metric such as AI advantage, broader impacts, commercialization, readiness level, or mission impact, mirror that language accurately and define a measurable test.

## Handle institutional and team constraints

Explicitly check:

- per-institution and per-PI submission caps
- internal competition or limited-submission deadlines
- required institution categories and lead restrictions
- letters, registrations, cost share, foreign participation, facilities, and data access
- whether proposed partners solve an eligibility requirement or merely add scientific depth

Do not assume two universities satisfy a multi-category teaming rule. Separate institutional eligibility from scientific desirability.

## Validate and finish

Run:

```bash
python3 <skill-dir>/scripts/validate_grant_workspace.py "<workspace path>"
```

Before finishing:

1. Resolve or prominently flag conflicting dates and amendment history.
2. Make the next irreversible deadline visible in the workspace README.
3. List open questions with an owner or evidence needed.
4. Record the research pass in `logs/research-log.md`.
5. Report what was created, the best-fit proposal lane, major blockers, and the next three actions.

## Boundaries

- Do not submit forms, send email, contact program officers, create external accounts, or commit the institution without explicit user authorization.
- Do not write credentials, private correspondence, unpublished proposal material, or sensitive personal data into public repositories.
- Do not overwrite human-authored grant files. Extend them carefully and preserve provenance.
- Do not claim a deadline is open merely because a landing page remains online; verify the specific application pathway and applicant class.
- Do not fabricate prior awards, investigator names, budgets, focus areas, or citations.
