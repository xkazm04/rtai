# b7-decisions (lane controls, n23) - docs only, about 5 minutes

Hard stop: 08:40. Commit by 08:35. Do not amend, do not rebase, no `git stash`, no `git add -A/./-u`, no `git commit -a`.
Before any Godot run (none should be needed): `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/controls`.

## Goal
Append exactly two lines at the end of `docs/decisions.md` (shared, append-only, one line at a time; do not touch any other line), matching the existing line format `- [YYYY-MM-DD] DECISION <area>: ...`:

1. `- [2026-11-22] DECISION controls: under the wheel a walk-over weapon pickup is stowed, not drawn (scroll or the grip key draws it); with only hands the wheel readout shows Hands lit; Rivet's own blast damage can kill him (owner: "hurt", not "spared"). Rejected: auto-select on pickup (it would change the weapon under the player's thumb mid-fight). Re-check: owner verdict on the n23 controls REPORT.`
2. `- [2026-11-22] DECISION controls: an explicit Use-grab of a weapon (quest 1's Dock 9 rifle, collect_call stage_actions -> CombatArena.grab_rifle) draws it at once, unlike a walk-over pickup. Rejected tonight: stowing it (collect_call is not this lane's; one call in stage_actions is the alternative). Re-check: owner verdict on the n23 controls REPORT.`

## Allowlist
`docs/decisions.md` only. Any other path: stop and report a NEED. Forbidden: every other file, in particular other lanes' files (prologue, street, moves, loop).

## Acceptance
- `git diff HEAD -- docs/decisions.md` shows only these two added lines at the end of the file.
- `node tools/lint/lint.mjs` is not needed (docs are inert); the pre-commit hook may run: fix lint and format findings in your own edit and go on.
- Commit with `git add docs/decisions.md` then `git commit -m "Record the wheel pickup and Use-grab decisions" -- docs/decisions.md`.
- Final message: the commit sha and the two lines as committed.
