# TypeScript / React / Next.js / Node.js Rules

## TypeScript
- **No `any`.** Use `unknown` + type guards or generics instead.
- Prefer `interface` for object shapes, `type` for unions/intersections.
- Use `as const` for literal tuples and enums. Avoid `enum` keyword.
- Enable `strict: true` in tsconfig. Never disable strict checks per-file.
- Prefer `readonly` for properties that shouldn't mutate.

## React
- Functional components only. No class components.
- Follow Rules of Hooks — no conditional hooks, no hooks in loops.
- Always provide stable `key` props on lists (never use array index).
- Use `React.memo()` for expensive renders; profile before optimizing.
- Colocate state — lift only when two+ siblings need the same data.
- Prefer `useReducer` over `useState` for complex state logic.

## Next.js (App Router)
- Default to Server Components. Add `"use client"` only when needed (hooks, event handlers, browser APIs).
- Data fetching: use `async` Server Components or Route Handlers. No `getServerSideProps`.
- Use `loading.tsx`, `error.tsx`, and `not-found.tsx` for each route segment.
- Metadata: export `metadata` or `generateMetadata` from page/layout files.
- Images: always use `next/image` with explicit width/height or `fill`.

## Node.js
- `async/await` over callbacks. Never mix paradigms.
- Always handle errors — no unhandled promise rejections.
- Use `node:` prefix for built-in modules (`node:fs`, `node:path`).
- Validate all external input at the boundary (API routes, CLI args).

## TailwindCSS
- Utility-first. No inline `style={}` unless truly dynamic values.
- Use `cn()` (clsx + twMerge) for conditional class composition.
- Extract repeated patterns into components, not `@apply` classes.

## Testing
- Vitest preferred. Jest acceptable for existing projects.
- Test behavior, not implementation. Avoid testing internal state.
- Use `describe` / `it` structure. One assertion concept per test.
- Mock at boundaries (network, DB), not between internal modules.
