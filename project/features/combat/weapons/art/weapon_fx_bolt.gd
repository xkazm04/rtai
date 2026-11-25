class_name WeaponFxBolt
extends RefCounted
## The electro gun's bolt in flight as live current (the halo look of `ElectricArc`, like its chain
## hop): a jagged stroke from the tail to the head and a forked star at the head. Render-only, no
## RNG: kinks hash the bolt's spawn point and the 3-tick jag cell, never its moving position.
## `--electro-cells` (WeaponFxElectro.cells) = the before: the arc/spark cells, drawn by the caller.


## The strokes of a bolt from `tail` to `head` (m); `k` = 1 / screen scale. Empty under `cells`.
static func plan(
	tail: Vector2, head: Vector2, serial: int, tick: int, k: float = 1.0
) -> Array[WeaponFxElectro.Line]:
	var out: Array[WeaponFxElectro.Line] = []
	if WeaponFxElectro.cells:
		return out
	var path: PackedVector2Array = ElectricArc.shape(
		PackedVector2Array([tail, head]), serial, tick, false
	)
	WeaponFxElectro.add_path(out, WeaponFxElectro.to_px(path), k)
	out.append_array(WeaponFxElectro.star_plan(head, ElectricArc.FORK_M, serial, tick, k))
	return out


## A bolt's identity from its spawn point (m, to 0.25 m): fixed for the whole flight.
static func spawn_id(origin: Vector2) -> int:
	var q: Vector2i = Vector2i((origin * 4.0).floor())
	return posmod(q.x * 7 + q.y * 13, 997)


## Draws Rivet's bolt `s` ending at `head` (m) along `dir`; false = `cells` (the old cells draw).
static func draw(ci: CanvasItem, s: Shot, head: Vector2, dir: Vector2, tick: int) -> bool:
	if WeaponFxElectro.cells:
		return false
	var len_m: float = maxf(s.spec.tracer_len_m, WeaponFxArt.ARC_MIN_M)
	var k: float = WeaponFxElectro.screen_k(ci)
	var lines: Array[WeaponFxElectro.Line] = plan(
		head - dir * len_m, head, spawn_id(s.origin), tick, k
	)
	WeaponFxElectro.draw_lines(ci, lines)
	return true
