# Grant Research Playbook

Use this playbook for discovery, verification, and competitive-landscape research. Adapt the search terms to the sponsor and discipline.

## Contents

- Opportunity resolution
- Source hierarchy
- Requirements pass
- Awards and competitors pass
- Partner pass
- Repository fit pass
- Currentness and contradiction checks

## Opportunity resolution

Start with the grant name, sponsor, identifier, quoted title fragments, and likely program office. Resolve:

- canonical title and identifier
- sponsor and participating offices
- solicitation type and amendment number
- applicant pathway and current status
- official landing page and full solicitation

If multiple opportunities share a name, compare identifiers, fiscal years, applicant classes, and deadlines before choosing. Record alternatives in `research/opportunity.md` when ambiguity remains.

## Source hierarchy

Use sources in this order:

1. Official solicitation, amendment, regulations, sponsor landing page, FAQ, webinar, template, and award database.
2. Official award announcements, funded abstracts, laboratory or university project pages, and public repositories maintained by awardees.
3. Scholarly papers, conference materials, institutional news, and reputable trade or policy reporting.
4. Search snippets, social posts, forums, and aggregators only as discovery leads.

For technical questions, prefer the primary paper or official project artifact. For deadlines and eligibility, rely on the current official solicitation or amendment.

## Requirements pass

Extract and reconcile:

- issue, amendment, LOI, pre-proposal, internal, application, decision, and start dates
- award count, amount, duration, phases, budget periods, and funding instrument
- eligible leads, subrecipients, foreign entities, facilities, and individual investigators
- institution and PI submission caps
- required partner categories, letters, registrations, and portals
- cost share and focus-area-specific exceptions
- narrative and appendix limits, required templates, and prohibited content
- evaluation criteria, program policy factors, risk review, and security requirements
- data management, open science, IP, publication, reporting, meeting, and compute obligations

Create a deadline table with timezone and source. When dates conflict, prefer the latest numbered amendment and explain the change.

## Awards and competitors pass

Search combinations such as:

- `"<program name>" awards`
- `"<opportunity identifier>" award`
- `site:<official sponsor domain> "selected for award" "<topic>"`
- `site:<official award database> "<program office>" "<keyword>"`
- `"<focus area>" funded project`
- `"<principal investigator>" "<program>"`
- `"<technical approach>" grant award`

Search at least:

- previous rounds of the same program
- adjacent sponsor programs funding similar work
- seed or platform awards feeding the current call
- public abstracts and award lists
- project pages and publications that reveal active teams

Classify each result as precedent, competitor, collaborator, or weak lead. Explain the classification and preserve the supporting source.

## Partner pass

Identify partners by capability gap, not fame. Look for:

- required institution categories
- unique data, facilities, instruments, compute, or deployment environments
- software and AI infrastructure
- domain validation and benchmark ownership
- commercialization or transition pathways
- previous work under the sponsor

Separate eligibility-critical partners from optional scientific contributors. Note cost-share and intellectual-property consequences of industry participation.

## Repository fit pass

Read repository evidence before recommending a lane:

- README and project overview
- papers, abstracts, talks, and technical notes
- code, data, models, benchmarks, and existing workflows
- team or collaborator files
- prior proposals or awards when present and appropriate to use

Build a fit table covering sponsor objective, repository evidence, gap, proposed contribution, validation metric, and confidence. Do not infer expertise that the repository does not support.

## Currentness and contradiction checks

Before concluding:

- search for amendments, updated FAQs, recorded webinars, and deadline extensions
- compare the landing page with the latest PDF
- verify whether a generic close date actually permits the user's applicant pathway
- check whether award announcements have appeared since the initial research pass
- record the exact access date for all unstable facts

If a fact remains unresolved, state what sources conflict and what authoritative confirmation is needed.
