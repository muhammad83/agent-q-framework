# Workflow: Document Release

## Trigger
Run this after shipping code (PR created or merged) to sync all project
documentation with what actually shipped. Also run when asked to "update the docs",
"sync documentation", or "post-ship docs".

## Context Needed
Before running, make sure you have:
- [ ] Current branch (must be a feature branch, not the base branch)
- [ ] Access to all `.md` files in the project
- [ ] `todo.md` for current project state

## Steps

### Step 0: Detect base branch

Same as `workflows/ship.md` Step 0:
1. `gh pr view --json baseRefName -q .baseRefName`
2. `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
3. Fall back to `main`.

---

### Step 1: Pre-flight and diff analysis

1. **Branch guard.** If on the base branch, abort: "You're on the base branch.
   Run from a feature branch."

2. **Gather context:**
   ```
   git diff <base>...HEAD --stat
   git log <base>..HEAD --oneline
   git diff <base>...HEAD --name-only
   ```

3. **Discover all documentation files:**
   Find all `.md` files in the project (exclude `.git/`, `node_modules/`, vendor dirs).

4. **Classify changes:**
   - New features (new files, commands, capabilities)
   - Changed behavior (modified services, APIs, config)
   - Removed functionality (deleted files, removed commands)
   - Infrastructure (build system, tests, CI)

5. Output: "Analyzing N files changed across M commits. Found K documentation files."

---

### Step 2: Per-file documentation audit

Read each documentation file and cross-reference against the diff.

**README.md:**
- Does it describe all features visible in the diff?
- Are install/setup instructions still valid?
- Are examples and usage descriptions still accurate?

**ARCHITECTURE.md:**
- Do diagrams and component descriptions match the current code?
- Be conservative -- only update things clearly contradicted by the diff.

**CONTRIBUTING.md:**
- Walk through setup instructions as a new contributor. Would each step work?
- Are listed commands and test instructions accurate?

**CLAUDE.md / project instructions:**
- Does the file structure section match the actual file tree?
- Are listed commands and scripts still accurate?

**Any other .md files:**
- Read, determine purpose, cross-reference against the diff.

**Classify each needed update as:**
- **Auto-update:** Factual corrections clearly warranted by the diff (adding items
  to tables, updating paths, fixing counts, updating file trees).
- **Ask user:** Narrative changes, section removal, large rewrites (10+ lines),
  ambiguous relevance, new sections.

---

### Step 3: Apply auto-updates

Make all clear, factual updates directly.

For each file modified, output a one-line summary: not "Updated README.md" but
"README.md: added /new-command to commands table, updated file count from 9 to 10."

**Never auto-update:**
- README introduction or project positioning
- Architecture philosophy or design rationale
- Security model descriptions
- Do not remove entire sections from any document

---

### Step 4: Ask about risky changes

For each risky update identified in Step 2, ask the user with:
- Context: which doc file, what section, what the change is
- Your recommendation
- Options: A) Apply B) Modify C) Skip

---

### Step 5: CHANGELOG voice polish (if modified on this branch)

If CHANGELOG.md was modified on this branch, review for voice:
- Lead with what the user can now DO -- not implementation details.
- "You can now..." not "Refactored the..."
- Flag entries that read like commit messages.
- Only polish wording -- never delete, reorder, or replace entries.
- Use Edit tool with exact matches -- never overwrite the whole file.

If CHANGELOG was not modified on this branch, skip.

---

### Step 6: Cross-doc consistency check

1. Does README's feature list match CLAUDE.md's description?
2. Does ARCHITECTURE's component list match CONTRIBUTING's project structure?
3. Does CHANGELOG's latest version match the VERSION file (if both exist)?
4. **Discoverability:** Is every doc file reachable from README or CLAUDE.md?
5. Auto-fix factual inconsistencies. Ask about narrative contradictions.

---

### Step 7: Commit and output

1. **Empty check.** Run `git status`. If no docs were modified, output
   "All documentation is up to date." and exit.

2. **Commit.** Stage modified files individually. Commit:
   ```
   docs: update project documentation
   ```

3. **Output a doc health summary:**
   ```
   Documentation health:
     README.md       [Updated|Current|Skipped] (details)
     ARCHITECTURE.md [Updated|Current|Skipped] (details)
     CONTRIBUTING.md [Updated|Current|Skipped] (details)
     CHANGELOG.md    [Polished|Current|Skipped] (details)
     CLAUDE.md       [Updated|Current|Skipped] (details)
     VERSION         [Already bumped|Not bumped|Skipped] (details)
   ```

4. Update `todo.md` with documentation status.

## Tools Used
- git (diff, log, status, add, commit)
- Project documentation files (Read, Edit, Glob, Grep)

## Output
- Documentation files updated to match shipped code
- `todo.md` updated with doc status

## Success Criteria
- All doc files cross-referenced against the diff
- Factual corrections applied automatically
- Risky/narrative changes presented to user for approval
- CHANGELOG voice polished (not rewritten)
- Cross-doc consistency verified
- Doc health summary output

## Edge Cases
- **On base branch:** Abort with message
- **No documentation files exist:** Output "No documentation files found." and exit
- **CHANGELOG not modified:** Skip voice polish
- **No VERSION file:** Skip version-related checks
- **Permission errors on doc files:** Warn and continue
- **Very large diff:** Focus on docs most likely affected (those referencing changed files)
