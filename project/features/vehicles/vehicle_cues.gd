class_name VehicleCues
extends RefCounted
## The service cars' FX and audio cues (fx_triggers.json rows with cue `vehicles`), read off the
## bodies after each step: hp lost this tick = `crash` (at least CRASH_HP) or `hit_metal`, a car
## that turned WRECK = `car_wreck` (the explosion) plus a crash, the driven car starting a slide
## above SCREECH_V = `tyre_screech`, a traffic car it rammed = `horn`. Render only: the sink is
## FxTriggers.fire (the view's), nothing is written back, no RNG; the cue memory is not sim state,
## so replay and parity never see it. Each car has a COOLDOWN between impact cues (a scrape along
## a wall is one crash, not one per tick).

const CRASH_HP: float = 8.0
const SCREECH_V: float = 7.0
const COOLDOWN: int = 12
const HORN_GAP: int = 45

## Callable(id: StringName, pos_px: Vector2, angle: float, tick: int); invalid = count only.
var sink: Callable = Callable()
## Cues fired per id since boot (evidence and tests).
var fired: Dictionary[StringName, int] = {}
var _lost: Dictionary[int, float] = {}
var _state: Dictionary[int, int] = {}
var _slide: Dictionary[int, bool] = {}
var _quiet_until: Dictionary[int, int] = {}
var _horn_until: int = 0


## After a step: compares each car with what it was the tick before.
func observe(cars: Array[VehicleBody], driving: VehicleBody, rammed: int, tick: int) -> void:
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
		if b == driving and b.sliding and not _slide.get(b.id, false) and b.speed() > SCREECH_V:
			_fire(&"tyre_screech", b, tick)
		_lost[b.id] = b.hp_lost
		_state[b.id] = b.state
		_slide[b.id] = b.sliding
	if rammed > 0 and driving != null and tick >= _horn_until:
		_fire(&"horn", driving, tick)
		_horn_until = tick + HORN_GAP


func _fire(id: StringName, b: VehicleBody, tick: int) -> void:
	fired[id] = fired.get(id, 0) + 1
	if sink.is_valid():
		sink.call(id, b.pos * SimConst.PX_PER_M, b.vel.angle(), tick)
