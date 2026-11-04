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
## The lone-victim capture (`--lone`): the victim stands alone, so the frame leans toward him and
## his kill (or his burning run) sits nearer the middle; Rivet stays in a 48 px/m frame.
const LONE_LEAN: float = 0.65
const LONE_MAX_LEAN_M: float = 6.0
## A lone kill's aftermath stays framed 2.5 s (the next lone guard comes 2.5 s after the kill, so
## the longer hold drags no fight off the frame there).
const LONE_HOLD_TICKS: int = 150
## On the city block the lean rides the CityView's camera offset while the sim focus stays on
## Rivet; the view's actor window grows by that offset (CityView), so no edge actor drops.
const CITY_MAX_LEAN_M: float = 6.0

var lean: float = LEAN
var max_lean_m: float = MAX_LEAN_M
var hold_ticks: int = HOLD_TICKS
var at: Vector2 = Vector2.INF
var subject: Fighter = null
var _since: int = 0


func step(arena: CombatArena, tick: int) -> Vector2:
	_pick(arena, tick)
	var me: Vector2 = arena.rivet.pos
	var want: Vector2 = me
	if subject != null:
		want = me + ((subject.pos - me) * lean).limit_length(max_lean_m)
	at = want if at == Vector2.INF else at.lerp(want, EASE)
	return at


func _pick(arena: CombatArena, tick: int) -> void:
	if subject != null:
		if subject.alive():
			_since = tick
			if subject.pos.distance_to(arena.rivet.pos) <= REACH_M:
				return
		elif tick - _since < hold_ticks:
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
