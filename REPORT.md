# n16 lane tools: REPORT (DRAFT written 14:40 in session 3; the 19:40 session updates it)

Branch `n16-tools` from main `5843f5a28`. Memory: `JOURNAL.md`. Evidence: `gtai-masters/n16/tools/frames.json`
(14 entries) and `evidence/n16-tools/`.

## What works, with its proof

### 1. The kill reel (`tools/film/kill_reel.mjs`, README section "every signature death, one command")
One command films every signature death in the KillLab on the city block, for weapons x victim kinds x directions
(`--dirs=0,90,...,wall`) x zooms, same seed and tick, a contact sheet per weapon and zoom, clips, and before/after
(`--before=<sha> [--rev=<sha>] [--native=donor]`) from any lane's tree.
- v1 11:31 (afe581336); `all` reads the filmed tree's table; the victim is judged on the DRAWN card row (748aa7332).
- `--dirs=wall` / `--sig-wall` (Gloria's pin case, bbee28a9c); the kill shot stands Rivet 10 m west of the station
  dummies so every direction draws the guard.
- `--gore-check` (c6191736b): every death filmed with `--gore=reduced` must lie as one drawn card at kill+20.
  Proof s2gore: katana + rocket `whole: true`; the control without it is undrawn at kill+20 (FAIL), so it discriminates.
- Beat readout: per film `hit-stop N frames` (measured from the probe rows' frame gaps), window still, settled,
  aftermath share; per weapon the row's timings and the aftermath lifetime (KillMarks ring of 12 kills).
- s3: `--quick` (32 px/m, dir 90), sheet cells labelled (weapon/film, offset, `KILL HS6`), `--clips --feel=on` cut
  from the game's movie so the hit-stop PLAYS (calibrated: movie index = probe frame), the all-weapon overview
  `reel_<ppm>.png` + `reel.md`, `--resheet` (no Godot), the death judged on screen (`--subject=kill`), a far victim
  gets the window, and every cell is anchored to the street by the probe's camera shift.
- Full coverage proof (s3all, `--weapons=all --quick --feel=on`): all 12 signature weapons kill in the lab (11 PASS,
  the nuke then UNVERIFIABLE on Rivet off screen; after the subject + window fix s3nuke / s3anchor PASS).

### 2. c-2: `CAR_DEAD_END_TILES` 65 (7850111df)
Regenerated, NATIVE REBUILT 11:46-11:47 (debug + release). Parity bit for bit 1200 steps (planted fault caught at
629), final digest `94b2865f7f17d778` unchanged from n15 (no re-bless). Route tests 21/0. Hand-made map tier A: no
car dies (n15 at 1: car 0 died); tier B no deaths. Stills in frames.json (tier A after / n15 before).

### 3. `test_quest_blade` under `--select`
Nothing to fix on main: `run_unit.mjs --select=test_kill_lab_turn,test_quest_blade` 5/5. The n15 fix 5e41c66bc never
reached the n15-combat branch whose FRICTION reported it (not an ancestor of 4df42554a).

### 4. Merge-clash warning in `tools/gate/quick.mjs`
Done in n15 (6d77d2204); seen working all day (`merge-clash: no new code conflict with ...`; it caught kills-polish's
`topple_deg` vs kills-new's schema key).

### 5. Builders served
kills-new REQUEST 1 (`--subject=kill`), 2 (`--sig-wall`), 3 (the Gatling never spun up in the lab: kill_lab holds a
spun gun, 0b5c55fc7); kills-polish's step_guard flake (8cb956f7e). Each with a SERVED line in JOURNAL.

## Findings for the kill lanes
- A signature row's `hitstop_ticks` does NOT freeze the screen: SignatureKills.hold makes the pieces wait. The freeze
  is hit_feel.json's `kill_hitstop` (camera.json `kill`, 6) or the class's bigger stop (blast = `boss_hit` 8).
- Default reels have the feel OFF (locked camera); judge pacing on `--feel=on` reels and their clips.
- At 32 px/m the flamethrower and electro gun deaths read weakly (a small dark figure) in the s3all overview.
- Before caccc825d every film read the DESK MOUSE for Rivet's live aim: two films of one commit differed in Rivet's
  facing and pose (sim identical). Films are now pinned (0.00 % apart run to run); re-film any before/after whose
  difference is Rivet's aim or pose. (The `settled` +80/+150 and aftermath 5.8/3.2 % run-to-run spreads came from it.)

## Gates
caccc825d touches `project/dev/frames/film_probe.gd` (dev only, no gate uses it): the full gate must be re-run on it
or the final project/ commit. Before that: gate PASS on 0b5c55fc7 (lint 19/19, unit 2645/0/2, scenarios 55, parity bit for
bit, look goldens 11/11, release-compile 683/0, reels top/tilt70/combo OK). Every later commit is tools/docs/evidence
(lint 19/19 incl. tool-tests in each commit's hook).

## Codex ledger
2 tasks, both gpt-5.6-sol, 1 round each, discarded after landing: n16t-break-film-root (119 s, 10 tests, accepted
after revision: the cwd-below-a-tree promise was a weakness, fixed), n16t-break-reel-movie (188 s, 10 tests, 3 kept
red, all 3 accepted and fixed in code).

## Calls for the owner
- The kill reel's default is feel OFF (stable sheets, clean A/B); pacing is judged with `--feel=on`. Alternative:
  feel on by default. (decisions: tools/kill-reel-feel)
- The kill shot stands Rivet 10 m west of his city start (station dummies took every full rig at the start).
- The reel judges the death, not Rivet, on screen; a far victim (the nuke) gets the window.
- A film never reads the desk mouse (FilmProbe pins the cursor; decisions tools/film-cursor). Dev only.
- Gloria's pin counts parked cars as walls (the lab's nearest "wall" is a car): kill lanes' call, raised here.

## Merge notes
Merge tools FIRST: native changed (c-2, CAR_DEAD_END_TILES 65; view lanes keep their DLLs). The kill lanes cherry-
picked the game side of afe581336, bbee28a9c and 0b5c55fc7 with identical content: expect clean merges there.

## Next steps
(the 19:40 session fills this)
