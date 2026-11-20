# n20 lane `ohm`: Ohm becomes the Lightning Rod (DRAFT, iteration 3, 04:20; final at 07:40)

Branch `n20-ohm` (worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`), cut from `int-n20` at `a3eb0bf78`, merges
`n20-flight` once (480f141f9). Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`. Evidence:
`C:\Users\kazda\kiro\gtai-masters\n20\ohm\` (`frames.json`, best first). Final gate: TODO (06:15).

## What works

| Item | Evidence | Number |
|---|---|---|
| Spectral body (p70, p55, top), legless; stoop, three jars, copper fork read at 32 px/m | `n20/ohm/ohm_vs_plate.png`, `n20/ohm/body_32ppm_guard.png`, commit d49654b67 | 5 facings x 2 tilts + top parts |
| Jars are the wind-up: fill one by one in the 0.5 s between casts, empty on the press | `n20/ohm/bolt/cast_strip_top_32.png` (ticks 105..139) | 3 jars, 10 ticks apart |
| Bolt from the fork, first link thin (0.6x), forks heavier, links 2 ticks apart, teal ring per stunned victim, sparks off the bodies | ba4c81c88, `n20/ohm/bolt/press4_close_64.png` | test_ohm_bolt_draw; mutate ohm_bolt_draw.gd 22/28 (78.6%) |
| Interrupted delayed cast: jars flash amber and vent (never teal) | `n20/ohm/bolt/cancel_vent_32.png`, `n20/ohm/ohm_attack_delay_32.mp4` | delay stays off by default |
| Old-man drift: 2.4 s sway, hem/beard follow 8/5 ticks (clamped 25 deg), staff leads, low slow bob | 080bfdd5e, `n20/ohm/drift/turn_{before,after}_*_32.png`, `n20/ohm/ohm_move_32.mp4` | test_ohm_drift |
| Top view: copper fork held clear of the flank, reads at 32 px/m | fc6c6b3fe, `n20/ohm/drift/staff_{before,after}_top_{32,64}.png` | prong 7 -> 12 px at 32 px/m; tips >= 6 px apart (test_ohm_drift) |
| Transform in/out: Rivet + teal orb -> spectral Ohm inside the burst ring, no legacy cell, no feet | `n20/ohm/form/{enter,exit}_{start,mid,end}_{tilt70,top}_32.png` | no code change needed |
| Hit reaction: spectral hover body leans 12 deg with the blow (GhostRecoil), jars and fork stay on, settles by +16 | 078d91612, `n20/ohm/form/hit_{0,4,8,16}_{tilt70,top}_32.png` | test at ages 0/4/8/16 both sides |
| HUD chip: spectral portrait with three lit jars, goggles, beard, fork | b38e571cd, `n20/ohm/form/chip_legacy_vs_spec.png` | 84 px |
| Look switch: spectral is Ohm's default, legacy one flag away (`--ghost-look=legacy`) | 359eacb83, decisions.md line | legacy captures pixel-identical to pre-switch |
| Films | `n20/ohm/ohm_move_32.mp4`, `ohm_attack_32.mp4`, `ohm_close_64.mp4` (+ jpg) | 5 / 5 / 10 s, 1920x1080 h264 60 fps |

## What does not
- TODO after brief 05/06.
- The small red dash between Ohm and the guards in the attack film is the guard's rifle tracer (shared `fx_view.gd`), not Ohm's.

## What blocked or slowed you (minutes each)
- Director session cuts killed an attached Astra run (01:46, ~20 min lost); every call is launched detached since 02:58.
- Astra edited unowned combat files and deleted doc comments to fit size caps (bolt, 02:12): bounced and redone (~25 min).
- drift-films hit the 75 min cap without a final message (films done, mutate and the clutter attribution not).

## Calls for the owner
1. Shock-kill X-ray over a guard killed by a spectral Ohm bolt: the skeleton starbursts cover the victims (`n20/ohm/bolt/cast_strip_top_32.png`, press +2..+6). A rim-only kill look for spectral Ohm exists as a patch (`evidence/patches/n20-ohm-kill-rim-only.patch`; touches unowned KillShockFx/KillView). Take it, or keep the X-ray.
2. Left facings mirror the right ones, so the staff swaps hands (no `ohm_spec_hover_left.png`).
3. The p70/p55 "away" row is three-quarter away, not straight behind.
4. A white impact spray beside the first victim (shared hit effect, not Ohm's files).

## Merge notes
- Ohm's row in `ghost_hover.json` sets `fade_from` 0 (flight's tail-0b sets 0.18 on `n20-flight`): keep ours.
- Two one-line call sites outside Ohm's files: `shock_arcs_view.gd:102` (`OhmVictimRims.arcs`), `fight_areas_art.gd:39` (`OhmVictimRims.sparks`); one in flight's `ghost_acts.gd` (`rig.tick = tick` in prepare_ohm).
- `ohm_drawn.gd` reads flight's private `drawn._fade` (NEED flight: a public release call).

## Next steps
- TODO

## Astra ledger
| Call | Minutes | Result |
|---|---|---|
| body-art | 21 | accepted (d49654b67) |
| wire | ~64 | cut by the director session end; 4 commits accepted |
| bolt | 24 | bounced (unowned files edited); 2 commits accepted |
| bolt-scope (resume) | 45 | accepted (ba4c81c88) |
| drift-films | 75 (cap) | accepted (080bfdd5e + films) |
| form-rest | 58 | accepted (078d91612, b38e571cd, 359eacb83); left flight's hitback test red |
| strip-refilm | running | |
