# n21 lane `kerf`: Kerf becomes the Swarf Ronin (REPORT)

Written sessions 4 to 7 (last edit 18:33). The `--reels` gate on `b045d75e5` (code still `2b38c1353`) was started at 18:31 after the freeze; its result goes into JOURNAL session 7 (out `masters:n21/kerf/scratch/s7_gate_reels.txt`). Until then the 17:07 gate below is the standing verdict.

Branch `n21-kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, cut from `int-n21` `ad87caa17`. Director: Opus 5.5;
builder: GPT-6.2 Astra. Films and stills: `C:\Users\kazda\kiro\gtai-masters\n21\kerf\` (`frames.json`, first entry the
game beside the plate). Plate: `C:\Users\kazda\kiro\gtai-masters\n21\concepts\kerf_b.png`.

Final gate (17:07, last code commit `2b38c1353`, gated at `40378a1c7`): `gate: PASS` - lint 19/19 over 1805 files; unit 3369 passed / 0 failed / 2 skipped; scenarios 65 passed; parity 1200 steps bit for bit (planted mutation caught at step 629); selftest look goldens 11/11, block goldens 5/5; export-audit 816 loaded / 0 failed. `build/gate/40378a1c74cc/gate.json` (git-ignored, local). The earlier gate on `118872760` (code `c14ae6f97`) also passed: `build/gate/118872760ea2/gate.json`.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Body: legless person (wedge helmet, slit lens, plates, two crescent blade forearms, S swarf ribbon with punched holes) in tilt 70, tilt 55 and the top view; drawn from Opus-written prompts, keyed on magenta | `kerf_plate_vs_game.png`, `kerf_guard_32.png`, `body_scale_32ppm.png`, `kerf_poses_64.png` | 4 tilt atlases (fly + act, 70 and 55) + 1 top part sheet; profile helmet 90 px (70) / 77 px (55) = Dent's scale (f96b2f2e7, 0c312d279) |
| 2. Flight: HOVER upright with raised blades, CRUISE tipped forward with blades swept back, TURN held 5 ticks above 360 deg/s, top view a swallow with both crescents behind the shoulders; the overhead trail ends at the painted ribbon (c14ae6f97) | `kerf_move_32.mp4`, `kerf_move_before_after_32.png`, `scratch/brief05/overhead_before_after.png` | hover row unchanged (lag 1, bank 12); overhead arms 45 deg at rest, 50/25 in a turn, 55 on a hit (e0fbe9815) |
| 3a. Blink charges shown on the body: three chest slots front, three back-plate slots behind and from the top; spent dark, relit in the last 4 recharge ticks | `charges_3views_64.png` | mutate `kerf_charge_slots` 17/20 |
| 3b. Blink-slice re-fitted, n20 read kept: after-image in the pose he left (35 %), one straight slot with sparks off the victim, Ronin past with the cutting crescent forward, victim whole on the press tick and drawn above the Ronin until +30 | `slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_before_after_top_32.png`, `kerf_attack_32.mp4`, `kerf_close_64.mp4` | quest1_kerf / ghost_attacks / replay_60s byte-identical before/after (replay final `cbeb734f...`), parity 1200 exact, bake 256/256; mutate `kerf_victim` 16/17 |
| 3c. Legacy look untouched | `slice_strip_legacy_32.png` | legacy strip SHA-256 `1a9314ef...` identical; legacy attack film byte-identical |
| 4. Rest of the form: transformation in/out, hit reaction, HUD chip (Ronin bust); Kerf's `look` row flipped to `spectral` (90f948645) | `kerf_morph_32.mp4`, `kerf_transform_strip_32.png`, `kerf_hit_strip.png`, `kerf_hud_chip.png` | morph audit 402 ticks per view clean; full unit after the flip 3368/0/2; scenarios 65/0; replay 60 s `cbeb734ff9b97c41` unchanged; parity 1200 exact; bake 256/256 |
| 5. Profile HOVER shows the far crescent behind the helmet (74304cba8) | `kerf_profile_far_blade.png` | both blades read as arms at 32 px/m in tilt 70 and 55 |
| 6. Plain blink in the owner's attack take (polish served kerf's NEED in `25ffc58cd`; filmed session 5): 4 m dash, after-image in the HOVER pose he left, one straight line, Ronin past in CRUISE, no victim | `kerf_plain_blink_strip_32.png`, `kerf_attack_32.mp4` (frame 275) | press -1 / press / +3 / +15 at 32 px/m, tilt 70 and top |
| 7. Owner Call built as an off flag: `--kerf-cruise-wings=open` (overhead CRUISE 62/40 instead of 43/20), default unchanged (2b38c1353) | `call_cruise_wings_open.png` | `--changed` 3353/0/2; lint 19/19; debt `files_past_soft_cap` 66 -> 64 (one `KNOWN_FLAGS` line accepted); mutate `kerf_ronin_top` changed lines 4/4 |

## What does not
- `kerf_attack_32.mp4` with the plain blink was shot on a film-only commit (`35a611453` = this branch + polish's `25ffc58cd`), not on this branch: until both lanes merge, re-shooting the film from `n21-kerf` alone drops the plain blink again.
- The form card has no art of its own: it uses the same 84x84 portrait as the HUD chip (now the Ronin bust, 6a687d51a).
- The overhead CRUISE reads as an arrow more than a person (the plate's top inset is the same shape).

## What blocked or slowed you
- `tools/gate/quick.mjs` Godot parse step red on untouched `cut_rig.gd` (standalone `--check-only` cannot compile the autoload chain): quick ran with `--no-godot`; 4 min.
- Shared git index race: director files swept into Astra's commit `4cde368b5` (content correct, no amend); director commits are pathspec commits since; 3 min.
- Overhead silhouette took a second Astra call (02b, 43 min): the first rig put the upper arms 90 deg off the spine (a star, not a swallow).

## Calls for the owner
- 70-degree ACTION sheet accepted as drawn: in the toward-facing COCK/RECOVER/BLINK cells the crescent tips droop (each lives at most 16 ticks with the blades moving). Re-roll is one sheet job. Kept; judge it in `kerf_attack_32.mp4`.
- Fly HIT cells are nearly the HOVER pose; the hit reads through the 12-degree lean, the flinch and the helmet snap (`kerf_hit_strip.png`).
- CRUISE from the top reads as an arrow more than a person (the plate's own top inset is that shape too). Side by side: `call_cruise_top_vs_plate.png` (plate top inset, game HOVER, game CRUISE, 64 px/m). The game keeps the plate's helmet-forward wedge and two side crescents, but sweeps the tips back as the lane brief asked; the plate curves them forward and down. Built as one flag, off: `--kerf-cruise-wings=open` widens the CRUISE sweep 43/20 -> 62/40 (2b38c1353, `kerf_ronin_top.gd`; default byte-identical, unit pins both). Side by side at tick 118, 12 m/s, 64 and 32 px/m: `call_cruise_wings_open.png`. Director's read: open breaks the arrowhead and shows two arms, but the two crescents start to join into one bow; default kept. Your pick flips it (one line in `cruise_sweep`).

## Merge notes
- Kerf files only, plus one view-only line set in `kerf_stage.gd` (`trail_radius`, not serialized: no digest moves) and append-only lines in `docs/decisions.md` and `steam/ai-provenance/2026-11.jsonl`.
- polish's 1123a9881 edited `project/dev/ghost-powers/kerf_beat.gd` (moved `_nearest` into `GhostReel.nearest`); kerf has no commit on that file, so the merge takes polish's side cleanly. Polish planned to restore it to the int-n21 content; either way it merges.
- `tools/debt/baseline.json` (2b38c1353, `--accept-regression` for one `KNOWN_FLAGS` line) and `project/boot/launch_args.gd` (one appended flag): on a baseline conflict with polish run `node tools/debt/merge_baseline.mjs`, commit, then `--update`.
- Kerf's row in `ghost_forms.json` is now `spectral`: after the merge, re-run the full unit suite (both lanes touched ghost tests) and the scenarios.

## Next steps
- Re-roll the 70-degree ACTION sheet's toward-facing COCK/RECOVER/BLINK cells so the crescent tips stay swept back (one sheet job).
- A distinct fly HIT cell (blades flung open, helmet snapped back) instead of the HOVER-like one.
- After the merge, re-shoot `kerf_attack_32` from the merged tree (`node tools/film/ghost_films.mjs --ghost=kerf --look=spectral --takes=attack --out=...`) so the shipped film comes from a real branch.

## Astra ledger

| # | Tag | Minutes | Result | Commits |
|---|---|---|---|---|
| 1 | body | 18 | accepted | f96b2f2e7 |
| 2 | reroll (resume) | 15 | accepted | 0c312d279 |
| 3 | wire | 43 | accepted | 21f8714b8, da5260ebd, b535c478b |
| 4 | wire / topfix (resume) | 43 | accepted | e0fbe9815, 09ea98c8e, e6e5920d4 |
| 5 | attacks | 61 | accepted | bec7d3229 .. 4174e2a73 (10) |
| 6 | attacks / 03b (resume) | 20 | accepted | 56c31b555 |
| 7 | form | 37 | accepted | 6a687d51a, d20712d89, 59619e7c3, 90f948645, f6a85d2f7, e5355f75a |
| 8 | polish05 | 27 | accepted | 74304cba8, c14ae6f97 |
| 9 | cruise06 (+ 06b resume) | 17 | accepted | 2b38c1353 |

Total: 9 calls, 281 minutes, 9 accepted, 0 bounced (3 follow-ups as `--resume`: topfix, 03b, 06b).

What I would brief differently:
- State the overhead silhouette as a measurable rule in the first wiring brief (upper arms at most 50 degrees off the rear spine, both tips behind the shoulder line, a world-space tip test). Stated only as "swallow", it cost a second call (02b).
- Name the shared pieces that would cross a teleport (flight tail, vapour) in the attack brief. The zigzag tail across the 9 m jump and the vapour thread were found late, one call apart.
- Tell a brief that touches `KNOWN_FLAGS` up front that one added line trips the debt ratchet on `launch_args.gd` and how to accept it (`--accept-regression`). Without that, cruise06 stopped at a red lint and needed a second leg.
- Ask for the owner's films in the same call as each fix. The calls that re-shot their own films (03b, polish05) saved me a Godot slot.
