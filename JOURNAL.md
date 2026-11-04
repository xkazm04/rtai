# JOURNAL: lane human-reactions (branch n-human-reactions), night run 2026-11-04

## Iteration 1 (01:05-02:05), BUILD

Read: brief, enemy-ai REPORT, hit_feel README, RigClips/CutRig/RigPose/RigSprings/RigGait,
ArenaRigs, CombatArena.struck, HitLink. Registry rules applied (realtime-combat-semantics,
motion-quality-gating): every reaction is direction-true (the body moves along the round's
travel, the head snaps with it), a fast attack (0.15 of the family) and a slower ease back, the
families are distinguishable in silhouette at 32 px/m (knockdown and deaths change the outline,
flinch/stagger/stun change the pose), the corpse holds a pose that names its death. Deviation:
no authored key poses or sprite art yet; every family is procedural on the cutout rig.

- MILESTONE 01:17 f1ada818: reaction + death layer (`features/combat/react/`), table
  `human_reactions.json` + schema, CutRig `react` slot, unit test (8 tests), dev board
  `dev/human_react/react_board.gd`. Lint 13/13, unit 703/703 at that commit.
- FRICTION 01:16: first board render showed the feet left behind when a body slid (feet are
  world-planted, only the body node moved). Fixed: travel moves the rig node (`HumanReact.slide`),
  the feet follow. Blood also piled up across segments; the board now starts each segment clean.
- Evidence: `evidence/react_families_32ppm.mp4`, `evidence/react_families_64ppm.mp4` (27 s each,
  real time, 12 captioned segments: patrol, riot, patrol, riot, ped, ped hit from front, behind,
  north, south). Contact sheet checked (`evidence/sheet_check.png`).
- MILESTONE 01:22: ReactLink (CombatArena.struck -> wound family / standard death on the rig via
  DeathPipe), wired into ArenaRigs (`--rigs`), which drops its old HIT clip when the link is on.
  test_react_link 3/3.

### Replies to REQUESTs
- gunplay REQUEST 1 (kill_landed payload): AGREED as proposed. ReactLink listens to `struck`
  (which already carries lethal + weapon + dir) today; when kill_landed lands I switch deaths to it
  and map `kind` (shot/blown/burned) over the weapon's hit class (burned -> death_burn, blown ->
  death_blast). Please keep `dir` = the round's travel (that is what the reaction falls along).
- brutality REQUEST 2: DONE as a hook. `DeathPipe.add_signature(func(rig, hit_class, dir, weapon)
  -> bool)`; return `SignatureKills.consumed.has(rig.actor_id)` (rig.actor_id == Fighter.id) and the
  standard death never starts. ReactLink.pipe is the arena's DeathPipe.
- showcase REQUEST 2: the flinch/stagger toward the hit and deaths by kind are live on the pit
  cops under `--rigs` from this commit (ReactLink in ArenaRigs). Shock from the jab maps to
  stun/death_shock when its weapon row's hit_class is `shock`.
