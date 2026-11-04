class_name ArenaDodges
extends RefCounted
## Enemy shots Rivet dodged: a hostile shot that came within NEAR_M of him and then went past
## (moving away, still in flight, so it neither struck him nor stopped in cover) counts once.
## Also stops every shot whose next tick would cross a solid arena prop (ArenaWalls), so cover
## works for both sides; call before the arena steps.

const NEAR_M: float = 1.5

var dodges: int = 0
var blocked: int = 0
var _near: Dictionary[Shot, bool] = {}


## Lane gunplay: a table gun's lobbed bottle flies over the props (it lands at its aim point), and
## a table rocket bursts on the prop it hits (FightAreas.land: blast, splash, knockdown) instead
## of vanishing.
func cull(arena: CombatArena, walls: ArenaWalls) -> void:
	for s: Shot in arena.shots.duplicate():
		var kind: int = s.spec.kind if s.spec != null else -1
		if kind == WeaponSpec.Kind.THROWN:
			continue
		if walls.blocks(s.pos, s.pos + s.vel * SimClock.TICK_DT):
			arena.shots.erase(s)
			blocked += 1
			if kind == WeaponSpec.Kind.ROCKET and arena.areas != null:
				arena.areas.land(arena, s, null, s.pos)


## After the arena stepped: near shots marked, the ones now past Rivet counted.
func watch(arena: CombatArena) -> void:
	var at: Vector2 = arena.rivet.pos
	var live: Dictionary[Shot, bool] = {}
	for s: Shot in arena.shots:
		if s.from_rivet:
			continue
		live[s] = true
		var to_shot: Vector2 = s.pos - at
		if to_shot.length() <= NEAR_M and not _near.has(s):
			_near[s] = true
		elif _near.get(s, false) and to_shot.dot(s.vel) > 0.0:
			dodges += 1
			_near[s] = false
	for s: Shot in _near.keys():
		if not live.has(s):
			@warning_ignore("return_value_discarded")
			_near.erase(s)
