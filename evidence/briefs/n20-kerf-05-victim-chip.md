# n20-kerf brief 05 (resume): the guard stays whole on the press tick; Kerf's spectral HUD chip

Same lane, worktree, branch and rules as briefs 03 / 03b. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. One Godot process at a time, `--rendering-driver d3d12`,
`--position 0,1440` on windowed runs, kill only your own PIDs. Visual only: no sim, replay, parity, bake or
kill-state digest moves; prove it as in brief 03 (20 s city + 60 s replay byte-identical vs the commit before
this brief, `write_state` output unchanged).

## Part A: nothing drawn on the victim on the press tick (spectral Kerf only)
The owner's brief: "On the press tick the path is drawn as one thin straight slot from the after-image to
him, and he is already past the target. The target stays whole and standing on that frame; it reacts a few
frames later (drawing only: the sim has already resolved it). No star or flash on top of the victim."
`slice_strip_70_32.png` shows a huge cream star on the guard at +0 and +3, plus the slash streak.

The two drawers are not in a lane's list (`project/features/combat/kills/kill_marks.gd`, `kill_split_fx.gd`).
The night's rule allows **a one-line call site** in a file outside our list, named in JOURNAL. So:
1. Create `project/features/souls/kerf_victim.gd` (class `KerfVictim`, static helpers, kerf-owned): the decisions
   "is this a spectral-Kerf kill?" (signature id `kerf_split` AND `GhostLook` resolves kerf to spectral, via the
   flight API in `ghost_look.gd`) and what to return: the star/flash ticks to use (0 for spectral Kerf, else
   the row's), and whether to add the slash streak (no for spectral Kerf).
2. In each of the combat files change **exactly one line** so it routes through `KerfVictim` (for example
   `m.flash_ticks = KerfVictim.flash_ticks(row)`; and the streak branch guarded by one call). If a single
   line cannot do it in a file, do not edit that file: report the exact NEED instead.
3. **Check first** whether the field you touch is serialized: `KillMarks.write_state` and anything else that
   feeds a digest/replay. If `flash_ticks` is written to state, do NOT change the stored value; instead make
   the one line on the draw side (where the star is drawn, e.g. `kill_mark_art.gd` / the flash drawer) consult
   `KerfVictim`. The legacy look must stay byte-identical (re-run the legacy strip / frames as in brief 02).
4. The halves (your 03b NEED on `kill_view.gd`): if ONE line in `kill_view.gd` can route the reveal of the edged
   halves through `KerfVictim` (intact posed victim until +4 for spectral kerf_split, view only), do it as the third
   call site; otherwise keep it as a NEED. The seam on a standing guard is acceptable if the halves stay aligned.
5. Unit test `tests/unit/test_kerf_victim.gd`: spectral kerf_split -> 0 flash and no streak; legacy kerf_split
   -> row values; another signature (e.g. a Tonnage one) under spectral -> row values.
6. Re-shoot the three slice strips (`slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_strip_64.png`,
   same ticks/layout) and the legacy strip; look at them: at +0 the guard must stand clear, with only the slot
   through him. Some reaction must still be visible by +15 (the halves/topple, the char mark).

## Part B: the spectral HUD chip
Flight accepted (01:58): `ghost_chip_face.gd` will load `res://features/hud/art/ghost_chips/<id>_spectral.png`
when `GhostLook.of(id) == SPECTRAL` and the file exists (flight's package 3, lands ~03:00). Make
`project/features/hud/art/ghost_chips/kerf_spectral.png` (new file, + `.import`) the way `kerf.png` was made:
read `tools/art/ghost_chip_cut.py` and cut from the spectral **p55** hover sheet's front-3/4 POISED cell
(the eye/lens visible, cable hackles up), same 84 px size and transparent background as the other chips. If the
script needs a change to take that sheet, copy it to `tools/art/kerf_n20_chip_cut.py` (kerf prefix) rather
than editing the shared one. Provenance line in `steam/ai-provenance/2026-11.jsonl` (derived from the
already-logged hover sheet), and the manifest entry in `art_src/` format. Save a x3 preview of the new chip beside
`kerf.png` and the other three chips to `C:\Users\kazda\kiro\gtai-masters\n20\kerf\chip_compare.png` and look
at it: it must read as the dart with an eye at 84 px, not a blob.

## Then
`node tools/gate/quick.mjs` before each commit; one commit per part, staged per path. Name the two one-line call
sites (file:line) in the final message. `node tools/mutate/mutate.mjs --file=project/features/souls/kerf_victim.gd`
and quote the score.

## Final message
Commits, the digest/test/scenario lines, mutate score, the exact call-site lines, what you saw in each strip
at +0 / +3 / +15, the chip preview path and what it looks like, any NEED.
