# Follow-up a3b (lane dent): three fixes from the director's review of a3

Same machine rules, repo law and file ownership as the a3 brief (APPDATA=.../appdata/dent, d3d12,
`--position 0,1440`, one Godot at a time, stage per path, never push, render only, no digest moves).
Commit each fix separately; `node tools/gate/quick.mjs` before each commit.

## 1. Legacy must not change (bug)
`DentBody.step` (commit 4b9b30257) turns `facing` toward the held car BEFORE it branches on
`_spectral`, so the LEGACY body also turns to the car while steering. The legacy look must stay
byte-identical tonight. Gate the facing override to the spectral path only. Prove it: the legacy
attack take (`--ghost-look=legacy --ghost=dent --take=attack --view=tilt70 --ppm=64`) at ticks 160
and 200 compared byte-for-byte with the same frames at 9e8bc0619 (the film helper in `tools/film/`
can render the same tick on two revisions; or a temp worktree). Quote the result.

## 2. The blast must read as the ring's content from its first frame
Your sheet `scratch/a3/attack-32ppm-strap160-heat234-blast235-radius252.jpg` shows the blast does
reach the ring by tick 252, good. But at the contact tick 235 the dashed ring disappears and the
victim's big white hit star dominates, with one thin spoke, so the first frames still read as two
events. Fix the first 8 ticks:
- Keep the dashed ring drawn through the blast and flash it (full alpha, 1.6x ink width) for 18
  ticks, then fade it with the fireball.
- A shock disc from the car centre that reaches exactly `blast_radius_m` within 8 ticks (ease-out),
  amber-white `#FFE7B0` core to amber `#E9A23B` edge, alpha 0.55 -> 0 over 18 ticks, under the
  existing fireball shape.
- Spokes: twice as thick as now (ink under amber), drawn ABOVE the hit star, so the line visibly
  lands on the victim.
- Reduced motion: no growth; the filled disc at 0.3 alpha for 18 ticks.
- Stills at blast+0, +4, +8 ticks, tilt 70 and top, 32 px/m, as one sheet into `scratch/a3/`.

## 3. A broader belt
At 32 px/m the strap reads as a rope (about 6 px). The plate's strap is a broad flat belt, wider
than his forearm. Raise `strap_width_m` to 0.48 and the buckle to match (data only), keep the ink
edge 2 px, check the webbing ticks still read. Still: steering (teal, taut), tilt 70 and top,
32 px/m, the tick you choose, into `scratch/a3/`; and one at 64 px/m.

## 4. A strike shape on the jab
`scratch/a3/tilt70-64ppm-attack-jab-tick94-after.png`: the fist reaches the guard, but nothing marks
the hit; the victim is a dark blob at the fist. Add a small impact shape at the fist on the jab's
hit tick (the tick the 1 damage lands; read it render-side, never move it): a crumpled-steel
starburst in soul teal `HaulerLook.TEAL` with pale-aqua core and ink outline, about 0.6 m across,
plus three short speed lines behind the fist along the punch axis during the strike cells; both
fade over 6 ticks; drawn with the jab's raised order (above the car). Reads in the top view too. No
red (red is blood only). Stills: tilt 70 and top, 64 px/m, hit tick and hit+3, into `scratch/a3/`.

## 5. Gate hygiene and test strength
- Your report says standalone `node tools/godot/check.mjs` and the quick gate flagged
  `dent_roof.gd` and `dent_strap.gd` (dependency / allocator-shutdown errors). The final gate runs
  that check: make both pass standalone (e.g. preload the classes they name, or whatever the other
  souls files do that pass) and quote `check.mjs` exit 0 for every dent_* file.
- `dent_strap.gd` mutate 9/19 (the buckle draw survived). Add assertions so the strap's draw calls
  are tested (a recording canvas or counting draw calls is fine) and re-run `mutate --max=20`.

## Report
Files, commit shas, the three still sets with ticks, the legacy byte compare result, `mutate` on
`dent_overload.gd` (`--max=20`): killed/(killed+survived). Stop at 45 minutes with what is done.
