# Troubleshoot Skill

Investigate unexpected behavior by analyzing debug logs and examining tool usage patterns.

## When to use

- "Why did this happen?"
- "Why is the task slow?"
- "Why weren't these tools used?"
- "Why aren't my instructions/skills being followed?"
- Debugging failed builds or test runs

## Process

1. Check for debug logs in workspace storage or build output
2. Parse JSONL files for execution traces
3. Examine tool call sequences (what ran, what didn't, why)
4. Correlate logs with expected behavior
5. Identify root cause (missing config, wrong tool, timeout, etc.)

## Output

Provide a clear analysis with:

- What went wrong
- Where it failed (file/line/step)
- Why it happened (root cause)
- How to fix it (if applicable)
