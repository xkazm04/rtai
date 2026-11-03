class_name NoirCarPass
extends RefCounted
## A scripted car for the noir showcase (lane noir, dev only): it brakes in along a straight line
## and stops with its headlights on the fight. Scripted because the sim's cars do not see the
## scripted fighters (they drove through them); this one stops short of every fighter.
## Metres relative to the fight's origin, on the showcase's live-tick clock; no RNG.

## Where the nose stops and the point it aims at (both relative to the fight's origin).
var stop_nose: Vector2 = Vector2(-8.5, 3.0)
var aim: Vector2 = Vector2(0.0, 1.0)
## How far the nose travels while braking, and over how many live ticks (constant deceleration).
var run_m: float = 18.0
var brake_ticks: int = 96


func heading() -> Vector2:
	return (aim - stop_nose).normalized()


## The nose (x, y metres from the origin) and the heading (z, w) at live tick t (0 = run start).
func at(t: int) -> Vector4:
	var u: float = clampf(float(t) / float(brake_ticks), 0.0, 1.0)
	var left: float = run_m * (1.0 - u) * (1.0 - u)
	var h: Vector2 = heading()
	var nose: Vector2 = stop_nose - h * left
	return Vector4(nose.x, nose.y, h.x, h.y)
