class_name CitySimBodyCars
extends RefCounted
## n9: cars against the player body in the reference sim (the twin of body.cpp body_cars(), op
## for op). Every live tier-A car's hull, grown by the body radius: a car at or above BD_CAR_HIT
## m/s knocks the body down along its heading (the first such car this step is reported and
## loses 0.6 of its speed to the blow); a slower car brakes hard (half its speed per tick of
## contact) and shoves the body aside. Either way the body is pushed out of the hull along its
## shallower axis (no drive-through, no lane blocked for good). Plain floats only (doubles).

const CAR_HULL_F: float = 2.3
const CAR_HULL_S: float = 0.95


## Moves body.bx / body.by out of every car and writes the step's hit into `hit` (speed, hx, hy).
static func resolve(
	s: CitySimState, h: CitySimHash, body: CitySimBody, hit: PackedFloat64Array
) -> void:
	var r: float = body.spec[SimConst.BD_R]
	for j: int in h.query(body.bx, body.by, 1):
		var kj: int = s.kind[j]
		if s.alive[j] == 0 or (kj != SimConst.K_CAR and kj != SimConst.K_PCAR) or s.tier[j] != 0:
			continue
		var hhx: float = s.hx[j]
		var hhy: float = s.hy[j]
		var rx: float = body.bx - s.px[j]
		var ry: float = body.by - s.py[j]
		var f: float = rx * hhx + ry * hhy
		var sd: float = -rx * hhy + ry * hhx
		var bk: bool = CitySimCarPush.is_bike(s, j)
		var hf: float = (SimConst.BIKE_HULL_F if bk else CAR_HULL_F) + r
		var hs: float = (SimConst.BIKE_HULL_S if bk else CAR_HULL_S) + r
		if not (absf(f) < hf and absf(sd) < hs):
			continue
		if s.v[j] >= body.spec[SimConst.BD_CAR_HIT]:
			if hit[0] == 0.0:
				hit[0] = s.v[j]
				hit[1] = hhx
				hit[2] = hhy
			s.v[j] *= 0.4
		else:
			s.v[j] *= 0.5
		var pf: float = hf - absf(f)
		var ps: float = hs - absf(sd)
		if ps <= pf:
			var sg: float = 1.0 if sd >= 0.0 else -1.0
			body.bx += -hhy * sg * ps
			body.by += hhx * sg * ps
		else:
			var sg2: float = 1.0 if f >= 0.0 else -1.0
			body.bx += hhx * sg2 * pf
			body.by += hhy * sg2 * pf
