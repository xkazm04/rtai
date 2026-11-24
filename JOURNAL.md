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
- 19:23 Session 3 start. No builder running (lock empty, last builder.mjs call 17:44). Machine-wide, the newest image under
  ~/.codex/generated_images is 18:50 (the ray gun run edit).
- 19:24 BUILDER RUNNING n28-07-ray-molotov since 19:24 (in-session Sonnet subagent, brief
  evidence/briefs/n28-07-ray-molotov.md: ray gun walk by half sheets, pistol-sheet fallback, mini-nuke stop-gap column, then
  molotov; ray gun commit by 20:02, molotov by 20:28, END 20:35). It commits nothing if no image returns.
- 19:24 Combat's 19:12 finding (NEED keys): "the ATTACK CLAW prompt box covers chip numbers 1-3 in the game itself". Checked:
  that box is the bot film's act caption (`project/dev/test_player/gauntlet_bot_film.gd` `_caption()`, `_label.text =
  tr(bot.act())`), dev-only, not in the shipped game; their still is from that film. Not a keys fault; the caption is
  combat's dev film. The real keys part: chip 1's plate sits at the left screen edge (the known 4 px overhang, brief item 5).
- 19:25 Briefs n28-04 (Gloria brass) and n28-05 (collar p55) now carry the in-session builder header; their {COMMIT}/{END}
  placeholders are filled by the session that launches them. Time plan: session 4 (~20:52-22:22) hosts ONE call of about
  70 min; session 5 starts the final gate by 22:55. Image jobs are 4-15 min each, so a 12-image Gloria call will not fit:
  give it concept (<=2) + p70 strips (<=3) + held art, p55 strips only if time remains. Idea for the next session: have
  a builder start the next weapon's image job detached (PowerShell Start-Process on gen.mjs) before it ends, so the image
  waits for the next call instead of the next call waiting for it.
- 20:11 BUILDER n28-07-ray-molotov 47 n/a accepted-partial: ray gun 011e504f6 (grids) + 7e6918fd3 (evidence; mini-nuke
  stop-gap column added). Molotov not shipped (run row 1 edit 30 % short, foot_slide run 10.77 cm > 7); round resumable.
  IMAGES 7 this call (ray gun 4 + the run sheet of session 2, molotov 2) -> 13/60 counting attempts.
- 20:10 I looked at grid_ray_gun_64.png: the ray gun in one hand in all 8 facings walking and sprinting, donor legs and
  soles, collar as the plasma rifle's, no rifle remnant; clearer than the stop-gap's ghosted gun. foot_slide 32 px/m walk
  0.39/1.56 cm (rifle 0.60/1.56), run 6.35/8.26 (rifle 6.69/8.93).
- 20:10 DECISION ray gun leg IoU: shipped with walk rows 1, 2 at 0.80/0.81 and run rows 1, 2, 6 at 0.82-0.84 against the
  0.85 bar; sole y exact on 96/96 cells and foot_slide better than the donor, so the misses are pixel drift inside the boot
  outline, not stride. Alternative is one data value (`walk_grid.by_weapon.ray_gun` back to the stop-gap). For REPORT.
- 20:10 FRICTION image tool: codex writes the image after 4-6 min, then never copies it to out/ and never exits; the
  builder copies by hand. The full-sheet ray gun walk produced nothing (twice); half sheets worked.
- 20:10 BUILDER RUNNING n28-07b-molotov-run since 20:10 (in-session, one run-sheet re-edit, commit only if passes by
  20:22, END 20:37).
- 20:11 I looked at grid_molotov_64.png (hybrid, not shipped): the lit bottle in one claw in all 8 facings, the other claw
  free, flame amber only, collar rigid, donor legs. The look is right; only run row 1's stride length fails (foot_slide).
- 20:18 BUILDER n28-07b-molotov-run 8 n/a bounced: the re-edited run sheet draws row 1 short again (raw leg IoU
  0.55-0.89; a prompt line does not fix it). Nothing committed. IMAGES 14/60.
- 20:19 BUILDER RUNNING n28-07c-molotov-row1 since 20:19 (in-session, prep only: one row-1 image, cut, IoU, composite
  into final2; commits nothing; END 20:37).
- 20:22 NEXT (session 4, ~20:52-22:22; it hosts one builder call of ~70 min, END by 22:07; session 5 commits only
  until 22:40, starts the final gate `node tools/gate/run.mjs --rev=HEAD` by 22:55, then films + REPORT):
  (1) Read the n28-07c report in `gtai-art/rivet-n28/molotov/STATE.md` (that call commits nothing; no builder runs after
  20:37). (2) One call, brief to write (n28-08): part A finish the molotov from STATE "Next" (wire, capture, foot_slide,
  commit by ~21:25); if row 1 still fails, DECISION: ship row 1 from the donor-leg hybrid only if foot_slide <= 7, else
  leave the molotov on the stop-gap and say so. Part B Gloria brass: brief n28-04 trimmed to concept (<= 2 images) + p70
  held strips (<= 3) + held art; start the concept image in the background while part A's Godot work runs. Fill
  {COMMIT1}/{COMMIT2}/{END}. (3) Not reachable tonight at this image speed (4-6 min per image, one call per session):
  plasma sword grid, Gloria's own walk grid, the p55 collar, Gloria p55 strips: REPORT "Next steps" with the round
  states. If session 5 has room before 22:40, the p55 collar (n28-05, art-only composite) is the cheapest of them.
  (4) Five-weapon 32 px/m clip (only shipped grids: homing shard, mini-nuke, ray gun, molotov if shipped) after the gate.
  Ledger so far: BUILDER n28-07 47 min accepted-partial, n28-07b 8 min bounced, n28-07c running. IMAGES 15/60 with 07c.
- 20:25 BUILDER n28-07c-molotov-row1 7 n/a accepted (prep): a one-row edit fixed run row 1 (leg IoU 0.844-0.887 per cell,
  was 0.55-0.74); composite `gtai-art/rivet-n28/molotov/final3/`. IMAGES 15/60. Lesson: a row the full-sheet edit draws
  short is fixed by a one-row job, not by a prompt line.
- 20:26 BUILDER RUNNING n28-07d-molotov-wire since 20:26 (in-session: wire final3, capture, foot_slide; commits only if
  it can start by 20:31, else leaves wired files UNCOMMITTED in the tree, listed in molotov/STATE.md; END 20:44).
  Session 4: if `git status` shows uncommitted molotov files, check STATE.md numbers and have the next call commit them.
- 20:31 BUILDER n28-07d-molotov-wire 5 n/a bounced (not committed): walk passes (hold 0.43/1.56 cm, rifle 0.60/1.56), run
  fails (step 10.94/20.31 cm, rifle 6.69/8.93), the same number as before the row-1 fix (10.77/20.3), so row 1 is NOT
  what the foot-slide lane measures or not the cause. Per-column output: build/fs_molotov.json.
- 20:31 UNCOMMITTED in the tree (left by n28-07d, on purpose): p70 `rivet_walk_eq_molotov.png(.import)`,
  `rivet_run8_eq_molotov.png(.import)`, `rivet_motion.json` (molotov rows), `test_rivet_grid_stride.gd` (3 pins),
  `steam/ai-provenance/2026-11.jsonl` (2 lines). run_unit --changed 714 passed with them.
- 20:32 NEXT (session 4, replaces the 20:22 NEXT item 2 part A): first brief (n28-08) part A = molotov: from
  build/fs_molotov.json find which strip row/cells the 32 px/m foot-slide lane reads and why it slips (compare the
  ray gun's wiring: it KEPT run_row_k at 1 for the flagged rows, this one dropped them; check the run cells of that row
  against the donor's legs); fix by putting the donor's legs under the edited arms in the slipping cells (82 % seam as
  final2), re-wire, re-measure; commit if run <= 7. Fallback DECISION if it still fails by ~21:25: commit walk-only
  (drop the run8 png, its provenance line and its rows so the run stays the stop-gap) and say so; never leave the files
  uncommitted past session 4. Then part B Gloria brass as in the 20:22 NEXT. IMAGES 15/60. No builder running now.
- 20:30 BUILDER RUNNING n28-07e-molotov-slip since 20:30 (in-session, diagnosis only, commits nothing, END 20:45; its
  result goes to `gtai-art/rivet-n28/molotov/STATE.md` "Next"). If this session ends first, read that file.
- 20:32 BUILDER n28-07e-molotov-slip 5 n/a accepted (diagnosis + fix, uncommitted): cause = run row 1 (the strip row
  the foot-slide lane reads) had soles shifted sideways ~14 px in 6 cells; the earlier "unchanged" re-measure was a stale
  texture (a recapture does not re-import: always `--import` before a recapture). final4 = donor legs under the edited
  arms in those 6 cells, installed in the tree; run step 6.03/8.93 cm (rifle 6.69/8.93), walk hold 0.43/1.56. Provenance
  line updated. Not yet: the 64 px/m candidate capture, my look at the row-1 seam, evidence md, commit.
- 20:33 NEXT (session 4): part A of n28-08 shrinks to: `--import`, `capture28.py molotov candidate`, the director looks
  at run row 1 at 64 px/m for a seam or floating boot, `run_unit.mjs --changed`, evidence md + frames.json, commit the
  molotov files listed at 20:31 (all still UNCOMMITTED in the tree) per path. Then part B Gloria brass (20:22 NEXT).
  No builder running at session end.
- 20:34 BUILDER RUNNING n28-07f-molotov-capture since 20:34 (in-session, capture + grid stills + row-1 crop, no commit, END 20:46).
- 20:35 BUILDER n28-07f-molotov-capture 9 n/a accepted (capture only): grids re-rendered, crop
  `gtai-masters/n28/keys/molotov_run_row1_crop.png`.
- 20:36 I looked at molotov_run_row1_crop.png (4x, run row 1, new over donor): **REJECT final4 run row 1.** The donor-leg
  composite shows a hard horizontal cut at the seam in cols 2, 3, 4, 6, 8; smeared fragments beside the boots in cols 2-4
  and 7-8 (donor rifle-hand remnants below the seam); col 4 draws a second collar band below the first; and in most
  cells the collar is a thick spiral of stripes, wider than the donor's (rope-like: fails the rigid-collar rule). The
  foot-slide number passes, the look does not. Walk sheet: not yet looked at closely at 4x.
- 20:36 NEXT (session 4, replaces the 20:33 NEXT part A): the molotov files in the tree (listed 20:31; run8 = final4)
  are UNCOMMITTED and **must not be committed as they are**. Part A: build run row 1 from `out/edit_row1.png` (the one-row
  edit, leg IoU 0.844-0.887) by shifting each cell horizontally so its sole x matches the donor (no donor-leg composite),
  check dome within 3 %; if the collar there is still a spiral, one more one-row edit with "the collar exactly as image 1's
  narrow rigid band" (cap 1 image); `--import` before every recapture; a 4x crop of run row 1 AND of the walk sheet's
  front rows for my look before any commit. If that is not passing by ~21:30: DECISION ship walk-only (the run stays the
  stop-gap: restore `rivet_run8_eq_molotov.png` out of the tree, its provenance line and run rows) and move on to Gloria
  brass. No builder running at session end. IMAGES 15/60.
- 20:38 BUILDER RUNNING n28-07g-molotov-shift since 20:38 (in-session, art prep only: final5 run row 1 = the one-row edit shifted to the donor's sole x, no seam; crop for my look; END 20:48; state in molotov/STATE.md).
- 20:39 BUILDER n28-07g-molotov-shift 1 n/a bounced: shifting the one-row edit's cells to the donor's sole x puts the
  dome 5.6-23.7 % off the donor in 6/8 cells (bar 3 %): that edit leans the body sideways against the feet, so neither a
  shift nor a seam saves run row 1. Not installed.
- 20:40 DECISION molotov (for session 4): ship the walk sheet only (it passes: hold 0.43/1.56 cm; give it a 4x look
  first) and keep the run on the stop-gap; restore `rivet_run8_eq_molotov.png` out of the tree with its provenance line
  and run rows, commit the rest. At most ONE more one-row run image if session 4 has slack after Gloria. The owner sees
  it under "Calls for the owner". Alternative = one value (`walk_grid.by_weapon` molotov run back on, once a row passes).
- 20:40 NEXT (session 4): (1) brief n28-08 part A = the molotov walk-only commit above (about 20 min with the hook),
  part B = Gloria brass (n28-04 trimmed: concept <= 2 images + p70 held strips <= 3 + held art; start the concept image
  in the background during part A). Fill {COMMIT1}/{COMMIT2}/{END}, END by 22:07. (2) Plasma sword, Gloria's grid, p55
  collar: REPORT "Next steps" unless time appears. (3) Session 5: commit by 22:40, gate by 22:55, the five-weapon clip
  (shipped grids only), REPORT. No builder running at session end. IMAGES 15/60.
- 20:39 Session 4 start. No builder running (lock absent; builder.mjs still out, in-session fallback). I looked at
  grid_molotov_64.png walk column: bottle lit in one claw, flame amber only, collar a band as the donor's, donor legs:
  PASS for the walk. Run (final4) stays rejected (20:36).
- 20:41 BUILDER RUNNING n28-08-molotov-walk-gloria since 20:41 (in-session Sonnet subagent, brief
  evidence/briefs/n28-08-molotov-walk-gloria.md: part A molotov walk-only commit by 21:10, part B Gloria brass concept +
  p70 held strips + held art, <= 5 images, commit started by 21:30, END 21:53).
