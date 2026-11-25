# JOURNAL - lane melee, run n31 (2026-11-25 night)

Branch `n31-melee`, worktree `gtai-wt/n23-street`, base `ba8e470b0`. APPDATA `C:/Users/kazda/kiro/gtai-n31/appdata/melee`.
Gate slot: ground first, foes +10, **melee +20 min** after ground's start. Commit last work by 06:00, gate by 06:15.
Lane Godot lock: `build/n31/godot.lock` (one line `<tag> <pid> <time>`, created exclusively, removed after; > 30 min old = stale).

## Session 1 (20:57 - 22:27)
- 20:57 START. Read AGENTS, decisions tail, log. No `NEED melee` in ground/foes/ghost journals.
- 20:57 Verified on main: `player_melee.gd:_land` tests from `arena.rivet.pos`, reach_m + radius, cone_dot; `melee_combo.gd:lands()` true only at `tick_in == windup` (or grind every grind_ticks). Existing tools: `tools/film/swing_measure.gd` (cadence only), `tools/film/owner_takes.mjs`, `tools/gauntlet/pressure_films.mjs`.
- 21:05 BUILDER RUNNING 01a (opus, blade volume lab + polar plots + in-play count, before) since 21:05
- 21:05 BUILDER RUNNING 01b (sonnet, enemy melee reach on Rivet + gauntlet melee kills/swing baseline + before take) since 21:05
- 21:05 IMAGES 0/60
- 21:03 Drafted evidence/briefs/n31-melee-02-sweep.md (waits for 01a before table). Quest 1 stage is boot/collect_call/* (CollectCallStage, not ArenaStage): item 3 needs its own install there. SignatureKills.on_kill picks by weapon deterministically (table.for_weapon), so wiring the hook is the main gap.
- 21:42 BUILDER 01a 38 accepted-partial: timing numbers sound (single test tick; cut drawn 2-6 ticks after it), drawn geometry overlay FAILS (baton line off, claw crescent at feet), katana/plasma/saw strip blades unmeasured. Commits 18c2c7393, 7bd951964. Brief differently: ask for pixel-based drawn volume from the start.
- 21:42 MILESTONE before numbers: 01b baseline kills/swing claw .795 saw .787 baton 1.04 katana .994 plasma 1.238 (waves 1-4, seeds 1-5); enemy melee hits land with Rivet's centre up to 0.58 m past the drawn tip but never with his whole body past it (body contact, fair).
- 21:45 DECISION melee n31 item order: item 2's sweep is built behind `--melee-sweep` (off) while the drawn-volume measure is rebuilt from pixels (01c); the flag flips on only when 01c's after shows drawn-no-hit 0 and the guard rail holds. Reason: the timing defect (single hit tick, cut drawn 2-6 ticks after) is measured and sound; the geometry bar is not yet measurable.
- 21:45 BUILDER RUNNING 02 (opus, sweep part 1 behind --melee-sweep off) since 21:45
- 21:46 Brief ready: evidence/briefs/n31-melee-01c-pixels.md (pixel-based drawn volume, before from a temp worktree at ba8e470b0). Launch first thing next session.
- 21:52 BUILDER 01b 47 accepted: commits 30e70f80c (baseline), 88eff8d46 (foe reach), 0e29f606f (before takes: gtai-masters/n31/melee/before_play_{katana,plasma_sword,claw}.mp4, 35 s each, seed 7; re-run `node tools/melee/play_take.mjs --label=after --frames=2100`). Caveat: plasma/claw takes ran while 02's sweep edit (flag off) was in the tree -> byte-identical by design, verify later. Enemy melee: authored reach used as drawn tip (rig/card strike not measured in metres); no hit with Rivet's whole body past the tip. NEED foes (informational) noted.
- 21:52 FRICTION lane-tree-shared: builders' live edits leak into other builders' Godot runs (films). Next briefs: films via `--rev=<sha>` snapshot or a temp worktree.
- 21:56 BUILDER scout-03 (sonnet Explore, 2 min) accepted: fatality wiring plan folded into evidence/briefs/n31-melee-03-fatalities.md. Key: install BrutalityHook after GauntletCombat.install (it replaces stage.arena); nothing attaches hook views in the gauntlet (do it in features/gauntlet/gauntlet_view.gd); `--gore` rejected by dev/gauntlet/gauntlet.gd KNOWN_FLAGS (read-only tonight).
- 21:56 NEED director: add "--gore" to project/dev/gauntlet/gauntlet.gd KNOWN_FLAGS (dev/gauntlet is read-only for lanes tonight); until then the melee feed also reads LaunchArgs `--gore` before `--`.
- 22:14 BUILDER 02 30 accepted-partial: a607e0b77 `MeleeSweep` behind `--melee-sweep` (off): hit tested every drawn-cutting tick (window = CUT_TICKS before windup end .. 12 % into recovery), sector crossed since last tick from MeleeSwing.angle, struck set once per hit (state only when on). Tested ticks per hit: claw 2..8, baton 1..7, katana 4..11, plasma 5..15, saw 9..14 + grind 22,30 + 31..33. Full unit suite green flag off (4368 pass). NOT shown: scenario/replay digests (run timed out at 8 min). Reach still table reach_m (not drawn). Open: sweep follows RivetHeldView's angle (no swing_style) while RivetSwipeView uses swing_style - settle which the eye sees.
- 22:14 FRICTION incident: builder 02 killed another lane's Godot (n25-yard scenario run, PID 17904 + 7964, 49128) after its own timeout, without reading the command line. Ghost lane session messaged at 22:15. Every brief from now: "before killing a PID, print its CommandLine and kill only if it names this worktree's build/n31 or your own tool".
- 22:15 Foes' windowed Godot runs (res://dev/foes_n3*) are relative `--path project`: not ours, do not touch.

NEXT (session 2):
1. Launch 01c (evidence/briefs/n31-melee-01c-pixels.md, opus) at once: pixel-based drawn volume + overlay validation; before from a temp worktree at ba8e470b0.
2. In parallel (different files) launch 02 part 2 (sonnet/opus): run `node tools/tests/run_scenarios.mjs` flag off (allow 20 min) to prove no digest moves; settle the angle source (held vs swipe view); reach = drawn reach (grip + length_m + radius) and lift rivet_swipe_view REACH_MAX_M / shorten reach_m; katana lunge_ticks check; guard rail `node tools/melee/play_baseline.mjs --label=after` with `--melee-sweep` (needs the probe to pass the flag); pay back with recovery ticks if > +15 %.
3. When 01c's after on HEAD with the flag shows drawn-no-hit 0 / mover <= 5 % / hit-not-drawn <= 5 %: flip `--melee-sweep` default on (flag becomes `--melee-sweep=off`), re-pin digests with a dated decisions line, film after takes `node tools/melee/play_take.mjs --label=after --frames=2100` (+ 64 px/m slow clip per weapon with the hit volume drawn), frames.json.
4. Then item 3 (evidence/briefs/n31-melee-03-fatalities.md).
- 22:14 Ghost lane acknowledged the killed run; it re-runs its scenarios. No builder running at session end (none launched after 21:52, too little time left before 22:27).
