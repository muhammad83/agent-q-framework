# Quick Guide — Agent Q + gstack

Two systems, one workflow. **Agent Q** handles orchestration. **gstack** provides specialist roles.

## The Flow

```
  THINK          PLAN           BUILD          REVIEW         TEST           SHIP
  ─────          ────           ─────          ──────         ────           ────
  /office-hours  /q:plan        /q:execute     /review        /qa            /ship
                 /plan-ceo      /q:quick       /cso           /qa-only       /land-and-deploy
                 /plan-eng                     /design-review /canary        /document-release
                 /plan-design                  /q:verify      /benchmark
                 /autoplan
```

## Quick Reference

| When you want to...             | Use                          | Source   |
|---------------------------------|------------------------------|----------|
| Rethink the product             | `/office-hours`              | gstack   |
| CEO-level scope review          | `/plan-ceo-review`           | gstack   |
| Engineering architecture review | `/plan-eng-review`           | gstack   |
| Design review (pre-build)       | `/plan-design-review`        | gstack   |
| Auto-run all plan reviews       | `/autoplan`                  | gstack   |
| Plan a build (reverse elicit)   | `/q:plan`                    | Agent Q  |
| Execute a build plan            | `/q:execute`                 | Agent Q  |
| Small focused fix               | `/q:quick`                   | Agent Q  |
| Full pipeline (plan→ship)       | `/q:orchestrate`             | Agent Q  |
| Parallel execution (tmux)       | `/q:spinjitsu`               | Agent Q  |
| TDD red-green-refactor          | `/q:tdd`                     | Agent Q  |
| Code review                     | `/review`                    | gstack   |
| Verify against spec             | `/q:verify`                  | Agent Q  |
| Design review (post-build)      | `/design-review`             | gstack   |
| Browser-based QA                | `/qa`                        | gstack   |
| QA report only (no fixes)       | `/qa-only`                   | gstack   |
| Security audit (OWASP+STRIDE)   | `/cso`                       | gstack   |
| Performance benchmark           | `/benchmark`                 | gstack   |
| Debug a bug                     | `/q:debug` or `/investigate` | both     |
| Browse a URL                    | `/browse`                    | gstack   |
| Ship a PR                       | `/ship`                      | gstack   |
| Merge + deploy + verify         | `/land-and-deploy`           | gstack   |
| Post-deploy monitoring          | `/canary`                    | gstack   |
| Update docs after shipping      | `/document-release`          | gstack   |
| Weekly retrospective            | `/retro`                     | gstack   |
| Brainstorm with live preview    | `/q:brainstorm`              | Agent Q  |
| Show project progress           | `/q:progress`                | Agent Q  |
| Pause session for handoff       | `/q:pause`                   | Agent Q  |
| Resume paused session           | `/q:resume`                  | Agent Q  |
| Enable safety guardrails        | `/guard`                     | gstack   |
| Lock edits to one directory     | `/freeze`                    | gstack   |
| Remove edit lock                | `/unfreeze`                  | gstack   |
| Second opinion (Codex)          | `/codex`                     | gstack   |

## Common Workflows

### Build a new feature (full)
```
/office-hours          → reframe the idea
/plan-ceo-review       → scope check
/q:plan                → detailed build plan
/q:execute             → build it
/review                → catch bugs
/qa http://localhost    → browser test
/ship                  → open PR
```

### Quick fix
```
/q:quick               → small fix, no planning overhead
/review                → sanity check
/ship                  → PR
```

### Full auto pipeline
```
/q:orchestrate         → plan → execute → verify → debug (all Agent Q)
/review                → gstack deep review
/qa                    → browser QA
/ship                  → PR
```

### Pre-launch audit
```
/cso                   → security audit
/qa http://staging     → full QA pass
/benchmark             → performance baseline
/canary                → post-deploy watch
```

### Working on production (safe mode)
```
/guard                 → enable safety (warns on destructive commands + edit lock)
... do your work ...
/unfreeze              → remove lock when done
```

## Tips

- `/q:` commands understand Agent Q's todo.md state — they track progress automatically
- gstack's `/review` auto-fixes obvious issues; `/q:verify` checks against your spec
- Use `/qa` with a URL for browser testing, `/qa-only` if you just want a bug report
- `/autoplan` chains CEO → design → eng review so you don't have to run each manually
- `/guard` = `/careful` + `/freeze` combined — use it when touching prod
- `/retro` works across projects — run `/retro global` for a cross-project view
