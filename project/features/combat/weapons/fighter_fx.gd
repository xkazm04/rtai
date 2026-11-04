class_name FighterFx
extends RefCounted
## One fighter's lasting area effects in the real fight (FightAreas): burning (panic + damage over
## time), the electro stun and a knockdown. Ticks only (SIM-01). Lane gunplay.

var burn_ticks: int = 0
## Fighter hp per second while burning (already in the fight's hp scale).
var burn_dps: float = 0.0
## Who set the fire (the kill credit for a burn death).
var burn_by: int = 0
## The way a burning human runs (away from the fire that caught him).
var flee: Vector2 = Vector2.RIGHT
var stun_ticks: int = 0
var down_ticks: int = 0


## True while this fighter's own brain is off (burning, stunned or down).
func holds() -> bool:
	return burn_ticks > 0 or stun_ticks > 0 or down_ticks > 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(burn_ticks)
	out.put_float(burn_dps)
	out.put_32(stun_ticks)
	out.put_32(down_ticks)
	out.put_float(flee.x)
	out.put_float(flee.y)
