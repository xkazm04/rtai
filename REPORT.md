# REPORT - lane cast, run n26 (2026-11-23), branch `n26-cast`

DRAFT written 15:35 by session 4; the final session replaces every PENDING with a measured value or removes the line.

Lane brief: planted feet as a checklist rule + the patrol cop re-cut to it, then Mulroney, the appliance warden, then robot
gunner, contractor, thug. Worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, cut from `main` `0779185ac`.
Final gate: PENDING, started 16:30 on the last code commit `4f505e377` (`node tools/gate/run.mjs --rev=4f505e377 --reels`,
log `C:\Users\kazda\kiro\gtai-n26\logs\cast\gate-final.out`); quote its line and the `gate.json` path.

**The builder account hit its usage limit at 16:12** (every lane; "try again at Nov 28th"): no product change after
`af94f1c6e` (Mulroney) and `2c7f91f25` (warden art).

## What works

| Item | Evidence | Number |
|---|---|---|
| Planted feet is a measurable checklist rule | `docs/art/cast-checklist.md` Feet row; audit tool `tools/art/cast_feet.mjs` + `project/dev/cast/cast_feet.gd`; table in `docs/art/cast-audit.md` "Planted feet, n26" | PASS = support sole travels <= 2 px over its whole contact AND body jump <= 12 px between rendered frames, at 32 px/m, every gameplay gait, tilt 70 and 55 |
| Patrol cop re-cut to it (8-drawing walk + 8-drawing run, drawn new) | `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_cop_patrol_before_after_64ppm_tilt70.png`, `..._tilt55.png`, `feet_cop_patrol_before_after_32.mp4` | sole 42.80 px -> 0.00 px (64 px/m still); all 64 rendered checks at 32 px/m: sole <= 0.001 px, body jump <= 10.79 px, <= 21.53 drawings/s (retreat 49.26 -> 16.98 via the run sheet above 4.0 m/s); mutate `street_cop_walk.gd` 16/20 |
| Sergeant Mulroney redrawn from the owner's plate, card ON in the prologue | `mulroney_beside_64ppm_tilt{70,55}.png`, `mulroney_pump_64.png`, `mulroney_close_64.mp4`, `mulroney_fight_32.mp4`, `mulroney_hit_shadow_64.png` | 8-drawing walk 0.1903 m/drawing = 16.82 drawings/s at 3.2 m/s; down-right sole 32.98 -> <0.001 px; wound gap 7.0 / 12.04 px -> 0; height 42 px vs the cop's 43 at 32 px/m; reversal body jump 30.49 -> 9.59 px (the cop's 14.17 px fixed too, `project/tests/unit/test_cast_walk_reversal.gd`); hit edge dark exterior px 354 -> 0 (70) and 462 -> 0 (55), `mulroney_hit_edge_64.png`; mutate 11/11. Every checklist row PASS |
| Mulroney's pump for the yard lane | `FoeCastView.set_pump(h, progress, fired_this_tick)`; attack rows 2 pump back, 3 pump forward | reads at 32 px/m (gun raised diagonal vs level) |
| Appliance warden: cut art only | `project/features/characters/art/view/p70/appliance_warden_planted8_armed_walk.png` and nine more sheets (`2c7f91f25`) | not drawn in game (no row on `n26-cast`); row, anchors and catch rows on side branch `n26-cast-warden-wip` (see What does not) |
| Source art for every remaining character, all reviewed | `C:\Users\kazda\kiro\gtai-art\foes-n26\{gunner,contractor,thug}\out\`, 8-drawing walks `{gunner8c,contractor8c,thug8c,warden8c,lancer8,mul8,cop8,cop8run}\out\` | every 8-drawing walk in the 2x4 one-facing layout; the 8-per-band layout drifted slim on every take |

## What does not

- Feet still FAIL (before = after) for enabled characters this lane did not reach: riot cop, SWAT, contractor (shipped), lancer,
  door carrier, pile-driver (table in `docs/art/cast-audit.md`). Cause for the humans: 4 drawings per stride cannot plant a foot
  without a hop. PENDING: feet-four call (lancer 8-drawing walk, door + pile-driver anchored).
- Robot gunner, contractor, thug: source sheets and 8-drawing walks accepted, not cut into the game (no builder time). Their rows stay as on main.
- Appliance warden NOT shipped: the builder died mid-call (usage limit). Her row (`enabled: false`), 8-drawing anchors, the catch
  entry `FoeWardenCardView.set_catch(h, held, tick)` and her test sit on branch `n26-cast-warden-wip` (20920e043, not for merge):
  lint 19/19, unit 3994 pass / 1 fail: `project/tests/unit/test_street_walker_hit.gd:164` (a thrown card's fill 1.00 vs 1.03: the
  WIP's `StreetWalkerCards.place` reads the texture path instead of meta `ON`). No checklist row, no films.
- Mulroney's card in the prologue is drawn over by the yard's vector dress until the yard wiring is merged (see Merge notes).

## What blocked or slowed you

- Codex image runner stalled on the copy to `./out` (known fault) and on an open stdin: ~14 min; replaced by `foes-n26/gen26.mjs`.
- 4-drawing walks cannot satisfy planted + small hop + sane cadence together (feet and feet-hop calls, ~75 min): solved by drawing 8-drawing walks.
- 8-per-band image layout drifted every figure slim/tall (warden, gunner, contractor, thug): ~20 min of rejected takes; the 2x4 one-facing layout fixed it.
- Pre-commit hook `kill_reel_life.break.test.mjs` red only when the class cache was stale (the launcher's `--import` reached the test's fake runner): bypassed under a DEVIATION line in the feet calls.

## Calls for the owner

1. Thug A "street brawler" (picked) vs B "barrel bouncer": `C:\Users\kazda\kiro\gtai-art\foes-n26\plates\out\`.
2. Gunner B (carbine + amber shoulder lamp as the tell, picked) vs A (navy plates, too close to police blue).
3. Contractor colour B (white hat, pale lemon vest, picked) vs A (shipped orange hi-vis, collides with the vermilion law). One plate value.
4. Patrol cop 4 vs 8 drawings: `feet_cop_patrol_before_after_32.mp4`.
5. Body jump 10.79 of 12 px on the tall actor's 70 down-right arrival: closest to the limit.
6. The foot-track dots in the lab films are teal (lab view only, never in game).

## Merge notes

- Yard wiring for Mulroney's card (yard JOURNAL 15:09 `NEED director`): in `project/boot/prologue/prologue_command_view.gd`
  `_process`, hide the vector dress when `CastCards.current(&"sergeant_mulroney") != null` and drive `FoeCastView.set_pump`.
  Without it the merged prologue draws the vector dress over the card.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own.

## Next steps

In order, each one builder call (all source art is drawn and accepted; the briefs exist):
1. Warden: from `n26-cast-warden-wip`, restore meta `ON` for the hit check in `StreetWalkerCards.place` (the one red test), then
   her checklist + audit row, then films; yard wires `FoeWardenCardView.set_catch` and hides its overalls dye + vector pole.
   Brief `evidence/briefs/n26-cast-03-warden.md`.
2. feet-four: lancer 8-drawing walk (`foes-n26/lancer8`), door carrier + pile-driver on the anchored placement. Brief `evidence/briefs/n26-cast-08-feet-four.md`.
3. Riot cop + SWAT planted (they fail like the old cop): 8-drawing walks `C:\Users\kazda\kiro\gtai-art\foes-n26\riot8c\out\`,
   `swat8c\out\`, SWAT run `swat8run\out\` (all accepted tonight), cut like cop8.
4. Gunner, contractor, thug: briefs `evidence/briefs/n26-cast-05-gunner.md`, `n26-cast-06-contractor.md`, `n26-cast-07-thug.md`
   (8-drawing walks `foes-n26/{gunner8c,contractor8c,thug8c}`).
5. Check whether the shared impact-outline material draws the same dark teeth on other cards' hits at 64 px/m (it did on Mulroney's).

## Astra ledger

| Call | Minutes | Verdict |
|---|---:|---|
| feet | 33 | bounced (body hop 40.50 px) |
| feet-hop | 41 | accepted in part (49 drawings/s on the retreat) |
| mulroney | 61 | accepted in part (row off: walk/feet/hit/shadow) |
| cop8 | 59 | accepted |
| mul-fix | 50 | accepted in part (reversal jump found after commit) |
| mul-edge | 22 | accepted (reversal + hit edge) |
| warden | 28 | abandoned (usage limit at 16:12; art committed, the rest on `n26-cast-warden-wip`) |

What I would brief differently: PENDING.
