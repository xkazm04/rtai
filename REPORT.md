# n20 lane `ohm`: Ohm becomes the Lightning Rod

Branch `n20-ohm` (worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`), cut from `int-n20` at `a3eb0bf78`, merges
`n20-flight` twice (480f141f9, a340d0464). Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`. Evidence:
`C:\Users\kazda\kiro\gtai-masters\n20\ohm\` (`frames.json`, best first). Final gate on 8b4862e1f (the last code commit; every later commit is docs only):
`gate: PASS; C:\Users\kazda\kiro\gtai-wt\n20-ohm\build\gate\8b4862e1f2f9\gate.json`. Lint 19/19, unit 3259 passed /
0 failed / 2 skipped, scenarios 65 passed, parity bit for bit over 1200 steps (mutation caught at step 629), selftest look
goldens 11/11 and block goldens 5/5, release-compile 787 loaded / 0 failed. Run 05:57 to 06:08.

## What works

| Item | Evidence | Number |
|---|---|---|
| Spectral body (p70, p55, top), legless; stoop, three jars, copper fork read at 32 px/m | `n20/ohm/ohm_vs_plate.png`, `n20/ohm/body_32ppm_guard.png`, commit d49654b67 | 5 facings x 2 tilts + top parts |
| Jars are the wind-up: fill one by one in the 0.5 s between casts, empty on the press; the judged stun-only strip shows all three links and all three ringed victims | `n20/ohm/bolt/cast_strip_stun_{top,tilt70}_32.png` (jars 72/82/92, press 95, +2 97, +4 99) | guards 1.0 -> 0.5 HP, still stunned at +4 |
| Bolt from the fork, first link thin (0.6x), forks heavier, links 2 ticks apart, teal ring per stunned victim, sparks off the bodies | ba4c81c88, `n20/ohm/bolt/press4_close_64.png` | test_ohm_bolt_draw; mutate ohm_bolt_draw.gd 22/28 (78.6%) |
| Interrupted delayed cast: jars flash amber and vent (never teal) | `n20/ohm/bolt/cancel_vent_32.png`, `n20/ohm/ohm_attack_delay_32.mp4` | delay stays off by default |
| Old-man drift: 2.4 s sway, hem/beard follow 8/5 ticks (clamped 25 deg), staff leads, low slow bob | 080bfdd5e, `n20/ohm/drift/turn_{before,after}_*_32.png`, `n20/ohm/ohm_move_32.mp4` | test_ohm_drift |
| Top view: copper fork held clear of the flank, reads at 32 px/m | fc6c6b3fe, `n20/ohm/drift/staff_{before,after}_top_{32,64}.png` | prong 7 -> 12 px at 32 px/m; tips >= 6 px apart (test_ohm_drift) |
| Transform in/out: Rivet + teal orb -> spectral Ohm inside the burst ring, no legacy cell, no feet | `n20/ohm/form/{enter,exit}_{start,mid,end}_{tilt70,top}_32.png` | no code change needed |
| Hit reaction: spectral hover body leans 12 deg with the blow (GhostRecoil), jars and fork stay on, settles by +16 | 078d91612, `n20/ohm/form/hit_{0,4,8,16}_{tilt70,top}_32.png` | test at ages 0/4/8/16 both sides |
| HUD chip: spectral portrait with three lit jars, goggles, beard, fork | b38e571cd, `n20/ohm/form/chip_legacy_vs_spec.png` | 84 px |
| Look switch: spectral is Ohm's default, legacy one flag away (`--ghost-look=legacy`) | 359eacb83, decisions.md line | legacy captures pixel-identical to pre-switch |
| Films (re-shot after brief 05, spectral) | `n20/ohm/ohm_move_32.mp4`, `ohm_attack_32.mp4`, `ohm_close_64.mp4` (+ jpg) | 5 / 5 / 10 s, 1920x1080 h264 60 fps, 0 SCRIPT ERROR |
| Before/after against last night's legacy films (same driver take, half size, side by side; not tick-aligned) | `n20/ohm/ohm_attack_32_before_after.mp4`, `n20/ohm/ohm_move_32_before_after.mp4` (+ jpg) | 300 frames each |
| Tests and mutation | full unit run on 8b4862e1f | 3259 passed / 0 failed / 2 skipped; mutate ohm_drift 11/12, ohm_spirit 4/9 (+3 invalid), ohm_bolt_draw 22/28 |

## What does not
- Call 1 is open: under the spectral look a killed guard still gets the shared shock-kill X-ray starburst, which covers the
  body at +2..+6 (`n20/ohm/ohm_attack_32.jpg`). The judged strip uses stun-only guards, so all three victims show there;
  in the lethal take they read as skeletons.
- Left facings mirror the right ones, so the staff changes hands (Call 2); the p70/p55 "away" row is three-quarter (Call 3).
- A white impact spray (shared hit effect) sits beside the first victim (Call 4).
- Mutation on `ohm_spirit.gd` is weak: 4/9 killed (+3 invalid). The surviving faults are in draw order and alpha lines
  that only a pixel golden would see.
- No bench or rig-cost number for the spectral Ohm. The bench lock was not taken tonight, so any frame time would be
  CONTENDED, and none is claimed.
- The small red dash between Ohm and the guards in the attack film is the guard's rifle tracer (shared `fx_view.gd`), not Ohm's.

## What blocked or slowed you (minutes each)
- Director session cuts killed an attached Astra run (01:46, ~20 min lost); every call is launched detached since 02:58.
- Astra edited unowned combat files and deleted doc comments to fit size caps (bolt, 02:12): bounced and redone (~25 min).
- drift-films hit the 75 min cap without a final message (films done, mutate and the clutter attribution not).

## Calls for the owner
1. Shock-kill X-ray over a guard killed by a spectral Ohm bolt: the skeleton starbursts cover the victims (`n20/ohm/bolt/cast_strip_top_32.png`, press +2..+6). A rim-only kill look for spectral Ohm exists as a patch (`evidence/patches/n20-ohm-kill-rim-only.patch`; touches unowned KillShockFx/KillView). Take it, or keep the X-ray.
2. Left facings mirror the right ones, so the staff swaps hands (no `ohm_spec_hover_left.png`). Still:
   `n20/ohm/calls/call2_right_vs_mirrored_left_p70.png` (right, mirrored left, toward-right, mirrored). The staff still
   leads the body in both directions, so I'd keep the mirror; a drawn left cell is one image job if you want the hand fixed.
3. The p70/p55 "away" row is three-quarter away, not straight behind. Still:
   `n20/ohm/calls/call3_away_right_away_toward_p70.png` (away-right, away, toward). The jars and fork read in all three;
   a straight-behind cell would hide the face and the staff behind the jars.
4. A white impact spray beside the first victim (shared hit effect, not Ohm's files).

## Merge notes
- Ohm's row in `ghost_hover.json` sets `fade_from` 0 (flight's tail-0b sets 0.18 on `n20-flight`): keep ours.
- Two one-line call sites outside Ohm's files: `shock_arcs_view.gd:102` (`OhmVictimRims.arcs`), `fight_areas_art.gd:39` (`OhmVictimRims.sparks`); one in flight's `ghost_acts.gd` (`rig.tick = tick` in prepare_ohm).
- Public accessors `GhostDrawn.release_fade()` / `GhostDrawnActs.hurt_tick()` used since ca37bd94c (no private reads left).
- Two edits in flight's tests, agreed with flight; ours wins at the merge: 6c9319597 (`test_ghost_hitback.gd` Ohm windup pinned to legacy), 8b4862e1f (`test_ghost_spectral_sheets.gd` legacy belt test uses Kerf's leg cut, since Ohm's fade is 0).
- HUD chip is `features/hud/art/ghost_chips/ohm_spectral.png`, loaded by flight's selector (15e257bea).

## Next steps
- Owner verdict on Calls 1-4. If Call 1 is "rim only", apply `evidence/patches/n20-ohm-kill-rim-only.patch` (the combat
  owner's files) and re-film `ohm_attack_32`.
- Draw a true left-facing cell (`ohm_spec_hover_left.png`) and a straight-behind "away" row: one image job each,
  with the same prompt and refs as `docs/art/prompts/n20/ohm/`.
- Raise `ohm_spirit.gd` mutation with a small look golden of the top-view jars at fill 1/2/3.
- Measure the spectral Ohm under the bench lock (rig bench, 50 and 200 people).

## Astra ledger
| Call | Minutes | Result |
|---|---|---|
| body-art | 21 | accepted (d49654b67) |
| wire | ~64 | cut by the director session end; 4 commits accepted |
| bolt | 24 | bounced (unowned files edited); 2 commits accepted |
| bolt-scope (resume) | 45 | accepted (ba4c81c88) |
| drift-films | 75 (cap) | accepted (080bfdd5e + films) |
| form-rest | 58 | accepted (078d91612, b38e571cd, 359eacb83); left flight's hitback test red |
| strip-refilm | 34 | accepted (a340d0464 merge, befe2be8e, 6c9319597, 3bf81a93d, 15e257bea, ca37bd94c, 901c3475e, a0ce0ebd4) |
| sheet-test (resume) | 7 | accepted (8b4862e1f) |

8 calls, about 328 minutes: 6 accepted, 1 bounced and then redone on resume (bolt), 1 cut by a director session end with its commits kept (wire).
What I would brief differently: (1) launch every call detached from the first one, with the lock and an out file;
(2) give the owned-file list as an explicit allowlist and say "any other path: stop and report a NEED", which would have
saved the bolt bounce; (3) name the other lanes' tests that pin the legacy look in the first brief, because two of them
broke when Ohm's default flipped; (4) ask for the judged strip early, since it was the most useful still and came last.
