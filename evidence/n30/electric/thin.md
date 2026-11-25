# n30 call 02: the chain hop and the daze stars back to the thin look; bold only for the bolt

Owner verdict (2026-11-25): "the chain hop and stun go back to the thin look, bold current only for the bolt"; `fx_amber_ink` stays.
Code commit `a0f9c8bed`: `project/features/combat/weapons/art/weapon_fx_electro.gd` (199 lines), tests in
`project/tests/unit/test_weapon_fx_electro.gd` and `test_weapon_fx_electro_hash.gd`.

## What changed
- New `THIN_BODY_PX` 3.0 / `THIN_CORE_PX` 1.5 beside the bold `BODY_PX` 10 / `CORE_PX` 4 / `INK_EXTRA_PX` 3 (bolt unchanged).
  `add_path(plan, pts, k, outline, thin)`; `star_plan(..., style)` with `enum { STAR_BOLD, STAR_THIN, STAR_DAZE }`
  (the old `under: bool` became `STAR_DAZE`: thin + the faint ink under-halo).
- `chain_plan` no longer calls `WeaponFxBolt.amplify` (no `JAG_K`: ElectricArc's own n28 kink), draws the thin path with no ink
  outline and a `STAR_THIN` star. `stun_plan` uses `STAR_DAZE`. Both translucent halo passes (9 px a0.18, 4.5 px a0.5) are kept
  (the n28 glow). Going bold again for hop/stun = the `thin` args / two constants.
- `WeaponFxBolt` untouched; `WeaponFxBolt.plan` still calls `add_path` and `star_plan` with the bold defaults.

## Reference width
`C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/electro_hop_pair_64_thin.png` (800x600 stack, 1:1 crop): the lower half's hop
is a cream stroke 1-2 px across (rows 462-463 at x=556, 1 px elsewhere), no visible amber, i.e. the 2 px `ElectricArc.CORE_PX`
core with the translucent halo printed away. Target 2 +-1 px; the new stroke is 3 px (amber 3 px body, cream 1.5 px core).

## Commands
Env: `APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=.../gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Before (HEAD `5114a4441`, rendered before the edit): `node tools/film/owner_takes.mjs <dir> 64 electro_gun_hop`.
- After: same command on the edited tree; 32 px/m film: `... <dir> 32 electro_gun_hop` -> `films/hop_thin_32.mp4`.
- Frames are the take's per-tick jpgs (`build/p5-takes/n30-hop-before|after`), hop tick 119 (take.json `first_hop_tick` 119, the
  first thug killed 119, the second thug hurt 119), stills at tick 121 (hop) and 150 (stun).
- Stun: the `electro_gun_hop` take itself. The second robot thug, hit by the chain hop, is stunned (`FightAreasArt` -> `WeaponFxElectro.stun`)
  and wears two daze stars at tick 150; no other item was needed.

## Numbers (64 px/m, 1920x1080)
- Bolt in flight, tick 114, whole frame: before vs after 0 differing pixels (also ticks 110 and 118: identical; first diff is tick 119).
- Hop box (1583,463)-(1800,561), ticks 119 / 120 / 121 / 125, amber near #edab42 (|dR|<=28, |dG|<=28, |dB|<=40):
  before 1019 / 1032 / 1056 / 1162, after 48 / 43 / 10 / 17 (> 0 at every tick listed). Red (R>170, G<110, B<90): 0 both arms.
  Teal (B>R+25, G>R+10, B>110, R<110): 0 both arms.
- Stun box (1711,479)-(1809,536), tick 150: amber before 373, after 0; red 0, teal 0 both. Honest note: at 3 px the amber body is a
  tan edge on the cream core and my colour counter finds none near #edab42 there; the stars read cream/tan, not amber. The
  hop still keeps a few amber-ish pixels. If the owner wants more amber, raise `THIN_BODY_PX` (4 would still be thin).
- Across-path width: by construction 3 px body / 1.5 px core at k = 1 (screen px, the same at 32 and 64 px/m). By pixels: three
  rows (dim amber, cream, dim amber) at x=1665, tick 121; two to three elsewhere, against the reference's 1-2.

## Stills (masters `C:/Users/kazda/kiro/gtai-masters/n30/combat/`)
- `stills/hop_thin_pair_64.png` (before | after, tick 121, labelled): before, a fat amber rope with ink rim and a sharp 3x zigzag and
  bold star; after, a thin tan/cream line with the small n28 kink, a 3-fork thin star, plus the glowing
  wreck arcs on the first thug at the left, identical in both halves (not part of this change).
- `stills/stun_thin_pair_64.png` (before | after, tick 150, 4x, labelled): the two daze stars round the second thug's head, bold
  amber Y-shapes before, thin cream/tan Y-shapes after.
- `films/hop_thin_32.mp4`: ffprobe `width=1920 height=1080 avg_frame_rate=60/1 nb_frames=1080 duration=18.000000`.
- `frames.json` there lists the three.

## Checks
- `node tools/tests/run_unit.mjs --select=test_weapon_fx_electro,test_weapon_fx_electro_hash`: 31 passed, 0 failed.
- `node tools/lint/lint.mjs`: all 18 checks pass over the 3 staged files (pre-commit); debt-ratchet ok.

## Mutate (after commit `a0f9c8bed`)
`node tools/mutate/mutate.mjs --file=features/combat/weapons/art/weapon_fx_electro.gd --lines=26-32,61-72,84,89,131-146 --max=12 --tests=test_weapon_fx_electro,test_weapon_fx_electro_hash`:
score 83.3% = killed 10 / (killed 10 + survived 2); timeout 0, invalid 0; 690 s. Survivors: `:65` `phase * 2` -> `phase / 2` in the hop star's
tick (the star's jag cell only; no test pins which cell the hop star uses) and `:89` `k * FORK_K` -> `k / FORK_K` (equivalent, FORK_K is 1.0).

## 3 px vs 4 px (c14)
No code change. 3 px = the existing `build/p5-takes/n30-hop-after` frames (take at the shipped `a0f9c8bed` code, line 30 unchanged since;
frames are named by tick). 4 px = `THIN_BODY_PX: float = 4.0` on line 30 only (core stays 1.5), then
`node tools/film/owner_takes.mjs build/p5-takes/_c14out 64 electro_gun_hop` -> `build/p5-takes/electro_gun_hop-64-6xPY7k`; line 30 restored
with `git checkout -- ...weapon_fx_electro.gd`, `git status --short` shows no `project/` path.
Same boxes and colour rules as above, ticks 121 (hop box) and 150 (stun box):

| box | arm | amber | red | teal |
|---|---|---|---|---|
| hop t121 | 3 px | 10 | 0 | 0 |
| hop t121 | 4 px | 10 | 0 | 0 |
| stun t150 | 3 px | 0 | 0 | 0 |
| stun t150 | 4 px | 0 | 0 | 0 |

The counter cannot tell them apart (the frames do differ: hop box bbox 1583,463-1793,561, stun 1711,479-1809,529). Still:
`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/thin_3_vs_4_pair_64.png` (hop 3x, stun 5x, labelled).
- Hop t121: 3 px is a cream/tan hairline; 4 px is a visibly thicker line with golden-tan edges, a little more amber, still thin.
- Stun t150: 3 px stars are cream with faint tan edge; 4 px stars are fatter with a clearer amber/gold rim, so 4 px reads more amber current.
