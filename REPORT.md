# REPORT - lane cast, run n30 (2026-11-25, day run)

DRAFT (session 3, 14:00): filled in as items land; final at 18:55.

Branch `n30-cast` from `main` `5114a4441`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5. Builders: Claude
sub-agents in the director's session (Sonnet for most calls, Opus for the art and measurement calls), each from a brief under
`evidence/briefs/n30-cast-*.md` (common law `evidence/briefs/_common.md`). Owner's order: (1) robot thug A on, (2) the
pile-driver on eight, then pads by registration, (3) hit flash on the turret and the war machine, (4) the patrol cop's build
jitter +-8 %, (5) door carrier eight with three one-row edits (keep four unless the eight beats it everywhere).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n30\cast\` (`frames.json` there, best first). IMAGES 16/60.

**Gate (early, session 3): PASS** on `084e11b56` (the last code commit at 14:22): `node tools/gate/run.mjs --rev=084e11b56` -> `gate: PASS; build/gate/084e11b56074/gate.json`: lint 19/19 over 2295 files, unit 4318 passed / 0 failed / 2 skipped, scenarios 68, parity bit for bit over 1200 steps (planted mutation caught at step 629), selftest, export-audit 1003 loaded / 0 failed. The `--reels` gate runs on the final commit.

## What works

| Item | Evidence | Number |
|---|---|---|
| **Robot thug A on** (`045fccbf2` row `enabled: true`; `6c190e91b` fight/beside scenes read the shipped row) | `thug_live_32.mp4` (1920x1080 60 fps 20.02 s, live path, three thugs, "card on" from tick 1), `thug_beside_64.png` | thug 141 px at 64 px/m, Rivet 154 (0.92), unjittered cop 100.6 (1.40); scenarios 68 passed headless incl. replay and digests: nothing moved |
| **Pile-driver on eight drawings** (`bc22b9749` `CastWarAnchors.WALK = EIGHT`) | `war8_live_four_eight_32.mp4` (four | eight in the live turret + war machine fight, same ticks, 1920x1080 60 fps 25.02 s, `82a9bd7a7` `cast_war_films.mjs live`), `war8_live_64.png` (the eight mid-stride in that fight), `war8_four_eight_32.mp4` (the same on the feet harness, 25.83 s, `10ba0be5c` `pair`), `war8_feet_before_after_64.png`; `docs/art/cast-audit.md` "Pile-driver, n30" | sole / jump (32 px/m unit), four -> eight: 70 R 12.50/16.82 -> 18.16/10.73, 70 DR 18.86/12.87 -> 27.45/10.37, 55 R 21.94/11.78 -> 20.91/10.74, 55 DR 18.64/12.87 -> 23.86/9.93: the jump bar (12) passes everywhere, the sole bar (2) nowhere |
| **Hit flash on the turret and the war machine** (`6ffe37321` `CastFarCard.tint_of` shared, both views `sync_tint`; tests `ad72cb7c1`, `084e11b56` through `show_rig`) | `flash_turret_64.png`, `flash_war_64.png`, `flash_turret_war_32.mp4` (25.0 s) | turret 22 flashes / 22 shots, war machine 20 / 21 scheduled hits; red added 0, teal 0; the war vent keeps its own glow; mutate: the deleted `sync_tint` line in each `show_rig` 1/1 killed, `CastFarCard` != flip killed |
| **Patrol cop build jitter +-8 %** (`c2281acbb` `StreetCrowdCards.COP_SCALE_VAR` 0.08, crowd keeps 0.16; `89f23929d` measured table + test) | `cop_jitter_64.png` (min / unjittered / max cop beside the card foes and Rivet; scene `1099bd8b6`), `cop_jitter_32.mp4` (city shot, 5114a4441 | HEAD, same ticks, 15.0 s) | min id 710 92 px, unjittered 100, max id 230 108 at 64 px/m (were 84.6 / 100.6 / 116.7); / Rivet 0.60-0.71; scenarios 68 passed: no digest moved; at 32 px/m no cop reads visibly different (<= 4 px); mutate `street_crowd_cards` 76-77 3/3 |
| **Door carrier eight: the owner's three one-row edits, then two p55 rounds** (`da11ce846`, table `be1e521cd`; p55 rounds `15590aa9b`, `4c62f3b65`, `6ee306fd8`, tables `df8289a63`, `5e32a5e72`) | `door8_edits_64.png`, `build/look/n30-c16/edited_cells_sheet_2x.png`, `build/look/n30-c17/edited_cells_sheet_2x.png` | eight with the three edits: 70 R 1.96/6.61 PASS, 70 DR 1.39/12.00 PASS, 55 R 2.15/7.69, 55 DR 3.06/11.93; after two p55 rounds (four one-cell edits, 11 images): 55 R 2.05/6.98, 55 DR 2.08/11.78 (four 2.03/5.09, U/10.43): WALK stays FOUR (both p55 soles over the 2 px bar), per the owner's rule |

## What does not

- **Pile-driver pads by registration: built, measured, not shipped.** Sole worse by 7.7-9.6 px in every facing, jump better. The art keeps the planted pad at a fixed offset from the torso through each contact; registration needs whole-column redraws at both pitches (table in `docs/art/cast-audit.md` "Pile-driver, n30"). Patch `build/look/n30-c02/register_pads.patch`.
- **Door eight** passes both bars at p70 but not at p55 (soles 2.05 and 2.08 after two p55 rounds, each 0.05-0.08 over the 2 px bar). A computation (c19, `docs/art/cast-audit.md` "Door eight, p55 drawing 8, n30", a Python copy of the walk checked against the measured take) closes the art route: the remaining slide inside a hold is the lean change times the sole's depth below the cell pivot, halved (p55 right drawing 8: 0.200 x 20.5 / 2 = 2.05, measured 2.04), because a hold leans about the pivot line, not the planted sole; no drawing-8 edit fixes p55 right, and any drawing-8 edit changes `EIGHT_STEP_M` and pushes p70 right over the bar.

## What blocked or slowed you (minutes each)

- Pre-commit hook on the shared machine: the flash commit sat 16+ min in the hook (12:12 ->) and then died with the
  session end, leaving a stale `index.lock` (found 12:31, landed 13:15): about 60 min from finished to committed.
- Lane Godot lock waits: about 10 min twice (c02 behind c01; c04b behind a stale c03b lock left by a background-limit kill).
- Windowed films clamp to 1422x800 (movie 1280x800) on this machine, so `tools/film/compare.mjs` exits UNVERIFIABLE and skips
  the composite: c11 hand-composed `cop_jitter_32.mp4` from two unscaled crops (about 15 min). NEED director.
- The image tool's known copy stall: every job's image was copied by hand from `~/.codex/generated_images/` (about 2 min each).
- One bounced call (c06, 29 min): it measured the warden's living death on the wrong fall row; c06b re-measured (22 min).

## Calls for the owner

1. Pile-driver pads: the art steps in place (the planted pad is torso-fixed through a contact), so registration loses on this art (sole +7.7-9.6 px in every facing). A one-cell probe (`war_pad_edit_probe_2x.png`, p70 right drawing 4, 2 images) moved the planted pad back 27.6 sheet px of the 29 asked on the second try, machine intact, but 7.2 sheet px off the floor; the first try overshot (42.4). The redraw is possible but costly: about 20 cells (both pitches, right and down-right contacts) x about 2 tries + a floor check each (about 40-50 images, 2-3 builder hours). Ship the eight with sliding soles as now (jump passes), or order the redraw.
2. Door carrier eight: p55 still blocks after two p55 rounds (right sole 2.05, down-right 2.08; bar 2; jumps pass; p70 passes). The eight's art is in the tree; `CastDoorAnchors.WALK` is the one value to switch. Keep the four, or accept the eight at p55's near-bar soles (`door8_edits_64.png`).
3. Appliance warden at death: no sheet draws him larger (cap walk / hit / fall row 0 at 64 px/m: p70 36 / 28 / 28-31, p55 30 / 23 / 22-31). What changes at the switch is the drawing angle and the hat: the walk wears a grey bucket hat seen from above, hit and fall a tan camo cap seen frontally. Keep, or recolour the walk's hat tan: a masked recolour candidate (no new shapes, ink untouched) on four cells is in `warden_hat_candidate_2x.png` (shipped walk | recoloured | hit cap): it reads as the hit's tan camo family; the shape stays a bucket hat against the peaked cap. Shipping it = the recolour over every walk cell, both pitches, with a per-cell mask check and an in-game 64 still. Still `warden_switch_64.png`.

## Merge notes

- NEED combat (merge): `features/combat/kills/kill_fall_cells.gd` `victim_scale` sizes a killed pose-less cop with `body_scale(actor_id)` (+-16 %); with cops at +-8 % a killed street cop changes size at death. One line: `StreetCrowdCards.body_scale_of(rig)` (exists only on `n30-cast`).
- `project/tests/unit/test_kill_card_scale.gd` (one line mirroring the cop scale) touched by cast.

## Next steps

1. Owner call 1 (pads): if he orders the redraw, one round per pitch x facing (about 5 cells each, 2 tries, a floor
   check per cell anchored to a drawn landmark: c13's lesson), then apply `build/look/n30-c02/register_pads.patch` and
   re-measure with `cast_war_films.mjs ... feet four,eight,eight_reg`.
2. Owner call 3 (warden hat): the masked recolour over all walk cells at both pitches, per-cell mask check, in-game 64 still.
3. NEED combat at merge: `kill_fall_cells.gd` `victim_scale` -> `StreetCrowdCards.body_scale_of(rig)` (see Merge notes).
4. NEED director: `compare.mjs` / windowed film size check on this machine (clamped 1422x800).
5. Door eight (and the pile-driver): the card views re-pin the node position on a held walk drawing
   (`foe_shield_card_view.gd` `update_fighter`, `foe_war_card_view.gd` `hold_foot`), which discards the pose's lean
   correction about the registered sole, so a held drawing leans about its cell pivot and the planted sole slides (c20:
   the still line is y 168 = the pivot in all 8 takes; the anchors' sole y and the feet reader's contact agree to 0 px).
   Fix: pin the planted sole instead (brief `evidence/briefs/n30-cast-21-held-sole-pin.md`), measured before commit.

## Builder ledger

All Claude sub-agents launched from the director's session, briefs under `evidence/briefs/n30-cast-*.md`.

| Call | Model | Item | Minutes | Verdict |
|---|---|---|---:|---|
| c01 | sonnet | thug A on, live film, 64 still | 41 | accepted |
| c02 | opus | pile-driver eight + registration measured | 29 | accepted (registration not shipped) |
| c03 | sonnet | turret / war machine flash | 55 | accepted-partial (commit stuck in the hook) |
| c04 | sonnet | cop jitter 8 % | 16 | accepted-partial (still, mutate open) |
| c05a | opus | door: three one-row image edits | 22 | accepted |
| c05b | opus | door: cut, anchors, feet table | 13 | accepted (WALK stays FOUR) |
| c03b | sonnet | flash commit, mutate, test | 54 | accepted |
| c06 | opus | warden fall fit (combat's NEED) | 29 | bounced (wrong fall row measured) |
| c07 | sonnet | five decisions.md lines | 1 | accepted |
| c04b | sonnet | cop jitter rendered still, mutate | 20 | accepted |
| c06b | opus | warden size at death, measure only | 22 | accepted (no rescale) |
| c08 | sonnet | dev scenes commit + debt accept, mutate | 10 | accepted |
| c09 | sonnet | pile-driver pair film tool + clip | 12 | accepted |
| c10 | sonnet | flash host tests through `show_rig` | 5 | accepted |
| c11 | sonnet | cop jitter before / after clip | 12 | accepted-partial (hand-composed) |
| c12 | sonnet | warden hat recolour candidate | 3 | accepted (candidate only) |
| c13 | opus | pile-driver one-cell pad edit probe | 5 | accepted (experiment) |
| c14 | sonnet | pile-driver four / eight in the live fight, 64 still | 29 | accepted |
| c16 | opus | door p55 round 1 (6 images) | 34 | accepted (art ships, WALK stays FOUR) |
| c18 | sonnet | two decisions.md lines, frames.json prune | 4 | accepted |
| c17 | opus | door p55 round 2 (5 images) | 17 | accepted (art ships, WALK stays FOUR) |
| c19 | opus | door p55 drawing 8, computation (0 images) | 8 | accepted (no drawing-8 edit can pass) |
| c20 | opus | door sole y vs feet reader, measure only | 3 | accepted (hypothesis wrong; found the card-view pin) |

What I would brief differently: one checklist point per call from the start (the short calls c07-c13 were the best value);
give every measurement call the exact sheet row the game draws at that moment (c06 measured a row the game never shows);
never end a session with a commit sitting in the hook (land it, or leave a named resume line).
