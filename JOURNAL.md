# JOURNAL - lane gunplay (night 2026-11-04, branch n-gunplay)

## Iteration 1 (01:05-02:05), BUILD

- 01:05 Read: evening REPORT (largest gap: CombatArena direct hits only), AGENTS, arena README,
  combat_arena.gd, gun_hand.gd, impact.gd, projectile_sim.gd, hit_link.gd. No other night lane has a
  JOURNAL yet (brutality, human-reactions, rivet-arsenal, showcase, weapon-art checked 01:12).
- Registry rules applied (realtime-combat-semantics): one damage chokepoint, the kill payload decided
  before the lethal hit lands, sim state in ticks with no RNG in the area model.

### REQUEST 1 -> brutality, human-reactions: the kill-event payload (proposal, 01:15)
`CombatArena.kill_landed(victim: Fighter, weapon: StringName, dir: Vector2, at: Vector2, kind: StringName)`,
emitted from the one chokepoint `CombatArena.damage()` right after `Events.actor_killed`, for every
lethal hit on a non-Rivet fighter, in the arena, the city block and the quest.
- `weapon`: the weapons.json id (`pistol`, `rocket_launcher`, `plasma_rifle`...) or quest ids
  (`gloria`, `assault-rifle`); `&"burn"` for a damage-over-time or fire-patch kill.
- `dir`: unit vector of the hit (the round's travel, the blast centre -> victim, the chain hop).
- `at`: the hit point in metres (on the round's path; the victim's position for burn).
- `kind`: the events.json death kind: `shot` (bullets, bolts), `blown` (rocket direct + splash),
  `burned` (flame, molotov, burning, fire patches). Non-lethal hits keep `CombatArena.struck`.
Agree by replying in your JOURNAL; I will not change the shape without a line here.
- 01:20 MILESTONE real-fight area model: `FightAreas` + `FighterFx` (features/combat/weapons), wired into
  CombatArena (lazy with the first GunHand shot), `Shot.spec`, rockets/bottles end at the aim point.
  DECISION chain through humans (flag), DECISION burn lethal (dot_s 3.5). Unit 700/700 (5 new in
  test_fight_areas.gd); scenarios 28/28 (`evidence/n1/scenarios-a.log`), lint 13/13.
- FRICTION: python on Windows writes CRLF in text mode; use newline='' (fixed before commit).
- FRICTION: bash heredoc with a long GDScript body failed to parse in the Bash tool; use Write.
