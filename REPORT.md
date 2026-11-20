# n20 lane `kerf`: Kerf becomes the Gantry Wraith (REPORT)

Branch `n20-kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, cut from `int-n20` `a3eb0bf78`, merged
`n20-flight` four times (69431c358, 91af03d90, d0ba3b4c8, 3a63413ff). Director: Opus 5.5; builder: GPT-6.2 Astra. Films and stills are in
`C:\Users\kazda\kiro\gtai-masters\n20\kerf\` (frames.json first entry: game beside plate).
Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png`.

Final gate: TBD (line + gate.json path).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Body: legless cutter-dart, one body in tilt 70, tilt 55 and top view; lens = eye, cable loops = hackles, nose = face | `kerf_plate_vs_game.png`, `body_contact_sheet.png`, `body_scale_32ppm.png`, `kerf_creature_32.png` | cruise hull 190 px (70) / 191 (55) / 191 (top) at 64 px/m; was 140 vs 185 before 7b8d88100 |
| 2. Flight: dart hover, three beams = three blink charges, long and straight at speed, short at rest; sharp turns | `kerf_move_32.mp4`, `kerf_turn_64_t163.png`, `kerf_tilt55_32.mp4` | `ghost_hover.json` kerf row lag_ticks 1, bank_deg 12 (f6a830612) |
| 2b. Idle is the wind-up: poised, lens + nose laid on the aim line to a locked target, both views | `kerf_creature_32.png`, `kerf_creature_before_after_32.png` | 7f009c5b0 (view only) |
| 3. Blink-slice: press tick shows after-image (pre-blink pose, teal wash 35 %), one straight slot, Kerf already past, guard whole and standing, no star/streak | `kerf_attack_32.mp4`, `slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_strip_64.png` | sim resolves on the press tick unchanged; replay/city/quest bytes identical (JOURNAL 01:44, 02:46, 03:21) |
| 3b. Legacy look untouched | `kerf_attack_32_legacy.mp4`, `slice_strip_legacy_32.png` | 14/14 legacy frames identical (03:21) |
| 4. HUD chip: spectral face | `kerf_hud_chip.png`, c3e83779f | flight loader 4362c8109 |
| 4b. Transformation in/out: Kerf and beams fade through flight's morph, no legacy frame, no double body | `kerf_transform_strip_32.png`, `kerf_morph_32.mp4` | 402 frames per view, 0 overlaps / legacy parts / stray echoes (2827defd9) |
| 4c. Hit reaction: hull + beams lean together, lens flinches | `kerf_hit_strip.png` | 12 deg at hit, 5.88 at +3, 0.48 at +8, 0 at +15; lens closed 6 ticks |
| Tests / mutate | JOURNAL | full GUT 3252/1/2 before the guard (see What does not); scenarios 65/65; mutate kerf_echo 48/59, kerf_victim 18/18, kerf_spectral 15/18 changed lines + 41/52 sample, kerf_hit path 11/13 |

## What does not
- **The kerf look row stays `legacy`.** The spectral Kerf is complete (body, flight, blink, slice, transform, hit, chip) and filmed in both tilts. The flip failed one check: `project/tests/unit/test_ghost_card.gd:92` (flight's) asserts Kerf's legacy card as the default. With the flag `--ghost-look=spectral` everything shown here is reachable. Flipping is one value in `project/data/tables/ghost_forms.json` plus pinning that test to legacy (flight's merge note).
- `project/tests/unit/test_ghost_flight_hosts.gd:114` (flight's, b0f2629c1) crashed on this branch after the merge (Kerf's own body has no `drawn.sprite()`); guard TBD.

## What blocked or slowed you
- quick.mjs Godot parse check false FAIL on `project/features/combat/kills/*` (depended-scripts cascade): ~6 min, worked around with `--no-godot` + `run_unit.mjs --changed`.
- Root `JOURNAL.md` tracked on n20-flight vs untracked here: Astra's merge refused, ~3 min (films 1 abandoned).
- Astra resume calls spend most of their time re-shooting strips and full mutate runs (slicefix 61 min for four fixes; form ~75 min).
- Flight's new arena-gait test vs kerf's own body: merge-induced red, found 05:44, ~15 min.

## Calls for the owner
1. **Victim call sites in combat/kills** (night rule "one-line call site"): `project/features/combat/kills/kill_marks.gd:50`, `kill_split_fx.gd:110`, `kill_view.gd:142` route the spectral Kerf kill through `KerfVictim` (no star, no streak, victim whole to press +4). Legacy untouched. Accept, or move into a shared hook. Still: `slice_strip_top_32.png`.
2. **Hooked cable ends under the tail in tilt** (`kerf_creature_32.png`): they give him "character" but sit low; cut them if they read as legs.
3. **Flip Kerf to spectral by default?** Everything is filmed and green behind the flag; only the shared card test needs pinning. Recommend yes at the morning merge.
4. **Speed curl on Kerf's vapour wake** (flight 696862ee0): accepted, because on the plate the smoke wavers around straight beams. Kerf's own beams stay ruler-straight.

## Merge notes
- Root `JOURNAL.md` is per lane; keep kerf's copy (flight's travelled in with the merge).
- `ghost_hover.json`: the kerf row from this branch wins (lag 1 / bank 12); flight's schema and defaults win.
- `ghost_forms.json` kerf row: `legacy` (see Calls 3).
- `project/tests/unit/test_ghost_flight_hosts.gd` `_drive_arena`: dent, tonnage and kerf each guard the null sprite; kerf's lines are tonnage's (`if not drawn.own_body:`), dent's differ: take one.
- merge-clash warned that `project/tests/unit/test_ghost_look.gd` conflicts with n20-ohm (flight's file and ohm's lines, came in with the flight merge).

## Next steps
- TBD

## Astra ledger
| Call | Minutes | Result |
|---|---|---|
| body | 19 | accepted |
| wire | 28 | accepted |
| slice | 35 | accepted |
| slicefix | 59 | accepted |
| victim | 34 | accepted |
| films | 1 | abandoned (merge refused) |
| films2 | 29 | accepted |
| form | 69 | accepted |
| finish | 31 | accepted (row left legacy) |
| guard | TBD | TBD |

What I would brief differently: TBD
