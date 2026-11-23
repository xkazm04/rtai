# JOURNAL n26 lane `pressure` (branch `n26-pressure`, worktree `gtai-wt/n23-loop`)

Continues `docs/day/2026-11-23/n24-pressure/`. Brief items: 1 trooper rocket art, 2 deflect 20 deg + curve,
3 rocket trooper rest/lead vs a moving player, 4 seed 9 stall, 5 three medians + tuner cycle (no retune).

## Session 1 (11:06 to 12:36)

- 11:06 start. main = 0779185ac. No astra.lock, no astra-calls.jsonl for this lane. Godot --import ran 39 s, exit 0.
  The n24 red checks (fire-gaps 14>=15, 196<=180) read differently on main now (Director re-derived them at merge).
- 11:12 DECISION pressure order: item 2 (deflect, data + a measurement) goes to Astra first while I direct the
  rocket art generation (Codex image_gen, outside the repo, no Godot). Item 1's cut and wiring is the next Astra call.
  Reason: one Astra at a time; the image round runs beside it without touching the worktree. Items still commit in
  their own commits.
- 11:09 ASTRA deflect started (pid 55692, brief `evidence/briefs/n26-pressure-01-deflect.md`, hard stop 12:10).
- 11:10 art round `C:\Users\kazda\kiro\gtai-art\pressure-n26\` (3 variants a/b/c of the enemy rocket: body row + three
  ice-blue exhaust plumes on green key; refs = trooper firing crop + Rivet's rocket in flight). Running `gen.mjs`.
- 11:15 briefs drafted: 02 rocket art (cut tool + wiring + stills), 03 trooper (rest/lead sweep, orbit-aware lead as a
  data value, arena circle vs circle_dash, gauntlet 3x10 seeds, re-derived fire-gaps test), 04 stall (repro from
  n23 soft-lock runs `evidence/n23-loop/moves/on/`, cause file:line, a test red on the cause). No NEED pressure in
  other journals at 11:14.
- 11:26 art A arrived (copy stall, copied by hand from ~/.codex/generated_images/01a207e2-...): clean dark gunmetal casing, ice-blue rim lines + nose band, three ice-blue plumes. Deflect curve at 20 deg: 6 m guard 24.3 % / bat 30.6 % (`evidence/n26-pressure/deflect/share.md`).
- 11:45 DECISION pressure rocket look: plate A (slim cased rocket, solid ice-blue rim lines + nose band) over B (bulbous warhead, rim too thin to read at 32 px/m, tilted body). C still generating for the record.
- 12:10 ASTRA deflect 61 accepted. Staged all, committed nothing (commit deadline missed: full scenarios ran 25+ min
  under load, then the hook's tool tests failed on load timing). I reviewed the diff (spread 12 -> 20 only; two test
  bounds re-derived from the configured half-angle; tool rows 4/6/8/12/20 m) and committed it myself:
  MILESTONE deflect `7d23e60c5` (data + tests + decision line) and `ae6a23d1c` (tool + `evidence/n26-pressure/deflect/share.md`).
  Unit full 3996 passed 0 failed 2 skipped; 68 scenarios passed over three runs; quest 1 + replay_60s pinned digests
  unchanged; rig_stress p50 1.123 ms vs 1 ms budget CONTENDED (5 other runs). Mutate 0/0: no mutants generated for
  `deflect_rule.gd` lines 34/55 (data-only change; the bound tests cover the read). Curve at 20 deg (guard/bat):
  4 m 40.7/52.2 %, 6 m 24.3/30.6 %, 8 m 16.4/19.2 %, 12 m 9.7/10.9 %. Owner's "about a quarter at 6 m" holds.
- FRICTION 12:11 hook tool-test flake (`timeout must kill a grandchild ...` under load): one retry passed, 2 min.
- 12:19 ASTRA RUNNING rocket-art since 12:19 (pid 80832, brief `evidence/briefs/n26-pressure-02-rocket-art.md`, hard stop
  13:25, commit by 13:15, out `evidence/briefs/n26-pressure-02-rocket-art.out.txt`). Briefs 03 trooper and 04 stall are
  written (fill HARDSTOP/COMMITBY), lessons from call 01 appended to both.

NEXT (session 2): (1) check `C:\Users\kazda\kiro\gtai-n26\logs\pressure\astra.lock` (pid 80832, process node) and
`astra-calls.jsonl`; when rocket-art ends: read its diff (view only, no digest move; war_cannon unchanged; Rivet's rocket
unchanged), LOOK at the four stills in `C:\Users\kazda\kiro\gtai-masters\n26\pressure\`, check sampled colours; commit
staged work yourself if it missed its deadline (pathspec commit). Log `ASTRA rocket-art <min> <verdict>`.
(2) launch brief 03 trooper (fill HARDSTOP/COMMITBY, Start-Process as at 12:19). (3) then 04 stall. (4) then item 5:
three medians (10 seeds each, noise floor per `docs/gauntlet-loop.md`) + one tuner cycle for the record (no retune).
(5) films brief (both rockets in a fight; deflect at 6 m; circling vs two troopers with and without dash, health bar in
frame) after the last behaviour change; last new work by 17:10, final gate by 17:25. Re-check items 3 after
`MILESTONE keys` in `C:\Users\kazda\kiro\gtai-wt\n23-controls\JOURNAL.md`. Art variant C still generating in
`gtai-art/pressure-n26` (copy from `~/.codex/generated_images/` by hand if it stalls; for the owner gallery only).
- 12:24 art C recovered by hand (`gtai-art/pressure-n26/out/enemy_rocket_c.png`, from `~/.codex/generated_images/01a207fe-...`):
  thicker casing with three ice-blue bands and a blunt nose; also good. A stays the build (in work, its full rim outline
  reads as a silhouette); C becomes a Call for the owner. FRICTION: all three jobs hit the known copy stall (15 min each,
  gen.mjs then stopped "3 failures in a row"); each copied by hand, ~3 min.
NEXT addendum (session 2): after rocket-art lands, a short follow-up (`--resume`) cuts plate C with the same tool to a
scratch dir (not wired) and makes one 32 px/m still of A vs C in flight for Call "rocket A or C" (one file swap).
- 12:26 FINDING stall lead (from `evidence/n23-loop/moves/on/runs/*.json`): every stalled run's frozen wave has no `rivet`
  form time, and Ohm + Tonnage accumulate together (average-9 w40 423.4 / 418.9 s, expert-1 w33 498.8 / 496.35 s,
  average-8 w40 284.7 / 531.7 s; hp min = max). Rivet is stuck in a ghost form where no one hurts anyone. n24 turned
  `transform_unlocked` off in the gauntlet (may hide it on HEAD); melee's earned transformation tonight would bring it
  back. Brief 04 now carries this lead and the ownership rule (souls code = melee's: NEED + pending test, not an edit).
  NEED melee may follow from call 04.
- 12:27 session 1 end. ASTRA RUNNING rocket-art since 12:19 (pid 80832 = node, alive; hard stop 13:25). No Godot of mine.
NEXT: as written at 12:19 (session 2 list) + the 12:24 addendum (cut plate C for an A-vs-C call still) + brief 04 carries
the stall lead. Order after rocket-art: 03 trooper, 04 stall, item 5 medians, films, gate by 17:25.

## Session 2 (12:22 to 13:52)

- 12:22 start. ASTRA rocket-art alive (pid 80832 node, lock 12:19). No NEED pressure in the four other journals; no MILESTONE keys yet.
- 12:40 CORRECTION stall lead: the missing `rivet` key is an artifact (bot_street_stats.gd keys only ghost forms); the real signal is 816-995 s settled in Ohm/Tonnage in the frozen wave. Appended to brief 04.
- 13:23 ASTRA rocket-art 64 bounced (commits kept: `b370c3ba4` art + cut tool `tools/art/enemy_rocket_cut.py --check`,
  `dab47bef7` wiring + tests; unit full 4000 pass; replay_60s / quest 1 / movement tapes byte-identical; mutate
  fight_areas_art 2/5 = 40 %, survivor `and`->`or` routing at line 86). Looked at all four stills: shape and colours right
  (rim and jet sampled `#92c9f5`, casing `#585f61`, Rivet's jet `#e5a12e`), but at 32 px/m the enemy rocket is a ~30 px
  dark sliver, Rivet's size, weaker than the old blob: fails "reads large". Sent back: 1.4 m body, ~1 m jet, soft
  ice-blue under-glow, a routing test, re-made stills, plate C scratch still for the owner call if time.
- 13:24 ASTRA RUNNING rocket-read since 13:24 (pid 77404 node, `--resume`, brief `evidence/briefs/n26-pressure-02b-rocket-read.md`,
  hard stop 14:20, commit by 14:10, out `evidence/briefs/n26-pressure-02b-rocket-read.out.txt`).
- 13:32 DECISION pressure schedule: 03 trooper and 04 stall get ~60-75 min each with small batches (brief 03 now carries a
  time budget: arena <= 8 combos x seeds 1-3; gauntlet average x10 waves<=12 for control + 2 candidates, then the shipped
  one on novice/expert waves<=6 for the "no rocket death before wave 6" check). Item 5 (three medians, 10 seeds x 3
  profiles, salt 0 and salt 1 for the floor, ~32 min at 15 runs / 8 min; + one tuner cycle in its temp worktree) is run
  by me, not Astra, after 04 lands; if the day runs short, the tuner cycle is the part that is cut (said in REPORT).
NEXT (session 3, from 13:52): (1) `astra.lock` pid 77404 (node) = rocket-read, hard stop 14:20. When it ends: read the
diff, LOOK at the four re-made stills (32 px/m: enemy rocket visibly larger than Rivet's, pops off asphalt) and
`rocket-a-vs-c-32.png` if made; commit anything staged by pathspec; log `ASTRA rocket-read <min> <verdict>`; MILESTONE
rocket <sha>. (2) launch brief 03 trooper (times filled: hard stop 15:35, commit 15:20; shift them if it starts late)
with Start-Process exactly as at 13:24 (no `--resume`: a fresh thread). (3) then 04 stall (fill HARDSTOP/COMMITBY).
(4) item 5 by me. (5) films brief (both rockets in a fight; deflect at 6 m; circling vs two troopers with/without dash,
health bar in frame; 32 px/m tilt 70 1080p60 15-40 s, 64 px/m still each; `frames.json`). Commit last work by 17:10,
gate `node tools/gate/run.mjs --rev=HEAD` by 17:25. Check `n23-controls/JOURNAL.md` for `MILESTONE keys` (re-check 03).
- 13:44 rocket-read committed `d42706a60` (1.4 m casing, ~1 m ice jets, re-cut) and `41eccb33e` (ice rim under-glow,
  draw-ownership test). LOOKED at the re-made stills: at 32 px/m the trooper's rocket is now clearly larger than Rivet's,
  steel casing with an ice rim that pops off the asphalt, ice-blue jet, no amber; Rivet's amber exhaust unchanged.
  Accepted on look. `rocket-a-vs-c-32.png` made (A slim pointed, C blunt banded): Call for the owner.
- 13:51 session 2 end. ASTRA RUNNING rocket-read since 13:24 (pid 77404 node, finishing runs/mutate; hard stop 14:20).
NEXT (session 3): read `evidence/briefs/n26-pressure-02b-rocket-read.out.txt` (mutate scores, digests unchanged?), check
no staged leftovers, log `ASTRA rocket-read <min> accepted` + `MILESTONE rocket 41eccb33e` (or later sha), then the
13:32 NEXT list from (2): brief 03 trooper (shift its 15:35/15:20 times if it starts after 14:20), 04 stall, item 5 by me,
films, last work 17:10, gate 17:25.

## Session 3 (13:52 to 15:21)

- 13:52 start. ASTRA rocket-read still alive (pid 77404 node, lock 13:24, hard stop 14:20); out file empty so far, tree has
  no staged/modified tracked paths. MILESTONE keys 8d8bb3787 seen (12:24): the test players press actions, re-check 03 after.
  No NEED pressure in the other four journals.
- 13:56 ASTRA rocket-read 31 accepted (1885 s; commits `d42706a60`, `41eccb33e`; unit 3986 pass / 0 fail / 2 skip;
  mutate routing 3/4, art 3/5 (survivors: lift sign, halo deletion, halo offset: placements checked on the stills);
  war_cannon byte-identical to `0779185ac`; replay_60s and quest 1 byte-identical). MILESTONE rocket 41eccb33e.
- 13:56 ASTRA RUNNING trooper since 13:56 (pid 80132 node, fresh thread, brief `evidence/briefs/n26-pressure-03-trooper.md`
  + 13:57 addendum, hard stop 15:12, commit by 14:55, out `evidence/briefs/n26-pressure-03-trooper.out.txt`).
- 13:56 DECISION pressure schedule: item 5 batches are ~16 min per 30 runs on today's balance (n24 final: 15 runs in
  477 s), so salt 0 + salt 1 = ~32 min; that fits after 04 (target 16:40) and before the 17:25 gate. Films after the gate.
- 14:06 DECISION pressure order (lesson n24: the final gate held the lane's one Godot 84 min and the films were never
  made): 03 trooper (to 15:12) -> 04 stall (fresh, ~15:15-16:30) which ALSO runs item 5's two batches (salt 0/1, 10 seeds
  x 3 profiles, waves 40) + `tune.mjs floor` on its final state (= the re-run of the stalled seeds) -> 05 films
  (~16:30-17:22, its dev take committed by 17:00; after the last behaviour change) -> gate 17:25 on that HEAD ->
  REPORT. "Tuner cycle for the record" = `tune.mjs propose` on the salt-0 batch by me (node only, nothing applied).
  Briefs: `evidence/briefs/n26-pressure-04-stall.md` (step 8), `evidence/briefs/n26-pressure-05-films.md`.
- 14:36 trooper committed `82dbc7258` (orbit lead model as data `lead_model`, default linear; arena + gauntlet probes) but
  SHIPPED NOTHING NEW (1.4 s linear kept): it read (c) as "no rocket last blow" and novice seed 4 died by a rocket at
  wave 5. Read `gauntlet.json`: that run's only rocket hit all run was the killing blow in the stomp wave (9/10 novices
  die at wave 5 in every arm). Rocket-only deaths: 0. Arena: linear misses every circle (0/42, 0/48), orbit hits every
  circle (42/42, 48/48) and every dash dodges (0/42, 0/48). DECISION pressure trooper: ship orbit at 1.1 s (brief's
  rule: closest to (a): average 0.205 vs 0.141 at 1.4 orbit), 1.4 s one value away; the harshness (a steady circler
  dies in seconds) is measured in 03b and goes to Calls for the owner with the circle film. Follow-up brief
  `evidence/briefs/n26-pressure-03b-trooper-ship.md` (`--resume`) after the call exits.
- 14:48 ASTRA trooper 52 bounced-in-part (3122 s; commits `82dbc7258` lead model + probes + tests, `ce195a82f`
  verification; unit full 4004 pass / 2 pending; scenarios 68/68; quest 1, prologue, replay_60s unchanged; mutate
  13/14 = 92.9 % (survivor: the error-log condition). Bounced only the ship decision (see 14:36).
- 14:49 ASTRA RUNNING trooper-ship since 14:49 (pid 66184 node, `--resume`, brief
  `evidence/briefs/n26-pressure-03b-trooper-ship.md`, hard stop 15:28, commit by 15:08).
- 14:52 Briefs timed: 04 stall hard stop 16:42, fix commit 16:02, batches start by 16:05; 05 films hard stop 17:22,
  commit 17:00. Shift both by the delay if 03b ends late (keep 05's end <= 17:22: the gate starts 17:25).
- 15:07 ASTRA trooper-ship 18 accepted (1092 s; `6288453ee` rocket `cooldown_s` 1.4 -> 1.1, `lead_model` orbit; arena
  10 m: circle 48/48, dash 0/48; a steady circler loses 75.46 HP in 10 s and dies at 13.30-13.47 s (one trooper);
  gauntlet average 0.205 hits per trooper, rocket-only early deaths 0/21; test bounds: 15-16 launches / 30 s, circle
  >= 14 hits, standing every launch, dash 0; unit 3988 pass; 23 selected scenarios pass; quest 1 tapes and replay_60s
  pinned hash held; mutate rocket_lead 12/14 = 85.7 % (survivors: error log, model selection)). MILESTONE trooper 6288453ee.
  Call for the owner: harshness of the steady circle (13 s to death vs one trooper); rest 1.4 s orbit is one value.
- 15:08 ASTRA RUNNING stall since 15:08 (pid 47220 node, fresh thread, brief `evidence/briefs/n26-pressure-04-stall.md`
  with step 8 = item 5 batches; hard stop 16:22, fix commit 15:52, batches start by 15:55;
  out `evidence/briefs/n26-pressure-04-stall.out.txt`).
- 15:10 session 3 end. No Godot of mine.
NEXT (session 4): (1) `astra.lock` pid 47220 (node) = stall, hard stop 16:22. When it ends: read its out file + diff
  (cause file:line, test red-then-green, fix owner: if souls/player code -> pending test + NEED melee/keys line in this
  JOURNAL), check `evidence/n26-pressure/medians/` (salt0, salt1, floors.md, medians.md; no tick-cap/freeze runs), log
  `ASTRA stall <min> <verdict>`. Then run `node tools/gauntlet/tune.mjs propose --batch=<abs>/evidence/n26-pressure/medians/salt0/batch.json --out=<abs>/evidence/n26-pressure/medians/plan.json --profile=all --metric=death`
  myself (node only; the tuner's record; NOTHING applied) and quote it in REPORT. (2) Launch 05 films (fresh, Start-Process,
  brief `evidence/briefs/n26-pressure-05-films.md`, hard stop 17:22, commit 17:00; shift earlier if 04 ends early, never
  later than 17:22). Before it: if 04 touched combat/squad or ai, fine, films come after. (3) 17:25 gate
  `node tools/gate/run.mjs --rev=HEAD` (Godot is mine; ~85 min last night; if a markerless `%TEMP%/gtai-gate-<sha>`
  breaks it, `git worktree remove --force --force` it). (4) LOOK at every film; frames.json; REPORT by 18:50 with
  Calls: rocket A vs C (`rocket-a-vs-c-32.png`), trooper rest 1.1 vs 1.4 orbit (harshness), deflect curve
  (`evidence/n26-pressure/deflect/share.md`: 6 m guard 24 %, bat 31 %). `node tools/evidence/cites.mjs REPORT.md`.

## Session 4 (15:10 to 16:39)

- 15:11 start. ASTRA RUNNING stall since 15:08 (pid 47220 node alive, hard stop 16:22). No Godot of mine. Waiting.
- 15:47 stall fix committed by Astra `bf32bfd1a` (call still running step 8 batches). Read the diff and `evidence/n26-pressure/stall/cause.md`:
  reproduced average-9 on `548989d7e` byte for byte; at tick 77115 a Kerf slice picked a target from the bot's float aim,
  but the pilot decodes the 256-heading wheel aim and Kerf picked a different foe beside the wall; the slice landed Rivet
  beyond the street's south wall (y 7.6, wall 6-7); from there nobody has sight (40 hostiles, Rivet), forms keep him on
  the same side -> tick cap. Fix (ours): `bot_view_arena.gd:96` and `bot_arena_moves.gd:54` predict with the decoded
  heading; `gauntlet_combat.gd` `report_bot_freeze` ends a headless bot run with an error after 60 s live combat without
  HP loss (no result written, so a batch cannot score survival). Paired replay: before tick cap 216000, after exit 0 at
  82694. Tests: `test_gauntlet_kerf_wall` (bot pair red on old code, green now; player crossing pending for melee),
  freeze clock in `test_gauntlet_enemy_damage`. A human with Kerf unlocked CAN cross the wall the same way.
- NEED melee: `project/features/souls/kerf_stage.gd:~118-125` lets a Kerf slice land Rivet beyond a thin wall
  (`KerfBehind.resolve` + destination-only `eject_circle`). Validate the travel segment with `KerfBehind._clear` before
  `_cut_path`/move; blocked blink stays at origin. Patch as text + pending test `test_gauntlet_kerf_wall.gd`
  `test_player_kerf_slice_keeps_the_street_in_reach`: `evidence/n26-pressure/stall/cause.md` (branch n26-pressure).
