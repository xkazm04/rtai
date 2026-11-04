class_name PlayerThrow
extends RefCounted
## rivet-arsenal: the molotov's wind-up on the fixed tick. A held fire with a thrown weapon ready
## (no cooldown, no next bottle being lit) starts a wind-up of the class's windup_ticks
## (rivet_arsenal.json thrown); the bottle leaves on its last tick along the latest aim, so the
## arm is seen drawing back before the release. A tap commits the whole wind-up; a switch or a
## claw hit (not armed) cancels it. Pure sim: StagePilot turns the returned aim into fire_at.

## Wind-ups started (the view starts the throw clip on a change).
var winds: int = 0
## Ticks wound so far; -1 = not winding.
var wound: int = -1
var _aim: Vector2 = Vector2.ZERO


## One tick: the aim the bottle leaves along this tick (ZERO: nothing leaves).
func step(windup_ticks: int, held: bool, armed: bool, ready: bool, aim: Vector2) -> Vector2:
	if not armed:
		wound = -1
		return Vector2.ZERO
	if wound < 0:
		if not (held and ready and aim != Vector2.ZERO):
			return Vector2.ZERO
		wound = 0
		winds += 1
	if aim != Vector2.ZERO:
		_aim = aim
	wound += 1
	if wound < windup_ticks:
		return Vector2.ZERO
	wound = -1
	return _aim


func winding() -> bool:
	return wound >= 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(winds)
	out.put_32(wound)
