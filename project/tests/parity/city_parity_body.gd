class_name CityParityBody
extends RefCounted
## The player body in the NAT-06 parity run (CityParity): the same spec on both twins each step.


## Adds the step's knockdowns to counts[0] and a car hit on the body to counts[1].
static func count(br: PackedFloat64Array, counts: PackedInt32Array) -> void:
	counts[0] += int(br[SimConst.BR_N])
	counts[1] += 1 if br[SimConst.BR_HIT] > 0.0 else 0


static func set_bodies(a: CitySimBackend, b: CitySimBackend, st: int, riot: Vector2) -> void:
	var s: PackedFloat64Array = body_spec(st, riot)
	@warning_ignore("integer_division")
	if (st / 240) % 3 == 2:
		_in_front_of_car(s, a.snapshot(), st)
	a.set_body(s)
	b.set_body(s.duplicate())


## n9 (cars knock Rivet down): every third leg the body stands 2.5 m ahead of a tier-A car (the
## leg number picks which), inside its grown hull, so the car-hit branch (>= BD_CAR_HIT) and the
## stop-dead branch below it are both stepped by the two twins.
static func _in_front_of_car(s: PackedFloat64Array, snap: PackedFloat64Array, st: int) -> void:
	@warning_ignore("integer_division")
	var want: int = st / 240
	var seen: int = 0
	for o: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[o] >= SimConst.SNAP_PROJ_BASE:
			break
		var k: int = int(snap[o + 1])
		if (k != SimConst.K_CAR and k != SimConst.K_PCAR) or snap[o + 3] != 0.0:
			continue
		seen += 1
		if seen <= want % 7:
			continue
		s[SimConst.BD_X] = snap[o + 4] + snap[o + 6] * 2.5
		s[SimConst.BD_Y] = snap[o + 5] + snap[o + 7] * 2.5
		s[SimConst.BD_VX] = 0.0
		return


## The player body (features/bodies) crossing the riot east-west, 12 m each way: a walk (1.5 m/s,
## shoves) on even legs, a sprint (6 m/s, tackles) on odd legs, with the shipped body table.
static func body_spec(st: int, riot: Vector2) -> PackedFloat64Array:
	@warning_ignore("integer_division")
	var leg: int = st / 240
	var u: float = float(st % 240) / 240.0
	var spd: float = 6.0 if leg % 2 == 1 else 1.5
	var dir: float = 1.0 if (leg % 4) < 2 else -1.0
	var x0: float = riot.x - dir * spd * 2.0
	var vx: float = dir * spd
	var s: PackedFloat64Array = SimArrays.f64(SimConst.BD_LEN)
	s[SimConst.BD_X] = x0 + vx * 4.0 * u
	s[SimConst.BD_Y] = riot.y + 0.5
	s[SimConst.BD_VX] = vx
	s[SimConst.BD_ON] = 1.0
	s[SimConst.BD_R] = 0.42
	s[SimConst.BD_RP] = 0.35
	s[SimConst.BD_SHARE] = 160.0 / 235.0
	s[SimConst.BD_TACKLE] = 3.2
	s[SimConst.BD_KNOCK] = 5.0
	s[SimConst.BD_DOWN] = 1.4
	s[SimConst.BD_FLEE] = 3.0
	s[SimConst.BD_RUN_IN] = 3.2
	s[SimConst.BD_CAR_HIT] = 5.0
	return s
