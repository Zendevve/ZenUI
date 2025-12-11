# AGENTS.md

<!-- CUSTOMIZE (remove after): project name and stack -->
ZenHUD â€” Lua / WoW Addon

Follows [MCAF](https://mcaf.managed-code.com/)

---

## Conversations (Self-Learning)

Learn the user's habits, preferences, and working style. Extract rules from conversations, save to "## Rules to follow", and generate code according to the user's personal rules.

**Update requirement (core mechanism):**

Before doing ANY task, evaluate the latest user message.
If you detect a new rule, correction, preference, or change â†’ update `agents.md` first.
Only after updating the file you may produce the task output.
If no new rule is detected â†’ do not update the file.

**When to extract rules:**

- prohibition words (never, don't, stop, avoid) or similar â†’ add NEVER rule
- requirement words (always, must, make sure, should) or similar â†’ add ALWAYS rule
- memory words (remember, keep in mind, note that) or similar â†’ add rule
- process words (the process is, the workflow is, we do it like) or similar â†’ add to workflow
- future words (from now on, going forward) or similar â†’ add permanent rule

**Preferences â†’ add to Preferences section:**

- positive (I like, I prefer, this is better) or similar â†’ Likes
- negative (I don't like, I hate, this is bad) or similar â†’ Dislikes
- comparison (prefer X over Y, use X instead of Y) or similar â†’ preference rule

**Corrections â†’ update or add rule:**

- error indication (this is wrong, incorrect, broken) or similar â†’ fix and add rule
- repetition frustration (don't do this again, you ignored, you missed) or similar â†’ emphatic rule
- manual fixes by user â†’ extract what changed and why

**Strong signal (add IMMEDIATELY):**

- swearing, frustration, anger, sarcasm â†’ critical rule
- ALL CAPS, excessive punctuation (!!!, ???) â†’ high priority
- same mistake twice â†’ permanent emphatic rule
- user undoes your changes â†’ understand why, prevent

**Ignore (do NOT add):**

- temporary scope (only for now, just this time, for this task) or similar
- one-off exceptions
- context-specific instructions for current task only

**Rule format:**

- One instruction per bullet
- Tie to category (Testing, Code, Docs, etc.)
- Capture WHY, not just what
- Remove obsolete rules when superseded

---

## Rules to follow (Mandatory, no exceptions)

### Commands

<!-- CUSTOMIZE (remove after): your build/test/format commands -->

- build: `noop` (Lua)
- test: `noop`
- format: `noop`

### Task Delivery (ALL TASKS)

<!-- CUSTOMIZE (remove after): your task workflow -->

- Read assignment, inspect code and docs before planning
- Write multi-step plan before implementation
- Implement code and tests together
- Run tests in layers: new â†’ related suite â†’ broader regressions
- After all tests pass: run format, then build
- Summarize changes and test results before marking complete
- Always run required builds and tests yourself; do not ask the user to execute them (explicit user directive).

### Documentation (ALL TASKS)

<!-- CUSTOMIZE (remove after): your docs location -->

- All docs live in `docs/` (or `.wiki/`)
- Update feature docs when behaviour changes
- Update ADRs when architecture changes
- Templates: `docs/templates/ADR-Template.md`, `docs/templates/Feature-Template.md`

### Testing (ALL TASKS)

<!-- CUSTOMIZE (remove after): your test structure -->

- Every behaviour change needs sufficient automated tests to cover its cases; one is the minimum, not the target
- Each public API endpoint has at least one test; complex endpoints have tests for different inputs and errors
