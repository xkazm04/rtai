# n20-kerf brief 04: films, the plate still, frames.json, decision lines

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Visual night; no digest
moves. Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`,
`--position 0,1440` on windowed runs, one Godot process at a time, kill only your own PIDs.

## Step 0
Flight's film tool is on n20-flight (95d914ab8 + 073237b56): after the merge, use
`node tools/film/ghost_films.mjs --ghost=kerf --look=spectral --out=<dir> --takes=move,attack,close --stills=163`
(read its --help; `--look=legacy` for the before take).
If `n20-flight` has new commits since your last merge (`git log --oneline HEAD..n20-flight`), merge it
again (`git merge n20-flight`, the only merge allowed). Look for its film tool (`tools/film/ghost_films.mjs`
or similar, and the README "Spectral look" section / `tools/README.md`). Abort and report on conflict.

## Step 1
Kerf's `ghost_hover.json` row (lag 1, bank 12) was committed in brief 03b. Do not touch it again; just look
at a hard turn in the move film: he must snap onto the new heading, not swing. Say what you saw.

## Films for the owner (into `C:\Users\kazda\kiro\gtai-masters\n20\kerf\`)
The owner reviews all four ghosts together, as last night (`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md`
describes the layout and the movement/attack inputs; last night's `kerf_*.mp4` there are the "before").
With `--ghost-look=spectral`, Kerf only, through `project/dev/ghost-powers/ghost_review.tscn`
(flight's film tool if it exists; otherwise the driver's own capture + ffmpeg), each showing the 70-degree
play tilt ABOVE and the straight-down top view BELOW:
- `kerf_move_32.mp4` (5 s of movement at 32 px/m: rest, run, the turn sequence, one empty blink),
- `kerf_attack_32.mp4` (5 s of attack at 32 px/m: the blink-slice chain from `kerf_beat.gd`),
- `kerf_close_64.mp4` (64 px/m close-up of an idle-to-slice),
- a poster `.jpg` for each (a frame that shows the point of the clip).
Also `kerf_tilt55_32.mp4` (about 8 s: the same movement then two slices, the 55-degree tilt above and the
top view below, if the driver can set 55; otherwise a 55-degree still strip of rest / cruise / press tick /
+15, `kerf_tilt55_strip_32.png`): the switch rule needs both tilts filmed.
Also `kerf_attack_32_legacy.mp4`: the same attack take without the flag (the before at the same ticks).
Watch each clip (extract frames every 5 ticks around each blink and look at them). Report honestly what
reads and what does not.

## Stills
- `kerf_plate_vs_game.png`: the plate `C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png` on the
  left; on the right, Kerf in game (spectral, cruise, 64 px/m crop) in the 70 tilt above and the top
  view below, on the same dark backdrop.
- `kerf_creature_32.png`: a 32 px/m still where he is POISED near a guard, eye open, hackles up, plus the
  same crop x3 nearest-neighbour.

## frames.json (`C:\Users\kazda\kiro\gtai-masters\n20\kerf\frames.json`, 8 to 15 entries, best first)
`[{ "file", "title", "ppm", "before", "note" }]`. First entry: `kerf_plate_vs_game.png`. Include the
slice strips from brief 03, the creature still, the posters, `body_contact_sheet.png`. `before` names
the matching n19 file under `C:\Users\kazda\kiro\gtai-masters\n19\ghosts\` or null. Delete scratch
renders in that folder that frames.json does not reference (keep `masters/`, the mp4s, posters).

## Docs (append-only shared file, one line each)
Append to `docs/decisions.md` (format `- [2026-11-20] DECISION <area>: what, why, what was rejected.`):
1. `kerf body`: rigid art, no cycles: top-view cutout parts + a 5x3 hover grid per tilt (POISED/CRUISE/LUNGE);
   lens open/half/slit is the eye; rejected drawn cycles and an independent p55 generation.
2. `kerf beams`: the three trailing beams are the three blink charges (spent beam gone, regrowing beam's
   length = recharge fraction); view only.
3. `kerf slice`: one after-image of the pre-blink pose + one full-length slot on the press tick +
   render-only 0.5 m overshoot; nothing drawn on the victim on the press tick; sim timing unchanged.
Commit the decisions lines (staged per path), `node tools/gate/quick.mjs` first.

## Final message
The clip and still paths, what you saw in each, the frames.json order, commit hash.

## Additions (director, 03:28)
- HEAD is `cd4555736` (victim read committed). Step 0's merge of `n20-flight` now also brings flight's
  chip loader (`4362c8109`): after the merge, take one 64 px/m HUD still under `--ghost-look=spectral`
  showing `ghost_chips/kerf_spectral.png` in the chip (`kerf_hud_chip.png`) and name it in frames.json.
- Quick gate: `tools/gate/quick.mjs` fails on `kill_marks.gd` / `kill_split_fx.gd` / `kill_view.gd` /
  `kerf_victim.gd` with only "Failed to compile depended scripts" (it fails the same way on the untouched
  files at f6a830612; the full unit suite compiles them: 3212/0/2 at cd4555736). If that cascade is the ONLY
  failure, use `node tools/gate/quick.mjs --no-godot` plus `node tools/tests/run_unit.mjs --changed`, and
  say so in your final message. Any other quick failure is real: fix it.
- After the films, run `node tools/mutate/mutate.mjs --file=features/souls/kerf_victim.gd` (check the path
  form in tools/mutate/README.md) and quote killed/(killed+survived). If the score is under 60 %, add tests
  that kill the survivors and commit them.
- Watch each film before you hand it over: the 70 tilt above and the top view below must show ONE body (the
  spectral hull, no legs anywhere, no foot/ground ring), and the press tick of the attack take must show the
  guard whole with the slot through it. If flight's merge brings anything that puts legs or a ground ring
  back on Kerf, report it in one NEED flight line; do not edit flight's files.
- Keep the session under 60 minutes: if a step runs long, drop `kerf_tilt55_32.mp4` to the 55 still strip.
