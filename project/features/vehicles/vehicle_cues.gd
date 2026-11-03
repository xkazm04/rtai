class_name VehicleCues
extends RefCounted
## The service cars' FX and audio cues (fx_triggers.json rows with cue `vehicles`), read off the
## bodies after each step: hp lost this tick = `crash` (at least CRASH_HP) or `hit_metal`, a car
## that turned WRECK = `car_wreck` (the explosion) plus a crash, the driven car starting a slide
## above SCREECH_V = `tyre_screech`, a traffic car it rammed = `horn`. Render only: the sink is
## FxTriggers.fire (the view's), nothing is written back, no RNG; the cue memory is not sim state,
## so replay and parity never see it. Each car has a COOLDOWN between impact cues (a scrape along
## a wall is one crash, not one per tick). A wreck keeps smoking (`wreck_smoke`) until it goes.
## Traffic standing behind any service car honks too (`horn` at the queued car), before it pulls
## out to pass (CitySimCarPass waits 2.5 s).

const CRASH_HP: float = 8.0
const SCREECH_V: float = 7.0
const COOLDOWN: int = 12
const HORN_GAP: int = 45
## A wreck smokes (`wreck_smoke`) every SMOKE_GAP ticks for as long as it stays.
const SMOKE_GAP: int = 75
## The smoke rises from the engine bay, this far ahead of the centre (the wreck art stays readable).
const NOSE_M: float = 1.7
## Queued traffic: checked every QUEUE_EVERY ticks; a service car with a sim car standing behind it
## for QUEUE_HONK checks in a row gets honked at, then every QUEUE_REPEAT checks while it lasts.
const QUEUE_EVERY: int = 15
const QUEUE_HONK: int = 4
const QUEUE_REPEAT: int = 6

## Callable(id: StringName, pos_px: Vector2, angle: float, tick: int); invalid = count only.
var sink: Callable = Callable()
## Cues fired per id since boot (evidence and tests).
var fired: Dictionary[StringName, int] = {}
var _lost: Dictionary[int, float] = {}
var _state: Dictionary[int, int] = {}
var _slide: Dictionary[int, bool] = {}
var _quiet_until: Dictionary[int, int] = {}
var _horn_until: int = 0
var _queued: Dictionary[int, int] = {}


## After a step: compares each car with what it was the tick before; `world` (optional) is read
## for the traffic queued behind the cars.
func observe(
	cars: Array[VehicleBody],
	driving: VehicleBody,
	rammed: int,
	tick: int,
	world: VehicleWorld = null
) -> void:
	for b: VehicleBody in cars:
		var lost: float = b.hp_lost - _lost.get(b.id, b.hp_lost)
		var wrecked: bool = (
			b.state == VehicleBody.State.WRECK
			and _state.get(b.id, b.state) != VehicleBody.State.WRECK
		)
		if wrecked:
			_fire(&"car_wreck", b, tick)
		if lost > 0.0 and (wrecked or tick >= _quiet_until.get(b.id, 0)):
			_fire(&"crash" if lost >= CRASH_HP or wrecked else &"hit_metal", b, tick)
			_quiet_until[b.id] = tick + COOLDOWN
		if b.state == VehicleBody.State.WRECK and not wrecked and (tick + b.id) % SMOKE_GAP == 0:
			_fire(&"wreck_smoke", b, tick, b.head * NOSE_M)
		if b == driving and b.sliding and not _slide.get(b.id, false) and b.speed() > SCREECH_V:
			_fire(&"tyre_screech", b, tick)
		_lost[b.id] = b.hp_lost
		_state[b.id] = b.state
		_slide[b.id] = b.sliding
	if rammed > 0 and driving != null and tick >= _horn_until:
		_fire(&"horn", driving, tick)
		_horn_until = tick + HORN_GAP
	if world != null and tick % QUEUE_EVERY == 0:
		_queue_horns(cars, world, tick)


func _queue_horns(cars: Array[VehicleBody], world: VehicleWorld, tick: int) -> void:
	for b: VehicleBody in cars:
		var rec: PackedFloat64Array = queued_behind(b, world)
		if rec.is_empty():
			@warning_ignore("return_value_discarded")
			_queued.erase(b.id)
			continue
		var n: int = _queued.get(b.id, 0) + 1
		_queued[b.id] = n
		if n >= QUEUE_HONK and (n - QUEUE_HONK) % QUEUE_REPEAT == 0:
			_fire_at(&"horn", Vector2(rec[0], rec[1]), atan2(rec[3], rec[2]), tick)


## A civilian sim car standing 0-13 m behind b in its own path: [x, y, hx, hy], else empty.
static func queued_behind(b: VehicleBody, world: VehicleWorld) -> PackedFloat64Array:
	var recs: PackedFloat64Array = world.cars_near(b.pos, 14.0)
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		if recs[r + 1] > 0.5 or recs[r + 6] > 0.5:
			continue
		var at: Vector2 = Vector2(recs[r + 2], recs[r + 3])
		var head: Vector2 = Vector2(recs[r + 4], recs[r + 5])
		var rel: Vector2 = b.pos - at
		var f: float = rel.dot(head)
		if f > 0.0 and f < 13.0 and absf(rel.cross(head)) < 2.0:
			return PackedFloat64Array([at.x, at.y, head.x, head.y])
	return PackedFloat64Array()


func _fire(id: StringName, b: VehicleBody, tick: int, off: Vector2 = Vector2.ZERO) -> void:
	_fire_at(id, b.pos + off, b.vel.angle(), tick)


func _fire_at(id: StringName, at: Vector2, angle: float, tick: int) -> void:
	fired[id] = fired.get(id, 0) + 1
	if sink.is_valid():
		sink.call(id, at * SimConst.PX_PER_M, angle, tick)
