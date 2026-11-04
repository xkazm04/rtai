# JOURNAL - night lane brutality (branch n-brutality), 2026-11-04

## Iteration 1 (01:06-02:06), BUILD

- 01:06 Read: brief, AGENTS.md, d5-combat report, arena report, arena hook API, CutRig/RigBuild,
  CombatArena (struck signal = the kill event source today), KillBeat. No other night lane has a
  JOURNAL yet, so no REQUESTs to me.
- Registry rules applied (realtime-combat-semantics): the kill is decided at the damage chokepoint
  (CombatArena.struck carries lethal + weapon), the sim side is data on the 60 Hz tick with a named
  RNG stream (`brutality`), the view only reads. Hit-stop is a sim hold (gibs wait), so it replays.
- DECISION brutality: the gib parts are the victim's own rig sprites (GibCut copies the posed
  CutRig's part sprites, shared print materials and cream halos into six groups: head, torso+pelvis,
  arm L/R, leg L/R), not new art. Keeps the D5 print and costs no image slot. Rejected: separate gib
  art first (blocked on weapon-art; asked for extras below).
- DECISION brutality: the kill hook lives in the arena as an ArenaHook (station brutality_pit,
  data/tables/arena_stations/brutality.json), and the dev arg `--sig-gun=<weapon>` hands Rivet that
  weapons.json gun (the arena has no weapon pick yet). `--gore=full|reduced` is a LaunchArgs flag
  (shared file boot/launch_args.gd: one line added to KNOWN_FLAGS).
- Shared-file edit: dev/arena/arena_rigs.gd gets `hidden` (fighter ids a signature kill consumed:
  no rig fed for them). 4 lines.
- MILESTONE framework: signature_kills.json + schema, SignatureKill(Table), KillEvent payload,
  GibSim (72-slot ring pool = leftover budget, comic gravity 24 m/s2, bounce, slide), KillMarks
  (scorch + spray fan, budget 12), SignatureKills director, KillView, GibCut, BrutalityHook.
  Unit test_signature_kills 6/6 (same seed same gibs, planted 1 % velocity fault caught, reduced
  gore, robots, budget).

### Kill event payload (proposed; REQUESTs)
`KillEvent { victim_id, at (m), dir (unit, the blow), weapon (weapons.json id), damage_type
(hit_class), human, facing }` built today from `CombatArena.struck(victim, dir, lethal, weapon)`.
- REQUEST 1 -> gunplay: keep `struck(victim, dir, lethal, weapon)` emitting for every lethal hit
  incl. rocket splash (the splash kill should carry the burst->victim direction), and use the
  weapons.json ids (`rocket_launcher`, `hand_cannon`, ...) as `weapon`.
- REQUEST 2 -> human-reactions: before playing the standard death, ask
  `SignatureKills.consumed.has(victim_id)` (or listen for `SignatureKills.killed`) and skip the
  standard death/sprawl for that body: its rig is gibs now.
- REQUEST 3 -> weapon-art: (low priority, the rig cut covers parts) a chroma-green sheet of
  gore bits for the D5 print: a ragged red stump cap (neck/shoulder/hip), 3 small inked meat
  chunks, a charred-body overlay (for the flamethrower), an X-ray skeleton silhouette (electro).

### Later in iteration 1
- MILESTONE 01:19 the rocket kill runs live in the arena pit (`--bot=pit --rigs
  --sig-gun=rocket_launcher`): telemetry `signature_kills 1` (evidence/brutality/pit-rocket-32-telemetry.json).
  At 32/48 px/m the pit camera leaves the kill at the screen edge, so I added the framed lab
  (`--sig-lab`, KillLab: six contractors pinned in front of Rivet at the hub, holding fire, one
  shot every 110 ticks). Lab run: 6/6 gib kills (lab-rocket-48-telemetry.json).
- MILESTONE rocket gib v2: blood stumps on each torn part, lobed splat, scorch star drawn over the
  spray, cream ink flash 4 ticks (soot after, blasts only). Clips 32 px/m real time, 64 px/m real
  time, 64 px/m 0.4x slow close-up in gtai-masters/n4/brutality/clips/. I looked at every sheet.
- MILESTONE hand cannon blowback (row `hand_cannon_blowback`): the whole rig copied as one piece
  plus its cap, flies back along the shot (7.5-9 m/s, up 2.2-2.8), slides on a blotchy smear, exit
  spray in a 34 deg fan, small flash, hit-stop 3. Unit: body ends 3-9 m along the shot. Clips 32/64
  real time + 64 slow.
- FRICTION: python `str.replace` edits silently missed text that gdformat had re-wrapped (three
  times: smear art, lab line, the `whole` flag into GibCut) -> the blowback body was invisible for
  four captures. Use the Edit tool (it fails loudly) for any edit after gdformat ran.
- FRICTION: a full unit run racing my own edits reported script errors; run gates on a still tree.
- Shared-file edit: tests/unit/test_arena_hooks.gd assumed no shipped station has a hook; now it
  finds its probe hook among all hooks (my brutality_pit station is the first shipped hook).
- Gates: lint 13/13 (pre-commit, every commit); scenarios 28/28 with my station loaded
  (evidence/brutality/scenarios-it1.log); test_signature_kills 7/7, test_arena_hooks 5/5; full unit
  re-run at the end of the session -> evidence/brutality/unit-it1.log.
- Not measured yet: the frame cost of the worst kill (no bench this iteration). Unmeasured, not zero.

## Calls for the owner (draft)
- brutality-1: the rocket gib keeps the victim's own rig parts (cut procedurally) vs. new painted
  gore parts from weapon-art. Default: rig parts (in the clips). Alternative = REQUEST 3 art.
- brutality-2: the ink flash on a signature kill: cream starburst 4 ticks (rocket) / small 2 ticks
  (hand cannon), off under --reduced-motion. Alternative: d5-combat's kill beat (`--kill-beat`).

NEXT:
1. Hand cannon polish: sprawl the body before the cut (set the rig's death clip, let one `drive()`
   pose it, then cut; calling RigPose.step alone flattened the copies), make the cap visibly leave
   (hide the head's cap on the body copy, or offset the hat copy), longer smear.
2. DONE 01:50 (gib/wall collision via SignatureKills.push_out, the stage's walls + cells; unit
   test; frame gtai-masters/n4/brutality/frames/hand-cannon-bodies-stop-at-wall-32ppm.png). Not in
   frames.json yet; the hand cannon 32 px/m clip there predates it (bodies pass the wall).
3. Suppress the standard d5-combat death blood (pool wedge, spurts) under a signature kill, or keep
   only the pool; decide after looking side by side.
4. Determinism scenario in tests/scenarios (arena lab with rocket: replay identical + planted fault)
   and the city block run (`--arena=city --rigs --sig-gun=rocket_launcher --sig-lab`).
5. Frame cost of the worst kill (rocket at 6 kills/11 s) under bench.lock.
6. Then kill #3 flamethrower (burn: run ablaze, charred silhouette, ash) - needs REQUEST 3 art or a
   procedural char tint (multiply the copies to ink + ember flecks).

## Iteration 2 (01:53-02:53), BUILD

- 01:55 Read JOURNAL, git log, the other lanes' JOURNALs. Replies:
  - gunplay REQUEST 1 (kill_landed payload): AGREED. BrutalityHook now listens to
    `CombatArena.kill_landed(victim, weapon, dir, at, kind)`; `kind` lands in KillEvent.damage_type.
  - human-reactions (my REQUEST 2 done as `DeathPipe.add_signature`): wired. BrutalityHook registers
    `_takes_death(rig) -> kills.consumed.has(rig.actor_id)` on `ArenaRigs.react.pipe`.
  - weapon-art (my REQUEST 3 delivered, `art/gore/`): taken by path from n-weapon-art 295db1b3
    (`git checkout n-weapon-art -- project/features/combat/weapons/art/gore`); the provenance lines
    stay in that commit (they arrive with weapon-art's merge). Used: `ash.png`. Not used: `charred.png`
    (front view, the rig is top-down), the rest kept for the katana/chainsaw/electro kills.
  - showcase REQUEST 6 (cc brutality, city rigs): human-reactions 39582854 attaches ArenaRigs on the
    city view; it is in my branch now with the merge below.
- MERGE n-human-reactions (8669b5d9, which carries n-gunplay b3b3c92f) into n-brutality: kill_landed,
  FightAreas burn/stun/knockdown, burning flail on the rigs, DeathPipe. Conflicts: arena_rigs.gd (both
  fields kept: `hidden` + `react`), test_arena_hooks.gd (theirs), JOURNAL.md (ours).
- Registry rules applied (realtime-combat-semantics): the fire kill is decided at the damage chokepoint
  (kill_landed), the char timeline is ticks from the row against the sim tick (replays), the char view
  shapes come from a hash of the kill serial (no dice in render). motion-quality-gating: judged on
  sheets of the real-time clips, 32 and 64 px/m.
- MILESTONE 02:12 kill #3 fire/flamethrower (`burn_char`, style `burn`): the victim, already running
  ablaze (tethered 1.8 m in the lab so it stays framed), stops as a charcoal print of his own rig
  (kill_char.gdshader), smoke wisps, ember cracks, then crumbles over 75 ticks into 34 ash flakes
  drifting downwind onto an ash heap (weapon-art ash.png) over a soot scorch. No blood. Clips 32/64 px/m
  real time + 64 px/m 0.4x slow. Telemetry 6/6 burn kills (evidence/brutality/lab-flame-32-telemetry.json).
- MILESTONE standard death blood vetoed under every signature kill (CombatBlood.veto, shared file,
  +11 lines; deferred bleed only when a veto is set). Fixes NEXT 3 of iteration 1 for rocket + cannon too.
- FRICTION: the rig copies without print_part showed the raw channel-packed part textures (dark RED
  silhouettes, read as blood) -> own char shader.
- FRICTION: CombatBlood bled on actor_killed, which CombatArena emits BEFORE kill_landed, so the veto
  saw no kill yet -> deferred.
- FRICTION: python str.replace asserts failed on a file gdformat had written with CRLF; Edit tool works.
- Shared-file edits: features/fx/combat_blood.gd (veto + deferred bleed), dev/arena/arena_rigs.gd
  (merge resolution only). Lab: burning guards may leave their mark (KillLab.RUN_M).
- MILESTONE 02:15 `scenario_brutality_kills` (tests/scenarios): rocket gib (12 kills), hand cannon
  blowback (6), fire char (4), electro X-ray (6) in the arena's real fight with the KillLab line:
  each lands >= 2 kills of its own style, replays identically on a fresh world, the same seed
  gives the same gib state, and a planted 1 % gib speed fault is caught. 15 s headless.
  Evidence evidence/brutality/brutality-kills.json + scenario-brutality-kills.log. Hook gained
  `arm(stage, ctx, weapon)` and `open_lab(stage)` for it.
- MILESTONE 02:18 city proving block: `--arena=city --rigs --sig-gun=rocket_launcher --sig-lab`,
  17 gib kills in 13 s on the city's cast-rig contractors (clip rocket-gib-city-block-48ppm-13s.mp4,
  source game-city). The lab fires point blank, so the parts pile near Rivet.
- MILESTONE 02:25 kill #4 electro (`electro_shock`, style `shock`, KillShockFx): stiff convulsion
  (hashed shake), X-ray strobe every 5 ticks (the body blinks out, weapon-art's xray sticker at 1.3 m
  inside cream ink arcs), then a stiff drop along the shot and collar smoke. No blood. Reduced motion:
  no strobe, no shake. Clips 32/64 px/m + 64 px/m 0.4x slow; a 12-frame strobe sequence still.
  DECISION brutality: the X-ray uses weapon-art's front-view skeleton sticker as a comic flash on the
  top-down body (reads as the gag at 64 px/m). Alternative: a top-down skeleton redraw (REQUEST 4).
- FRICTION: the X-ray drew under the living guards crowding the victim (rig parts reach z +30):
  shock_fx z 40. print_part forces alpha 1, so blinking a rig copy needs `visible`, not modulate.
- MEASURED 02:30 the kill view's CPU cost (new telemetry view_avg_us / view_worst_us; CONTENDED,
  another lane held bench.lock, so no bench run): rocket lab, 18 kills in 15 s, 900 frames at 32 px/m:
  before 20.7 ms avg / 47 ms worst (every frame reprinted all leftover marks and smears: ~6k circles);
  ground cache 10.9 / 59; + fresh-smear layer 4.1 ms avg / 62 ms worst. The worst frame is the kill
  frame (GibCut copying the rig + the ground reprint). Evidence evidence/brutality/cost-rocket-*.json.
- KillView is 251 lines now (soft 200, hard 300): split the draw layers into their own file next.

### REQUESTs (iteration 2)
- REQUEST 4 -> weapon-art (low): a TOP-DOWN X-ray skeleton sticker (seen from above: skull disc,
  shoulder girdle, ribs, arms along the body) and a top-down charred-body overlay; the current
  xray/charred stickers are front views. Same chroma route, art/gore/.
- REQUEST 5 -> gunplay (info): BrutalityHook listens to kill_landed; fire kills by kind `burned`
  (direct flame puffs carry `flamethrower`, DoT/patch kills `burn`) both char. CombatBlood gained
  `veto` (+ a deferred actor_killed bleed when it is set): you own CombatBlood, please keep it.

## Calls for the owner (draft, iteration 2)
- brutality-3: fire deaths: every fire death chars (flamethrower, molotov, patch) vs. only the
  flamethrower. Default: every fire death (flame-char clips). Alternative = one line in on_kill.
- brutality-4: the electro X-ray uses a front-view skeleton sticker over a top-down body (comic gag)
  vs. a top-down skeleton redraw (REQUEST 4). Default: the sticker (electro-xray clips).
- brutality-5: a signature kill suppresses the standard death pool and corpse soak (the kill prints
  its own blood; fire and electro none). Default: suppressed. Alternative: keep the pool under gibs.

NEXT:
1. Kill frame spike (62 ms CONTENDED): pre-cut lazily (copy the rig over 2 frames?), or keep a pooled
   set of group nodes; measure under bench.lock (the real bench, `node tools/bench/run.mjs`) with a
   rocket lab run; split KillView's layers into kill_ground.gd (251 lines now).
2. Fire char polish: ember cracks brighter/longer, smoke stronger at 32 px/m (they barely read);
   electro: scorch tint on the dropped body (print_part ignores modulate; use a char-like mix shader).
3. Kill #5 katana (split along the swing): rivet-arsenal owns melee; read their JOURNAL for the
   melee hit event (weapon id `katana`), cut the rig copy along the swing line (two groups by side
   of the line), blood fan along the cut; needs a lab mode that swings instead of shooting.
4. City clips for the fire and electro kills (`--arena=city`), and a reel of all four kills.
5. Hand cannon polish (iteration 1 NEXT 1): sprawl pose before the cut, cap visibly leaves.
6. `--gore=reduced` clip (each kill falls with the standard death) for the ratings proof.
- 02:36 Gates on the final tree: lint 13/13 (every commit), unit 725/725
  (evidence/brutality/unit-it2.log), scenarios 31/31 incl. scenario_brutality_kills
  (evidence/brutality/scenarios-it2.log). No bench this iteration (bench.lock held by another lane).
- 02:37 `--gore=reduced` clip (rocket lab, 48 px/m): signature_kills 0, victims fall whole with the
  standard death (clips/rocket-gore-reduced-arena-48ppm-10s.mp4). NEXT 6 done.
- 02:39 fire char polish (NEXT 2, part): smoke alpha 0.42 -> 0.62 and wider wisps (now reads at
  32 px/m; the 32 px/m clip re-rendered), ember cracks longer and thicker, but they still do not read
  at 32 px/m over the charcoal (keep in NEXT 2: a brighter cream core, or fewer, bigger cracks).
- 02:40 BUG found (not fixed, out of time): on the city block (`--arena=city --rigs
  --sig-gun=flamethrower --sig-lab`, 5 burn kills) the fire kills still bleed RED (pool, spray,
  corpse soak) although they char correctly; in the arena the veto works. Sheet:
  evidence/brutality/city-flame-48ppm-BUG-blood-on-fire-kills-sheet.png. Suspect: on the city the
  collect-call view scales its actor layer (k = SimConst.PX_PER_M / Ink.PX_PER_M), so the px that
  CombatBlood passes to `veto` are not SimConst px and `SignatureKills.marked_near` misses; or the
  city path bleeds through CityBlood's own CombatBlood (boot/city_blood.gd) without the veto.
  Not in frames.json (it shows the wrong look).

NEXT (supersedes the list above; iteration 3):
1. Fix the city blood veto (above): log the px CombatBlood passes on the city vs the victim's
   metres, convert with the right scale (or veto by victim id from kill_landed), re-shoot the city
   fire clip, then city clips for the electro kill.
2. Kill frame spike (62 ms CONTENDED) + the real bench under bench.lock; split KillView (251 lines).
3. Fire embers readable at 32 px/m; electro scorch tint on the dropped body.
4. Kill #5 katana (rivet-arsenal's melee hit event; cut the rig copy along the swing line).
5. A reel of all four finished kills (rocket, hand cannon, fire, electro) at 32 px/m.
6. Hand cannon polish (sprawl before the cut, the cap visibly leaves).
- 02:43 tried: give every CombatBlood under the arena game the veto at the first kill (the city's
  CityBlood glue makes its own CombatBlood after attach_view). Re-shot the city fire run: the red is
  unchanged frame for frame, so the city's fire-kill blood comes from ANOTHER path (candidates:
  ghost-powers' city-path blood in quest 1, the human-reactions city rig attach, CityBlood's rig-feed
  `follow`, or KillBeat). Change reverted (unverified). Start NEXT 1 by logging which node draws it.

## Iteration 4 (02:44-03:44), BUILD

(Iteration 3 left no commits after be2dcb9d; this session picked up its NEXT list.)
- 02:46 Capture recipe kept at `gtai-n4/scratch/brutality/cap.sh <name> <s> <ppm> [arena args]`
  (the arena is its own scene: `res://dev/arena/arena.tscn -- <args>`; `--arena=city` alone at
  boot only warns "unknown launch arg"). FRICTION: lost 5 min to that.
- ROOT CAUSE of the city fire-kill blood (iteration 2 BUG): two faults, both fixed (55791625):
  1. On the city block `CollectCallView.print_stage` is null, so `BrutalityHook.attach_view`
     returned early: NO KillView on the city at all. The iteration 2 city rocket clip showed the
     standard deaths + pools, never the gibs (I misread it then). KillView now goes on the
     CityView's actor layer when there is no print stage (like ArenaRigs.attach).
  2. The red came from CityBlood's own CombatBlood (city view fx_triggers `death` cue), which had
     no veto, and its cue resolved BEFORE the frame's `kill_landed` (logged order). Every
     CombatBlood under the arena game now gets the veto (deferred tree walk after attach), and
     the cue path defers its bleed past kill_landed when a veto is set (shared file
     features/fx/combat_blood.gd, +4 lines; the arena path already deferred).
  Evidence: city clips re-shot at 48 px/m for fire (5 burn kills, char + ash, no red), rocket (17),
  electro (6), hand cannon (6); `evidence/brutality/city-*-48-telemetry.json` now carry
  view_frames (the view really draws on the city).
- MILESTONE 03:25 kill #5 katana (`katana_split`, style `split`, e68008ac): one diagonal slash
  (55 deg off the approach, side alternates kill by kill) cuts the real rig in two: KillSplitFx
  copies the posed body twice, each clipped to a half-plane, the halves leave off their own side
  of the cut (+0.6 along the blade) and slide on red smears; KillCutEdge draws an ink lip + raw
  red band on each cut; blood fans along the cut (spray 16, 26 deg); a cream slash streak with
  an ink rim marks the blade for 12 ticks; hit-stop 6. Sim side: two new piece ids half_a/half_b
  (GibSim HEAVY/SPIN_K extended; the other rows' dice unchanged). Lab: `--sig-gun=katana
  --sig-lab` makes Rivet lunge 7 ticks to 1 m short of the guard, hit through
  CombatArena.damage (weapon `katana`, so the real melee hit will take the same row), walk back;
  the blade line is spread (2.4 m+) so each cut body lies clear.
- FRICTION (Godot 4.7): a Polygon2D with clip_children clipped nothing over the print-part
  sprites; a stretched white Sprite2D works, but its children inherit the stretch (undo with
  the mask's inverse transform), and children with their own z_index escape the clip (flatten z
  into tree order).
- DECISION brutality: the katana kill is driven in the lab by a brutality-owned lunge-slash until
  rivet-arsenal wires the melee weapons live (their NEXT 5); the kill keys on weapon id `katana`
  at the damage chokepoint, so the live swing needs no change here. Rejected: waiting.
- Registry rules applied (realtime-combat-semantics): kill decided at the damage chokepoint, the
  cut side from the kill serial (no dice in render), the halves on the 60 Hz tick from the
  `brutality` stream. motion-quality-gating: judged on frame sheets of real-time clips.
- 03:09 katana tuned (halves 3-3.8 m/s, drag 2.6: they now clearly slide apart on dotted red
  smears; cut edge bolder) and added to scenario_brutality_kills (6 split kills, replay
  identical). Clips: katana 32 px/m (14 s), 64 px/m (12 s), 64 px/m 0.4x slow, city block 48 px/m.
- MILESTONE 03:14 kill #6 plasma rifle (`plasma_hole`, style `hole`, 2bd5c4d9): KillHoleFx clips
  the victim's body copy with a mask that has a 0.2 m round hole at the torso (the street shows
  through), a ring on the edge (ink rim, hot cream glow cooling to charred brown over 90 ticks),
  the body drops back along the shot, no blood (cauterised). weapons.json has plasma_rifle
  `enabled: false` (gunplay's), but GunHand.make fires it for the lab. "The bolt continues" is
  gunplay's projectile (pierce), not done here. In the scenario (6 hole kills, replay identical).
  Clips 32/64 px/m, 64 px/m 0.4x slow, city block 48 px/m.
- MEASURED 03:15 under bench.lock (taken and released; my own city capture still ran beside it,
  so CONTENDED), 32 px/m labs, 900 frames: KillView avg / worst frame:
  rocket 18 kills 4.1 ms / 74 ms; katana 7 kills 0.8 / 18 ms; plasma 7 kills 0.27 / 1.0 ms.
  The worst kill frame is the rocket's (six GibCut groups + the ground reprint of every mark;
  possibly first-use pipeline compiles). Evidence evidence/brutality/cost-*-32-it4.json.
- Gates on f7249c44+: lint 13/13 every commit, unit 725/725 (unit-it4.log), scenarios 31/31
  (scenarios-it4.log); scenario_brutality_kills re-run alone after katana + plasma (7 weapons).
- Shared-file edits this iteration: features/fx/combat_blood.gd (+4: the cue-path bleed defers
  when a veto is set). Nothing else shared.

## Calls for the owner (iteration 4 additions)
- brutality-6: the katana cut runs diagonally (55 deg off the swing's approach, alternating side)
  vs. straight across the swing. Default: diagonal (katana-split clips). One value: `cut_deg`.
- brutality-7: the plasma kill is cauterised (no blood, a glowing hole) vs. a hole with a red
  exit spray behind. Default: no blood (plasma-hole clips). One value: `spray`.

NEXT (iteration 5):
1. The rocket kill frame spike (74 ms CONTENDED): log per phase (GibCut copy vs ground reprint vs
   first-draw pipeline compile: does only the FIRST kill spike?); pre-warm the copy materials at
   attach, or cut over two frames inside the hit-stop.
2. Plasma: thinner glow so more street shows through the hole; a short cream bolt streak that
   flies on past the body (the "bolt continues" read, render only).
3. Kill #7 chainsaw (the grind: victim held and shaking, continuous spray, then a split): reuse
   KillSplitFx.cut with a straight cut + KillShockFx-like shake; lab driver like the katana.
4. Kill #8 plasma sword = katana split + KillHoleFx's glow on the cut edges and spray 0.
5. A reel of all six finished kills at 32 px/m (ffmpeg concat of the lab clips, labelled).
6. KillView is 277 lines (hard stop 300): move _parts/_cut/_blobs into kill_parts.gd first.
7. Katana live: when rivet-arsenal's melee weapons land (their NEXT 5), merge and re-shoot with
   the real swing instead of the lab lunge.
- 03:20 reel of the six finished kills (32 px/m, 36 s, labelled): gtai-masters/n4/brutality/clips/signature-kills-reel-32ppm-36s.mp4 (NEXT 5 done). Seen on its sheet: the plasma hole barely reads at 32 px/m, and one red dot lies near a plasma victim (spray is 0: check which path drops it).
- 03:21 plasma hole polish: a fading heat bloom around the hole + a thinner glow lip (street shows
  through); reads at 32 px/m right after the kill, then a charred ring. Unit 725/725 re-run on
  the tree after it (unit-it4.log).
- 03:23 refactor: KillView's blob stand-ins moved into GibCut.parts (277 -> 262 lines).
- MILESTONE 03:27 kill #8 plasma sword (`plasma_sword_split`, 68b284b6): the katana split with
  cauterised edges (KillCutEdge `hot`: hot cream band in a heat bloom, no red), spray 0 so no
  smears and no blood. plasma_sword is not in melee_weapons.json (shared table, rivet-motion/
  arsenal own it), so the lab treats any weapon whose row is `split` as a blade. In the scenario
  (6 kills, replay identical). Clips 32 + 64 px/m.
- REQUEST 6 -> rivet-arsenal: when melee weapons go live, please emit the hits through
  CombatArena.damage with weapon ids `katana` / `plasma_sword` and set `hit_dir` to the swing's
  approach (Rivet -> victim): the brutality rows key on those ids and cut diagonally off hit_dir.
  A `plasma_sword` row in melee_weapons.json is yours to add.

NEXT (iteration 5, supersedes the list above):
1. The rocket kill frame spike (74 ms worst, CONTENDED): log per phase (GibCut copy vs ground
   reprint vs first-draw pipeline compile; does only the FIRST kill spike?); pre-warm, or cut
   over two frames inside the hit-stop.
2. Kill #7 chainsaw (the grind: the victim held and shaking with a continuous spray, then a
   straight split): KillSplitFx.cut + a shake like KillShockFx; the lab blade driver holds Rivet
   at the victim for ~50 ticks before the damage lands.
3. Plasma: a cream bolt streak flying on past the body (render only); check the red dot near a
   plasma victim on the reel sheet (spray 0: which path drops it? likely gunplay's hit splash).
4. Plasma sword: the cut glow cools over time like KillHoleFx (now static); a 64 px/m slow clip.
5. Re-cut the reel with all seven kills (rocket, cannon, fire, electro, katana, plasma rifle,
   plasma sword) and city clips for the plasma sword.
6. Katana/plasma sword live: merge rivet-arsenal when their melee weapons land, re-shoot.
- 03:31 final gates on 37e32e75+: lint 13/13, unit 725/725 (unit-it4.log), scenario_brutality_kills 8 weapons pass (full suite 31/31 at 03:05 before plasma; the brutality scenario re-run alone after each kill).

## Iteration 6 (03:29-04:29)
- Read: JOURNAL, git log, REQUESTs to brutality (rivet-arsenal 7 and 9: claw_shock / katana ids;
  showcase 9: the scenario's 30-tick plant check; showcase 13: spray across the pit wall).
- MERGE 03:33 n-rivet-arsenal (to 58c69b54; conflicts: JOURNAL kept ours, arena_rigs.gd kept both
  consts). Melee weapons are live: the katana swing is dealt as `katana` through CombatArena.damage.
  Unit 761/761 after it.
- FINDING 03:52 live katana (`--rigs --bot=rivet --loadout=katana`, 16 s, 64 px/m): the real swing
  fires `katana_split` (by_style split 1), with no lab code involved. The one victim in that run
  had no posed rig (an off-rig hostile near the wall), so blobs stood in for it. The pipeline
  works; a framed live-katana clip is still owed.
- MILESTONE 03:39 kill #7 chainsaw (`chainsaw_grind`, ae85d5d7): style split with a new
  `grind_ticks` (54): GibSim.wait keeps the two halves together; KillSplitFx shakes them on a tick
  hash, lifts them over Rivet's claws (z 40), and blood drops spurt out through the body (away
  from the saw, where Rivet does not cover them) with cream sparks off the teeth, then the halves
  fall apart along a straight cut (cut_deg 0) on red smears. The lab holds Rivet on the victim
  through the grind (hold_ticks). Scenario: 6 split kills, replay identical. Clips 64 px/m, 32 px/m,
  48 px/m city block, 64 px/m 0.4x slow, strip.
- FRICTION: the first grind showed no drops; they flew back toward Rivet and were drawn under his
  rig. Fixed by spraying out through the far side and drawing split_fx over HELD_Z.
- REQUEST 9 (showcase) confirmed: their 30-tick planted-fault check is cherry-picked (93c17a88).
- FIX 03:58 showcase REQUEST 13 (23f927df): KillMarks.clip walks each spray drop's ray on the
  stage push-out and lands it on the last free step before a wall (sim side, no dice). Unit test
  with a planted no-wall run.
- MERGE 03:57 n-gunplay (to 1c0aa98f; conflicts: JOURNAL ours, arena_rigs.gd gunplay's held-weapon
  kick + human-reactions' react gate). Brings the ray gun at 100 damage (a one-shot) and the
  mini-nuke.
- MILESTONE 04:00 kill #9 ray gun (`ray_gun_dissolve`, style `dissolve`, KillDissolveFx): the body
  copy sits under a round clip mask; it glows stiff for 12 ticks, then the mask shrinks over
  55 ticks. A hot cream ring eats the body from its outline inward, gold echo rings ripple out
  and motes fall. What is left: a dust pile, the crumpled blue uniform on it and the cap beside
  it. No blood. Reduced motion drops the echoes, motes and pulse. The lab stands the guards on
  the spread line for it. Scenario: 5 dissolve kills, replay identical. FIRST PASS, seen on the
  64 px/m strip: gunplay's ray scorch mark draws over the pile, the body darkens inside the mask,
  and the pile reads grey, not tan.
- Registry rules applied: realtime-combat-semantics (the kill is still decided at the damage
  chokepoint; the grind is a sim hold on the 60 Hz tick with no dice; the wall clip is
  deterministic). motion-quality-gating: every look claim judged on strips cut from real-time
  clips; the wall clip and the grind each have a planted fault (unit no-wall run; scenario 1 %
  gib fault).
- Shared files touched this iteration: arena_rigs.gd (both merge resolutions only). Nothing else.
- REQUEST 10 -> rivet-arsenal: please add `chainsaw` (heavy_two_hand is already in
  rivet_arsenal.json) and `plasma_sword` rows to melee_weapons.json, so `--loadout=chainsaw` puts
  the saw in Rivet's claws. The chainsaw kill keys on weapon `chainsaw`; a hit lands it, and
  holding Rivet in place for about 56 ticks after the lethal hit sells the grind (the lab does
  this now).
- REQUEST 11 -> gunplay: the ray gun's stop mark (scorch ring + pop, 54e3c280) lands on top of
  the dissolve's dust pile. Could the ray mark skip a hit whose victim died (kill_landed with
  weapon `ray_gun`), or draw under z 4?

## Calls for the owner (iteration 6 additions)
- brutality-8: the chainsaw cut runs straight along the saw's push vs. diagonally like the katana.
  Default: straight (chainsaw-grind clips). One value: `cut_deg`.
- brutality-9: the chainsaw grind lasts 54 ticks (0.9 s) vs. a shorter 30. Default 54. One value:
  `grind_ticks`.

NEXT (iteration 7):
1. Ray gun polish: find out why the body darkens inside the mask (flatten + the part material?),
   make the pile tan/cream glowing and bigger at 32 px/m, and keep gunplay's ray mark off a
   dissolve kill (REQUEST 11, or veto it the way CombatBlood is vetoed).
2. Kill #10 homing shard gun: shards stick in (cream slivers on the body copy), then after a
   delay burst into a pop of red mist (spray + a big soft red disc that fades). Check whether
   gunplay has a homing_shard_gun weapon id.
3. Kill #11 mini-nuke (gunplay enabled `mini_nuke`, kind thrown, 2000 damage): everyone in the
   radius vaporised to ink shadows on the ground (a `shadow` style: the body copy flattened to
   ink at alpha 0.85 that never fades, plus a flash under the screen-flash budget; reduced motion:
   no flash).
4. Re-cut the reel with all nine kills (add plasma sword, chainsaw, ray gun).
5. A framed live-katana clip (`--bot=rivet --loadout=katana` with the rigs focused) and the
   chainsaw live once rivet-arsenal adds the row.
6. The rocket kill frame spike (74 ms CONTENDED): per-phase log; pre-warm the copy materials.
7. KillView is 278 lines (hard stop 300): move the style dispatch (_on_killed's elif chain and
   _parts) into a KillStyles helper before the next style lands.
- 04:10 reel re-cut with all nine kills (32 px/m, 45 s, labelled):
  gtai-masters/n4/brutality/clips/signature-kills-reel-9-32ppm-45s.mp4 (NEXT 4 done). Looked at
  its sheet: every kill reads, but small, because the 32 px/m arena camera frames the whole hub.
- Gates on f6854d38+: lint 13/13, unit 775/775 (unit-it6.log), scenario_brutality_kills pass
  (9 weapons).
- 04:08 full scenario suite after the merges: 33/35. scenario_rivet_claw and scenario_rivet_katana
  failed (the bot never finished). Cause: my branch kept human-reactions' old react_line spot,
  which showcase found blocks the claw station on a merged build (their REQUEST 10). Cherry-picked
  human-reactions' fix 9503319e as 2107b178 (their station file, taken whole). After it: rivet
  filter 4/4, full suite 35/35 (scenarios-it6.log).
- FRICTION: a background unit run without `GODOT_BIN` exported reported "exit -1" on every phase
  and the previous junit count (762). Read the exit codes, not only the count.
- 04:13 final gates on 136a8e9a: lint 13/13, unit 775/775, scenarios 35/35. Session closed.
