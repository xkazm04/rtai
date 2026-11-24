# Brief n26-cast-04-cop8: the patrol cop's 8-drawing walk (and run), planted at a sane cadence

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop 14:45 local** (check `date`). **Commit deadline 14:30.** After it: stills, clip and your report only.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Why
Your feet-hop call (commits d0e794f9a, dcc149b0a, 2bb114c46) planted the patrol cop with the 4-drawing sheet, but only at
`STEP_M` 0.135 m (`project/features/characters/street_cop_walk.gd`): 23.7 drawings/s on the 3.2 m/s wave walk and
**49.26 drawings/s** on the 6.65 m/s retreat. That strobes; it is not owner-ready. Four drawings per stride cannot give planted
feet, a small hop and a sane cadence together. The director had the cop redrawn with EIGHT drawings per stride.

## Source sheets (director-generated with Codex image_gen, accepted; do not regenerate)
`C:\Users\kazda\kiro\gtai-art\foes-n26\cop8\out\cop8_armed_walk_{70,55}_{a,b}.png`: chroma green #00B140; `_a` = 3 facing
bands (down, down-right, right), `_b` = 2 bands (up-right, up); 8 figures per band, one stride:
(1) L heel contact, (2) L flat, (3) passing, (4) R reaching, (5) R heel contact, (6) R flat, (7) passing, (8) L reaching.
Support foot is L in 1-3, R in 5-7. Prompts: `cop8/jobs.json`. The 70 sheets are a greyer navy than the 55 pair: tone them
to the shipped patrol navy like your earlier cut (`tools/art/street_tone.py`).
A RUN sheet set may also exist by the time you read this: `C:\Users\kazda\kiro\gtai-art\foes-n26\cop8run\out\cop8_armed_run_{70,55}_{a,b}.png`
(same layout; (4) and (8) are airborne). Use it for the fast gaits ONLY if all four files exist and you judge them the same
officer; otherwise ignore it and say so.

## Build, in order
1. Cut the eight-drawing walk into `project/features/characters/art/view/{p70,p55}/cop_patrol_planted8_armed_walk.png`
   (+ `.import`), same figure scale as the shipped patrol (scale by body height, not cell), key-clean, toned, one provenance line
   per shipped PNG (`steam/ai-provenance/2026-11.jsonl`, prompt ref `gtai-art/foes-n26/cop8/jobs.json#<job>`). Keep cut
   intermediates in `C:\Users\kazda\kiro\gtai-art\foes-n26\cop8\pack\`.
2. Generalise the patrol `Contact` placement to N drawings per stride with a per-facing, per-drawing support-sole anchor TABLE
   measured from the cut art by the cutter (data the tool writes, not hand numbers), so the support sole stays pinned
   through drawings 1-3 / 5-7 and the re-anchor happens at the contact change. Choose `STEP_M` from the art's own measured
   torso advance per drawing (target ~0.175 m; the body jump comes from the gap between STEP_M and the drawn advance). The
   4-drawing path must remain selectable with ONE value (a const or table key naming the strip and its drawing count) so the
   director can switch back. Keep it scoped to the patrol cop (near rig, far/quest cards, wave cards).
3. If the run sheets are used: above a speed threshold (one named constant, start at 4.0 m/s) the cop draws the run cycle with
   its own `STEP_M` measured the same way. Without a run sheet: report the retreat's drawings/s honestly.
4. Re-run `node tools/art/cast_feet.mjs` for the patrol: every gait (city 1.4, wave 3.2, arrival 3.8, retreat 6.65), 70 and 55,
   right and down-right, incl. the quest card and the tall actor scale 1.16 your last report flagged (16.11 px). Table =
   sole px / body jump px / **drawings per second** per gait. PASS needs sole <= 2 px and jump <= 12 px at 32 px/m. Record the
   cadence in the audit; the director judges > 24 drawings/s as strobing. Update `docs/art/cast-audit.md` "Planted feet, n26".
5. Unit tests for the N-drawing placement (`test_cast_patrol_feet.gd`), `node tools/tests/run_unit.mjs --changed` green,
   `node tools/gate/quick.mjs` before each commit. Commit: art + provenance; placement + tests; audit table.
6. `node tools/mutate/mutate.mjs --file=project/features/characters/street_cop_walk.gd --max=20 --lines=<changed lines>`; quote it.
7. Evidence (look at every frame you deliver): replace `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_cop_patrol_before_after_64ppm_tilt{70,55}.png`
   (before = `0779185ac`, after = your tree, same tick and zoom, sole dots per rendered frame, contact bracketed) and
   `feet_cop_patrol_before_after_32.mp4`: the owner's film this time, so make it read: before left / after right, the cop
   walking then running on a metre grid, each panel at 32 px/m but with a 64 px/m inset of the feet, and the support-sole
   track drawn as dots on the ground in both panels; 15 to 40 s, 1920x1080, 60 fps (ffprobe it).

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/cop_patrol_*`, `project/features/characters/street_*.gd`,
`project/features/characters/cast_*.gd`, `project/features/arena/arena_wave_cards.gd` (smallest edit),
`project/features/combat/squad/foe_*card*.gd`, `project/dev/cast/**`, `tools/art/**`, `tools/film/**` (new files only),
`project/tests/unit/test_cast_*.gd` (+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`,
`steam/ai-provenance/2026-11.jsonl` (append), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line, then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n26\cop8\**`, `cop8run\pack\**`.
**Forbidden**: `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art, `input_actions.json`,
`project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`, `combat.json`, `enemies.json`,
`weapons.json`, `bosses.json`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`. Do not touch Mulroney's or the warden's files.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path; never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend or
rebase; never push. `--import` after new art/scripts before committing; commit `.uid`/`.import` with their source.
**Fix lint and format findings in your own edit and go on.** Replay digests, quest 1 and prologue tapes must not move
(rendering only). Never fake a number or a frame.
Pre-commit hook: the director ran `node --test tools/film/kill_reel_life.break.test.mjs` alone at 12:40 on this branch: 8/8 pass
(2.8 s). So it is not a plain pre-existing failure; it fails inside the hook (load or env). Find out why in at most 10 minutes
(run the hook's own command line by hand, read the ERR_INVALID_ARG_TYPE stack). If the cause is outside your allowlist, you may
bypass the hook ONLY when that test is its sole failure, with the body line `hook-bypass: kill_reel_life.break.test.mjs <one-line cause>`,
and append ONE line to `docs/decisions.md` (allowed for this line only):
`- [2026-11-23] DEVIATION <hook rule id from STANDARDS.md> n26 cast: <cause>; commits <shas>; re-check when <trigger>.`

## Report at the end
Commits (sha + subject), STEP_M chosen and why, the full table with drawings/s, whether the run sheet was used, the switch
back to 4 drawings (exact name and value), mutate score, quick gate, evidence paths, what you could not do.
