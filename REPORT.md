# REPORT: n20 lane tonnage: Tonnage becomes the Press Golem

DRAFT (session 4, 04:3x). Final numbers, gate line and film paths are filled in by the last session.

- Lane: `tonnage`, branch `n20-tonnage`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-tonnage`, cut from `int-n20` `a3eb0bf78`.
- Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png` (Press Golem).
- Evidence: `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\` (`frames.json` first entry = in-game still beside the plate).
- Final gate: GATE_LINE (`GATE_JSON`).

## What works

| Item | Evidence | Number |
|---|---|---|
| Body: legless Press Golem, p70 + p55 drawn cells (carry / cruise / armed / recoil + raise / pound / lift / carry, 5 facings, left mirrored), top view = rigid cut-out parts | `tonnage_plate_game_64.png`, `tonnage_rest_tilts_64.png` | spectral 312 px vs legacy 313 px tall at p70 64 px/m (size kept) |
| Spectral glow: translucent fill + halo | `tonnage_glow_64` stills | fill a 0.42, halo a 0.62 over 5.6 m |
| Flight: weighted hover (own_body on flight's mount), soft smoke column from the waist, chest vapour | `tonnage_tail_fix_rest_64.png` / `_before`, `tonnage_tail_fix_cruise_top_32.png` / `_before`, `tonnage_move_32.mp4` | tail row: width 2.15 m, fray 0.15, 2 strands, 1 wisp |
| Press slam = double-fist clap: fists rise and spread (landing marks inked through the wind-up), come down together in front, thin 4 m ring instead of a filled disk | `tonnage_raise_tilts_64.png`, `tonnage_pound_32.png`, `tonnage_attack_32.mp4` | body at 0.55 alpha on the strike: car + victims visible from the top |
| Ram = armed press fist forward from 2.4 m/s (full at 3.0), punch-through on contact; hit lean suppressed while armed; legacy ground bow retired under spectral | `tonnage_ram_lead_64.png`, `tonnage_ram_contact_64.png` | armed first tick 171, contact 259 = 88 ticks lead (brief asked >= 6) |
| HUD chip cut from our p55 front carry cell (no new image) | `tonnage_chip_hud.png` / `_legacy` | 84 px |
| Transformation: golem rises from Rivet's burst, fades in low and small, fists unfold last; out is the reverse | `tonnage_morph_strip_64.png`, `tonnage_morph_32.mp4` | mutate tonnage_morph.gd 24/(24+0) |
| 55 deg tilt: rest / raise / pound / armed / contact beside the plate | `tonnage_p55_contact_64.png` | 5 panels |
| Recoil cell kept at golem size | `tonnage_recoil_64.png` / `_before` | p70 hit 307 -> 307 px (was 261) |

## What does not

## What blocked or slowed you

- Astra session 03 (fix-films) killed at my session handover (01:44) before its report: ~75 min, films salvaged.
- Astra session 05 (smoke-flight) hit the 75-min cap without a report; the smoke column failed (fray 0.82 = spark scribbles, plus our own RamWake bow line read as a cable). Traced and fixed in 06: ~60 min lost.
- Mutate under 5-lane contention: tonnage_pose.gd 158 mutants ran 41 min unfinished; killed; later briefs used `--max=40`.
- `tools/godot/check.mjs` false-fails on unchanged files (ghost_rim.gd autoload chain), so `tools/gate/quick.mjs` was not usable; relied on run_unit + lint.

## Calls for the owner

1. **The ground bow wave is gone under the spectral look** (the owner called it "a thin bow"); the armed press fist (88 ticks before contact) is the ram tell now. One const (`RamWake.SPECTRAL_GAIN`) brings it back. Quest 1's grown-Rivet ram keeps its wave. Stills: `tonnage_ram_lead_64.png` vs `tonnage_ram_lead_64_legacy.png`.
2. **The body goes to 0.55 alpha on the slam strike** so the car and the victims under the clap stay visible from the top view (the plate draws them in front; at our camera the body covers them). Still: `tonnage_pound_32.png` vs `_legacy`.
3. **Default look**: Tonnage's row is spectral (8c3586694); `--ghost-look=legacy` or the row value brings the old hauler back. Two tests that read the legacy body are pinned to legacy (`test_tonnage_stride.gd`, flight's `test_ghost_card.gd`, flight OK).

## Merge notes

- Flight's `project/tests/unit/test_ghost_card.gd` is pinned to the legacy look on this branch (8e82e68d1, flight OK: ours wins at the merge); one guard at `test_ghost_flight_hosts.gd:114` in merge 80c27095b.
- Named one-line call site in a flight file: `ghost_form_bodies.gd` step_tonnage `tonnage.hauler = p.hauler`.
- `n20-flight` merged several times into this branch, last 6bb29c7a0 = flight final aa9ff166e (root JOURNAL.md/REPORT.md kept ours). The merge-clash hook warns that flight's `project/tests/unit/test_ghost_look.gd` conflicts with n20-ohm: a flight/ohm overlap carried in through the merge, no tonnage lines.
- `RamWake` has two callers (`tonnage_view.gd`, `boot/collect_call/view/cast_view.gd` quest 1); the spectral gate is in TonnageView only so quest 1 keeps its bow wave.

## Next steps

## Astra ledger

| # | Tag | Min | Verdict | What I would brief differently |
|---|---|---|---|---|
| 1 | body-art | 34 | accepted | ask for the back-3/4 row by name in the prompt; it drew side views twice |
| 2 | rig | 33 | accepted | forbid amend/rebase up front (it autosquashed across flight merges) |
| 3 | fix-films | ~75 | abandoned (killed at handover) | split films from code; start detached so a director handover cannot kill it |
| 4 | glow-arm | 73 | accepted | mutate `--max=40` from the start (158 serial mutants ate 41 min) |
| 5 | smoke-flight | 75 | bounced (cap) | give a target look in numbers (fray, wisps) and a stop-and-commit mark at 60 min |
| 6 | form-rest | 68 | accepted | it touched one line of flight's test (test_ghost_flight_hosts.gd:114) during a merge: name foreign test files as off-limits explicitly |
| 7 | flip | 8 | accepted (flip reverted by rule) | list every test that reads the legacy body by default BEFORE flipping; I briefed the flip without that census |
| 8 | reflip | 13 | accepted | (worked as briefed: pin tests, re-flip, full unit, then polish) |
