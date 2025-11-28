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
