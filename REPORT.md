# n20 lane `kerf`: Kerf becomes the Gantry Wraith (REPORT)

Branch `n20-kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, cut from `int-n20` `a3eb0bf78`, merged
`n20-flight` twice (69431c358, 91af03d90 TBD-third). Director: Opus 5.5; builder: GPT-6.2 Astra. Films and stills are in
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
| Tests / mutate | JOURNAL | unit 3232/0/2; mutate kerf_echo 48/59, kerf_victim 18/18, kerf_spectral TBD |

## What does not
- TBD (look row; transform/hit strips)

## What blocked or slowed you
- quick.mjs Godot parse check false FAIL on `project/features/combat/kills/*` (depended-scripts cascade): ~6 min, worked around with `--no-godot` + `run_unit.mjs --changed`.
- Root `JOURNAL.md` tracked on n20-flight vs untracked here: Astra's merge refused, ~3 min (films 1 abandoned).
- Astra resume calls spend most of their time re-shooting strips and full mutate runs (slicefix 61 min for four fixes; form ~75 min).
- TBD

## Calls for the owner
1. **Victim call sites in combat/kills** (night rule "one-line call site"): `project/features/combat/kills/kill_marks.gd:50`, `kill_split_fx.gd:110`, `kill_view.gd:142` route the spectral Kerf kill through `KerfVictim` (no star, no streak, victim whole to press +4). Legacy untouched. Accept, or move into a shared hook. Still: `slice_strip_top_32.png`.
2. **Hooked cable ends under the tail in tilt** (`kerf_creature_32.png`): they give him "character" but sit low; cut them if they read as legs.
3. TBD

## Merge notes
- Root `JOURNAL.md` is per lane; keep kerf's copy (flight's travelled in with the merge).
- `ghost_hover.json`: the kerf row from this branch wins (lag 1 / bank 12); flight's schema and defaults win.
- `ghost_forms.json` kerf row: TBD.

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
| form | TBD | TBD |
| finish | TBD | TBD |

What I would brief differently: TBD
