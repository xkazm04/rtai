# REPORT - lane cast, run n30 (2026-11-25, day run)

DRAFT (session 3, 14:00): filled in as items land; final at 18:55.

Branch `n30-cast` from `main` `5114a4441`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5. Builders: Claude
sub-agents in the director's session (Sonnet for most calls, Opus for the art and measurement calls), each from a brief under
`evidence/briefs/n30-cast-*.md` (common law `evidence/briefs/_common.md`). Owner's order: (1) robot thug A on, (2) the
pile-driver on eight, then pads by registration, (3) hit flash on the turret and the war machine, (4) the patrol cop's build
jitter +-8 %, (5) door carrier eight with three one-row edits (keep four unless the eight beats it everywhere).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n30\cast\` (`frames.json` there, best first). IMAGES 3/60.

**Gate (early, session 3): PASS** on `084e11b56` (the last code commit at 14:22): `node tools/gate/run.mjs --rev=084e11b56` -> `gate: PASS; build/gate/084e11b56074/gate.json`: lint 19/19 over 2295 files, unit 4318 passed / 0 failed / 2 skipped, scenarios 68, parity bit for bit over 1200 steps (planted mutation caught at step 629), selftest, export-audit 1003 loaded / 0 failed. The `--reels` gate runs on the final commit.

## What works

| Item | Evidence | Number |
|---|---|---|
| **Robot thug A on** (`045fccbf2` row `enabled: true`; `6c190e91b` fight/beside scenes read the shipped row) | `thug_live_32.mp4` (1920x1080 60 fps 20.02 s, live path, three thugs, "card on" from tick 1), `thug_beside_64.png` | thug 141 px at 64 px/m, Rivet 154 (0.92), unjittered cop 100.6 (1.40); scenarios 68 passed headless incl. replay and digests: nothing moved |
| **Pile-driver on eight drawings** (`bc22b9749` `CastWarAnchors.WALK = EIGHT`) | `war8_four_eight_32.mp4` (four | eight, same ticks, 1920x1080 60 fps 25.83 s, `10ba0be5c` `cast_war_films.mjs pair`), `war8_walk_32.mp4` (25.85 s), `war8_feet_before_after_64.png`; live eight in `flash_turret_war_32.mp4`; `docs/art/cast-audit.md` "Pile-driver, n30" | sole / jump (32 px/m unit), four -> eight: 70 R 12.50/16.82 -> 18.16/10.73, 70 DR 18.86/12.87 -> 27.45/10.37, 55 R 21.94/11.78 -> 20.91/10.74, 55 DR 18.64/12.87 -> 23.86/9.93: the jump bar (12) passes everywhere, the sole bar (2) nowhere |
| **Hit flash on the turret and the war machine** (`6ffe37321` `CastFarCard.tint_of` shared, both views `sync_tint`; tests `ad72cb7c1`, `084e11b56` through `show_rig`) | `flash_turret_64.png`, `flash_war_64.png`, `flash_turret_war_32.mp4` (25.0 s) | turret 22 flashes / 22 shots, war machine 20 / 21 scheduled hits; red added 0, teal 0; the war vent keeps its own glow; mutate: the deleted `sync_tint` line in each `show_rig` 1/1 killed, `CastFarCard` != flip killed |
| **Patrol cop build jitter +-8 %** (`c2281acbb` `StreetCrowdCards.COP_SCALE_VAR` 0.08, crowd keeps 0.16; `89f23929d` measured table + test) | `cop_jitter_64.png` (min / unjittered / max cop beside the card foes and Rivet; scene `1099bd8b6`), `cop_jitter_32.mp4` (city shot, 5114a4441 | HEAD, same ticks, 15.0 s) | min id 710 92 px, unjittered 100, max id 230 108 at 64 px/m (were 84.6 / 100.6 / 116.7); / Rivet 0.60-0.71; scenarios 68 passed: no digest moved; at 32 px/m no cop reads visibly different (<= 4 px); mutate `street_crowd_cards` 76-77 3/3 |
| **Door carrier eight: three one-row edits cut and measured** (`da11ce846`, table `be1e521cd`) | `door8_edits_64.png`, `build/look/n30-c05/edited_cells_2x.png` | eight with edits: 70 R 1.96/6.61 PASS, 70 DR 1.39/12.00 PASS, 55 R 2.15/7.69, 55 DR 3.06/11.93 (four 2.03/5.09, U/10.43): WALK stays FOUR (p55 blocks), per the owner's rule |

## What does not

- **Pile-driver pads by registration: built, measured, not shipped.** Sole worse by 7.7-9.6 px in every facing, jump better. The art keeps the planted pad at a fixed offset from the torso through each contact; registration needs whole-column redraws at both pitches (table in `docs/art/cast-audit.md` "Pile-driver, n30"). Patch `build/look/n30-c02/register_pads.patch`.
- **Door eight** passes both bars at p70 but not at p55.

## What blocked or slowed you (minutes each)

- Pre-commit hook on the shared machine: 16+ min (12:12 ->), and a stale `index.lock` left by a session end (found 12:31).
- Lane lock waits ~10 min twice (c02 behind c01, c04b behind a stale c03b lock).

## Calls for the owner

1. Pile-driver pads: the art steps in place (planted pad torso-fixed); planted pads need whole-column redraws (both pitches, right and down-right). Ship the eight with sliding soles as now, or order the redraw.
2. Door carrier eight: p55 blocks (right: jump 7.69 vs four 5.09; down-right sole 3.06). One more x-only edit of p55 down-right drawing 8 is possible; p55 right would still block.
3. Appliance warden at death: no sheet draws him larger (cap walk / hit / fall row 0 at 64 px/m: p70 36 / 28 / 28-31, p55 30 / 23 / 22-31). What changes at the switch is the drawing angle and the hat: the walk wears a grey bucket hat seen from above, hit and fall a tan camo cap seen frontally. Keep, or a one-row hat recolour of the walk. Still `warden_switch_64.png`.

## Merge notes

- NEED combat (merge): `features/combat/kills/kill_fall_cells.gd` `victim_scale` sizes a killed pose-less cop with `body_scale(actor_id)` (+-16 %); with cops at +-8 % a killed street cop changes size at death. One line: `StreetCrowdCards.body_scale_of(rig)` (exists only on `n30-cast`).
- `project/tests/unit/test_kill_card_scale.gd` (one line mirroring the cop scale) touched by cast.

## Next steps

## Builder ledger
