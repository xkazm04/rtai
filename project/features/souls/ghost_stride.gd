class_name GhostStride
extends RefCounted
## n11 hero it12: a drawn walk's frame by the ground walked, timed by its measured strides.
## `steps[i]`: the stance foot's drawn travel from frame i to i + 1 (cell px, the profile row).
## Frame i shows from half of step i - 1 before it to half of step i after, so the foot is drawn
## where the ground is; even steps are the even cycle. A frame's share is floored at MIN_SHARE of
## the mean so a near-still pair of frames still shows. No table: the even cycle.

const MIN_SHARE: float = 0.4


## The column at `phase` (0..1 of a cycle).
static func col_of(phase: float, steps: PackedFloat32Array) -> int:
	var n: int = steps.size()
	if n == 0:
		return mini(int(phase * 8.0), 7)
	var dwell: PackedFloat32Array = dwell_of(steps)
	var total: float = 0.0
	for d: float in dwell:
		total += d
	var at: float = fposmod(phase, 1.0) * total
	for i: int in n:
		at -= dwell[i]
		if at < 0.0:
			return i
	return n - 1


## Each frame's share of the cycle: half the step into it plus half the step out of it, floored.
static func dwell_of(steps: PackedFloat32Array) -> PackedFloat32Array:
	var n: int = steps.size()
	var mean: float = 0.0
	for d: float in steps:
		mean += d / n
	var out: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	for i: int in n:
		out[i] = maxf((steps[posmod(i - 1, n)] + steps[i]) * 0.5, mean * MIN_SHARE)
	return out
