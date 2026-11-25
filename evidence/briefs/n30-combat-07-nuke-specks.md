# n30 combat call 07: the nuke band's last 39 vermilion px

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Hard stop 12:30**: commit only if the in-game
count drops, by 12:29; otherwise report what you found and END (nothing uncommitted matters then: restore the PNG with
`git checkout -- project/features/combat/weapons/art/fx/nuke_shell.png`).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` before launching Godot (another builder may be ending).

Read `evidence/n30/rounds/band.md` and `evidence/n30/rounds/recolour_band.py` (commits 42e7af756, 201763968). In game at
64 px/m (nuke t1212, `evidence/n29/red/take.mjs` as band.md shows) 39 single vermilion px remain on the amber band's edges
next to the two black stripes: the item print snaps the amber/ink blend px to vermilion. Fix in the PNG only: the band px
adjacent to the stripe ink whose colour is an amber/ink blend get a dark amber-brown (low value, e.g. amber hue at value <= 0.35)
so the print snaps them to ink, alpha kept, 0 px outside the band + edge. Add it as a `--stripe-edge` step in
`recolour_band.py`. Re-render t1212 and count (is_red gate and r-max(g,b) >= 0.31) in the round box; target 0.
Commit `nuke_shell.png` + the script if the count drops (`n30 combat: nuke band stripe edges dark amber (in-game vermilion 39 -> N)`,
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`; stage per path; never skip the hook; no amend).
Save the new still to `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/round_band_nuke_pair2_64.png` (before = HEAD, after).
Allowlist: that PNG, `evidence/n30/rounds/**`, `build/**`, the masters dir. Report: counts, commit hash, END.
