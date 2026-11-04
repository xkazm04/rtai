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
