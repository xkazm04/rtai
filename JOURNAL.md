# JOURNAL lane melee (n27, 2026-11-24)

Branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, cut from `main` `a3b3f1466`.
Continues `docs/day/2026-11-23/n26-melee/`. Builder: Claude Sonnet 5.5 via `gtai-n27/tools/builder.mjs`.

- 02:45 MILESTONE session 1 start. Read n26 REPORT, briefs, decisions tail. No `NEED melee` in other lanes' journals;
  keys has not posted `MILESTONE keys-order` yet (needed before any film with the HUD strip).
- 02:46 DECISION plan: call m1 = items 1+2 (master_at 30, per_boss_cut 3, mastery free behind `bond.mastery_free`,
  ten-seed table in two arms `pace` / `free`); m2 = item 3 films entries + films (bond film, charged-claw take);
  m3 = item 5 ring render test + item 4 if time.
- 02:46 DECISION free mastery: the draw stays as is (reserved slot, same RNG); taking `master_*` applies at once and the
  rest stays open for one normal pick among the other cards. Alternative (a fourth card) rejected: it changes the draw.
- 02:46 BUILDER RUNNING m1-mastery since 02:46 (pid 80724, brief `evidence/briefs/n27-melee-01-mastery.md`, hard stop 03:55).
- 02:57 REVIEW m1 part A `58a1b8d07` (master_at 30, per_boss_cut 3, `release_boss_cuts` on the strike, a killing cut
  counts as a kill only): read the diff, sound. TOUCH keys `project/features/souls/ghost_deploy.gd:54` (one line, the
  record call gains `strike.release_boss_cuts`) -> merge note for the Director.
- 03:12 REVIEW m1 part B `1a6badfc8`: `bond.mastery_free` true; `GauntletDraw.take` returns the rest of the hand after a
  free mastery, the rest stays open (manual picks get `pick_offered` again with the remaining cards); draw and RNG untouched;
  each free mastery is its own `run.picks` entry (schema allows no extra field). Bot unchanged (it already takes master_*
  first and then picks again). Integration + unit tests added. Accepted pending part C and the scenario line.
- 03:15 keys posted MILESTONE keys-order e1c4b73d9 (deploy_slots in ghost_forms.json). Merge it after m1 ends, before m2 films.
- 03:51 BUILDER m1-mastery 65 min $1.65 accepted. Commits `58a1b8d07` (A), `1a6badfc8` (B), `6522ce667` (table).
  Unit 4097 passed 0 failed (1 FLAKY test_audio_driving, passed alone); scenarios 68 passed; tapes did not move.
  TOUCH `gauntlet_waves.gd` (`choose()`, 3 lines; gauntlet rest code, melee owns it tonight). Mutate on ghost_bond.gd
  timed out at 900 s (no score) -> redo in m3. NEED (not raised further): `gauntlet_run.schema.json` allows no extra pick
  field, so a free mastery is its own `run.picks` entry.
- 03:51 MILESTONE mastery table `evidence/n27/bond/mastery.md`: n26 6/10 (2,4,4,8,8,8) -> n27 pace 4/10 (3,3,4,8) ->
  free 4/10 (3,3,4,8); in band 8..15: 3 -> 1 -> 1. Kerf never mastered (28/30 on seed 5, boss cuts 4). Raising the bar
  does not move the early Tonnage masteries (waves 3-4): it only drops the late ones. Builder's single-value estimate:
  master_at 22 -> three firsts at 8, 8, 9 (not re-run). Call for the owner.
- 03:55 MILESTONE merged keys `e1c4b73d9` -> `4a3ff4b04` (conflict in ghost_forms.json `doc` only, resolved by hand:
  keys' text + the bond sentences; lint 19/19 on the hook). Tests of both lanes re-run as m2's step 0.
- 03:55 BUILDER RUNNING m2-films since 03:55 (pid 29208, brief `evidence/briefs/n27-melee-02-films.md`, hard stop 05:00).
  Next brief ready: `evidence/briefs/n27-melee-03-ring-tests.md` (item 5; add times + the ghost_bond mutate redo).
NEXT: wait for m2 (check `gtai-n27/logs/melee/builder.lock`); review its films frame by frame (ffprobe, 4 frames each);
  then m3 ring tests + ghost_bond mutate; then item 4 (thug/gunner wreck art, discharge arcs). Mastery-pace call for
  the owner: early Tonnage is the problem, not the bar; consider a per-form value only as an owner call (no tuning tonight).
  Commit last work by 08:00, gate by 08:15.
- 04:06 session 1 end. BUILDER RUNNING m2-films since 03:55 (pid 29208, lock held; it has staged
  `tools/film/owner_take.gd`, `owner_takes.mjs`, `evidence/n27/films/films.md`: the claw_shock take, not yet committed).
  Commit beside it only with a pathspec (`git commit -- JOURNAL.md`).
NEXT: (same as 03:55) review m2 at its end (~05:00): films in `C:/Users/kazda/kiro/gtai-masters/n27/melee/`, ffprobe +
  4 frames each, frames.json; then launch m3 (`evidence/briefs/n27-melee-03-ring-tests.md`, add times and a
  `ghost_bond.gd` mutate with `--max=20 --tests=test_ghost_bond,test_ghost_boss_cut` and a 25 min budget).
- 04:20 MILESTONE session 2 start. m2 still running (pid 29208). Reviewed film 2 `films/claw_shock_robots.mp4` (1920x1080 60 fps 27.2 s): 8 frames + crops; thug t106, thug t356, gunner t606, shield t856/t956, war machine stunned only (never_finish). Discharge reads; white branched strokes at 64 px/m still look like glyphs (item 4). Accepted. No `NEED melee` in other journals. Wrote `evidence/briefs/n27-melee-04-wreck-arcs.md` (item 4: wrecks from each robot's live rig art, so cast's thug/gunner redraw carries over; arcs as current).
- 04:20 DECISION item 4 wrecks: built from the victim's own live rig textures, no generated images (cast redraws gunner A and thug A tonight on its branch; a fixed new texture would be stale at the merge). Alternative (generated wreck sheets) rejected: IMAGES 0/15 stays.
