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
