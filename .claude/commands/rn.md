---
name: rn
description: Rename this session using the current branch, Jira ticket, and PR number
allowed-tools: Bash, Grep
---

Rename the current session. Run these bash commands to get context:

1. `git -C /workspace/quizlet-web branch --show-current`
2. First check if gh is authenticated: `gh auth status 2>&1`
   - If NOT authenticated, tell the user to run `! gh auth login` and then try `/rn` again. Stop here.
   - If authenticated, continue:
3. `gh pr view --json number,title,state,statusCheckRollup 2>/dev/null || gh pr list --head $(git -C /workspace/quizlet-web branch --show-current) --json number,title,state,statusCheckRollup 2>/dev/null`

Extract the Jira ticket from the PR title or branch name (patterns like ART-NNN, TLS-NNN, ACT-NNN etc).

Build the name using these emoji conventions:
- Ticket: 🎫 before the ticket ID
- PR state: ✅ merged, 🚧 open, 🔴 closed (not merged), omit if no PR
- CI checks: append after PR number — ⏳ pending, ✅ all passing, ❌ failing. Determine from statusCheckRollup: if any FAILURE use ❌, if any PENDING/IN_PROGRESS use ⏳, if all SUCCESS use ✅. Also count required review approvals as a check — if review is required and not approved, treat as failing.

Example formats:
  🎫 ART-722 recs phase metrics 🚧 #77412 ✅
  🎫 ART-722 recs phase metrics 🚧 #77412 ❌
  🎫 ART-722 recs phase metrics (no PR)

If $ARGUMENTS is provided, use that as the full name instead.

Tell the user to run `/rename THE NAME` — skills cannot invoke /rename directly.
