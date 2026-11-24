# Follow-up n27-cast-01c: close the warden's open points, switch her on if they pass (resume of your warden session)

Same worktree, branch `n27-cast`, same rules as your first two briefs (APPDATA, GODOT_BIN, one Godot at a time, d3d12,
`--position 0,1440`, owned/forbidden lists, repo law, no image generation, no amend/rebase, stage per path).
**Hard stop 05:45 local** (check `date`): commit what is green, report and END. **Commit the audit + row by 05:15.**
Fix lint and format findings in your own edit and go on.

## Director's review of `8061d631b`
Accepted, with one correction: **the bar for body jump is the checklist's, not yours.** `docs/art/cast-checklist.md` Feet row:
"The largest body jump between consecutive rendered frames must also stay within 12 screen px (0.375 m) at every gameplay
speed" at 32 px/m. "Travel + 2 px" is not a rule of this repo; do not use it. Against 12 px her numbers (walk/turn/reversal
9.60 px, down-right 9.07 / 9.15 at 70, 5.36 / 5.81 at 55, start 6.19) all PASS. Rewrite those verdict cells to PASS against
12 px (keep the numbers; you may add "Mulroney ships 12 px bound" as context). Drawings per second 14.9 on the arrival walk:
note it ("above 12, Mulroney ships 16.8"), not a fail.
The yard lane (`n27-yard`) will hand the Director the exact `prologue_stage.gd` / `prologue_props.gd` hunks at the merge
(`evidence/yard27/warden_catch_wiring.md` on their branch): the "Catch view in the live prologue" row becomes
"wired at the merge by the yard's patch (NEED yard)", not a fail of the card.

## Do, in this order (stop each at its time box)
Already measured in `f230bf8ca` and accepted: live-frame rim 0 px on all ten sheets, wound contact 0.000 to 0.001 px, soles 0.00 px,
palette. Do not re-measure them.
1. (10 min) Size with the pole excluded at 32 px/m 70 degrees, front and back (crop her pole column, or the body silhouette from
   the sheet cell scaled to 32 px/m); quote it beside the patrol cop (43 / 44) and Rivet (77 / 73).
2. Rewrite the jump verdict cells against 12 px (see above) and the "Why it stays off" paragraph. **Every point now passes
   (the catch row excepted), so set `enabled: true` for `appliance_warden` in `cast_cards.json` in the same commit**, then run
   `node tools/tests/run_unit.mjs --changed` and the scenario suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`):
   prologue tapes and scenarios must stay green and byte-identical (her card is a view; if any digest or tape moves, set it back
   to false and report why). Append one `docs/decisions.md` line: `- [2026-11-24] DECISION n27 cast: the appliance warden's card
   on (soles 0.00 px, body jump 9.6 px <= 12, live rim 0, wound contact 0, not taller than Rivet); the prologue's catch view and the
   dye/pole skip land with the yard's patch at the merge; rejected: keeping her off on a stricter self-made bar.` Commit by 05:15.
3. **Re-render both films at a true 1920x1080.** Your `warden_fight_32.mp4` / `warden_close_64.mp4` are 1280x800: Movie Maker
   renders at the project viewport (`project.godot` 1280x800) and ignores `--resolution`, and the frame is scaled, so the
   "32 px/m" film shows Rivet about 40 px tall instead of 77 (I measured a frame). The repo's fix is in
   `tools/film/ghost_films.mjs` lines 20 to 50: a scratch copy of the project with `viewport_width=1920` / `viewport_height=1080`
   written into its `project.godot`, mounting the live assets; reuse that (a new file under `tools/film/` or `project/dev/cast/`;
   never edit `project.godot`). Check on one extracted frame that Rivet stands about 77 px (front) at 32 px/m and about 154 at 64.
   Deliver `warden_fight_32.mp4` (15 to 40 s; she should be readable: two wardens, the catch, Rivet breaking free) and
   `warden_close_64.mp4` (the same fight centred, 64 px/m), both 1920x1080 60 fps; `ffprobe` both; replace the old files and
   their `frames.json` entries (valid JSON array). Look at frames from both and say what you saw.
4. If time: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_warden_card_view.gd --max=8 --lines=<the
   set_catch lines>` with `--tests=test_cast_warden`; run it in the background with a 15 minute cap; quote killed/(killed+survived).

## Report (and END at the hard stop)
Commits; the new numbers; enabled true/false and why; scenario line; film paths + ffprobe lines; mutate score; what is left.
