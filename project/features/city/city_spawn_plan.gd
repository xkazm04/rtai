class_name CitySpawnPlan
extends RefCounted
## One spawner tick's bookkeeping: what is still missing per category, and whose turn it is
## (categories take turns so no kind starves). Rioters are peds with the RIOTER flag: in a riot
## scenario every ped counts as a rioter.

enum { RIOTERS, COPS, POLICE_CARS, CARS, PEDS }

var made: int = 0
var _want: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0])
var _have: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0])
var _cats: Array[int] = []
var _turn: int = 0


func _init(t: CityTargets, counters: PackedInt32Array) -> void:
	_want = PackedInt32Array([t.rioters, t.cops, t.police_cars, t.cars, t.peds])
	var peds: int = counters[SimConst.CN_PEDS]
	_have = PackedInt32Array(
		[
			peds if t.rioters > 0 else 0,
			counters[SimConst.CN_COPS],
			counters[SimConst.CN_PCARS],
			counters[SimConst.CN_CARS],
			peds,
		]
	)
	for cat: int in [RIOTERS, COPS, POLICE_CARS, CARS]:
		if _want[cat] > 0:
			_cats.append(cat)
	if t.peds > 0 and t.rioters == 0:
		_cats.append(PEDS)


## The next category that still needs actors, taking turns; -1 when all are full.
func next() -> int:
	var n: int = _cats.size()
	for q: int in n:
		var cat: int = _cats[(_turn + q) % n]
		if _have[cat] < _want[cat]:
			_turn += 1
			return cat
	return -1


func add(cat: int) -> void:
	_have[cat] += 1
	made += 1
