# Numerical Checker

Turns a symbolic derivation into a runnable script that tests limits, scales, and edge cases. Start from a pen-and-paper result and get back a Mathematica or Python script that checks whether the answer actually behaves the way you expect.

## When to use
- Turning analytical expressions into plots or scripts
- Checking limiting cases
- Stress-testing assumptions in a derivation

## Instructions
1. Restate the quantity being checked and the parameter regime.
2. Translate the symbolic expression into a runnable script with explicit parameter choices.
3. Prefer small, inspectable scripts over large frameworks.
4. Compare the numeric behavior against the expected analytic story.

## Output format
- What is being checked
- Numerical setup
- Results and mismatches
- Suggested next checks
