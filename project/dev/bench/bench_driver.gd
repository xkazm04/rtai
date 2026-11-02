class_name BenchDriver
extends WorldSystem
## Drives the bench on the fixed tick (registered after the city): the drive moves the focus and
## the pursuit target along BenchRoute; the riot circles the target around the riot centre and
## evicts one neighbouring chunk every CHURN_TICKS so chunk swaps keep happening.

const RIOT: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const CHURN_TICKS: int = 180
const RING: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]

const DENSE_RA: float = 45.0
const DENSE_RB: float = 80.0
const DENSE_R_MIN: float = 36.0

var scenario: String = "drive"
var route: BenchRoute = BenchRoute.new()
var _city: CitySystem
var _s: float = 0.0


func _init(city: CitySystem, p_scenario: String) -> void:
	_city = city
	scenario = p_scenario
	_city.steer_by_input = false
	if scenario == "riot":
		_city.spawner.targets = CityTargets.riot(300, 100)
		_city.spawner.riot_c = RIOT
		_city.focus = RIOT
	else:
		_city.spawner.targets = CityTargets.street(300, 90, 10)
		if scenario == "drive_dense":
			# the in-car 48 px/m view is 40 x 25 m: the same 400 actors in a tighter bubble
			# (4x the density), still spawned off screen
			_city.sim.set_radii(DENSE_RA, DENSE_RB, CitySystem.RIOT_R)
			_city.spawner.rb = DENSE_RB
			_city.spawner.r_min = DENSE_R_MIN
		_city.focus = route.at(0.0)[0]
	_city.target = _city.focus


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if scenario == "riot":
		var t: float = tick * SimClock.TICK_DT
		_city.target = RIOT + Vector2(cos(t * 0.3), sin(t * 0.3)) * 6.0
		if tick > 0 and tick % CHURN_TICKS == 0:
			var c0: Vector2i = Vector2i(
				floori(RIOT.x / SimConst.CHUNK_M), floori(RIOT.y / SimConst.CHUNK_M)
			)
			_city.residency.evict(c0 + RING[floori(float(tick) / CHURN_TICKS) % 4])
		return
	_s += route.speed_at(_s) * SimClock.TICK_DT
	var pos: Vector2 = route.at(_s)[0]
	_city.focus = pos
	_city.target = pos
