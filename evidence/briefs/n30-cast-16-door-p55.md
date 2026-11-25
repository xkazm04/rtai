# n30-cast-16: door carrier eight, p55 round (tag `c16`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `evidence/briefs/n30-cast-05-door-eight-edits.md` (the method,
the image tool, the splice) and `C:\Users\kazda\kiro\gtai-art\foes-n30\door8c\STATE.md` (state: 3 accepted edits, tools/).
Launched ~15:05. Image round done by 15:40. Commit by 16:00. Hard stop 16:10 (report and END).

## Where it stands (read, do not re-derive)
`docs/art/cast-audit.md` "## Door eight with three more edits, n30": the eight passes both bars at p70 but p55 blocks.
The owner's rule: `CastDoorAnchors.WALK = EIGHT` only if the eight beats the four in EVERY facing (sole and jump both <=
the four's, or both within the bars sole <= 2, jump <= 12). Numbers (tool's 32 px/m unit):
- p55 right: four 2.03 / 5.09; eight 2.15 / 7.69: jump 7.69 on 7 -> 8, sole 2.15 on contact 5-8.
- p55 down-right: four U / 10.43; eight 3.06 / 11.93: jump 11.93 on 4 -> 5 (7 -> 8 now 9.14), sole 3.06 on 5-8; drawing 8's
  rear boot still ~13.5 sheet px behind drawing 4's in x (the n30 edit fixed depth, not x).
- p70 both pass (do not touch p70).
Culprit probe: `build/look/n30-c05/probe.py` over the takes (per drawing jump and slide).

## Do
1. (10 min, no Godot) From the anchors (`EIGHT55`) and the probe, decide the fewest one-row edits that can make p55 right
   reach jump < 5.09 and sole < 2.03, and p55 down-right reach sole <= 2 and jump <= 10.43. Write the plan with the numbers
   (which drawing, which boot, which direction, how many sheet px and source px) into the round's STATE.md under "## c16".
   If the plan needs more than 5 edited cells, or a jump no single-cell edit can fix, write that and do only the cells
   that move the furthest-off number.
2. Image edits, ONE drawing per job, new round dir `C:\Users\kazda\kiro\gtai-art\foes-n30\door8d\` (copy door8c's tools/
   and jobs.json as the template; Ref 1 = the CURRENT accepted source row incl. the n30 splice, Ref 2 = the shipped four
   sheet). Calibrate the ask: builder c13 (pile-driver) found a bare "N px back" overshoots by ~50 %, and x held best when
   the target was anchored to a drawn landmark in the same cell ("the boot centre under the rear edge of the X"): name one.
   At most 8 images in total. Known stall: copy the image from `~/.codex/generated_images/<session>/` by hand (find the
   session with `grep -l door8d ~/.codex/sessions/2026/11/25/rollout-*.jsonl`); never wait 900 s. Usage-limit answer:
   stop, `BLOCKED images`. Splice only the edited cell; other cells silhouette xor 0; LOOK at a 2x crop N-1 | N | N+1.
   Provenance line per accepted image (door8c format, tools/prov.py).
3. Cut (`REDRAWN` / `REDRAWN_CELLS` in `tools/art/cast_door_eight.py`; every other sheet cell byte-identical), anchors
   (`tools/art/cast_door_soles.py`), import (`run_unit --select=test_cast_door` imports first), lane lock, then
   `node tools/film/cast_door_films.mjs build/look/n30-c16/feet feet`. Table: four / eight n30 (da11ce846) / eight c16.
4. Commit rules:
   - The eight c16 beats the four in every facing: commit art + .import + tool + anchors + provenance (pathspec), then a
     SEPARATE commit `WALK = EIGHT` (generator `--walk`), `run_unit --select=test_cast_door` green first; 64 px/m still
     `door8_p55_64.png` (film tool `stills`) + 32 px/m `door8_walk_32.mp4` (15-40 s, ffprobe) to masters + frames.json entries.
   - The eight c16 improves a blocking number and makes none worse: commit the art (WALK stays FOUR).
   - Otherwise: commit nothing in the repo except provenance lines marked "not shipped"; leave the splices in door8d.
   Append "## Door eight, p55 round, n30" (plan, table, verdict) to `docs/art/cast-audit.md` (commit, pathspec) in every case.

## Allowlist
`C:\Users\kazda\kiro\gtai-art\foes-n30\door8d\**` (new), `tools/art/cast_door_eight.py`, `tools/art/cast_door_soles.py`,
`project/features/characters/cast_door_anchors.gd` (generated), the door walk sheets it writes (+ `.import`),
`project/tests/unit/test_cast_door*.gd` (only counts that follow WALK), `docs/art/cast-audit.md` (append),
`steam/ai-provenance/2026-11.jsonl` (append), `build/look/n30-c16/**`, masters files. Do NOT touch `tools/film/cast_war*`,
`cast_flash_fight*` (builder c14 works there). Anything else: NEED.

## Report
Images used, the plan, the table, the verdict and why, commits, stills and what you saw, every command's result line.
