class_name NearMiss
extends RefCounted
## A round of Rivet's that flies past a human within NEAR_M without hitting it makes that human
## duck (the `cover` family: a half flinch away from the round, the body tucked), once per round
## per human. The fight reads as shot at, not only shot. Judged once the round is past the body
## (a round about to hit never ducks its victim first). Render only: ReactLink calls it each
## frame after the landed hits; it reads the arena's rounds and writes nothing back.
## Lane human-reactions.

const NEAR_M: float = 1.1

var ducks: int = 0
## The humans each live round already ducked: shot -> {fighter id: true}.
var _seen: Dictionary[Shot, Dictionary] = {}


func apply(arena: CombatArena, rigs: CharacterRigs, pipe: DeathPipe) -> void:
	var now: Dictionary[Shot, Dictionary] = {}
	for s: Shot in arena.shots:
		if not s.from_rivet:
			continue
		var done: Dictionary = _seen.get(s, {})
		for h: Fighter in arena.hostiles:
			if h.alive() and not done.has(h.id) and passed(s, h):
				done[h.id] = true
				_duck(rigs.rig_for(h.id), s.vel, pipe)
		now[s] = done
	_seen = now


## True when the round is past the body and its line went by within NEAR_M (but missed it).
static func passed(s: Shot, h: Fighter) -> bool:
	var to: Vector2 = h.pos - s.pos
	if to.dot(s.vel) >= 0.0 or to.length() > NEAR_M * 2.0:
		return false
	var side: float = absf(to.cross(s.vel.normalized()))
	return side > h.radius_m and side <= NEAR_M


func _duck(rig: CutRig, along: Vector2, pipe: DeathPipe) -> void:
	if rig == null:
		return
	var r: HumanReact = HumanReact.on(rig)
	if r.dying or r.active():
		return
	r.carry = 0.0
	@warning_ignore("return_value_discarded")
	pipe.wound(rig, &"light", along, false, true)
	ducks += 1
