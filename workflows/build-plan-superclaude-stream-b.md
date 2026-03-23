# Build Plan: SuperClaude Stream B — Domain Specialists + Orchestration Routing
_Created: 2026-03-23_
_Parent plan: workflows/build-plan-superclaude-integration.md_

## Goal
Create 3 domain specialist agents and add specialist routing to the orchestration
protocol. Update SKILL.md manifest and todo.md.

## Decisions
- Cap specialists at 3: security, frontend, researcher
- Specialists advise alongside core 4 pipeline agents, don't replace them
- Priority order for ambiguity: security > frontend > researcher
- Follow exact pattern of existing agents/q-planner.md
- Gemini CLI falls back to inline loading (no subagent spawning)

## Tasks

### Task 1: Create 3 specialist agent files
- **Create** `agents/q-security.md`
  - Frontmatter: name, role (specialist/security), triggers, capabilities
  - Identity: Security specialist in the Agent Q framework
  - Triggers: vulnerability, XSS, auth, OWASP, injection, CVE, security,
    CSRF, SQL injection, encryption, secrets, permissions
  - File triggers: *.env, auth/*, middleware/*, security/*
  - Responsibilities: OWASP Top 10 review, dependency vulnerability check,
    auth/authz audit, secrets scanning, input validation review
  - Does NOT: make architectural decisions, replace q-verifier, install
    security tools, perform penetration testing
  - Context loading: reads context/rules.md, relevant source files
  - Handoff format: follows orchestration-protocol.md handoff structure

- **Create** `agents/q-frontend.md`
  - Triggers: UI, CSS, component, layout, responsive, accessibility, a11y,
    Tailwind, React, animation, design system
  - File triggers: *.tsx, *.css, *.scss, components/*, pages/*, layouts/*
  - Responsibilities: accessibility audit (WCAG 2.1), component pattern review,
    responsive design check, performance review (bundle size, lazy loading),
    semantic HTML check
  - Does NOT: make design decisions, choose frameworks, create new components
    without approval, override design system

- **Create** `agents/q-researcher.md`
  - Triggers: research, compare, evaluate, alternatives, best practice,
    benchmark, trade-off, library choice, architecture decision
  - Responsibilities: structured investigation with multiple sources,
    comparison matrices, pros/cons analysis, recommendation with rationale
  - Does NOT: make decisions (presents options), implement anything,
    replace the planner's interview process
  - Output: structured findings document saved to shared_context/

- **Acceptance:** All 3 files exist with proper frontmatter, follow q-planner.md pattern

### Task 2: Update orchestration + SKILL.md + todo.md
- **Modify** `workflows/orchestration-protocol.md`
  - Add a "Specialist Routing" section after the "Agent Chain" section
  - Content: routing table mapping keywords/file patterns to specialist agents,
    priority order (security > frontend > researcher), invocation rules
    (specialist loaded as advisor alongside active pipeline agent, not as
    replacement), "no match = no specialist" default
  - Format: table with columns: Specialist, Keyword Triggers, File Triggers, Priority

- **Modify** `SKILL.md`
  - Add to `provides:` list: domain-specialists, behavioral-modes, token-efficiency
  - Add to Agents section: q-security, q-frontend, q-researcher with descriptions
  - Add to Capabilities section: brief entries for domain specialists, behavioral modes,
    token-efficiency

- **Modify** `todo.md`
  - Update Current Goal to reflect SuperClaude integration
  - Move previous goal to Recently Completed
  - Add session log entry
  - Record decisions made

- **Acceptance:** Orchestration protocol has routing table, SKILL.md manifest is accurate,
  todo.md reflects current state

## Verification
- All 3 specialist files have valid frontmatter and follow q-planner.md structure
- Orchestration protocol routing table has clear priority rules
- SKILL.md lists all new capabilities and agents
- todo.md is current
