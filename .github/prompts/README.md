# Custom Agent Prompts

This directory contains reusable prompt templates for common agent workflows.
Reference these when creating new `.github/agents/*.md` files or asking agents to perform specific tasks.

## Usage

### Option 1: Direct reference in agent files
```markdown
See `.github/prompts/code-review.md` for how to structure code reviews.
```

### Option 2: Inline in agent instructions
Copy and adapt templates into your agent YAML frontmatter or `.github/agents/*.md`.

## Available prompts

- `code-review.md` — Guidelines for security and style review
- `testing.md` — Test generation and coverage strategy
- `documentation.md` — Auto-doc generation patterns
