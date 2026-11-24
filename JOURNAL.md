# JOURNAL lane keys, run n28 (2026-11-24 16:40 to 00:40)

- 16:27 START iteration 1. Branch n28-keys at d0ab9d03a. No builder lock, no builder-calls.jsonl yet. IMAGES 0/60.
- 16:33 DECISION keys-dash: dash.cooldown_ticks 40 -> 24. Dash 10 ticks + 24 = a 34-tick press-to-press cycle, under the
  36-tick shortest gap between two troopers' rockets (n27-pressure REPORT section 2: 36 to 49 ticks after 10 s in seeds 3, 5),
  with 2 ticks of margin for the reaction and any off-by-one in when the cooldown starts. Rejected 26 (cycle exactly 36, no
  margin) and 20 (spammable faster than needed). The alternative is the one data value.
- 16:28 BUILDER RUNNING n28-01-dash since 16:28 (node pid 26160, out evidence/briefs/n28-01-dash.out)
- 16:33 Briefs drafted while the dash call runs: n28-02-homing-shard (sheet-sized edit test, legs-kept composite, cap 10
  images), n28-04-gloria-brass (concept + strips + held art, cap 12), n28-05-collar-p55 (edit + collar-only composite, cap 8).
  Gloria's own grid (part B) waits for the homing shard route verdict. The p55 run sheet audit by eye: rows 1, 2, 5, 6, 7 draw
  the collar as rope or a knotted scarf; rows 0, 3, 4 read rigid.
- 17:37 BUILDER n28-01-dash 69 $0.59 accepted (partial: value, test, decision line committed; full suites, after trace and
  mutate not run, every Godot launch waited on mem-budget from 16:44).
- 17:37 MILESTONE keys-dash 64004a59d (dash.cooldown_ticks 40 -> 24; measured shortest press to press 34 ticks by
  test_shortest_press_to_press_gap_is_burst_plus_cooldown_and_covers_a_rocket_pair; evidence 38d76f7f7).
- 17:37 FRICTION mem-budget 53 (the builder's Godot runs waited from 16:44 to 17:37; cap status 7132/8192 MB used at 17:37,
  peak 9082). git show also failed once: "packfile cannot be mapped: File too large" (memory pressure).
- 17:38 BUILDER RUNNING n28-02-homing-shard since 17:38 (node pid 11896; out evidence/briefs/n28-02-homing-shard.out).
  Brief: Part 0 = the dash checks (focused unit select + after trace, 15 min max), then the homing shard test (sheet-sized
  edits of the plasma rifle walk/run, legs-kept composite, ship only if all 16 rows pass; commit by 18:35, END 18:52).
- 17:40 NEXT: (1) when n28-02 ends (lock gone): read its report and diff, look at grid_homing_shard_64.png myself
  (hands on the weapon, rigid collar, no extra limb, sole travel = donor); log BUILDER line. (2) If it shipped: brief the
  next four weapons in the route it recommends (two weapons per call if each took < 30 min; mini-nuke, molotov, plasma
  sword, ray gun), image budget 60 - used. If it failed: decide per-row edits for the homing shard only if the images left
  allow Gloria (12) + collar (8). (3) Gloria brass brief ready: evidence/briefs/n28-04-gloria-brass.md ({COMMIT1},
  {COMMIT2}, {END} placeholders); collar brief ready: n28-05-collar-p55.md ({COMMIT}, {END}). Gloria's own grid (part B)
  brief not written yet: same route as the weapons, donor = the pistol's p70 walk/run sheets, then flip
  walk_grid.by_weapon.gloria. (4) Dash film with two troopers still owed (pressure_dash_trace after column, a 32 px/m clip).
  (5) Watch the RAM cap (GTAI_CAP_STATUS): at 17:37 it was 7.1/8.2 GB used; every Godot waits.
  Last new work committed by 22:40, final gate started by 22:55.
- 17:42 FRICTION self: committed JOURNAL.md (781177fbc) with --no-verify by mistake; docs-only path, no code. From here every commit runs the hook.

## Session 2 (18:01, iteration 2, BUILD)
- 18:01 START. n28-02-homing-shard ended 17:44 exit 1 after 336 s, $0.64: "You've hit your weekly limit · resets Nov 25,
  10pm". All four lanes lost builder.mjs at the same minute (yard's journal 17:44). Nothing committed by it; its round
  `gtai-art/rivet-n28/homing_shard/` holds Edit A (walk + run sheet edits, 2 images) and a cut of the walk sheet.
- 18:01 BLOCKED builder: builder.mjs (Sonnet account) out until Nov 25 22:00.
- 18:01 BUILDER n28-02-homing-shard 6 $0.64 abandoned (weekly limit). IMAGES 2/60.
- 18:03 DECISION builder fallback (same as yard 17:55): an in-session Sonnet subagent (the owner's builder model) builds
  from the brief files; I keep directing, reviewing and gating and never edit product files. Calls end 15 min before my
  session stop (19:31). Rejected: me editing product files (owner's rule), stopping the lane (never block), Codex/Astra
  (forbidden tonight).
- 18:03 Looked at cand1/montage_walk.jpg: raw walk cells read right (shard in hands, donor legs); legs-kept cells keep the
  plasma rifle's stock below the seam (fails "no remnant"). Run sheet edit at thumbnail: strides as donor; back rows may
  draw the collar twisted: check at full size.
- 18:04 BUILDER RUNNING n28-02b-homing-shard-finish since 18:04 (in-session Sonnet subagent, brief
  evidence/briefs/n28-02b-homing-shard-finish.md, grids commit by 18:50, END 19:12). Cap 3.1/8.2 GB at 18:01.
- 18:03 Dash check (me, while the builder does images): `node tools/tests/run_unit.mjs --select=test_pressure_takes,test_bot_dash,test_player_motion_dash`
  -> "22 passed, 0 failed" (26.7 s). `pressure_dash_trace --seeds=3,5,1` at cooldown 24 -> evidence/n28-keys/dash_trace_after.md:
  HP lost after 10 s seed 3: 2.7 (n27 at 40: 48.5), seed 5: 1.5 (40.5), seed 1: 3.4 (3.4). The dash now covers the pair.
- 18:24 BUILDER n28-02b-homing-shard-finish 21 n/a accepted (3ea5cf48c grids, 6d27d55a0 evidence). IMAGES 2/60 (Edit A
  only, 16/16 rows raw). I looked at grid_homing_shard_64.png: shard in both hands every facing, donor legs and soles, no
  rifle remnant, collar as the donor's. foot_slide 32 px/m walk 1.09 / run 5.44 cm (plasma rifle 5.63 / 4.35, measured at the
  rig film's own lane speeds). Not done: temp-worktree before (it flipped by_weapon in place and reverted), row labels garbled.
  Mutate: no code changed (art + data rows), none owed.
- 18:25 DECISION weapon donors: plasma rifle sheets for all four (the owner's words), image 2 = each weapon's equipped
  strip. Mini-nuke + ray gun first (rifle grip); molotov + plasma sword next call, with the builder's note that one-hand
  weapons may want the pistol/katana donor if the rifle route fails their bars.
- 18:26 BUILDER RUNNING n28-03-nuke-ray since 18:26 (in-session Sonnet subagent, brief evidence/briefs/n28-03-nuke-ray.md,
  END 19:14).
- 19:07 BUILDER n28-03-nuke-ray 42 n/a accepted-partial: mini-nuke 2f5dde79d (grids) + 82760ae9e (evidence); ray gun not
  shipped (its walk edit never returned, the run edit stalled on the copy: image under ~/.codex/generated_images, see the
  round STATE.md). IMAGES 6/60 (homing 2, mini-nuke 2, ray gun 2 attempted).
- 19:07 I looked at grid_mini_nuke_64.png: the striped tube in both hands in all 8 facings, donor legs and soles, collar as
  the plasma rifle's. Missing: the stop-gap column (owed, brief n28-03b). Row labels overprint.
- 19:08 DECISION mini-nuke run foot slide 7.62 cm vs the 7 cm bar: accepted. The legs are the donor's (sole y 0 px, raw
  cut), the number comes from the rig film's profile lane at 3.2 m/s (not the game's 9.3), where the donor itself peaks
  at 7.69 and the donor's walk (5.63) is worse than the edit's (1.52): the measure is noisy at that lane speed, not a
  visible slide. The alternative is one data value: `walk_grid.by_weapon.mini_nuke: "bare_claw"` puts it back on the
  stop-gap. Goes to REPORT "Calls for the owner" with the clip.
- 19:08 Observation: in the p70 back rows (facings 4, 7) the shipped plasma rifle sheet's collar has spiral-looking stripes;
  the edits copy it. The owner's pick names p55 only; noted for REPORT, not changed.
- 19:09 FRICTION builder in-session: a subagent dies with my session, so no call can start after ~19:10 in a session that
  ends 19:31. Each session hosts about one 60-minute call.
- 19:10 NEXT (session 3): (1) no builder is running (both in-session calls ended). (2) Launch the ray gun finish
  (evidence/briefs/n28-03b-ray-gun.md, fill {END}/{COMMIT1}; ~35 min), then molotov + sword
  (evidence/briefs/n28-06-molotov-sword.md, fill {END}/{COMMIT1}/{COMMIT2}/{CLIP}). One call at a time, as an in-session
  Sonnet subagent (Agent tool, model sonnet, background), each ending 15 min before the session stop. (3) Then Gloria brass
  (evidence/briefs/n28-04-gloria-brass.md: add the in-session header "cd to the worktree in every command", fill
  placeholders), then the p55 collar (n28-05-collar-p55.md), then Gloria's own grid (brief not written: the same sheet route
  from the pistol's p70 sheets, then flip walk_grid.by_weapon.gloria). Order by the owner: weapons, Gloria, collar.
  If time is short, the collar (8 images, art-only composite) is cheaper than Gloria's grid. (4) Dash: milestone done,
  trace after in 4240207bf; combat lane merged 64004a59d for its two-trooper take: cite their film in REPORT.
  Last new work committed by 22:40, final gate (`node tools/gate/run.mjs --rev=HEAD`) started by 22:55.
- 19:08 BUILDER RUNNING n28-03c-ray-prep since 19:08 (in-session Sonnet subagent, prep only: copy the run edit, fix the
  prompt, one walk edit, cut; no repo change; END 19:25). If the session is replaced first: read the round STATE.md
  (`gtai-art/rivet-n28/ray_gun/STATE.md`) for its state; it commits nothing.
- 19:23 BUILDER n28-03c-ray-prep 15 n/a accepted (prep only): run edit copied to the round's out/; a ray-gun-only
  scripts/mkjobs.py with the fixed one-hand prompt; jobs.json = walk job only. The walk edit did not return in 12 min
  (second time: 18:46 and 19:08); its processes freed by PID. IMAGES 7/60 counting attempts.
- 19:23 FRICTION image tool: the ray gun walk-sheet edit has not returned twice (12-15 min each, nothing under
  ~/.codex/generated_images). If it fails a third time in session 3: try a 4-row half sheet (rows 0-3, then 4-7) instead.
- 19:24 NEXT (session 3): no builder running. Start with brief n28-03b-ray-gun.md (round STATE.md "Next" line has the
  exact commands), then n28-06-molotov-sword.md, then Gloria brass, collar p55, Gloria's grid; see 19:10 NEXT for the rest.
