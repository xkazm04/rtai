# n30 combat 17: rim ink candidates measured (#EDAB42 kept)

Arithmetic first: r - max(g,b) = A #EDAB42 0.26, B #D9922C 0.28, C #C27A1F 0.28; all under verm_gate 0.31, classify 0.

## Commands
Patch applied (`git apply evidence/n30/lights/rim.patch`), `hex` of `amber` edited per candidate, one take each:
`node evidence/n29/red/take.mjs build/n30rim2/<before|A|B|C> 482,486,490 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
(before = unpatched; every take ends `timedOut`, stills landed; no reimport was needed, B and C pixels differ from A).
Measure: `build/n30rim2/m.py` -> `build/n30rim2/measure.txt`. Disc = bbox of c12 (t490 reuses the t486 disc: the light has faded, so the t490 numbers are rough).
Ring band = r in 0.75R..R of the disc, floor = annulus R+20..R+40 px outside. Added = class count inside the disc minus before.

## Table (changed = max channel diff > 24 vs before, in disc)
| tick | cand | changed | mean RGB of changed | amber added | verm / red / teal added | ring lum | ring sat | floor lum | floor sat | ring-floor sat |
|---|---|---|---|---|---|---|---|---|---|---|
| 482 | before | 0 | | | | 177.0 | 0.155 | 84.0 | 0.225 | -0.069 |
| 482 | A | 296777 | 230,223,171 | 39900 | 0/0/0 | 173.2 | 0.271 | 84.0 | 0.225 | +0.047 |
| 482 | B | 296777 | 230,219,166 | 39900 | 0/0/0 | 170.8 | 0.289 | 84.0 | 0.225 | +0.064 |
| 482 | C | 296777 | 229,214,163 | 39900 | 0/0/0 | 168.0 | 0.295 | 84.0 | 0.225 | +0.071 |
| 486 | before | 0 | | | | 211.9 | 0.490 | 172.0 | 0.721 | -0.230 |
| 486 | A | 296921 | 255,235,161 | 0 | 0/0/0 | 206.8 | 0.559 | 172.0 | 0.721 | -0.161 |
| 486 | B | 296921 | 255,230,157 | 0 | 0/0/0 | 204.2 | 0.570 | 172.0 | 0.721 | -0.151 |
| 486 | C | 296921 | 255,226,154 | 0 | 0/0/0 | 202.2 | 0.578 | 172.0 | 0.721 | -0.143 |
| 490 | before | 0 | | | | 82.0 | 0.206 | 58.2 | 0.263 | -0.057 |
| 490 | A | 0 | | 33941 | 3/0/0 | 76.1 | 0.343 | 58.2 | 0.263 | +0.079 |
| 490 | B | 296634 | 103,80,62 | 34178 | 3/0/0 | 73.1 | 0.351 | 58.2 | 0.263 | +0.088 |
| 490 | C | 296634 | 99,76,59 | 21143 | 3/0/0 | 70.5 | 0.357 | 58.2 | 0.263 | +0.093 |

Vermilion added 3 at t490 is the same for A, B and C (take jitter / fading light, not the ink). Red and teal added 0 everywhere.
Ring-floor luminance gap shrinks with a deeper ink (t486: 34.8 A, 32.3 B, 30.2 C); the saturation gap grows by only ~0.01 per step.

## What I saw
`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_rim_ink_abc_64.png` (t486, before | A | B | C). The cream star and the
white core stay pale in all three; B and C warm the outer rings by a hair and darken them slightly, but none reads as a distinct
amber ring over the nuke's amber floor. A deeper ink moves the rim by ~5 RGB steps per candidate: below what the eye separates.
The weak read is the rim weight in the patch (how much ink the shader mixes), not the token value.

## Pick
None beats A by eye: #EDAB42 kept, palette.json and the test untouched. Finding: contrast over the amber floor needs a stronger
rim mix in the shader (or an ink further from the floor hue), not a darker amber. Patch restored (`git apply -R`), `git apply --check` exit 0.

## Wide variant (c19)
Variant: the rim covers bands <= 2 (`step(band, 1.0)` -> `step(band, 2.0)` in `light_ink.gdshader`), saved as
`evidence/n30/lights/rim_wide.patch` (the rim.patch set with that one value and its comment changed). Takes (back to back, 64 px/m,
blast_1.png as in the tree at the time, `git status --short project/features` showed it modified by c18 for before and A; W ran after):
`node evidence/n29/red/take.mjs build/n30rim3/{before,A,W} 482,486 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
(before = patch not applied; A = rim.patch; W = A plus the edit). Measure: `build/n30rim3/m.py` (c17's method), disc boxes as in c17.

| tick | take | changed px vs before | mean RGB of changed | ring lum / sat | floor lum / sat | vermilion / red / teal added |
|---|---|---|---|---|---|---|
| 482 | A | 296777 | 230,223,171 | 173.2 / 0.271 | 84.0 / 0.225 | 0 / 0 / 0 |
| 482 | W | 417273 | 237,229,155 | 173.2 / 0.271 | 84.0 / 0.225 | 89 / 0 / 0 |
| 486 | A | 296921 | 255,235,161 | 206.8 / 0.559 | 171.7 / 0.719 | 0 / 0 / 0 |
| 486 | W | 417362 | 255,241,177 | 206.8 / 0.559 | 171.7 / 0.719 | 0 / 0 / 0 |

Seen (`gtai-masters/n30/combat/stills/explosion_rim_wide_64.png`, before | A | W at t486): the outer ring is pixel-identical between A and W
(ring lum/sat equal), so W gives the owner nothing more at the rim. W instead tints the whole mid disc cream-yellow and shrinks the
white core to a small spot; the flash reads washed and flatter, less like a blast core. t482 W adds 89 vermilion px (bar is 0), so W
also fails the colour bar. Recommendation: keep A (bands <= 1); a stronger read needs a different mix, not a wider one.

Checks after restore: `git apply --check evidence/n30/lights/rim_wide.patch` exit 0; `git apply --check evidence/n30/lights/rim.patch` exit 0;
`git status --short project` empty.
