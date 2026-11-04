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
- MILESTONE 01:28 f6813fe4/f9eff12b: `scenario_human_react` (every wound family clears within 1
  tick of its table length; knockdown lies 1.57 s flat; stagger + round kill carry along the round
  from 4 sides, min dot 1.0; burn kill chars; two runs same digest). Planted faults all caught:
  inverted direction (dot -1.0), no burn row (char 0.0), signature takes the death.
- FRICTION 01:25: in the live arena the corpses vanished when Rivet turned: CharacterRigs keeps
  full rigs only within 14 m of a focus 7 m ahead of Rivet. Fixed in ArenaRigs (focus = centre of
  the box around Rivet, his aim point and hostiles within 20 m) and ReactLink (a corpse whose rig
  comes back re-plays its death at the last frame, `HumanReact.settle`).
- MILESTONE 01:32 4a2d9e3c: arena station `react_line` (4 never-dying dummies in the hub).
- MILESTONE 01:37 39582854: `--rigs` on the city block (`--arena=city`): ArenaRigs attaches to the
  CityView actor layer (before: no rigs at all there). Clip `city_pit_rigs_32ppm.mp4` = game-city.
- Gates 01:42 on 39582854: lint 13/13, unit 706/706, scenarios 29/29. Parity/replay untouched
  (render-only layer, no sim change).
- Evidence: `gtai-masters/n4/human-reactions/` (frames.json, 7 entries): city block 32 px/m,
  arena pit 32 px/m, reaction board 64 and 32 px/m, three contact sheets.
- Rejected clip: city block at 64 px/m (camera on Rivet, the deaths happen off-frame).

NEXT (iteration 2, in order):
1. Crowd reactions (brief item 4): pedestrians under fire in the city (duck, cover head, flee away
   from the shooter, trip over bodies). The city sim owns ped motion (native); start render-side:
   a `cower` family on CityCharacters' full rigs from the FLEE flag + nearest shot, then ask what
   the sim already exposes (panic state) before touching native.
2. "Shoot each cop type from four directions" in the arena itself: a bot for the `react_line`
   station (or `--start=hub` + a scripted walk around a dummy), clip at 32 + 64 px/m.
3. Riot shield + SWAT in the arena: Fighter has no shield/archetype; the arena pit spawns
   GuardBrain contractors only. Feed EnemyRigFeed looks (riot = look 6) through ArenaRigs when the
   enemy-ai pit is hooked into the arena (enemy-ai NEXT 2), so `shield` plays in the live game.
4. Switch deaths to gunplay's `CombatArena.kill_landed` once it merges (kind shot/blown/burned ->
   death family); hook brutality's SignatureKills through `ReactLink.pipe.add_signature`.
5. Quality: the drawn carry ignores cover (a body can slide onto a crate); board blood drag streak
   is a hard rectangle when `slide_px` is large (clamp it); electro death reads close to the round
   death at 32 px/m (stiffer plank: arms locked to the sides); the robot thug skeleton (item 5).
6. A 64 px/m close-up in the arena/city needs a camera on the victim (`--start` or a dev cam).
- 01:44 board re-rendered with the pool lead clamped to 10 px (`POOL_LEAD_MAX_PX`). FINDING: the
  hard vertical red bars under victims hit from north/south remain, so they are CombatBlood's
  spray along a vertical `dir` (d5-combat blood), not the pool lead. REQUEST 1 -> gunplay (owns the
  CityBlood/CombatBlood fixes tonight): `CombatBlood.kill_human(pos, Vector2.UP/DOWN)` draws a
  rectangular streak; see `gtai-masters/n4/human-reactions/react_families_64ppm_sheet.png` rows
  8-10, columns 3-4.
- 01:46 tried an electro "plank" death (tuck to pull the feet together, squash undone): it read as
  a curled huddle at 64 px/m, worse than the X; reverted. The plank needs the legs straight and
  together, which RigGait's sprawl spread cannot do: a `c_plank` envelope in RigGait._clip_feet
  (feet at (-210, +-60) instead of +-230) is the d5-cast-side change to ask for or make.
- Scratch cleaned (board frames deleted; clips stay in evidence/ and in gtai-masters). Encoder for
  the captioned board clips: `evidence/enc_clip.py <frames dir> <out.mp4> <title>`.
