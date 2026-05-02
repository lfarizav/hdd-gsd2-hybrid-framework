# Project Knowledge Base

> **Append-only shared knowledge.** Facts about this codebase that agents
> need to do their jobs correctly. Updated after every Gate 4 review.
>
> Keep entries SHORT. Per arXiv:2602.11988, verbose knowledge bases hurt
> rather than help. Each entry should be one fact an agent could not infer
> from reading source files.

---

## Framework & Tooling Facts

- **Test runner:** Jest + ts-jest. Run with `npm test`. Coverage threshold: 80% branches + lines.
- **Linter:** ESLint with `@typescript-eslint`. Run with `npm run lint`. Auto-fix: `npm run lint -- --fix`.
- **Type checker:** `tsc --noEmit`. Run with `npm run typecheck`.
- **Build:** `tsc`. Run with `npm run build`. Output in `dist/`.
- **Formatter:** Prettier. Single quotes, no semicolons, 2-space indent.

## Codebase Conventions

- Functional patterns preferred. Use `class` only for domain entities.
- Descriptive names: `getUserById` not `getUser` + a comment.
- No `any`. No `@ts-ignore` without an explanation comment.
- Validate at system boundaries only. No defensive checks inside pure functions.

## Known Constraints

> Add constraints discovered during execution that aren't obvious from specs.

*(None yet — append after first execution milestone)*

---

## Lessons Learned

> Append after each milestone Gate 4 review.

| Date | Lesson | Phase |
|------|--------|-------|
| <!-- DATE --> | Initial project setup complete | Definition |
