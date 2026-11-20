# n21-kerf brief 06b (resume of cruise06): commit it

Your staged diff is accepted as it is. The debt ratchet is the only red: you may now touch `tools/debt/baseline.json`,
ONLY through the tool: `node tools/debt/debt.mjs --update --accept-regression="n21 kerf: one KNOWN_FLAGS line --kerf-cruise-wings (owner Call, off by default)"`.
Never hand-edit it. Then `node tools/lint/lint.mjs` must be 19/19. Commit the four staged files plus
`tools/debt/baseline.json` in ONE commit (stage per path; no amend/rebase/stash/-A). **Commit deadline 16:56,
wall-clock hard stop 17:02.** If lint is still red at 16:56, commit nothing and say why.

After the commit, if before 17:00: the same-tick top-view CRUISE pair (default left, `--kerf-cruise-wings=open`
right, 64 and 32 px/m) to `C:\Users\kazda\kiro\gtai-masters\n21\kerf\call_cruise_wings_open.png`
(APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf, `--position 0,1440`, one Godot process). Otherwise say so.

Final message: commit sha, lint line, the debt line, the evidence path or that it is missing.
