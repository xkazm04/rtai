# REPORT - lane cast, run n27 (2026-11-24)

Branch `n27-cast` from `main` `a3b3f1466`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5; builder: Claude
Sonnet 5.5 (high) through `gtai-n27/tools/builder.mjs`. Owner's order: the warden, planted feet for the six that fail, then
gunner A, contractor, thug A; item 4 the impact-outline check. Films and stills: `C:\Users\kazda\kiro\gtai-masters\n27\cast\`
(`frames.json` there, best first). IMAGES 13/15 (all gunner A, generated at 02:52-03:06; no other generation).

Final gate on `635ca4f4b` (the last code commit; later commits are inert docs/evidence): `gate: PASS; build/gate/635ca4f4b3ee/gate.json`
(lint 19/19 over 2223 files; unit 4114 passed, 0 failed, 2 skipped; scenarios 68 passed; parity 1200 steps bit for bit,
planted mutation caught at step 629; selftest goldens 11/11 + 5/5; release-compile 991 loaded, 0 failed). Reels not run: a `--reels` gate does not fit the 09:30-09:40 stabilize window, so the Director runs them at the merge.

## What works

| Item | Evidence | Number |
|---|---|---|
| **Appliance warden (Peg Dolan) card ON** (`6101447c0`, from the n26 WIP `20920e043`; red `test_street_walker_hit.gd:164` fixed in `dae51b291` without resizing any shipped card) | `warden_beside_64ppm_tilt{70,55}.png` (beside Rivet, the patrol cop, Mulroney), `warden_swing_64.png`, `warden_before_after_32.png`, `warden_close_64.mp4`, `warden_fight_32.mp4` (1920x1080 60 fps, 16.0 s each; two wardens flank and catch Rivet); audit row `docs/art/cast-audit.md` "Appliance warden ... after the card landed" | soles 0.00 px (bar 2), body jump 9.6 px walk/turn/reversal (bar 12), live 64 px/m rim 0 on ten sheets, wound contact 0.000-0.001 px, 47 px at 32 px/m 70 deg with the pole, 43 without (Rivet taller); mutate `foe_warden_card_view.gd` set_catch lines 4/4 killed |
| **Planted feet: riot cop** walk on an eight-drawing anchored placement (`e3ca4c6b6`) | `feet_riot_before_after_64ppm_tilt70.png`, `feet_three_before_after_32.mp4` (1920x1080 60 fps 27.7 s, before above after); table "Planted feet, n27" in `docs/art/cast-audit.md` | sole before 14.3-31.5 px -> 0.00; body jump 2.7-5.1 px (bar 12); reversal 9.60 px |
| **Planted feet: SWAT** walk and run (`7ebdaa84e`) | `feet_swat_before_after_64ppm_tilt70.png`, same clip | sole before 16.2-40.8 px -> 0.00; jump walk 3.1-7.2, run 4.7-9.1 px; reversal 9.60 |
| **Planted feet: lancer** (`rocket_trooper`) walk (`7ebdaa84e`, tests `d06453a34`) | `feet_lancer_before_after_64ppm_tilt70.png`, same clip | sole before 13.7-22.2 px -> 0.00; jump 2.8-9.2 px; reversal 9.60 |
| Film tooling at a true 1920x1080 (Movie Maker ignores `--resolution`) | `tools/film/cast_warden_films.mjs` (`6b3bdffcd`), `tools/film/cast_foot_films.mjs` (`0b5044a26`) | ffprobe 1920x1080 60/1 on every clip |
| **Robot gunner A (navy plates) drawn and wired, row OFF** (`9733ddf64` art from tonight's 12 accepted sheets, `635ca4f4b` `FoeGunnerCardView` on his robot rig + eight-drawing walk; `enabled: false`) | `gunner_vs_cop_32.png`, `gunner_beside_64ppm_tilt{70,55}.png` (beside Rivet, the patrol cop and today's robot rig), `gunner_lineup_32ppm_tilt70.png`; audit row "Robot gunner A" in `docs/art/cast-audit.md` | soles 0.00 px; jump 9.60 max over walk/stop/turn/reversal (stop was 15-20 px before he held the last planted drawing); 8.1 drawings/s; 46/49 px at 32 px/m 70 deg vs patrol 43/44, Rivet 77/73; navy 5-7 % of solid px, no teal/vermilion; key clean |

All three feet sheets keep the shipped height (0.999-1.000) and add no dark exterior edge at 64 px/m (0 / 0). Each old strip is
one value away: `WALK = FOUR` in `CastRiotAnchors`, `CastSwatAnchors`, `CastLancerAnchors`.

## What does not

- **Door carrier and pile-driver feet** (anchored placement), **contractor** (white hat, pale lemon vest, its 8-drawing walk),
  **robot thug A**: not started. Art for all three exists and is accepted (`gtai-art/foes-n26/`); briefs ready:
  `evidence/briefs/n27-cast-03-feet-door-pile.md`, `n27-cast-05-contractor.md`, `n27-cast-06-thug.md`.
- **Item 4, the impact-outline teeth on other cards at 64 px/m**: not checked (folded into the door-pile brief).
- Feet: the dedicated stop and turn takes were not run (`cast_feet` has no such take; walk maxima and the reversal test stand in).
  Mutate on `cast_card_kinds.gd` gave no score (killed at 330 s).
- Feet cadence: 12.7 to 15.6 drawings a second (riot 12.8, SWAT 13.9, SWAT run 12.7, lancer 15.6), above the 12 a drawn walk
  usually wants. Not a checklist bar; the drawn strides are short for the gameplay speeds. Judge it in the clip.
- **Robot gunner A stays off**: four checklist points are unmeasured (live 64 px/m rim, ink runs, a shadow toggle exposure that
  reaches his own rings, a live film of lens tell, fire, hit and fall). The clips `gunner_close_64.mp4` / `gunner_fight_32.mp4`
  were not shot; no mutate score. With the row off his robot rig draws exactly as on `main`.

## What blocked or slowed you

- Warden compile cycle (the WIP's CastCards helpers made `street_cop_walk -> CastCards -> ...` circular): about 25 min.
- Movie Maker renders at the project viewport (1280x800) and ignores `--resolution`: one re-shoot of the warden films (~20 min)
  until the scratch-project path in `6b3bdffcd`.
- The builder kept the warden off on a self-made "travel + 2 px" bar instead of the checklist's 12 px: one extra call (~30 min).
- Pre-commit hook about 12 min per commit on this shared machine: roughly a third of every feet call.

## Calls for the owner

1. **Feet cadence** (riot, SWAT, lancer at 12.7-15.6 drawings a second): play `feet_three_before_after_32.mp4`. If it reads as a
   shuffle, the fix is longer drawn strides (new walk art), or `WALK = FOUR` per character to go back.
2. **Warden in the prologue**: her card is on; on this branch alone the prologue draws the dyed rig and vector pole under the card
   until the yard's patch lands (see Merge notes). Judge her in `warden_fight_32.mp4` and `warden_beside_64ppm_tilt70.png`.
3. **Gunner A reads as a robot, not a cop** (owner's condition on keeping navy): `gunner_vs_cop_32.png`. By eye at 32 px/m the
   pale box head (no cap), tan frame and hose arms read as a machine and navy shows only as plate patches, where the cop is navy
   all over under a round cap. He stands slightly taller than the patrol cop (46 vs 43 px), well under Rivet (77). No plate
   re-roll was needed. Say if navy still reads too close to the police.

## Merge notes

- **Apply the yard lane's warden patch in the same merge** (evidence/yard27/warden_catch_wiring.md on branch `n27-yard`,
  commits `fe573d9ea` and `55b1d8d29`): it drives `FoeWardenCardView.set_catch` from `PrologueStage._move()` and skips her
  overalls dye, vector pole/straps and dress loop when her card is current. Without it, set `appliance_warden.enabled` to false
  in `project/data/tables/cast_cards.json`.
- Shared files touched: `docs/decisions.md` (appended lines), `tools/debt/baseline.json` (through the debt tool,
  `dev_loc` accepted rises for the dev film scenes). No other lane's files.
- Root `JOURNAL.md` / `REPORT.md`: add/add conflict expected; keep each lane's own.

## Next steps

1. Door carrier and pile-driver feet + the impact-outline check: `evidence/briefs/n27-cast-03-feet-door-pile.md` (no art needed).
2. Contractor (white hat, pale lemon vest; `contractor8c` walk): `evidence/briefs/n27-cast-05-contractor.md`.
3. Robot thug A (street brawler): `evidence/briefs/n27-cast-06-thug.md`.
4. Gunner A on: measure the live rim, ink, shadow exposure; shoot `gunner_close_64.mp4` and a three-gunner `gunner_fight_32.mp4`
   via the 1920x1080 path in `tools/film/cast_warden_films.mjs`; then `enabled: true` in `cast_cards.json` (one value).
5. Stop and turn takes in `tools/art/cast_feet.mjs`; mutate `cast_card_kinds.gd` on a quiet machine.

## Builder ledger

| Call | Minutes | $ | Verdict |
|---|---:|---:|---|
| warden | 57 | 1.22 | accepted in part (row off + anchored walk + red test fixed; no numbers) |
| warden-measure (resume) | 66 | 3.61 | accepted in part (numbers, live rim, wound contact); bounced 1280x800 films, self-made bar |
| warden-finish (resume) | 31 | 4.52 | accepted (on, true 1080p films) |
| feet3 | 71 | 3.23 | accepted (riot, SWAT, lancer with numbers); films and checks moved on |
| feet-films (resume) | 37 | 4.89 | accepted (films, lancer test fix); mutate no score |
| gunner | 35 | 2.74 | accepted (art, card, numbers, stills; row honestly off) |

Total: 6 calls, 297 min, $20.21.

What I would brief differently: put the checklist's exact bars in the first brief (it cost a call); name the 1080p film path
from the start; budget 12 min per commit for the hook and ask for the first `git commit` 20 minutes in, not 25.
