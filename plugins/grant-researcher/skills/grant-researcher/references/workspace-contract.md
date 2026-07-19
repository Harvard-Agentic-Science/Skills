# Grant Workspace Contract

The initializer creates a workspace under `grants/<slug>/`. Populate the existing files and keep the workspace navigable from its README.

## Required files

### `grant.json`

Maintain canonical identity and state:

- `grant_name`, `slug`, `sponsor`, `opportunity_id`, `official_url`
- `created_at`, `last_researched_at`
- `status`, `stage`, and `next_deadline`

Use ISO dates where known. Use `null` rather than guesses.

### `README.md`

Keep this as the dashboard. It must show:

- exact opportunity and current applicant pathway
- status and last research date
- next deadline with timezone
- recommended proposal lane
- largest eligibility or execution blocker
- links to all research and proposal files
- next three actions

### `research/opportunity.md`

Cover official identity, amendment history, funding, phases, deadlines, eligibility, submission limits, teaming, cost share, application components, review criteria, compliance, post-award obligations, and unresolved contradictions.

### `research/award-landscape.md`

Use tables for prior and adjacent awards. Capture awardee, institution, investigator, title, amount, period, program/focus area, technical overlap, classification, and source. Include negative search results only when the search scope is documented.

### `research/fit-and-strategy.md`

Connect sponsor needs to repository evidence. Rank plausible focus areas or proposal lanes, explain tradeoffs, identify differentiation, define measurable advantage, and state reasons not to pursue weak lanes.

### `research/partners-and-team.md`

Separate required and optional partners. Track role, institution category, capability, evidence, eligibility function, funding/cost-share implications, relationship status, and next action. Never represent a prospective partner as committed without evidence.

### `proposal/concept.md`

Develop a concise concept around problem, sponsor need, hypothesis, approach, end-to-end workflow, deliverables, validation, milestones, risks, and impact. Keep assumptions visibly labeled.

### `proposal/requirements-checklist.md`

Translate every mandatory requirement into a checkable item with owner, status, deadline, and source. Include internal downselect requirements separately from sponsor requirements.

### `sources/source-index.md`

Index every material source with publisher, title, URL, dates, source class, local capture, and supported claims. Prefer one row per source and stable direct links.

### `logs/research-log.md`

Append each pass with date, agent or researcher, questions investigated, files changed, key findings, unresolved issues, and next step. Do not rewrite prior entries.

## Completion standard

A research pass is complete only when:

- the current opportunity and applicant pathway are verified
- all deadlines and institutional caps are visible
- primary sources support material factual claims
- prior award and competitor searches are documented
- proposal fit is tied to repository evidence
- facts and inferences are distinguishable
- open questions and blockers are actionable
- workspace validation passes
