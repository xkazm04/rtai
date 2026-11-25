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
