# REPORT - lane cast, run n26 (2026-11-23), branch `n26-cast`

DRAFT written 15:35 by session 4; the final session replaces every PENDING with a measured value or removes the line.

Lane brief: planted feet as a checklist rule + the patrol cop re-cut to it, then Mulroney, the appliance warden, then robot
gunner, contractor, thug. Worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, cut from `main` `0779185ac`.
Final gate: PENDING (`node tools/gate/run.mjs --rev=HEAD`, quote its line and the `gate.json` path).

## What works

| Item | Evidence | Number |
|---|---|---|
| Planted feet is a measurable checklist rule | `docs/art/cast-checklist.md` Feet row; audit tool `tools/art/cast_feet.mjs` + `project/dev/cast/cast_feet.gd`; table in `docs/art/cast-audit.md` "Planted feet, n26" | PASS = support sole travels <= 2 px over its whole contact AND body jump <= 12 px between rendered frames, at 32 px/m, every gameplay gait, tilt 70 and 55 |
| Patrol cop re-cut to it (8-drawing walk + 8-drawing run, drawn new) | `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_cop_patrol_before_after_64ppm_tilt70.png`, `..._tilt55.png`, `feet_cop_patrol_before_after_32.mp4` | sole 42.80 px -> 0.00 px (64 px/m still); all 64 rendered checks at 32 px/m: sole <= 0.001 px, body jump <= 10.79 px, <= 21.53 drawings/s (retreat 49.26 -> 16.98 via the run sheet above 4.0 m/s); mutate `street_cop_walk.gd` 16/20 |
| Sergeant Mulroney redrawn from the owner's plate, card ON in the prologue | `mulroney_beside_64ppm_tilt{70,55}.png`, `mulroney_pump_64.png`, `mulroney_close_64.mp4`, `mulroney_fight_32.mp4`, `mulroney_hit_shadow_64.png` | 8-drawing walk 0.1903 m/drawing = 16.82 drawings/s at 3.2 m/s; down-right sole 32.98 -> <0.001 px; wound gap 7.0 / 12.04 px -> 0; height 42 px vs the cop's 43 at 32 px/m; mutate 11/11. PENDING: reversal body jump (30.49 px found by the builder) and hit cut edge (call mul-edge) |
| Mulroney's pump for the yard lane | `FoeCastView.set_pump(h, progress, fired_this_tick)`; attack rows 2 pump back, 3 pump forward | reads at 32 px/m (gun raised diagonal vs level) |
| Appliance warden | PENDING (call warden) | |
| Source art for every remaining character, all reviewed | `C:\Users\kazda\kiro\gtai-art\foes-n26\{gunner,contractor,thug}\out\`, 8-drawing walks `{gunner8c,contractor8c,thug8c,warden8c,lancer8,mul8,cop8,cop8run}\out\` | every 8-drawing walk in the 2x4 one-facing layout; the 8-per-band layout drifted slim on every take |

## What does not

- Feet still FAIL (before = after) for enabled characters this lane did not reach: riot cop, SWAT, contractor (shipped), lancer,
  door carrier, pile-driver (table in `docs/art/cast-audit.md`). Cause for the humans: 4 drawings per stride cannot plant a foot
  without a hop. PENDING: feet-four call (lancer 8-drawing walk, door + pile-driver anchored).
- Robot gunner, contractor, thug: source sheets and 8-drawing walks accepted, not cut into the game (no builder time). Their rows stay as on main.
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

PENDING (warden, feet-four, gunner/contractor/thug calls with briefs `evidence/briefs/n26-cast-0{5,6,7}-*.md`; riot/SWAT 8-drawing walks in `foes-n26/{riot8c,swat8c}`).

## Astra ledger

| Call | Minutes | Verdict |
|---|---:|---|
| feet | 33 | bounced (body hop 40.50 px) |
| feet-hop | 41 | accepted in part (49 drawings/s on the retreat) |
| mulroney | 61 | accepted in part (row off: walk/feet/hit/shadow) |
| cop8 | 59 | accepted |
| mul-fix | 50 | accepted in part (reversal jump found after commit) |
| mul-edge | PENDING | |

What I would brief differently: PENDING.
