# REPORT: n20 lane tonnage: Tonnage becomes the Press Golem

- Lane: `tonnage`, branch `n20-tonnage`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-tonnage`, cut from `int-n20` `a3eb0bf78`.
- Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png` (Press Golem).
- Evidence: `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\` (`frames.json` first entry = in-game still beside the plate).
- Final gate: `node tools/gate/run.mjs --rev=HEAD` on `b7eeed009` (code HEAD `2d1d83ea3`; later commits are docs only) at 06:10: `gate: PASS` (lint 19/19 over 1750 files; unit 3269 passed / 0 failed / 2 skipped; scenarios 65 passed; parity bit for bit over 1200 steps, planted mutation caught at step 629; selftest look goldens 11/11, block goldens 5/5; export-audit 782 loaded / 0 failed). `build/gate/b7eeed009cc7/gate.json` (git-ignored, in the worktree).
- Default look: Tonnage's `ghost_forms.json` row is `spectral` (`8c3586694`); `--ghost-look=legacy` brings the old hauler back.

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
| Films for the morning (spectral, re-filmed 06:12 at the gated HEAD, limited-range H.264 1080p60, posters `.jpg`) | `tonnage_move_32.mp4` 5 s, `tonnage_attack_32.mp4` 5 s, `tonnage_close_64.mp4` 10 s, `tonnage_morph_32.mp4` 6.7 s, each 70 deg above + top view below | attack poster: the clap lands in front, the wrecked car and every victim visible in both views |

## What does not

- **Smoke column starts low.** The tail leaves the belly near road level instead of hanging from under the hump as on the plate; at rest one cone side of the column is a straight hard edge (`tonnage_tail_fix_rest_64.png`, x about 380). It reads as smoke, not as a leg, ribbon or sparks.
- **HUD chip visor slot is faint** at 84 px (`tonnage_chip_hud.png`): hump and both striped fists read, the face does not.
- **No voice wash in the story apparition.** Tonnage draws his own body (own_body), so flight's `GhostBridgeFade.voice` has no shared sprite to tint; it returns safely and the apparition simply has no wash. Flight lists the same gap for the other own_body forms.
- **Thin 4 m ring is faint at 32 px/m** in the attack film poster: the reach mark is there but light against the road; the cracks and victims read more than the ring.
- **`tonnage_spectral.gd` is weakly tested**: on the final tree, `node tools/mutate/mutate.mjs --file=features/souls/tonnage_spectral.gd --max=40` (40 of 154 sampled) scored 27.5% = 11/(11+29). The 29 survivors sit in the presentation code (lines 47-189): the combat-tick hook, the ground-shadow ink discs, the fist landing-mark placement and its width and alpha through the wind-up, the art-set choice by pitch, and the cell's roll, stretch and lift. The tests check states and poses, not where these marks are drawn. `tonnage_pose.gd` is well held: 92.5% = 37/(37+3) (40 of 161 sampled; survivors at :71, :113, :129). `tonnage_morph.gd` 24/(24+0) (session 4). Logs: `build/tonnage-mutate-spectral.txt`, `build/tonnage-mutate-pose.txt` (git-ignored).
- **Performance unmeasured**: no bench under the lock tonight; the glow, morph and plume costs are not numbers.

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

- Flight's `project/tests/unit/test_ghost_card.gd` is pinned to the legacy look on this branch (8e82e68d1, flight OK: ours wins at the merge); one guard at `test_ghost_flight_hosts.gd:114` in merge 80c27095b (`if not drawn.own_body:`). Dent and kerf carry a different guard on the same line (a null-sprite check, f67fa2ea0 on n20-kerf): a same-file conflict at the merge. Take the null-sprite check: it covers Tonnage too (own_body Tonnage has a null sprite).
- Flight's `project/tests/unit/test_ghost_apparition.gd:100` gets a null-sprite guard on this branch (flight OK; own_body forms have no shared sprite to wash). Flight's REPORT lists the voice-wash gap for own_body forms.
- Named one-line call site in a flight file: `ghost_form_bodies.gd` step_tonnage `tonnage.hauler = p.hauler`.
- `n20-flight` merged several times into this branch, last 6bb29c7a0 = flight final aa9ff166e (root JOURNAL.md/REPORT.md kept ours). The merge-clash hook warns that flight's `project/tests/unit/test_ghost_look.gd` conflicts with n20-ohm: a flight/ohm overlap carried in through the merge, no tonnage lines.
- `RamWake` has two callers (`tonnage_view.gd`, `boot/collect_call/view/cast_view.gd` quest 1); the spectral gate is in TonnageView only so quest 1 keeps its bow wave.

## Next steps

0. The `--reels` gate was not run: the freeze is 07:30 and this lane's session stops at 07:27.

1. Seat the smoke column under the hump (raise its root, soften the straight cone edge) in Tonnage's `ghost_hover.json` row and vapour.
2. Ink the visor slot darker in the chip cut, or cut the chip from a 3/4 cell where the face is larger.
3. Thicken or brighten the 4 m slam ring at 32 px/m (still a line, not a disk).
4. Add tests that pin `tonnage_spectral.gd`'s draw outputs (landing-mark position, width and alpha through the wind-up; cell roll and lift; the combat-tick hook) to lift its 27.5% mutation score; then kill the 3 `tonnage_pose.gd` survivors.
5. Bench the spectral Tonnage under the lock (crowded drive + riot) to put a number on glow, plume and morph.
6. Retire the legacy hauler body once the owner signs off the spectral look (not tonight: legacy stays one value away).

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
| 9 | apparition-guard | 4 | accepted | (exact code in the brief: a one-file test guard needs nothing more) |

Total: 9 Astra calls, about 383 minutes; 6 accepted outright, 1 accepted with its flip reverted by rule and redone in call 8, 1 bounced at the cap (smoke column redone in call 6), 1 abandoned at a director handover (films salvaged).
