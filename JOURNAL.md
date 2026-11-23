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
