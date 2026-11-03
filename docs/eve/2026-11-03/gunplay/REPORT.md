# REPORT: lane gunplay (`e-gunplay`), evening 2026-11-03

Scope: weapons and projectiles, the weapon table, the shared hit-feel module, aim, readable enemy fire,
the range station. Head at report time: `7586a44` (the last code commit is `948aa53`; everything after it is docs).
`MASTERS` below means `C:\Users\kazda\kiro\gtai-masters\eve\gunplay\`. `WT` means this worktree.

## Summary

- The full pistol hit chain runs on quest 1's real dock fight in the D5 print: the tracer, the muzzle
  flash, hit-stop, the impact star, knockback, d5-combat's blood and the kill beat. Contractors
  telegraph their bursts with a vermilion aim line that locks before they fire. A strafe off the
  locked line dodges most of a burst. The owner picked the tight burst (gunplay-3 = A).
- The weapon table has the owner's whole set. The range scene models every behaviour (cone, burn,
  splash, chain, stun, fire patches). **The quest/city fight (`CombatArena`) still models direct
  hits only.** So in the real fight the flamethrower does not burn, the rocket does not splash and
  the electro gun does not chain. That is the largest gap.
- The owner has not judged any weapon other than the pistol in the final look. gunplay-1 and
  gunplay-2 are placeholders, following the owner's 21:25 direction.

## What works (each with its proof)

| Claim | Evidence / command |
|---|---|
| `data/tables/weapons.json` + schema: pistol, machine_pistol, flamethrower, rocket_launcher, electro_gun, molotov (core), gloria (canon); plasma_rifle, hand_cannon, ray_gun, homing_shard, mini_nuke present with `enabled: false`; `enemy_fire`, `aim_assist`, target classes (human 100, armored 250, robot 600 metal); optional `held_scale` (948aa53) | `WT/project/data/tables/weapons.json`, `WT/project/data/schemas/weapons.schema.json`; lint DAT-03 passes (`WT/evidence/lint-it7.log`) |
| Deterministic 60 Hz shooting model in GDScript (not native, so parity is untouched): Trigger (semi/auto, bloom that recovers, magazine, reload), Projectile, ProjectileSim (cover, enemy speed scaling, fire patches, digest), Sweep (swept circle/rect), Impact (splash falloff, electro chain 0.7x per metal hop, burn = panic + DoT, stun) | `WT/project/features/combat/weapons/*.gd`; `WT/project/tests/unit/test_gunplay_weapons.gd` (determinism per seed + a planted fault) |
| Projectile determinism as a scenario: the core six replay identically per seed, and a planted fault (target 5 cm off) moves the digest | `WT/project/tests/scenarios/scenario_gunplay_fire.gd`; `WT/evidence/gunplay/gunplay-fire.json`; scenarios 20/20 in `WT/evidence/scenarios-it7.log` |
| Time to kill / hit rate per weapon at 5, 10, 20 and 35 m against still and strafing targets (24 seeds per cell; pure sim) | `MASTERS/ttk.md`, `MASTERS/ttk.json`; `WT/project/dev/gunplay/ttk_bench.gd`. Pistol vs a still human: 0.08 / 0.17 / 0.33 / 0.85 s |
| Shared hit feel: hit-stop by damage class, camera shake under a budget with the reduced-motion flag, knockback, hit flash, `HitFeel.reaction` hook for enemy-ai, d5-combat REQUEST 3 (`beat_mode`: lethal hit = 8 ticks). README with the API for melee and powers | `WT/project/features/combat/hit_feel/{hit_feel.gd,hit_link.gd,README.md}`; `test_hit_feel.gd`, `test_hit_link.gd` |
| Aim: the aim line ends at the weapon's range, the reticle shows the live cone at the aim distance, an out-of-reach flag. Pad aim assist is an 8° cone to 25 m that bends 35 % of the way, pad only (the mouse aims raw) | `WT/project/features/combat/weapons/{aim_readout.gd,aim_assist.gd}`; `test_aim_readout.gd` |
| `GunHand`: an optional `CombatArena.gun`. When set, Rivet fires through the table. It is null in quest 1, so the quest goldens did not move | `WT/project/features/combat/weapons/gun_hand.gd`; `test_gun_hand.gd`; `WT/evidence/gunplay/scenarios-quest-gunhand.log` |
| The pistol's full hit chain in the D5 look on quest 1's real dock fight (real cast art, blood, kill beat), 20 s at 32 px/m, `--fixed-fps 60` | `MASTERS/pistol_fight/pistol_fight_32ppm.mp4` (24 shots, 24 hits, 24 kills) |
| Non-lethal hits read (armored contractors, 2.5 rounds): the impact star on a living figure, and a vermilion-rimmed star when Rivet is struck | `MASTERS/pistol_fight_armored/pistol_fight_armored_32ppm.mp4`, `.../rivet-struck-n0781.png`, `.../pistol-fight-32ppm-f0065.png` |
| Readable enemy fire (`GuardTell`): stop, a dashed vermilion aim line that tracks, a solid locked line plus a muzzle glint, then a burst at 0.45x speed down the locked line. Owner picked tight spread 0.3 (gunplay-3 = A, 22:55) | `WT/project/features/combat/weapons/guard_tell.gd`; `test_guard_tell.gd` (4/4, incl. a planted fault); `MASTERS/pistol_fight_tell/pistol_fight_tell_32ppm.mp4`, `MASTERS/pistol_fight_tell/tell-n0750.png` |
| Dodging works and is measured. Enemy rounds landed on Rivet, armored fight: standing 60/60; alternating strafe 17/48; strafe away from the other live gunners 8/42; machine pistol 10/31 -> 8/33 | `MASTERS/pistol_fight_dodge_s0.3/` (+ `dodge-pass-n0820.png`), `MASTERS/pistol_fight_dodge_away/pistol_fight_dodge_away_32ppm.mp4`, `MASTERS/pistol_fight_dodge_s1.0/` (the full-cone A/B); logs `WT/evidence/it5/` |
| One attack slot A/B (`GuardTell.one_slot`, off): 9/36 vs 17/48. Decided off, because the away-strafe beats it without slowing the fight by a quarter | `MASTERS/pistol_fight_one_slot/pistol_fight_one_slot_32ppm.mp4`; `WT/docs/decisions.md` |
| Machine pistol on the same chain: 104 rounds, 70 hits (67 %, bloom), 14 kills; the stream reads as separate tracers | `MASTERS/pistol_fight_machine_pistol/pistol_fight_machine_pistol_32ppm.mp4`, `.../pistol-fight-32ppm-f0060.png` |
| A real 48 px/m capture (`--ppm` snaps the camera rig, verified by the 4 m floor tile at 128 -> 192 px) | `MASTERS/pistol_fight_mp_48/pistol_fight_mp_48ppm.mp4`, `.../flinch-sheet-48.png` |
| Range scene: the core six side by side (debug circles), plus the dodge-volley drill at 32 and 48 px/m | `MASTERS/range-core6-32ppm.mp4`, `MASTERS/range-core6-48ppm.mp4`, `MASTERS/dodge-volley-{32,48}ppm.mp4` |
| Range station draft: validates against arena's `gtai.arena-station/1`, with 88 tuning keys | `WT/evidence/gunplay/station-draft/gunplay.json` |
| frames.json for the owner's page: 15 entries, every file exists (checked 23:41) | `MASTERS/frames.json` |

**Gates** (on code head `948aa53`; no code has changed since): lint 13/13 (`WT/evidence/lint-it7.log`);
unit 569/569 (`WT/evidence/unit-it7.log`); scenarios 20/20 (`WT/evidence/scenarios-it7.log`); evidence
gate all PASS, with parity bit-exact and the planted mutation caught at step 629 (`WT/evidence/evidence-it7.log`,
run with `--no-bench --allow-dirty`; the only dirty paths are the untracked `evidence/` folder). Replay and
parity goldens did not move, because no native or quest-sim code changed. No bench was taken (no perf-relevant change).

## What does not work / is not done

1. **Area behaviours exist only in the range scene, not in the real fight.** I ran each row
   through `CombatArena` (`WT/evidence/it5/w_*.log`). The flamethrower landed 54 hits and killed
   nothing: no cone, no burn DoT, no fire patch. The rocket kills on a direct hit only, with no
   splash or knockdown. The electro gun hits but does not chain or stun. Molotov, rocket-wrecks-car
   (the vehicles lane's damage states) and burn panic visuals are not done.
2. **No range clip per weapon in the D5 look.** Only the pistol and the machine pistol have one.
   The other four exist only as debug circles in `range-core6-*.mp4`.
3. **gunplay-1 (lethality model) and gunplay-2 (enemy round speed) are unjudged placeholders (A).**
   The owner's rule: re-ask only with a clip in the final look.
4. **The held pistol barely reads at 32 px/m** (Director's note on gunplay-3). The `held_scale` data
   hook exists, but no row sets it, because rivet-motion's socket does not read it yet (REQUEST 9).
5. **Live contractors clump with corpses** (Director's note). Not addressed (REQUEST 10).
6. **The flinch does not read.** The drawn 0.3 m lean hides under the impact star, even at a real
   48 px/m. A readable flinch needs enemy-ai's animation (REQUESTs 5/7).
7. **The dodge in the clips is a scripted rewrite of the bot's intent.** It is not a TickInput-driven
   twin-stick strafe, so the clip does not show Rivet's real acceleration.
8. **The station file is not in `data/tables/arena_stations/gunplay.json`.** The arena lane's
   schema and lint mapping are not on this branch. The draft is ready to move unchanged after the merge.
9. **The pistol prop art candidate is not integrated** (`MASTERS/art/pistol_topdown_candidate.png`,
   `pistol_scale_preview.png`). It has no provenance line, because no cell made from it landed.

## What blocked me, and for how long

- **A parse error made a runtime-loaded runner hang**, about 5 min (iteration 1). Fixed: the launcher now quits(2).
- **The arena was not on this branch** all evening. REQUEST 4 -> arena is still open. I proved the
  chain on quest 1's dock fight instead, so the arena itself shows nothing from gunplay yet.
- **The `--ppm=48` evidence was false** from iteration 4 until iteration 5 (about 40 min of wrong
  labels). The rig only eases in `step()`. Caught when two frames turned out byte-identical; fixed in
  `1a916bb`, and the false frame was withdrawn from frames.json (`docs/decisions.md`).
- **Shared-machine unit flake** `test_save_slots`. All lanes' worktrees share
  `SaveKit.SCRATCH = user://test_save`, so parallel GUT runs collide. It cost about 15 min of
  re-runs over the evening. REQUEST 8 -> autosave.
- **I committed a parse error** (`5ac6d4a`, caught by the capture's run.log, fixed next commit, about 10 min).
  Lint does not parse scripts.
- **Iterations 6-10 were 5-12 minute sessions after the 23:30 freeze.** Only a data hook (`held_scale`) and verification landed.

## Requests out (open)

- REQUEST 4 -> arena: set `arena.gun = GunHand.make(...)` and `HitLink` in `ArenaStage.setup`, and `guard_tell` next to it.
- REQUEST 5/7 -> enemy-ai: play the raised-rifle pose while `GuardTell.telling()`, and hold it while `locked()`; play the hit reaction on `HitFeel.reaction`.
- REQUEST 6/9 -> rivet-motion: arms along `aim_dir`, a 3-tick recoil kick, and the held-weapon socket scaled by `WeaponSpec.held_scale`.
- REQUEST 8 -> autosave: make `SaveKit.SCRATCH` per process.
- REQUEST 10 -> d5-combat/enemy-ai: corpses settle or darken under the living.

## Next steps (night run, in order)

1. Bring the table's area behaviours onto `CombatArena` through `GunHand`, reusing `impact.gd` and
   `sweep.gd` (no second copy): the flamethrower cone + burn DoT + fire patch, rocket splash +
   knockdown (+ the vehicles-lane car damage hook), the electro chain + stun, the molotov arc + patch.
2. Then a `pistol_fight --weapon=<each>` clip in the D5 look at 32 and 48 px/m, with a TTK row
   from the same chain. Re-ask gunplay-1 with that side by side.
3. The held gun reads at 32 px/m (`held_scale` per row, picked from a still once REQUEST 9 lands).
4. Keep the living readable apart from corpses (REQUEST 10).
5. A TickInput-driven twin-stick dodge clip instead of the intent rewrite. Re-ask gunplay-2 with the
   full tell chain in the final look (enemy-ai's pose + hit reaction).
6. After the merge: move the station draft into `data/tables/arena_stations/gunplay.json` and wire REQUEST 4 if it is still open.
