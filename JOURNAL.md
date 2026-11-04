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

## Iteration 7 (04:14-05:14), BUILD (Director's 04:00 checkpoint: no new kills; make the nine read)
- Read: JOURNAL, git log, the Director's checkpoint (isolated re-shoots at 48 follow + 64 slow,
  two separated halves, a visible skeleton flash, the rocket first-frame spike).
- Registry rules applied: motion-quality-gating (every claim judged on frame sheets cut from
  real-time `--fixed-fps 60` captures; one isolated subject per clip so the read is not
  confounded by a crowd), realtime-combat-semantics (the solo lab only moves where Rivet and the
  guard stand; the kill is still decided at CombatArena's damage chokepoint).
- FINDING 04:16 the hub is crowded: three stations' dummy rows sit at y -3 (rivet-motion), 1.5
  (human-reactions react_line) and 4.4 (rivet-arsenal claw cops), right where the lab line stood.
  That is why the cuts were "hidden among bodies".
- MILESTONE 04:20 solo lab (8218d423): `--sig-solo=x,y` stands Rivet at that arena point with ONE
  guard 3 m in front (KillLab.SOLO_OFF), no refill. Spot (-36, 2) in the course is open floor
  (checked on 48 px/m stills of five candidate spots; the pad, range and course-east all have
  props or dummies in frame).
- MILESTONE 04:22 two clearly separated halves (katana, plasma sword, chainsaw): the halves used to
  leave mostly along the blade (SPLIT_FOLLOW 0.6) and slide ~2.2 m, so both flew off the same way
  and out of the close-up. Now SPLIT_FOLLOW 0.25 (they part sideways from each other) and the
  katana/plasma-sword rows launch at 2.4-3 m/s: the halves come to rest about 2 m apart on either
  side of the blood fan, both in the 64 px/m frame (sheet seen).
- MILESTONE 04:24 the electro skeleton flash reads: the X-ray now HOLDS 4 ticks right after the
  hit-stop (XRAY_HOLD) over a jagged cream zap burst in an ink rim, at 1.6 m (was 2 of every 5
  ticks, 1.3 m, under the arcs), then strobes 2 of every 6. 60 fps sheet: four frames of cream
  bones on ink in the burst, then the strobe, then the stiff drop. Reduced motion: no flash (as
  before).
- FINDING: in the solo lab the electro gun's first round only stuns the guard (gunplay's stun);
  the kill lands on the second round, 110 ticks later. Not a one-shot on a fresh human today.
- REQUEST 12 -> gunplay: the brief's electro kill is "the charged shot", but the electro gun is
  60 damage with a stun (two rounds to drop a fresh 100 hp human). A charged shot (hold to charge,
  >= 100 damage, kill_landed weapon `electro_gun`) would make it the one-shot the owner asked for;
  `electro_shock` keys on the weapon id, so no brutality change is needed.
- MEASURED 04:23 the rocket spike is not a first-kill warm-up: a solo rocket kill (the first and
  only kill of the session) costs 0.9 ms to cut (new telemetry `kill_cut_us`, per kill) and 4.7 ms
  worst frame at 48 px/m, 7.3 ms at 64 (CONTENDED), against 74 ms worst after 18 lab kills. The
  cost grows with the leftovers: every kill and every part coming to rest reprinted ALL twelve
  kills' spray, smears, scorches and heaps on one ground canvas.
- MILESTONE 04:29 per-kill ground print (39dd2d0f): KillGround, one node per kill (its spray,
  settled smears, scorch, ash heap), reprinted only when its own kill changes; prints whose mark
  was recycled are freed. Rocket lab, 20 s at 32 px/m, CONTENDED, same command before/after:
  worst kill-view frame 67.7 ms (26 kills) -> 20.5 ms (24 kills); avg 4.3 ms unchanged (the
  per-frame cost is the fresh smears of moving parts). Evidence
  evidence/brutality/cost-rocket-it7-{before,after}-ground-per-kill.json. Still drawn: every
  leftover (still checked at tick 1150).
- MILESTONE 04:31 isolated re-shoots, all nine kills: one cop, solo lab at (-36, 2), 48 px/m real
  time 8 s + 64 px/m 0.4x slow (`<kill>-solo-48ppm-8s.mp4`, `<kill>-solo-64ppm-slow-0.4x.mp4`), and
  a labelled 39 s solo reel at 48 px/m. Sheets seen for all nine; electro 60 fps strip in frames/.
  frames.json rewritten (14 entries, solo clips first, the old crowd clips as `before`).
- FRICTION: an ffmpeg in a `while read` loop eats the loop's stdin (every other reel entry
  vanished); `-nostdin`.
- FRICTION: the camera stops at the course's west edge, so at (-36, 2) Rivet sits left of centre
  at 48 px/m. (-30, 2) would centre him; not re-shot.
- Gates 04:32: unit 775/775 (unit-it7.log).
- Gates 04:34 on 39dd2d0f: unit 775/775, scenarios 35/35 (scenarios-it7.log).
- MILESTONE 04:38 kill #10 homing shard (FIRST PASS, `homing_shard_burst`, style `burst`, already
  reserved in the schema): a gib-path row with grind_ticks 36. GibSim.wait holds the six parts
  together (the cop stands frozen on the shard), then they pop forward (cone 200 deg; 360 threw
  parts back over Rivet) in a full 360 deg ring of red mist. No new code. Weapon id `homing_shard`
  (gunplay). Clips: homing-shard-burst-solo-64ppm-{5s,slow-0.4x}.mp4. Missing: the shards stuck
  in the body during the hold, and the spray lands at the hit rather than at the pop.
- MILESTONE 04:38 kill #11 mini-nuke (FIRST PASS, `mini_nuke_vaporise`, style `vaporise`):
  KillCharFx takes it like a burn but keeps the char print as a flat shadow (alpha 0.8) on a
  0.7 m soot ring, with no embers, smoke, crumble or flash of its own. The shell's flash is
  gunplay's, under their flash budget and reduced motion. On the hub line one shell vaporises
  every human in the circle (22 in 11 s incl. the react dummies, which revive). FINDING: gunplay's
  6 s nuke fire patch covers the shadows, so they only read once it burns out.
- Scenario 04:37: scenario_brutality_kills now covers 11 weapons (homing_shard: 3 bursts,
  mini_nuke: 22 vaporised), replay identical, same seed same gibs, planted fault caught.
- REQUEST 13 -> gunplay: the mini-nuke's fire patch hides brutality's vaporise shadows for 6 s.
  Options: draw the patch under z -1, or shorten it for the nuke. Separately, the homing shard
  could keep its shards on the body (a stuck-shard list per victim) so the burst kill can draw
  them during its 36-tick hold.
- Shared files touched this iteration: none (rows in my own table; my own scenario).

## Calls for the owner (iteration 7 additions)
- brutality-10: the blade halves part sideways (SPLIT_FOLLOW 0.25, they rest ~2 m apart in place)
  vs. flying on along the blade (0.6, the old crowd clips). Default 0.25 (katana solo clips).
- brutality-11: the electro X-ray holds 4 frames over a cream zap burst, then strobes, vs. a pure
  strobe. Default: hold + burst (electro strip). One value: KillShockFx.XRAY_HOLD (0 = old strobe).
- brutality-12: mini-nuke victims become flat charcoal shadows that stay vs. white ash outlines.
  Default: charcoal (mini-nuke clip, first pass).

NEXT (iteration 8):
1. Homing shard: the shards and the mist puff are in (c8a26ff6). Still to do: move the red spray
   ring to the pop (marks at tick + grind), and add more shards on the near side when Rivet is far.
2. Mini-nuke: once gunplay answers REQUEST 13, a clean clip of several shadows on the street; a
   paler, slightly larger shadow; a solo spot clear of the course walkers ((-36, 2) is clear).
3. Re-shoot the solo set at (-30, 2) (Rivet centred), and in the city block with --sig-solo.
4. The remaining 20 ms worst frame on the rocket lab: the fresh-smear layer (every moving part's
   smear redrawn every frame); split fresh per kill like KillGround.
5. KillView is 290 lines (hard stop 300): move the style dispatch into a KillStyles helper first.
6. Electro is two rounds (REQUEST 12 -> gunplay: a charged shot).
- MILESTONE 04:47 homing shard view (c8a26ff6, KillBurstFx, render only): cream shards in an ink
  rim stick out of the frozen body's FAR side and tremble harder toward the pop; at the pop a red
  mist puff swells and thins over the flying parts. Clips re-shot (homing-shard-burst-solo-64ppm-*).
- FRICTION: the first shards were invisible. A magenta debug probe showed the hold branch drew,
  but the shards sat on Rivet's side under his claw, and as thin cream slivers on a cream torso.
  Fixed by moving them through to the far side and making them longer and wider (0.4-0.58 m,
  0.2 m base) with a 1.2 px rim (a 2.4 px rim swallowed the cream fill). The probe was reverted
  before commit.
- FRICTION: gdformat writes CRLF here, so python `\n` replaces miss after it runs. Use the Edit tool.
- 04:52 final gates on c8a26ff6: lint 13/13, unit 775/775, scenarios 35/35 (unit-it7.log, scenarios-it7.log). Session closed.

## Iteration 8 (04:52-05:52, BUILD)
- 04:53 read JOURNAL, git log, other lanes' JOURNALs. For brutality: showcase REQUEST 17 (char
  flakes and scorch fail Godot triangulation: 4,462 errors in one city reel, flakes never drew);
  gunplay answered my REQUEST 13 in a1eb709f (the nuke's fire patch burns as a ring round its rim).
  REQUEST 12 (electro charged shot) not answered yet.
- MILESTONE 05:00 showcase REQUEST 17 fixed (11781168): KillPoly.fill draws every kill fill
  (flakes, shards, scorch, blots, zap star, cloth pile) as a triangle fan with explicit indices via
  RenderingServer.canvas_item_add_triangle_array, so nothing is triangulated. Flame solo 64 px/m:
  0 triangulation errors, the ash flakes now peel off downwind (strip in
  evidence/brutality/shard-pop-and-flame-flakes-it8-strips.png). Unit test test_kill_poly.
- 05:01 cherry-picked gunplay a1eb709f (nuke fire patch as a ring, clean).
- MILESTONE 05:02 homing shard spray at the pop (31e69dc5): Mark.spray_from = hitstop + grind for
  style burst; the frozen cop stands on a clean floor, then parts, mist and spray land together.
  Render only, mark state of record unchanged.
- MILESTONE 05:06 nuke pack (6e0f8f23): --sig-solo with a vaporise row stands KillLab.PACK, five
  guards 8-10 m out; one shell, five charcoal shadows that stay (48 px/m clip
  mini-nuke-pack-48ppm-10s-it8.mp4, sheet in evidence/brutality/).
- FRICTION: my first three clips this session lacked `--rigs`: the arena then draws quest 1's
  sprites, the kill finds no rig to cut (rig_lookup null) and the victims fall as plain corpses.
  Found with a temporary Log line in _on_kill_landed (rigs=false), reverted. Every kill capture
  needs `--rigs`.
- 05:08 gates on 6e0f8f23: unit 770 + script error: the gunplay cherry-pick's test line `fx.art_mags`
  needs gunplay 4953ee25 (not in this branch). Dropped that one line (bf177d50; it comes back
  with gunplay's merge, net zero against main). Unit re-run 778/778 (unit-it8.log).
- Scenarios 34/35 on the same run: scenario_rig_stress rig p50 1.105 ms > 1.0 ms while a capture
  ran in parallel; alone 1/1 (scenario-rig-stress-alone-it8.log). Load flake, not this lane.
- MILESTONE 05:09 the city block works with rigs again (647a9622): `--arena=city --rigs` crashed in
  ArenaRigs.attach (rivet-arsenal's held-weapon view went on view.print_stage, null on the city);
  took showcase's identical glue line (layer.add_child(held)). Shared file: dev/arena/arena_rigs.gd,
  one line. `--sig-solo=start` puts the solo lab at Rivet's city start (the hub dummy rows still
  stand around; the city has no open course floor near the start).
- MILESTONE 05:15 KillStyles (ac274158): the style dispatch and the five overlays leave KillView
  (295 -> 242 lines). Katana halves and electro X-ray re-seen at 64 px/m after the move.
- MEASURED 05:16 kill-view cost from the clips' telemetry (CONTENDED, captures at 60 fps fixed):
  rocket on the city block 6.2 ms worst frame, avg 0.63 ms, cut 0.52 ms; nuke pack (5 kills in one
  tick) 3.4 ms worst, cuts 1.6/0.4/0.3/0.5/0.5 ms; shard 2.2 ms worst; flame 3.5 ms worst = its
  first cut (3.4 ms, the char material's first build).
- MILESTONE 05:19 city proving block reel (game-city): eight signature kills, one cop each at
  Rivet's city start (`--arena=city --rigs --sig-lab --sig-gun=<gun> --sig-solo=start`, 48 px/m,
  real time, labelled, 56 s): rocket, hand cannon, flamethrower, electro (2nd round), plasma rifle,
  ray gun, homing shard, plasma sword. One signature kill per clip (telemetry). Masters:
  clips/city-block-reel-8-kills-48ppm-56s-it8.mp4 (frames.json entry 4). Weak: the hub's dummy
  rows crowd the victim at the start; an open city spot would read better.
- MILESTONE 05:21 rivet-arsenal REQUESTs 7/9 answered: row electro_shock also keys on `claw_shock`
  (optional `also_weapons` column in my own schema), so Rivet's full-charge claw shock is a
  ONE-SHOT electro X-ray kill on a fresh human today (unit test). Not shown live: `--bot=rivet`
  plays the claw combo on the react dummies and never lands a full-charge shock kill in 19 s
  (signature_kills 0); a lab hook that fires the charged shock would show it.
- Gates 05:21-05:25 after the claw_shock alias: lint 13/13, unit 779/779, scenarios 35/35 (scenarios-it8.log).
- Shared files touched this iteration: dev/arena/arena_rigs.gd (one line, showcase's identical
  glue); tests/unit/test_gun_fx.gd (dropped the cherry-picked art_mags line, net zero vs main).
- Registry rules applied: motion-quality-gating (every kill judged on clips and strips at 64 px/m,
  rejected three clips shot without rigs); depth-ordered-layered-art (the shard spray waits for
  the pop so the ground print does not lead the event).

## Calls for the owner (iteration 8)
- brutality-13: the electro one-shot lives on Rivet's charged claw shock (claw_shock, now keyed)
  while the electro gun stays two rounds; or also make the gun's shot charged (REQUEST 12 ->
  gunplay, open). Default: both keyed, gun unchanged.
- (brutality-12 holds: mini-nuke charcoal shadows; now shown on a pack of five,
  mini-nuke-pack-48ppm-9s-it8.mp4.)

- MILESTONE 05:27 the electro one-shot has a clip (d46ad8b3): `--sig-gun=claw_shock` makes the solo
  lab drive Rivet's own PlayerShock: one guard at 1.5 m (reach 1.6), the charge held 66 ticks
  (full at 54), released on him: crackle, the cream zap burst with the X-ray skeleton, the stiff
  drop (strip evidence/brutality/claw-shock-electro-oneshot-64ppm-it8-strip.png; masters
  claw-shock-electro-oneshot-solo-64ppm-{5s,slow-0.4x}-it8.mp4, frames.json entry 2). At 1.2 m
  the body overlapped Rivet; 1.5 m parts them. The rig's own thrust clip does not play (the lab
  steps its own PlayerShock, not the pilot's).
- MILESTONE 05:28 open city spot (95316aff): `--sig-solo=start:dx,dy`; the lab pins a gun-armed
  Rivet to the spot every tick (the city block re-placed him at the start after setup, so he
  fired from the start). At start:-9,0 the victim stands alone on open asphalt; the city camera
  stays at the start, so Rivet sits near the frame edge. Re-shooting the reel at start:-7,0.

- Gates 05:31 on 95316aff: lint 13/13, unit 778/779 with test_noir_shadows (the brief's known
  load flake: `Parameter "t" is null`), 2/2 alone (unit-noir-shadows-alone-it8.log); scenarios
  35/35 (scenarios-it8.log).

- MILESTONE 05:34 city reel re-shot on the open spot (start:-7,0): nine kills incl. katana and
  plasma sword, one isolated cop each, labelled, 61 s, 48 px/m, one signature kill per clip
  (telemetry). Masters clips/city-block-reel-9-kills-open-spot-48ppm-61s-it8.mp4 (frames.json
  entry 5; the hub-row reel kept as `before`); sheet in evidence/brutality/. Weak: the victims sit
  left of centre (the city camera holds the start) and the burning cop runs out of the open spot.

- MILESTONE 05:35 determinism for the claw shock (18795a8e): scenario_brutality_kills runs
  claw_shock on KillLab.CLAW_LINE (three guards in claw reach, one charge per SHOT_EVERY): 3
  one-shot shock kills in 700 ticks, same seed same state, replay identical (evidence
  brutality-kills.json, 12 weapons).
- GATES OF RECORD 05:37 on 18795a8e: lint 13/13, unit 779/779, scenarios 35/35 (unit-it8.log,
  scenarios-it8.log). Parity and bench not run (no city-sim change; no bench this iteration).

NEXT (iteration 9):
1. The claw-shock lab plays the pilot's shock so Rivet's thrust clip shows with the X-ray.
2. City camera: follow Rivet at his solo spot (the city camera holds the start); add the chainsaw
   and the nuke pack to the city reel.
3. The rocket on the city block: 6.2 ms worst kill-view frame (CONTENDED); split the fresh-smear
   layer per kill like KillGround and measure again.
4. Homing shard: more shards on the near side when Rivet is far.
5. Electro gun charged shot (REQUEST 12 -> gunplay) when it lands: key nothing new, re-shoot.
- 05:38 session closed. Scratch renders not in frames.json deleted; masters frames.json 15 entries.

## Iteration 9 (05:39-06:39, BUILD)
- 05:40 read JOURNAL, git log, other lanes' JOURNALs. For brutality: showcase REQUEST 21 (the plasma
  `hole` victim keeps his standing silhouette with a dark disc for 5 s at 48 px/m: not read as a
  death); gunplay REQUEST 12 DONE (0c0465fd, the electro gun's charged shot) and REQUEST 13 second
  ask DONE (89c5fac9, stuck shards; not picked yet).
- MILESTONE 05:44 REQUEST 21 answered (eb04a301, KillHoleFx.Topple): the victim stands 8 ticks after
  the hit-stop with the glowing hole, then over 12 ticks (eased in) falls flat back along the shot.
  Seen straight down a fall is a lay-out, not a turn: slid 0.45 m along the shot, stretched 1.55x
  along the fall line, narrowed 0.88x across, twisted 0.35 rad. Render only. Unit test (stands
  while looking; lies along the shot; the pose is absolute).
- FRICTION: the first try rotated the body 90 deg and shifted it screen-down: in the straight-down
  view that read as a spin and slid him out of frame. The second wrote a stretched transform into
  KillView's node: KillView resets position/rotation/scale each frame but not skew, so the skew
  compounded and the body collapsed into a needle in 3 frames. Fix: punch() puts a `lay` node
  under the body root; Topple writes its transform absolutely each frame.
- 05:45 gates on eb04a301: lint 13/13, unit 781/781 (gut ran the whole suite), scenarios 35/35
  (evidence/brutality/scenarios-it9.log).
- MILESTONE 05:50 electro gun one-shot: cherry-picked gunplay 0c0465fd as 5473194f (conflict in
  weapon_spec.gd: dropped gunplay's `min_lob_m` line, which needs a gunplay commit this branch
  does not carry; net zero at the merge). KillLab._held_ticks (22649e3f) holds a charge gun's
  trigger through its tap, cooldown and full charge (30 + 36 + 3 ticks), so the plain bolt stuns,
  the charge gathers on the claw, and the 150-damage charged bolt lands the electro_shock kill.
  Needed one `--import` for the new class_name FightChargeArt (else 370 parse errors in a capture).
- Determinism: scenario_brutality_kills electro_gun 12 kills (12 signature) where 6 two-round kills
  stood, same seed same state, replay identical (evidence/brutality/brutality-kills.json).
- Clips 05:55 (looked at strips of each): electro gun charged one-shot solo 48 px/m + 64 px/m 0.4x
  slow + city block 48 px/m; plasma topple solo 48 + 64 slow + city 48. One signature kill per
  clip (telemetry), 0 script errors. Masters frames.json: 3 new entries on top; dropped the old
  electro strip, the old electro solo and the it7 solo reel (superseded), 15 entries.
- On the city block the tap bolt chains into the hub dummy row behind the victim (gunplay's 3
  chain hops). Reads as the gun working; it pulls the eye off the victim for half a second.
- MEASURED 05:58 the rocket's "first-frame spike" on the city block is not the first frame: new
  telemetry (view_worst_tick, kill_ticks, view_over_2ms) put the worst frame (4.0 ms) at tick 116,
  50 ticks after the kill at 66, with 48 of 480 frames over 2 ms: the cost was the slide, where
  the fresh layer redrew every smear blot (six parts x 40 points x 2 circles) every frame.
- MILESTONE 06:01 smears grow blot by blot (47e38261): KillMarkArt.smear_blot appends each new slide
  point once to a RenderingServer canvas item under its kill's KillGround (freed with it); the
  fresh layer, settled_smears and _track_moving are gone (KillView 242 -> 214 lines). Rocket city
  block 48 px/m, CONTENDED: worst 4.0 -> 1.2 ms (now the cut, tick 67), avg 545 -> 223 us, frames
  over 2 ms 48 -> 0 (evidence/brutality/rocket-city-48-telemetry-{before,after}-it9.json). Looked
  at: rocket before/after frames identical (rocket-city-smear-before-after-it9.png); hand cannon
  64 px/m long smear still tapers off behind the sliding body.
- FRICTION: a unit run without GODOT_BIN exported printed "exit -1" on every phase with a stale
  count (779); it is the same trap as iteration 6. Always export GODOT_BIN with APPDATA.
- Unit 785/785 on the smear change (781 + gunplay's 4 charge tests; unit-it9.log).
- DEFERRED: Rivet's thrust clip in the claw-shock lab. arena_rigs plays it on
  stage.pilot.shock.discharges, but the pilot steps its own PlayerShock every tick with the
  player's button, so the lab cannot drive that one without the two drivers fighting; it needs
  an input-level hook (the lab pressing melee through TickInput). rivet-arsenal's ground.
- 06:05 scenarios 35/35 on 47e38261 (scenarios-it9.log; brutality-kills.json unchanged). Note:
  `--evidence-dir` makes every scenario write its evidence there; I deleted the extra files.
- MILESTONE 06:09 city proving block reel, all eleven kills (game-city), 48 px/m, real time, 80 s,
  labelled: one isolated cop each at start:-7,0, the nuke on its pack. 0 script errors; one
  signature kill per clip except the nuke (10 bodies in its radius: the pack plus hub dummies).
  Masters clips/city-block-reel-11-kills-48ppm-80s-it9.mp4 (frames.json, it8 reel as before);
  sheet evidence/brutality/city-block-reel-11-kills-it9-sheet.png.
- MEASURED worst kill frame (kill-view CPU, CONTENDED, captures at 60 fps fixed, new telemetry):
  mini-nuke on the city block 4.3 ms on its kill tick (10 cuts at once); homing shard 2.5 ms;
  hand cannon 2.2 ms; flame 1.9 ms (its first char build); katana/chainsaw/plasma sword/ray gun
  1.1-1.4 ms; rocket 1.2 ms (after the smear fix). Every single kill now under 2.5 ms.
- MILESTONE 06:16 homing shards fan out (85d3609f). FRICTION/finding: a magenta probe in the hold
  branch showed the five far-side shards were drawn on top all along but stacked into one wedge
  (hashed sides within +-0.18 m, turns +-0.25 rad), so every clip since it7 showed one spike.
  Now spread evenly over the far side (turns to +-1.2 rad) plus three short butts on the near
  side. Tried and rejected first: a z raise to 200 (no change: z was never the problem; reverted).
  64 px/m slow re-cut in masters (frames.json entry replaced, it8 as before).
- Registry rules applied: motion-quality-gating (every change judged on 64 px/m strips; the
  shard probe before guessing at a fix); realtime-combat-semantics (the electro one-shot is the
  gun's own charged shot, not a lab damage cheat; the lab only holds the trigger).

## Calls for the owner (iteration 9)
- brutality-14: the plasma victim falls flat back along the shot after an 8-tick look at the
  hole (clips/plasma-hole-topple-solo-64ppm-slow-0.4x-it9.mp4) vs. dropping at once with no
  look. Default: the look (one value: KillHoleFx.LOOK_TICKS = 0).
- brutality-15: the electro gun's one-shot needs the held charge (tap stuns, hold kills;
  clips/electro-gun-charged-oneshot-solo-64ppm-slow-0.4x-it9.mp4). Default: as gunplay built it.

NEXT (iteration 10):
1. City camera: follow Rivet at his solo spot (the camera holds the start, so the nuke pack and
   any start:dx spot sit at the frame edge); then re-shoot the nuke pack on the city block.
2. The claw-shock lab: press melee through TickInput so the pilot's own PlayerShock fires and
   Rivet's thrust clip plays with the X-ray (deferred this iteration; see above).
3. Homing shard: the crystals are cream on a cream torso; try an ink-dark core or a red root so
   they read at 32 px/m; check the near-side butts under the victim's gun arm.
4. The nuke's 4.3 ms tick (10 cuts at once): spread the cuts of one tick over two frames, or
   cache the cut per rig look.
5. Cherry-pick gunplay 89c5fac9 (stuck shards on the corpse) and check it does not double up
   with KillBurstFx.
- MILESTONE 06:20 homing shards stand in red wounds (59429978): a blood dot at each shard's base
  and a 1.6 px ink rim; at 64 and 32 px/m the red now leads the eye to the cream crystals
  (evidence/brutality/homing-shard-wounds-64-32ppm-it9.png). Masters slow cut re-made, 32 px/m
  real-time clip added.
- 06:23 32 px/m real-time clips for the plasma fall and the electro charged one-shot (one
  signature kill each, 0 script errors; strips evidence/brutality/plasma-electro-32ppm-it9-strips.png).
- GATES OF RECORD 06:21 on 59429978: lint 13/13, unit 785/785 (unit-it9.log), scenario
  brutality 1/1 (scenario-brutality-it9.log); full suite 35/35 on 47e38261 (the commits after it
  are render-only: KillBurstFx). Parity and bench not run (no city-sim change; no bench taken).
- Shared files touched this iteration: none outside my folder, except the gunplay cherry-pick
  (5473194f: weapons.json, weapons.schema.json, weapon_spec.gd, trigger.gd, gun_hand.gd, shot.gd,
  gun_fx_art.gd, fight_areas_art.gd, fight_charge_art.gd, test_charge_shot.gd; gunplay's own
  commit, minus the `min_lob_m` line).
- 06:24 session closed. Scratch renders of this iteration deleted (all kept clips are in masters
  or evidence/brutality); masters frames.json 15 entries. No Godot process of mine left running.
6. (from 06:24) A capture now ends with "1 RID of type CanvasItem was leaked": the smear canvas
   item of a KillGround that is never freed at quit (the arena already leaks ~465 ObjectDB
   instances at exit). Free the smear RIDs from KillView's NOTIFICATION_PREDELETE / _exit_tree too.

## Iteration 10 (06:24-07:24, BUILD)
- 06:25 read JOURNAL, git log, other lanes' JOURNALs. No new REQUEST to brutality. Showcase's r9
  evidence (06:22) has look goldens 4/11 and names brutality's incremental smears as one suspect.
- MEASURED 06:30 look goldens on this branch (59429978, private APPDATA, CONTENDED): 11/11 within
  mean 4 (worst 1.54). The smear change does not move the look; told showcase below.
- NEXT 6 closed, no change: the "1 RID of type CanvasItem was leaked" at quit is there in a plain
  arena run with no kill (`arena.tscn -- --ppm=48`, 300 frames), so it is not the KillGround smear
  item (that one is freed on PREDELETE). Suspect view_prewarm.gd's texture item (not my folder).
  I tried freeing on EXIT_TREE too; the leak stayed; reverted.
- NOTE -> showcase: brutality 59429978 gives look goldens 11/11 (worst 1.54); bisect elsewhere.
- FRICTION 06:35 `--sig-gun=mini_nuke_launcher` is not an id (the gun is `mini_nuke`): the lab silently
  kept the default gun and a standard death. Check telemetry by_style before looking at frames.
- MILESTONE 06:40 NEXT 1 done (c4883020): the city camera held the start because CollectCallStage.step
  sets the city follow from Rivet before the hooks step; KillLab then moved Rivet to the solo spot,
  and on the next tick the city body pulled him back to follow.target (the start). KillLab now
  moves the follow with him (target = the spot, focus halfway to the guards' centre, so the nuke's
  pack sits mid-frame). Found `start:-22,0`: an open street with a police car and an ambulance at
  the kerb, no hub dummies in the nuke radius (at start:-7,0 the hub's dummy row stood on in the
  flames).
- Clips 06:47 (looked at the sheet evidence/brutality/nuke-city-it10-sheet.png): mini-nuke pack on the
  city block, 48 px/m 9 s real time, 64 px/m 0.4x, 32 px/m 8 s; five vaporise kills + one street
  pedestrian burnt by gunplay's fire patch; 0 script errors. Masters frames.json: the three on top,
  the it8 nuke clip and the electro city clip dropped (the eleven-kill city reel covers it); hand
  cannon kept. At 64 px/m the outer ring runs past the right edge; the shadows stay in frame.
- MEASURED 06:48 NEXT 4 was misread: the nuke's kill tick is not "10 cuts at once": kill_cut_us
  [1678, 64, 54, 55, 53] = the FIRST cut is cold and every later one is about 55 us. Flame's first
  kill paid the same (1.9 ms in it9).
- MILESTONE 06:50 the char print warmed at load (bbc674ee): KillCharFx._ready builds the char
  material and draws one faint speck with it for 0.1 s. City block 48 px/m, CONTENDED: nuke first
  cut 1678 -> 79-154 us, the kill-window worst (tick 108, 4.1 ms) gone; flame first kill 75 us.
- LEAD (unfixed): a burn/vaporise kill has one 2.4-5.4 ms kill-view frame at exactly age 96 (nuke 105
  -> 201, flame 347 -> 443, four runs, deterministic). Ruled out with temporary probes (reverted):
  KillGround._draw (spray/scorch/pile all < 0.5 ms) and KillView._process incl. styles.pose().
  Tried and rejected: a second plain ash speck in the prewarm (no change). Left: KillView._draw.
- GATES 06:58 on bbc674ee (private APPDATA, CONTENDED): lint 13/13; unit 785/785 (the first run had
  test_noir_shadows, the known load flake; the re-run passed all 785); scenario brutality 1/1
  (scenario-brutality-it10.log); look goldens 11/11 (on 59429978; both later commits render only /
  dev lab). Full scenario suite, parity, bench not run this iteration (no sim change).
- Registry rules applied: motion-quality-gating (judged on the frames before and after each change;
  telemetry before guessing at the cost); realtime-combat-semantics (no sim change: the camera fix
  is in the dev lab, the prewarm is render only).

- 06:55 LEAD narrowed (probes reverted): the age-96 cost is inside KillView._draw's gib-shadow loop
  (72 slots, a draw_circle per live gib): 2.0-4.1 ms there at tick 443, and once 2.0 ms at tick 160
  with no kill yet. 72 iterations cannot cost that: a main-thread stall (six lanes on the machine,
  or a render sync) landing in whichever timed block runs, not the kill's own work. The thread
  model is the default (single-safe). Unresolved.

NEXT (iteration 11):
1. The age-96 stall (LEAD above): run the same flame capture --headless with the gib-loop probe; if
   it vanishes it is a render sync (then look at what the crumble starts drawing at age 96:
   KillCharFx flakes + smoke), if not, contention (re-measure under bench.lock).
2. Re-shoot the eleven-kill city reel with the follow fix (each kill at its own clear spot; the
   start:-22,0 street works for the gun kills too).
3. The claw-shock lab: press melee through TickInput so the pilot's own PlayerShock fires (it9 NEXT 2).
4. Cherry-pick gunplay 89c5fac9 (stuck shards on the corpse) and check against KillBurstFx
   (showcase's merged reel reads "shards stuck -> burst" fine, so low risk).
5. The plasma rifle hole at 32 px/m (still the faintest kill at game zoom).
- FRICTION 07:08 the 06:47 nuke clips were shot WITHOUT `--rigs` (this branch's arena still draws quest 1's
  orange sprite cops; rigs-by-default lives in showcase's merge). Re-shot 07:12 with `--rigs`: the blue
  cast cops; the five shadows now read as black cop silhouettes in the scorch ring. Masters clips
  replaced under the same names; sheet evidence/brutality/nuke-city-it10-sheet.png re-made. 0 script
  errors. Always pass `--rigs` on this branch.
- 07:06 fix 584b3f77 (kill_hole_fx): Topple.pose skips a holed body with no rig cut (a sprite victim):
  266 script errors per plasma capture without --rigs, now 0. Unit test_kill* 9/9.
- Tried and rejected: the plasma ring's COOL colour (dark brown -> dim cream): no visible change at
  32 px/m (the ring is 6 px); reverted.
- 07:15 session closed. Gates of record: lint 13/13 (every commit), unit 785/785 on bbc674ee, scenario
  brutality 1/1, look goldens 11/11 (59429978). No Godot process of mine left running. Scratch
  gtai-n4/scratch-brutality/it10 (frame dumps, not referenced) left for deletion: the tool blocks rm
  on that folder.

## Iteration 11 (07:14-08:14, BUILD, the last before the 08:30 freeze)
- 07:15 read JOURNAL, git log, the lanes' JOURNALs. Open to brutality: showcase REQUEST 26 (ray pile
  reads as a round cream token), 27 (molotov victim hidden under the fire-patch stars), 28 (plasma
  topple null on the city block).
- REQUEST 28: already DONE by 584b3f77 (it10, 07:06): `Topple.pose` returns when the body has no
  child 0 (exactly showcase's suggested guard, kill_hole_fx.gd:83-85). NOTE -> showcase: no glue needed.
- REQUEST 27 -> not mine to draw: the fire patch is FightAreasArt._patch, drawn by fx_view at the
  `fx` band (z 400 on the actors canvas); the kill view sits at `actors - 1` (z 99) with its char
  overlay at +4. Lifting the corpse to z 400 would lift every gib over vehicles and roofs.
  REQUEST 29 -> gunplay (cc showcase): in `FightAreasArt._patch`, skip (or shrink to 0.3x) the fire
  stars whose centre is within 0.5 m of a corpse older than 60 ticks; brutality exposes the corpse
  spots as `SignatureKills.marks` (KillMarks rows with the kill tick). If not in by the merge,
  showcase's suggested z option is NOT safe (see above); the thin-stars option is.
- MILESTONE 07:30 REQUEST 26 answered (render + one data column): the ray gun's remains are now
  KillDustPile (new file): a lumpy hashed heap drawn out along the ray (1.24 m x 0.52 m, blown
  0.22 m downstream), a darker drift on its far side so it reads as a mound, an ink under-print in
  the heap's own shape (no circle anywhere), the empty uniform crumpled flat across its near half
  with ink fold lines, ink crumbs and cooling sparks scattered along the ray. The round thing that
  read as "a cop seen from above" was the cap gib lying on the pile: new optional row column
  `hat_kick_mps` (signature_kills schema; ray row 1.8) throws the hat alone off to one side of the
  shot (alternating by kill serial; no extra dice, so the RNG stream is unchanged), so it lands
  ~0.5 m off the heap on bare street. Sim note: only ray kills' hat positions change (in the world
  hash); every other row has kick 0.
- DECISION brutality ray remains: an elongated heap along the ray with the cap knocked aside, over
  showcase's "uniform crumpled flat and cap half a metre off" both taken; rejected keeping the cap on
  the pile (it is the token). Alternative = `hat_kick_mps: 0` (one data value).
- Clips 07:32 (looked at the crops/sheets: evidence/brutality/ray-remains-city-64ppm-it11-sheet.png,
  ray-remains-city-32ppm-it11-crops.png): ray gun on the city block, cast rigs, start:-22,0, 48 px/m
  real time, 32 px/m real time, 64 px/m 0.4x; 0 script errors each. The remains now read as the
  blue uniform on a pale dust drift along the ray with the cap lying aside on bare street.
  Committed 9c9aaabf (+ test_kill_dust_pile 2/2: the ray row kicks, the cap lands > 0.3 m to the
  side and < 2 m away).
- MILESTONE 07:38 NEXT 5 (70af17b3): plasma hole 0.2 -> 0.26 m, the bloom cools over 150 ticks,
  a thin gold ember lip stays lit. City block 32 px/m and 64 px/m 0.4x (0 script errors): the lying
  cop keeps a ringed hole to the end of the clip (evidence/brutality/plasma-hole-city-32ppm-it11-sheet.png).
  Showcase's "plasma victim is a dark blob at 64" is partly this: the hole now has a lit rim.
- GATES 07:37 (private APPDATA, CONTENDED): lint 13/13 (pre-commit, both commits); unit 787/787
  (on 9c9aaabf's tree); scenarios --filter=brutality 1/1, --filter=gunplay 2/2 (the gunplay fight
  fires the ray gun: no golden moved by the cap kick); full suite 35/35 on the 70af17b3 tree
  (evidence/brutality/scenarios-it11.log).
- Masters frames.json 07:40: four new city entries on top (ray 64 slow, ray 32, plasma 32, plasma
  64 slow); dropped the old ray solo, the it9 plasma solo, the it8 claw-shock and the nuke 32 (the
  nuke 48 and 64 stay). 15 entries.
- Registry rules applied: motion-quality-gating (judged on the frames at all three zooms before each
  commit; rejected the first heap pass because the cap still sat on it); depth-ordered-layered-art
  (the heap's ink under-print, the drift, then the cloth and the cap on top, not one disc);
  realtime-combat-semantics (the cap kick is on the 60 Hz gib sim with no new dice).
- MILESTONE 07:53 NEXT 2 (re-shot city reel): `clips/city-reel-8-kills-48ppm-it11.mp4` (masters,
  frames.json first entry, replaces the it9 reel entry which stays as `before`): rocket, hand cannon,
  flamethrower, electro (charged), plasma rifle, ray gun, homing shard, each with one isolated cast
  cop on the open street (`--arena=city --rigs --sig-lab --sig-gun=<gun> --sig-solo=start:-22,0
  --ppm=48`), then the it10 mini-nuke clip; labelled, 57 s, 0 script errors in every capture. Looked
  at the sheet (evidence/brutality/city-reel-8-kills-it11-sheet.png): every kill lands in frame.
- FRICTION 07:50 the melee kills (katana, plasma sword, chainsaw) do not stage on the city spot:
  `--sig-gun=katana --sig-solo=start:-22,0` ran the plain hub (Rivet among the dummy rows, no lab,
  no kill in 6 s). Killed my plasma_sword and chainsaw captures (by PID) to save the time. They stay
  in the it9 reel and their 64 px/m solo clips.
- FRICTION 07:51 the first 3 frames of every city capture show the hub (the follow moves to the solo
  spot on tick 1-2): trimmed by starting each chapter at frame 3 (camera break rejected).
- 07:56 scratch it11 frame dumps (7.9 GB) and the it10 scratch deleted; the published clips
  are in masters.

NEXT (iteration 12 / the report):
1. REQUEST 29 -> gunplay (molotov corpse under the patch stars) is open; if gunplay does not take it,
   the safe glue is thinning `FightAreasArt._patch` stars within 0.5 m of a KillMarks.Mark (`at`,
   `tick`) older than 60 ticks. Do NOT lift KillView to the fx band (gibs would draw over vehicles).
2. The melee kills on the city: make KillLab stage a melee weapon at --sig-solo (Rivet steps in and
   swings), then shoot katana, plasma sword and chainsaw on the open street for the reel.
3. The age-96 stall (it10 LEAD) still unmeasured headless.
4. Cherry-pick gunplay 89c5fac9 (stuck shards on the corpse) and check it against KillBurstFx.
5. Calls for the owner (new): brutality-ray-cap: the ray gun's cap knocked aside (now) vs left on the
   heap (`hat_kick_mps: 0`); clips: ray-dissolve-city-64ppm-slow-0.4x-it11 vs ray-gun-dissolve-solo-64ppm-slow-0.4x.
- LEAD 07:57 for NEXT 2 (melee on the city): KillLab.step re-places Rivet at the solo spot every
  tick only for guns (`if solo != Vector2.INF and blade.is_empty()`, kill_lab.gd:107), because the
  blade lunge moves him itself; on the city the body then pulls him back to follow.target. Fix shape:
  for a blade, re-place the follow (target = the lunge's current pos) instead of Rivet. Not landed
  this late (08:30 freeze).
- 07:58 session closed. Gates of record on 70af17b3 (private APPDATA, CONTENDED): lint 13/13 (every
  commit), unit 787/787, scenarios 35/35, brutality 1/1, gunplay 2/2. Parity and bench not run (no
  city-sim change; the cap kick is in the kills' own gib sim). No Godot process of mine running.

## Iteration 12 (07:55-08:30), BUILD

- MILESTONE 07:59 NEXT 2 landed (94ddeae6): the melee kills stage on the city block. With
  `--sig-solo` a blade now places Rivet at the solo spot once (KillLab never placed him for a
  blade, so he stayed at the hub 22 m from his guard: the it11 "plain hub, no kill" was the camera
  on the hub while the kill happened off screen), and each tick after the lunge the city's
  `follow.target` is set to his lunge position so the body does not pull him back. Lab only.
- Clips 08:00 (looked at every sheet; 0 script errors in all six captures): katana, plasma sword,
  chainsaw on the open street (`--arena=city --rigs --sig-lab --sig-gun=<blade>
  --sig-solo=start:-22,0`), 48 px/m real time + 64 px/m 0.4x. Katana: two halves part with a red
  fan; plasma sword: two halves with glowing edges, no red; chainsaw: the grind under a continuous
  spray, then the split. Masters: `clips/city-reel-melee-3-kills-48ppm-it12.mp4` (27 s, labelled,
  first 3 hub frames trimmed per chapter) + three 64 px/m slow city close-ups. frames.json: the
  melee reel and the three close-ups on top (before = the arena solo clips), dropped the three
  solo melee clips and the ray 32 city clip; 15 entries. Sheets in evidence/brutality/*-it12-*.png.
  All eleven kills now play on the city block (8-gun reel it11 + melee reel it12).
- GATES 08:01 (private APPDATA, CONTENDED) on 94ddeae6: lint 13/13 (pre-commit), unit 787/787
  (evidence/brutality/unit-it12.log), scenarios 35/35 (evidence/brutality/scenarios-it12.log).
- Registry rules applied: motion-quality-gating (judged on the 48 and 64 frames before publishing;
  rejected the first 3 hub frames of each chapter as a camera break).
- MILESTONE 08:06 (8020d7f4): the blade solo frame holds still. The stage re-centres the city
  focus on Rivet at the end of every tick, so the camera lurched 2 m with the lunge and sat forward
  through the chainsaw's grind (seen on the 08:00 chainsaw sheet: the street jumps at tick 89). The
  lab now pins the focus to the solo framing each tick, like the gun kills already do. Strip of
  frames 50-170 checked: the street stays put through lunge, grind and split.
- Clips re-shot 08:09 on 8020d7f4 (9 captures, 0 script errors each), replacing the 08:00 ones in
  masters under the same names: melee reels at 48 px/m (27 s) and 32 px/m (21 s, game zoom), and
  the three 64 px/m 0.4x close-ups (the chainsaw one now covers the grind AND the split).
  frames.json: 15 entries, the melee reel 48 + 32 and three close-ups right under the 8-gun reel;
  the plasma-hole 64 slow dropped (the plasma 32 city clip stays). Sheets re-cut in evidence/brutality.
- GATES 08:10 on 8020d7f4 (private APPDATA, CONTENDED): lint 13/13 (pre-commit), unit 787/787
  (unit-it12b.log), scenario brutality 1/1 (scenario-brutality-it12.log); full suite 35/35 on
  94ddeae6 (the later commit is lab-only). Parity and bench not run (no sim change outside the lab).
- FRICTION 08:02 NEXT 4 (cherry-pick gunplay 89c5fac9, stuck shards) aborted: it conflicts in
  test_gun_fx.gd because it carries a gunplay test (weapon-art magazines) that needs earlier gunplay
  commits not on this branch. Restored the five files; tree clean. MERGE NOTE for the Director:
  after n-gunplay and n-brutality both land, a shard-burst kill (style burst) hides the body but
  `FightShardArt.stuck` draws the stuck crystals at the dead fighter's pos for as long as he is in
  `arena.hostiles`, so they may stand in the red mist after the pop. REQUEST 30 -> gunplay: skip
  `stuck` for a fighter whose `alive()` is false and whose body is hidden (or clear `GunFx.stuck[id]`
  on death); brutality's burst draws its own shards flying out (KillBurstFx).
- NOTE 08:03 NEXT 3 (age-96 stall) cannot be measured headless: with no print stage and no
  CityView, `attach_view` gets no actor layer and KillView never exists, so a headless run has no
  view telemetry. Only measurable windowed, so contention cannot be ruled out without the machine
  to myself. Stays a LEAD (one 2-5 ms frame per burn/vaporise kill, well inside 16.6 ms).
- MILESTONE 08:16 the full city reel, clean: `clips/city-reel-all-11-kills-clean-48ppm-it12.mp4`
  (masters, frames.json first entry, before = the it11 8-gun reel, which leaves the list): all
  eleven kills on the open street at start:-22,0 with `--clean` (the arena already had the flag:
  it hides the dev HUD that sat top-left in every earlier city clip), 48 px/m real time, 77 s,
  labelled; 0 script errors in all eleven captures. Looked at the sheet
  (evidence/brutality/city-reel-all-11-clean-it12-sheet.png): every kill lands in a still frame.
  The cops that walk in at the right edge are the live city population.
- Registry rules applied this iteration: motion-quality-gating (every published clip judged on its
  sheet or strip first; rejected the camera lurch on the blade lunge and fixed it, rejected the
  first 3 hub frames per chapter); realtime-combat-semantics (no sim change: both fixes are in the
  dev lab's staging, the 60 Hz kill sim and its RNG stream are untouched, unit/scenarios unchanged).

NEXT (for the report / a later session):
1. REQUEST 30 -> gunplay (stuck shards after a burst kill, see the 08:02 merge note) and REQUEST 29
   (molotov corpse under the patch stars) are open; check both on the merged main.
2. The age-96 stall: measure windowed under bench.lock with the rest of the machine idle; it is not
   measurable headless (no KillView there).
3. Calls for the owner (unchanged from it11): brutality-ray-cap (cap knocked aside vs left on the
   heap, `hat_kick_mps: 0`); clips ray-dissolve-city-64ppm-slow-0.4x-it11 vs
   ray-gun-dissolve-solo-64ppm-slow-0.4x.
4. Use `--clean` for every future capture (it hides the dev HUD).
- 08:18 session closed. Gates of record on 8020d7f4 (private APPDATA, CONTENDED): lint 13/13,
  unit 787/787, scenario brutality 1/1; full suite 35/35 on 94ddeae6 (later changes are lab-only).
  Parity and bench not run (no city-sim change). No Godot process of mine running; scratch cleaned
  (only the capture scripts remain in gtai-n4/scratch/brutality).

## Iteration 13 (08:17-08:30, BUILD)
- MILESTONE 08:23 showcase REQUEST 29 (the electro corpse reads standing after the X-ray): the
  shock body is now wrapped (`KillShockFx.wrap`, root -> `lay` -> body, as KillHoleFx.punch) and
  the drop lays it out like KillHoleFx.Topple: stretched 1.6x along the shot, narrowed 0.85x across,
  slid 0.4 m along it, eased in over DROP_TICKS; the upright turn cut from 0.5 to 0.12 rad. Render
  only (the 60 Hz kill sim, its RNG and the goldens are untouched). Checked in the city at 48 px/m
  (`clips/electro-lie-down-city-48ppm-it13.mp4`, crop sheet `evidence/brutality/electro-lie-down-crop-it13.png`):
  the convulsion and X-ray read as before, the corpse then lies long along the street. It is a
  stretched lie-out, not DeathPose._shock's posed plank (c_plank/c_sprawl channels); taking that
  pose is the better fix once human-reactions' DeathPose is on this branch. 0 script errors.
- GATES 08:22 (private APPDATA, CONTENDED): lint 13/13, unit 787/787 (evidence/brutality/unit-it13.log).

NEXT:
1. Electro corpse: replace the stretch lie-out with human-reactions' DeathPose._shock rig channels
   when that lands on the merged main (showcase REQUEST 29 closed by the stretch for now).
2. REQUEST 30 -> gunplay (stuck shards after a burst) and REQUEST 29 -> gunplay (molotov corpse
   under the patch stars) stay open; check both on the merged main.
3. The age-96 stall: measure windowed under bench.lock; calls for the owner unchanged (brutality-ray-cap).
- GATES 08:22 on 63cc3ce1 (private APPDATA, CONTENDED): scenarios 35/35, 0 script errors
  (evidence/brutality/scenarios-it13.log). Parity and bench not run (render-only change). Session
  closed 08:23; no Godot process of mine running; scratch capture moved to masters.
