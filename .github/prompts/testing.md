# Testing Prompt

When generating or improving tests:

1. **Unit tests** (`tests/unit/`):
   - Test one function per describe block
   - Cover happy path + at least 2 error cases
   - Use descriptive test names: `should throw when email is missing`
   - Mock external dependencies

2. **Integration tests** (`tests/integration/`):
   - Test component interactions (e.g., API → DB)
   - Use test fixtures or factories, not live data
   - Clean up state after each test
   - Document why integration tests exist

3. **E2E tests** (`tests/e2e/`):
   - Reserved for critical user workflows only
   - Use realistic data
   - Assert on observable outcomes (UI, API responses)
   - Keep E2E tests < 10% of total test suite

4. **Coverage**:
   - Never remove a failing test
   - Target: ≥80% line + branch coverage
   - Report coverage with: `npm test -- --coverage`
