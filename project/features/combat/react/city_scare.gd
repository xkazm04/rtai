class_name CityScare
extends WorldSystem
## The fight's gunfire reaches the city's crowd (--arena=city, quest 1 on the city): every round
## that leaves a muzzle scares the pedestrians round the muzzle, every landing scares them round
## the victim, so the street empties away from the fight (the sim's FLEE, then CrowdReact's cower
## on the rig). A sim write: it runs on the tick, between the stage and the city (ArenaSession adds
## it there), and the scare count goes into the replay hash. Lane human-reactions.

## At most this many bangs a tick reach the sim (a shotgun's pellets are one bang).
const MAX_PER_TICK: int = 4
## Two bangs closer than this in one tick are one (pellets, a burst's rounds), metres.
const MERGE_M: float = 1.5

var scares: int = 0
## Off = the planted fault of scenario_city_scare (the crowd deaf to the fight).
var on: bool = true
var _stage: CollectCallStage
var _city: CitySystem
var _seen: Dictionary[Shot, bool] = {}
var _landed: PackedVector2Array = PackedVector2Array()
var _bound: CombatArena = null


func _init(stage: CollectCallStage, city: CitySystem) -> void:
	_stage = stage
	_city = city


func setup(_ctx: WorldContext) -> void:
	_bind()


func step(_tick: int, _input: TickInput) -> void:
	_bind()
	if not on or _city == null or _city.sim == null or _stage.arena == null:
		return
	var bangs: PackedVector2Array = _landed.duplicate()
	_landed.clear()
	var now: Dictionary[Shot, bool] = {}
	for s: Shot in _stage.arena.shots:
		now[s] = true
		if not _seen.has(s):
			@warning_ignore("return_value_discarded")
			# Quest 1's own rounds carry no origin; one tick out of the muzzle is near enough.
			bangs.push_back(s.origin if s.origin != Vector2.ZERO else s.pos)
	_seen = now
	for at: Vector2 in merged(bangs):
		_city.sim.scare(at.x, at.y)
		scares += 1


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(scares)


## The bangs of one tick, in order, with near repeats folded and at most MAX_PER_TICK kept.
static func merged(bangs: PackedVector2Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for at: Vector2 in bangs:
		if out.size() >= MAX_PER_TICK:
			break
		var near: bool = false
		for o: Vector2 in out:
			near = near or o.distance_squared_to(at) < MERGE_M * MERGE_M
		if not near:
			@warning_ignore("return_value_discarded")
			out.push_back(at)
	return out


func _bind() -> void:
	var a: CombatArena = _stage.arena
	if a == null or a == _bound:
		return
	_bound = a
	_seen.clear()
	@warning_ignore("return_value_discarded")
	a.struck.connect(_on_struck)


func _on_struck(victim: Fighter, _dir: Vector2, _lethal: bool, _weapon: StringName) -> void:
	@warning_ignore("return_value_discarded")
	_landed.push_back(victim.pos)
