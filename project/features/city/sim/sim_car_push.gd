class_name CitySimCarPush
extends RefCounted
## Car against car in the reference sim (the twin of car_hit.cpp, op for op). d9 the sim bike: a
## K_CAR whose art is SimConst.ART_BIKE has a smaller hull and person footprint, and in a contact
## with a car the lighter bike takes SimConst.BIKE_SHARE of the overlap (vehicle_handling.json
## masses). Car vs car keeps its old numbers, so a city with no bikes steps exactly as before.
## Plain floats only (Vector2 is 32-bit: the parity gate needs the C++ doubles).

const NONE: Array[float] = [0.0, 0.0, 1.0]


static func is_bike(s: CitySimState, j: int) -> bool:
	return s.kind[j] == SimConst.K_CAR and s.variant[j] == SimConst.ART_BIKE


## Car i (a bike when `bike`) overlapping car j at (rx, ry) from it: writes j's position and
## returns [how far i moves back along x, along y, i's speed factor]; NONE when apart.
static func push(s: CitySimState, bike: bool, j: int, rx: float, ry: float) -> PackedFloat64Array:
	var d2: float = rx * rx + ry * ry
	if not bike and not is_bike(s, j):
		if not (d2 < 4.84 and d2 > 1e-9):
			return PackedFloat64Array(NONE)
		var dd: float = sqrt(d2)
		var p: float = (2.2 - dd) * 0.5
		s.px[j] += rx / dd * p
		s.py[j] += ry / dd * p
		return PackedFloat64Array([rx / dd * p, ry / dd * p, 0.9])
	var both: bool = bike and is_bike(s, j)
	var rr: float = SimConst.BIKE_RR2 if both else SimConst.BIKE_RR
	if not (d2 < rr * rr and d2 > 1e-9):
		return PackedFloat64Array(NONE)
	var dd2: float = sqrt(d2)
	var k: float = 0.5 if both else (SimConst.BIKE_SHARE if bike else 1.0 - SimConst.BIKE_SHARE)
	var over: float = rr - dd2
	s.px[j] += rx / dd2 * over * (1.0 - k)
	s.py[j] += ry / dd2 * over * (1.0 - k)
	return PackedFloat64Array([rx / dd2 * over * k, ry / dd2 * over * k, 0.9])


## The person footprint's half width (a car 1.3 m).
static func hit_s(bike: bool) -> float:
	return SimConst.BIKE_HIT_S if bike else 1.3
