class_name FightCam
extends RefCounted
## Lane gunplay, dev capture only (`--cam=fight` in the arena pit): the camera frames Rivet and
## the hostile he fights, so a 64 px/m kill close-up keeps the victim in frame (the camera on
## Rivet alone cropped the kill at the frame's edge). Reads the fight, never writes it.

## How far a hostile may stand to become the subject (m).
const REACH_M: float = 14.0
## The camera sits this far along Rivet -> subject (0.5 = half way: both in frame).
const LEAN: float = 0.5
## Never further than this off Rivet (m), so he stays in a 64 px/m frame.
const MAX_LEAN_M: float = 4.5
## Per tick, how much of the way to the wanted point the camera moves (no snap on a new subject).
const EASE: float = 0.05
## A dead subject stays framed this long (ticks) so the fall and the spurt are seen; longer held
## the camera dragged Rivet's next fight off the frame (150 ticks, hand cannon pit A/B).
const HOLD_TICKS: int = 60

var at: Vector2 = Vector2.INF
var subject: Fighter = null
var _since: int = 0


func step(arena: CombatArena, tick: int) -> Vector2:
	_pick(arena, tick)
	var me: Vector2 = arena.rivet.pos
	var want: Vector2 = me
	if subject != null:
		want = me + ((subject.pos - me) * LEAN).limit_length(MAX_LEAN_M)
	at = want if at == Vector2.INF else at.lerp(want, EASE)
	return at


func _pick(arena: CombatArena, tick: int) -> void:
	if subject != null:
		if subject.alive():
			_since = tick
			if subject.pos.distance_to(arena.rivet.pos) <= REACH_M:
				return
		elif tick - _since < HOLD_TICKS:
			return
	subject = null
	var best: float = INF
	for h: Fighter in arena.hostiles:
		var to: Vector2 = h.pos - arena.rivet.pos
		if not h.alive() or to.length() > REACH_M:
			continue
		# the foe he faces wins: a guard behind him counts as three times as far
		var score: float = to.length() * (2.0 - arena.rivet.facing.dot(to.normalized()))
		if score < best:
			best = score
			subject = h
	_since = tick
