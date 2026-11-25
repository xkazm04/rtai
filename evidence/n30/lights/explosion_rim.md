# n30 combat 04: the explosion light rim amber (palette token `amber`)

Commit A `d4b6aabcc`: palette.json token `amber` #EDAB42 (role `accent`, no `accents` row: r - max(g,b) = 0.26 < verm_gate 0.31, so
`PaletteTokens.classify` gives 0 and the accent audit does not move; same shape as `blood_dark`), lights.json explosion `alt_token`
vermilion -> amber (+doc), `test_light_explosion_amber.gd` (3 tests: alt_color == #EDAB42, amber classifies 0, other kinds + explosion steps/radius/life unchanged).
Cost: one light per blast in both arms (ArenaCombatLights starts one `explosion` light per new blast; no new light).
`fire` stays vermilion (call for the owner).

## Takes (env: APPDATA=gtai-n30/appdata/combat, GODOT_BIN spike 4.7.2)
`node evidence/n29/red/take.mjs build/n30rim/<side> 68,70,72,74,78,84,92,104,500,504,508,512,516,524,532,544 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent --shot=user://n30rim_end.png --shot-tick=550`
(rocket first: blast ~tick 68-72, nuke blast ~tick 500-516). before = lights.json of d4b6aabcc^ (temporary checkout, restored); after = HEAD.
Counts (verm gate px / amber-near px) were identical every tick, e.g. t72 1912/55376 both arms, t516 7277/49854 both. Whole-frame diff (>24 per channel) 0 px at all 16 ticks.
Control: the same take with combat_lights.on false vs after: 0 px differ at 7 ticks (68-84, 516). So the arena captures draw NO light at all: the
rim change cannot be seen here. (HitFeel.feel_flag is "on" by default; Rivet is at the origin so the 20 m focus test passes.) Not found why; the
film/take path may not step or show the LightLayer, or ArenaCombatLights never starts. Needs a probe (ArenaCombatLights.started) outside my allowlist.

## Seen
`stills/explosion_rim_pair_64.png`: before and after are the same: an amber star with a cream core and ink rim, grey rubble, no ring of light
around it, no vermilion or amber band on the street. Ring crop identical. Film `films/explosion_rim_32.mp4` (ffprobe 1920x1080, 60 fps, 1000 frames, 16.67 s): after arm only; same.
Not done: a before film; a look at the city block fight (not tried).

## Probe (c04b)
Temporary, uncommitted `Log.warn("PROBE", ...)` in `ArenaCombatLights.step` / `_light` (ticks 60-110, 495-530, every
explosion call with its reason) and in `LightLayer.step` (`active`, visibility, layer, grade, `visible_instance_count`), plus
an env switch `PROBE_LIGHTS_OFF=1` forcing `on` false (the control without touching lights.json). Both files restored with
`git checkout --` before this commit. Same env and take tool as c04:
`node evidence/n29/red/take.mjs build/n30probe/<arm> <ticks> --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent --shot=user://n30probe_end.png --shot-tick=540`.

### What the probe says per tick
- `on` true, `reduced_motion` false, focus in radius on every call (rocket blast 214 px from Rivet, nuke 451 px; radius 640 px).
- Rocket: blast enters `areas.blasts` at **t64**: `acl t=64 explosion REFUSED budget` (FlashBudget). `started` was already 1
  before t60 (inferred: the rocket's own launch `muzzle_flash`, the only other light source; no blast existed yet; not logged before t60), and FlashBudget allows MAX_FLASHES 3 per 60-tick
  WINDOW while `spend_light` keeps BEAT_COST 2 in reserve: one light a second. The blast comes < 60 ticks after the launch flash,
  so it is refused. LightLayer `active=0` on every tick 60-110 (visible true, layer 3, grade day, `_grade.visible` true from the
  page age, `visible_instance_count` 0).
- Nuke: blast at **t478**: `explosion STARTED` (started 3, refused 1). LightLayer `active=1`, `visible_instance_count=1` on
  t495-t513, the logged window (life 36: t478-t513); `active=0` from t514. Light canvas visible, layer 3, node transform = the canvas transform.
- Counts over the whole probed run: ll step lines 95, `active=0` 76 (t60-110, t514-530), `active=1` 19 (t495-513).

### The light IS drawn: on/off pixel diff (`build/n30probe/{on,off}`, max channel diff)
| tick | px > 24 | px > 4 | bbox |
|---|---|---|---|
| 479 | 0 | 0 | - (the light's first frame lands at 480) |
| 480 | 421183 | 421183 | 686,33-1476,775 |
| 482 | 421236 | 421236 | 690,40-1479,782 |
| 486 | 421293 | 421293 | 693,51-1483,793 |
| 490 | 421245 | 421245 | 691,48-1481,790 |
| 496 | 421202 | 421202 | 665,39-1455,781 |
| 504 | 124419 | 421208 | 671,45-1461,787 |
| 508 | 3925 | 421219 | 674,50-1464,792 |
| 514 | 0 | 3931 | (expired) |
A ~790 px disc (6 m x 64 px/m radius), additive, three bands with the hatched edges: the n29 "pale hatched disc" is this light.

### Why c04 saw 0 px
1. Before/after (alt_token vermilion -> amber): `LightPool.write` uses `alt_color` only when `flicker_hz > 0`; explosion has 0,
   so the token change cannot reach a pixel anywhere (confirmed in the shader: one ink per light, see `rim_patch.md`).
2. Control (`on` false) vs after: c04 compared t68-84 and t516 only. At t68-84 the rocket blast light was refused by
   FlashBudget (never drawn); t516 is 2 ticks after the nuke light expired (t478 + 36 = t514). The nuke light is fully drawn on
   t480-t504 (and faintly to t513), ticks the control never compared. So "the arena draws no light" was a sampling gap, not a
   broken path: the LightLayer is stepped, visible in the day grade, and draws.
Side finding (for the Director): a rocket whose flight is under 60 ticks never gets its blast light, because the launch
muzzle flash spent the one-per-second light budget. If the blast should win, a NEED in `arena_combat_lights.gd` (skip the
muzzle light for a launcher round, or let a blast take the light the flash had); not in this call.

### Seen
`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_light_seen_64.png`: t486, nuke (started t478), 64 px/m, crop
x 560-1600 y 0-900, left `PROBE_LIGHTS_OFF=1`, right HEAD. Right: a white core, a pale yellow middle band, a faint yellow
hatched outer ring over the nuke's amber floor, extending past the star's tips. Over the amber floor an additive paper ring
reads pale yellow; an amber rim (the patch) would read as brighter, more saturated amber there and show most over the charcoal
street outside the blast fill.

### The rim
Not drawable by data: `rim_patch.md` (shader + LightPool + lights.json/schema `rim` flag, alt ink packed in instance custom
`.w`, test `test_light_pool_rim.gd`). A NEED for the Director: `project/core/render/**` and the shader are not this lane's.
