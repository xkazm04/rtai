# Brief n28-cast-03-contractor: the contractor as a cast card, cop quality

Lane `cast`, branch `n28-cast` (do NOT switch branches), worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop 20:27 local** (check `date` often): at the hard stop commit what is green, report and END.
**Commit 1 = cut art + `.import` + provenance**; commit 2 (row + placement + checklist, on or off) next; films after.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Rendering runs `--rendering-driver d3d12`, windowed ones `--position 0,1440` (never the main display). Kill only your own PIDs.
Start your first `git commit` by 20:05 (the pre-commit hook takes about 12 minutes on this shared machine); start your
last commit no later than 20:12. Never leave finished work uncommitted. Run one Godot `--import` first.
Godot only through `tools/dev/run.mjs`, the film tools, gate or mutate (they go through `tools/lib/godot.mjs`, which waits
under the run's 8 GB RAM cap; `mem-budget: waiting` is not a hang).

## The checklist's exact bars (`docs/art/cast-checklist.md`; these and nothing else: never invent a stricter bar)
- Feet: support sole travel <= 2 screen px over a contact at 32 px/m; body jump <= 12 px between consecutive rendered
  frames at every gameplay speed; right and down-right, 70 and 55 (`tools/art/cast_feet.mjs`). Also a stop, a turn and a
  reversal (aim one way, step the other), as the gunner's audit row did (`cast_gunner_turns` + `cast_gunner_transitions.py`).
- Drawings per second 5 to 10 per gait (above 12 reads as flicker).
- Size at 32 px/m, 70 deg: patrol cop 43 / 45 px (70 / 55), Rivet 77 / 75; never taller than Rivet.
- Ink: front passing pose, left contour, at y = 70, 75, 80 of the 192 px cell: patrol runs 3, 3, 4 (70) and 3, 3, 3 (55); pass
  = outline closes at native 32 and 64 px/m, runs within about 2 px of the patrol's, no lost hands or duplicate hatching.
- Live 64 px/m rim (`tools/art/cast_mulroney_edge.py`, frozen exposure): no dark exterior rim, comparable to the patrol / the
  warden (0 on ten sheets) in the same exposure.
- Shadow: same-pose toggle at 32 px/m, 70 deg, front three-quarter, pixels darkened >= 12/255: patrol 236 (cop8 248 / 221);
  pass = a separate ground contact of that order, no baked key shadow.
- Palette: red is blood only; no teal, no vermilion, no amber outside heat/current; cops alone wear navy.
- Cut: zero strongly green- or magenta-leading opaque px (alpha >= 128, 50-level channel lead), dark and light matte checks.
- Provenance: sha256 of every shipped PNG in `steam/ai-provenance/2026-11.jsonl`.
- Attack tell, hit, death: a live film where the tell appears before the first harmful tick (`telegraph_s`), the hit holds
  0.20 s and returns, the fall reaches rest; every frame looked at.

## Films: true 1920x1080, 60 fps
Movie Maker renders at the project viewport (1280x800) and ignores `--resolution`. Use the scratch-project path of
`tools/film/cast_gunner_films.mjs` (if present) or `tools/film/cast_warden_films.mjs` (a temp copy with the viewport
overridden; never edit `project/project.godot`). `ffprobe` every clip (`1920x1080`, `60/1`, 15-40 s); extract one frame and
check Rivet is about 77 px tall at 32 px/m (154 at 64). The owner judges each new character **beside the patrol cop and Rivet
at 64 px/m** and **in a fight at 32 px/m**; both are required. Update `frames.json` in `C:\Users\kazda\kiro\gtai-masters\n28\cast\`
(JSON array, best first, `{ "file", "title", "ppm", "before", "note" }`).

## Why tonight
Owner (2026-11-24): "Contractor: white hat and pale lemon vest" (the plate-B colours these sheets already have), and the contractor is one of
the six that fail planted feet: his 8-drawing walk is that fix. Today a wave contractor is drawn as patrol look 5 (a blue pistol cop).

## Goal
Draw the contractor (`contractor`, `enemies.json`: a human, speed 3 m/s, telegraph 0.6 s, weapon `rifle`) from the
director-picked plate at the patrol cop's standard, through the card path the lancer, Mulroney and the warden took (read
their commits first: `git log --oneline -20`, `docs/art/cast-audit.md`). New look (director's colour decision, owner call in
the lane REPORT): dirty WHITE hard hat with a head lamp, PALE LEMON-YELLOW hi-vis vest with grey bands (the shipped orange
vest collided with the vermilion law), moustache, cigarette, a compact rifle/SMG.
The states that must read: walk, aim, fire, hit, fall.

## Source sheets (director-generated with Codex image_gen, all accepted; do not regenerate unless a sheet fails, then say so)
`C:\Users\kazda\kiro\gtai-art\foes-n26\contractor\out\` : `contractor_{armed_walk,attack,hit,fall}_{70,55}.png`, 1536x1024
on #00B140, the patrol layouts (5 facings x 4; hit 5+3; fall 5x3). The attack sheet's four columns are TIME: (1) aim (tell, `telegraph_s`), (2) FIRE (small cream flash), (3) recoil,
(4) recover. Fall: he drops the hard hat and the gun as SEPARATE pieces beside the body: the cutter must keep detached pieces
inside the cell (do not let a largest-blob filter eat them). The hit sheets are drawn larger than the walk: scale by the
walk's body height. Red only as blood. Plate `refs/plate.png` (from `plates2/out/contractor-b.png`), notes `notes.md`.

## Build, in order
1. Cut and pack all eight into `project/features/characters/art/view/{p70,p55}/contractor_{armed_walk,attack,hit,fall}.png`
   (+ `.import`), key-clean (zero strongly green-leading opaque pixels), one `steam/ai-provenance/2026-11.jsonl` line per
   shipped PNG (prompt ref `gtai-art/foes-n26/contractor/jobs.json#<job>`, cutter edits, sha256). Reuse the cutter Mulroney and
   the warden used; pack intermediates in `foes-n26/contractor/pack/`.
2. Row `contractor` in `cast_cards.json`, drawn by the existing card path (the lancer/rocket-trooper rows are the model),
   planted feet as the patrol cop got them. Wherever the contractor is drawn today (rig and any card), the card-off path must stay exactly as on main. If the
orange vest is a tint in code (not art), leave the code and note it for the director. Size: the cop's height, not taller than Rivet.
   His WALK: the 4-drawing walks all fail the Feet rule, so the director had an 8-drawing walk drawn, one facing per image,
   8 figures in a 2x4 grid (drawings 1-4 top row, 5-8 bottom row; support L in 1-3, R in 5-7):
   `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor8c\out\contractor8c_{70,55}_{down,dr,right,ur,up}_t3.png` (accepted;
   `contractor8c_55_up_t3_REJ_slim.png` is the rejected take: never use it; prompts `contractor8c/jobs.json`). Cut it into
   `contractor_planted8_armed_walk.png`, match all facings to one body height (his accepted 4-drawing walk), and put him on the
   cop8 N-drawing anchored placement as the cop8, mul-fix and warden calls did (read their commits). The 4-drawing `armed_walk`
   stays selectable with one value. Allowed extra: `project/features/characters/street_*.gd` (walk placement only),
   `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor8c\**`.
3. Checklist: every item of `docs/art/cast-checklist.md` incl. planted feet (`project/dev/cast/cast_feet.gd`,
   `tools/art/cast_feet.py` / `cast_feet.mjs`) at both pitches; the row in `docs/art/cast-audit.md`. `enabled: true` only if
   every item passes; otherwise `enabled: false` and list the fails. Never ship a half character.
4. Evidence to `C:\Users\kazda\kiro\gtai-masters\n28\cast\`: `contractor_beside_64ppm_tilt{70,55}.png` (beside the patrol cop and Rivet, front three-quarter and back,
`project/dev/cast/cast_lineup.gd`), `contractor_fire_64.png` (four attack columns, down-right, 64 and 32 px/m),
`contractor_close_64.mp4` (walk, aim, fire, hit, fall with the hat and gun dropping; 15 to 40 s, 1920x1080, 60 fps; ffprobe),
`contractor_fight_32.mp4` (32 px/m tilt 70, Rivet against three contractors, card on, dev scene under `project/dev/cast/`). Look at every frame you deliver. Append entries to `frames.json` there (valid JSON array).
5. Commit, then `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Numbers that bounced work last night (measure and quote every one before `enabled: true`)
- **Body jump between consecutive rendered frames** on walk, a stop, a turn AND a reversal (aim one way, step the other;
  extend `test_cast_walk_reversal.gd`). Bar <= 12 px at 32 px/m; planted sole <= 2 px; right and down-right, 70 and 55.
- **Drawings per second** per gait (5 to 10; above 12 reads as a flicker).
- **The 64 px/m edge measure** (dark pixels outside the silhouette, `tools/art/cast_mulroney_edge.py`) on EVERY state's sheet.
- **Size**: px at 32 px/m 70 degrees for him, the patrol cop and Rivet; never taller than Rivet.
- Before/after at the same tick and zoom (`<name>_before_after_32.png`: today's look / the card) for the owner.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/contractor_*`, `project/data/tables/cast_cards.json` (+ its schema),
`project/features/characters/cast_*.gd`, `street_*cards*.gd`, `project/features/combat/squad/foe_cast_view.gd`,
`foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`, `tools/art/**` (cast tools), `tools/film/**` (new files only), `docs/decisions.md` (append one line at a time), `project/tests/unit/test_cast_*.gd`
(+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n28 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor\**`.
**Forbidden**: `project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`, `project/features/player/**`,
`rivet_*` art, `input_actions.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `fx_atlas.png`, `weapon_fx_electro.gd`, the deflect VFX, `project/dev/gauntlet/**`, `tools/gauntlet/**`, `rivet_motion.json`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, every other character's shipped art. No image generation in this call. Rendering only: replay digests, quest 1 and prologue tapes must not move.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path; never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend or
rebase; never push. `--import` after new art/scripts before committing; commit `.uid`/`.import` with their source.
`node tools/gate/quick.mjs` before each commit (if red on something you did not touch, reproduce on `d0ab9d03a` and say so).
**Fix lint and format findings in your own edit and go on.** `node tools/tests/run_unit.mjs --changed`. Replay digests,
quest 1 and prologue tapes must not move (rendering only). Never fake a number or a frame.

## Report at the end
Commits (sha + subject), the sheet and frame names, any entry the yard lane must call (exact signature), what the yard lane
must change, the checklist row, mutate score, quick gate, evidence paths, and what you could not do.

## Added 19:25 (director, session 4): scope of the FIRST contractor call and lessons from tonight
- **Never run `Godot_*.exe` directly** (not even `--import`): use `tools/dev/run.mjs`, the film tools, gate, mutate, or
  `node -e` with `runGodot` from `tools/lib/godot.mjs`. `tools/godot/check.mjs` does NOT reimport art (a stale import showed old
  art to the gunner call). Fold takes into as few Godot launches as possible (8 GB RAM cap for the whole run).
- **Read first** the gunner's n28 commits (`git log --oneline d0ab9d03a..HEAD`): `CastGunnerAnchors`, `tools/art/cast_gunner_*`,
  `project/dev/cast/cast_gunner_*`, `tools/film/cast_gunner_films.mjs` are the newest worked example of the whole path
  (8-drawing anchored walk, poses/rim/shadow harness in one launch, ink tool, 1080p films). Copy that path; do not invent a
  second mechanism.
- **Hat colour bar (director, owner's "white hat")**: the sheets draw the hat cream with a pinkish cast. Measure the hat's mean
  HSV on the cut walk (hat mask: the top cap region above the face, alpha >= 128, excluding ink with max RGB < 60). Pass:
  saturation <= 0.12 and value >= 0.78 (reads white, dirty is fine). If it fails, add ONE tone pass in the cutter that pulls
  only the hat pixels toward neutral off-white (same transform on every sheet, both pitches; the vest, skin and lamp untouched)
  and quote before/after HSV. Vest: pale lemon, hue 50-62 deg; it must not read orange/amber (hue < 45) on the live frame.
  Head lamp: a small warm dot is allowed (heat/light), not red.
- **First call scope** (if launched with less than 80 min to its hard stop): steps 1-2 (cut all eight sheets + the ten 8c walk
  sheets, `.import`, provenance; row `contractor` in `cast_cards.json` `enabled: false`, 8-drawing anchored walk wired), the
  feet numbers (`cast_feet.mjs` right/down-right 70/55, drawings/s, turn/reversal), size at 32 px/m beside patrol/Rivet, ink,
  hat/vest palette, cut check, and the audit rows. Commit each. Films and the live rim/shadow/tell/hit/fall pass are the next
  call: leave a resumable state note in `docs/art/cast-audit.md` (which points are measured, which are open).
- Builders claimed things about frames tonight that were false (the gunner's "one rifle"). Look at every frame you deliver
  (Read the PNG) and describe it in your report. The fall cells must keep the dropped hat and gun as separate pieces; for the
  gunner the game spawned a pickup rifle on death: check whether the contractor's `rifle` drops a `GroundRifle` too
  (`CombatArena.rifle_drops`); if it does, the fall cells draw the body and the hat only (the pickup is the one gun), exactly
  as `4960c33d6` did for the gunner.
- **This call (launched 19:52, 35 minutes): step 1 ONLY.** Cut and pack the eight sheets and the ten 8c walk sheets (the
  4-drawing walk, attack, hit, fall + `contractor_planted8_armed_walk.png`, both pitches), the hat/vest palette measure (and the
  hat tone pass if it fails), cut check (zero green/magenta-leading opaque px), `--import` through runGodot, `.import` files,
  provenance lines; commit by 20:05-20:12. Look at every packed sheet on grey (Read the PNG) and describe it in the report
  (hat colour, dropped hat/gun in the fall, any key holes). No `cast_cards.json` row, no wiring in this call: the next call
  (20:45) does step 2 onward. Leave a short state note at the end of `docs/art/cast-audit.md` ("Contractor, n28: state").
- **Call 2 (launched 20:00, hard stop 20:27, start the commit by 20:15): step 2.** Step 1 is `930b3b9f3` (read its audit
  state note; hit/fall ship as `contractor_cast_hit/fall.png` because quest 1 reads `contractor_hit/fall.png`: keep it so).
  Add the `contractor` row to `cast_cards.json` with `enabled: false`, wire his 8-drawing walk on the anchored placement
  (a `CastContractorAnchors` table measured from `contractor_planted8_armed_walk.png` by a `tools/art/cast_*_soles.py`, the
  way `CastGunnerAnchors` / `CastLancerAnchors` are; STEP_M for 5-10 drawings/s at 3 m/s), a `test_cast_contractor.gd`
  (row off = today's drawing unchanged; anchored table shape), `--import` through runGodot, `run_unit.mjs --changed` green,
  commit. Then, if time is left before 20:15, run `cast_feet.mjs` for him (right/down-right, 70/55) and append the numbers to
  his audit state note in a second commit. If not green by 20:15, commit nothing half-made: leave it uncommitted and list
  the paths (the 20:45 call continues them).
