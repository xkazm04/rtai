class_name FoeShoveZone
extends RefCounted
## The slab sweeps from the planted tell to full extension. Only its final position
## deals damage. A wall can shorten the lunge anywhere inside this strip.


static func polygon(
	start: Vector2, aim: Vector2, speed_mps: float, reach_m: float
) -> PackedVector2Array:
	var travel: float = speed_mps * SimClock.TICK_DT * FoeShield.LUNGE_TICKS
	var tip: Vector2 = start + aim * (travel + reach_m)
	var side: Vector2 = aim.orthogonal() * FoeShield.SLAB_HALF_M
	return PackedVector2Array([start - side, tip - side, tip + side, start + side])


## The sim expands the sides and tip independently by Rivet's radius (square
## corners). The rear plane tests his centre at the actual end of the lunge.
static func connects(delta: Vector2, aim: Vector2, reach_m: float, rivet_r: float) -> bool:
	var forward: float = delta.dot(aim)
	return (
		forward >= 0.0
		and forward <= reach_m + rivet_r
		and absf(delta.cross(aim)) <= rivet_r + FoeShield.SLAB_HALF_M
	)
