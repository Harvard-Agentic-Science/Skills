# Paper Reviewer

A configurable manuscript reviewer that reads your draft and gives structured feedback from one of several perspectives.

## What it does

You point it at a paper and it gives you a full referee-style review: summary, major concerns, minor concerns, questions, what works well, and revision priorities. Before it starts, it asks which kind of reviewer you want.

## Reviewer personalities

- **Nitpicker** — Finds every gap, every imprecise statement, every place where the logic could be tighter. For when you want to be bulletproof before submission.
- **Neutral referee** — A fair, balanced review that distinguishes major issues from minor ones. Closest to what an actual journal referee would write.
- **Skeptic** — Not convinced by the work. Challenges assumptions, questions whether the evidence supports the claims, pushes back on overreach.
- **Champion** — Thinks the work is interesting and wants it to succeed. Points out strengths and suggests high-impact additions before submitting.
- **Confused grad student** — Smart but not an expert on your specific topic. Points out every place where the paper lost them, skipped a step, or assumed too much background.
- **Custom** — You describe the personality you want.

You can combine personalities (e.g., "neutral referee but pay attention to accessibility like the grad student would"). You can also save a default so it skips the question next time.

## How to use it

Copy `paper-reviewer.md` to `.claude/agents/` in your project, then say "run the paper-reviewer agent on my draft."
