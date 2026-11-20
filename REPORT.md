# n21 lane `kerf`: Kerf becomes the Swarf Ronin (REPORT)

DRAFT (session 3, 15:10): sections marked PENDING are filled at the report time.

Branch `n21-kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, cut from `int-n21` `ad87caa17`. Director: Opus 5.5;
builder: GPT-6.2 Astra. Films and stills: `C:\Users\kazda\kiro\gtai-masters\n21\kerf\` (`frames.json`, first entry the
game beside the plate). Plate: `C:\Users\kazda\kiro\gtai-masters\n21\concepts\kerf_b.png`.

Final gate: PENDING (`node tools/gate/run.mjs --rev=HEAD`, line + `gate.json` path).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Body: legless person (wedge helmet, slit lens, plates, two crescent blade forearms, S swarf ribbon with punched holes) in tilt 70, tilt 55 and the top view; drawn from Opus-written prompts, keyed on magenta | `kerf_plate_vs_game.png`, `kerf_guard_32.png`, `body_scale_32ppm.png`, `kerf_poses_64.png` | 4 tilt atlases (fly + act, 70 and 55) + 1 top part sheet; profile helmet 90 px (70) / 77 px (55) = Dent's scale (f96b2f2e7, 0c312d279) |
| 2. Flight: HOVER upright with raised blades, CRUISE tipped forward with blades swept back, TURN held 5 ticks above 360 deg/s, top view a swallow with both crescents behind the shoulders | `kerf_move_32.mp4`, `kerf_move_before_after_32.png` | hover row unchanged (lag 1, bank 12); overhead arms 45 deg at rest, 50/25 in a turn, 55 on a hit (e0fbe9815) |
| 3a. Blink charges shown on the body: three chest slots front, three back-plate slots behind and from the top; spent dark, relit in the last 4 recharge ticks | `charges_3views_64.png` | mutate `kerf_charge_slots` 17/20 |
| 3b. Blink-slice re-fitted, n20 read kept: after-image in the pose he left (35 %), one straight slot with sparks off the victim, Ronin past with the cutting crescent forward, victim whole on the press tick and drawn above the Ronin until +30 | `slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_before_after_top_32.png`, `kerf_attack_32.mp4`, `kerf_close_64.mp4` | quest1_kerf / ghost_attacks / replay_60s byte-identical before/after (replay final `cbeb734f...`), parity 1200 exact, bake 256/256; mutate `kerf_victim` 16/17 |
| 3c. Legacy look untouched | `slice_strip_legacy_32.png` | legacy strip SHA-256 `1a9314ef...` identical; legacy attack film byte-identical |
| 4. Rest of the form: transformation in/out, hit reaction, HUD chip (Ronin bust); Kerf's `look` row flipped to `spectral` (90f948645) | `kerf_morph_32.mp4`, `kerf_transform_strip_32.png`, `kerf_hit_strip.png`, `kerf_hud_chip.png` | morph audit 402 ticks per view clean; full unit after the flip 3368/0/2; scenarios 65/0; replay 60 s `cbeb734ff9b97c41` unchanged; parity 1200 exact; bake 256/256 |
| 5. Profile HOVER shows the far crescent behind the helmet (74304cba8) | `kerf_profile_far_blade.png` | both blades read as arms at 32 px/m in tilt 70 and 55 |

## What does not
- The owner's attack take never shows a plain blink (no target): every press in polish's `ghost_review_input.gd` finds a guard. The plain blink (4 m dash, after-image) works and shows in the reel, not in `kerf_attack_32`.
- The form card has no art of its own: it uses the same 84x84 portrait as the HUD chip (now the Ronin bust, 6a687d51a).
- The overhead CRUISE reads as an arrow more than a person (the plate's top inset is the same shape).

## What blocked or slowed you
- `tools/gate/quick.mjs` Godot parse step red on untouched `cut_rig.gd` (standalone `--check-only` cannot compile the autoload chain): quick ran with `--no-godot`; 4 min.
- Shared git index race: director files swept into Astra's commit `4cde368b5` (content correct, no amend); director commits are pathspec commits since; 3 min.
- Overhead silhouette took a second Astra call (02b, 43 min): the first rig put the upper arms 90 deg off the spine (a star, not a swallow).

## Calls for the owner
- 70-degree ACTION sheet accepted as drawn: in the toward-facing COCK/RECOVER/BLINK cells the crescent tips droop (each lives at most 16 ticks with the blades moving). Re-roll is one sheet job. Kept; judge it in `kerf_attack_32.mp4`.
- Fly HIT cells are nearly the HOVER pose; the hit reads through the 12-degree lean, the flinch and the helmet snap (`kerf_hit_strip.png`).
- CRUISE from the top reads as an arrow more than a person (the plate's own top inset is that shape too).
- Kerf's attack take (polish's `ghost_review_input.gd`) never shows a plain blink: every press finds a guard (NEED polish written 14:47).

## Merge notes
- Kerf files only, plus one view-only line set in `kerf_stage.gd` (`trail_radius`, not serialized: no digest moves) and append-only lines in `docs/decisions.md` and `steam/ai-provenance/2026-11.jsonl`.
- polish's 1123a9881 edited `project/dev/ghost-powers/kerf_beat.gd` (moved `_nearest` into `GhostReel.nearest`); kerf has no commit on that file, so the merge takes polish's side cleanly. Polish planned to restore it to the int-n21 content; either way it merges.
- Kerf's row in `ghost_forms.json` is now `spectral`: after the merge, re-run the full unit suite (both lanes touched ghost tests) and the scenarios.

## Next steps
- Re-roll the 70-degree ACTION sheet's toward-facing COCK/RECOVER/BLINK cells so the crescent tips stay swept back (one sheet job).
- A distinct fly HIT cell (blades flung open, helmet snapped back) instead of the HOVER-like one.
- Polish: give Kerf's attack take one press with no guard in reach so the owner sees the plain blink.

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
| 8 | polish05 | PENDING | | 74304cba8 |

What I would brief differently: PENDING.
