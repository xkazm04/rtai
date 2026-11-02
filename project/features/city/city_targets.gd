class_name CityTargets
extends RefCounted
## How many of each actor the spawner keeps in the bubble (a scenario or district sets these).

var peds: int = 0
var cars: int = 0
var police_cars: int = 0
var rioters: int = 0
var cops: int = 0


static func street(p_peds: int, p_cars: int, p_police_cars: int) -> CityTargets:
	var t: CityTargets = CityTargets.new()
	t.peds = p_peds
	t.cars = p_cars
	t.police_cars = p_police_cars
	return t


static func riot(p_rioters: int, p_cops: int) -> CityTargets:
	var t: CityTargets = CityTargets.new()
	t.rioters = p_rioters
	t.cops = p_cops
	return t
