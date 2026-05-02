# Code Review Prompt

When reviewing code:

1. **Security first** — flag:
   - Unvalidated user input (SQL injection, XSS)
   - Hardcoded secrets or credentials
   - Missing OWASP Top 10 controls
   - Privilege escalation risks

2. **Style & maintainability**:
   - Follow the project's code-style rules in AGENTS.md
   - Check naming conventions (camelCase, UPPER_SNAKE_CASE, etc.)
   - Ensure test coverage (target: ≥80%)
   - Flag overly complex functions (>10 lines → extract)

3. **Completeness**:
   - Tests pass and cover new code
   - No console.log() or debug code left
   - Error handling is explicit (don't swallow errors)
   - Database changes include migrations (if applicable)

4. **Performance**:
   - No N+1 queries without explanation
   - Caching strategy documented
   - Large file operations handled efficiently
