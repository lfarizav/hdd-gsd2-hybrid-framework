# Agent Customization Skill

Create, update, review, fix, or debug VS Code agent customization files.

## Files this skill manages

- `.instructions.md` — Main agent instructions
- `.prompt.md` — Custom prompt overrides
- `.agent.md` — Agent configuration
- `SKILL.md` — Custom skill definitions
- `copilot-instructions.md` — GitHub Copilot repository instructions
- `AGENTS.md` — Repository agent context

## When to use

- Save coding preferences or project conventions
- Troubleshoot why instructions/skills are being ignored
- Configure agent mode patterns or specialized workflows
- Fix YAML frontmatter syntax errors
- Package domain knowledge for agents

## When NOT to use

- General coding questions (use default agent)
- Runtime debugging or error diagnosis
- MCP server configuration
- VS Code extension development

## Scope

- File system operations (read/write customization files)
- Question-asking for requirements gathering
- Subagent invocation for codebase exploration
- YAML validation and formatting

## Tips

- For quick YAML fixes, edit directly without invoking skill
- Single file operations don't require skill invocation
- Use this skill for systematic review of all customization files
