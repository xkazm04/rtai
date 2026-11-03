extends GutTest
## features/vehicles render cues: a hard hit is one crash (not one per tick of a scrape), a light
## knock is hit_metal, a wreck fires the explosion and a crash, a slide at speed screeches once,
## and the sink gets world px.

var _p: Dictionary[StringName, VehicleProfile]
var _got: Array[StringName] = []


func before_all() -> void:
	_p = VehicleProfile.load_all()


func before_each() -> void:
	_got.clear()


func _cues() -> VehicleCues:
	var c: VehicleCues = VehicleCues.new()
	c.sink = func(id: StringName, _px: Vector2, _a: float, _t: int) -> void: _got.append(id)
	return c


func _n(c: VehicleCues, id: StringName) -> int:
	return c.fired.get(id, 0)


func _car() -> VehicleBody:
	return VehicleBody.new(7, _p[&"sedan"], Vector2(10.0, 4.0), Vector2.RIGHT)


func test_hard_hit_is_one_crash_through_the_cooldown() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	c.observe(cars, b, 0, 0)
	for t: int in range(1, 6):
		b.hp_lost += 9.0
		c.observe(cars, b, 0, t)
	assert_eq(_n(c, &"crash"), 1, "a scrape is one crash")
	b.hp_lost += 2.0
	c.observe(cars, b, 0, 1 + VehicleCues.COOLDOWN)
	assert_eq(_n(c, &"hit_metal"), 1, "a light knock after the cooldown")


func test_wreck_fires_the_explosion_and_a_crash() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	c.observe(cars, b, 0, 0)
	b.hp_lost = 100.0
	b.state = VehicleBody.State.WRECK
	c.observe(cars, b, 0, 1)
	c.observe(cars, b, 0, 2)
	assert_eq(" ".join(PackedStringArray(_got)), "car_wreck crash")


func test_a_wreck_keeps_smoking() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	b.hp_lost = 100.0
	b.state = VehicleBody.State.WRECK
	for t: int in VehicleCues.SMOKE_GAP * 3:
		c.observe(cars, null, 0, t)
	assert_eq(_n(c, &"wreck_smoke"), 3)


func test_slide_at_speed_screeches_once() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	b.vel = Vector2(15.0, 0.0)
	c.observe(cars, b, 0, 0)
	b.sliding = true
	for t: int in range(1, 30):
		c.observe(cars, b, 0, t)
	assert_eq(_n(c, &"tyre_screech"), 1)


func test_a_parked_car_does_not_screech_and_rams_honk_at_most_every_gap() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	for t: int in VehicleCues.HORN_GAP + 1:
		c.observe(cars, b, 1, t)
	assert_eq(_n(c, &"horn"), 2)
	assert_eq(_n(c, &"tyre_screech"), 0)


## One civilian car standing 6 m behind the service car at (10, 4), heading east.
class Queue:
	extends VehicleWorld
	var behind: bool = true

	func cars_near(_at: Vector2, _radius: float) -> PackedFloat64Array:
		if not behind:
			return PackedFloat64Array()
		return PackedFloat64Array([12, 0, 4.0, 4.0, 1.0, 0.0, 0.0, 0])


func test_traffic_queued_behind_honks_after_a_wait_then_repeats() -> void:
	var c: VehicleCues = _cues()
	var b: VehicleBody = _car()
	var cars: Array[VehicleBody] = [b]
	var w: Queue = Queue.new()
	var every: int = VehicleCues.QUEUE_EVERY
	for k: int in VehicleCues.QUEUE_HONK - 1:
		c.observe(cars, null, 0, k * every, w)
	assert_eq(_n(c, &"horn"), 0, "no honk before the wait")
	c.observe(cars, null, 0, (VehicleCues.QUEUE_HONK - 1) * every, w)
	assert_eq(_n(c, &"horn"), 1)
	for k: int in range(VehicleCues.QUEUE_HONK, VehicleCues.QUEUE_HONK + VehicleCues.QUEUE_REPEAT):
		c.observe(cars, null, 0, k * every, w)
	assert_eq(_n(c, &"horn"), 2, "repeats every QUEUE_REPEAT checks")
	w.behind = false
	c.observe(cars, null, 0, 100 * every, w)
	w.behind = true
	c.observe(cars, null, 0, 101 * every, w)
	assert_eq(_n(c, &"horn"), 2, "the wait starts over once the queue clears")


func test_a_car_ahead_or_moving_is_not_queued() -> void:
	var b: VehicleBody = _car()
	var ahead: Queue = Queue.new()
	assert_eq(VehicleCues.queued_behind(b, ahead).size(), 4)
	b.pos = Vector2(-10.0, 4.0)
	assert_true(VehicleCues.queued_behind(b, ahead).is_empty(), "the car is ahead of it")


func test_every_cue_has_a_trigger_row() -> void:
	var t: FxTriggers = FxTriggers.new()
	for id: StringName in [
		&"crash", &"hit_metal", &"car_wreck", &"tyre_screech", &"horn", &"wreck_smoke"
	]:
		assert_true(t.rows.has(id), "fx_triggers row %s" % id)
		var row: Dictionary = t.rows.get(id, {})
		var cue: String = row.get("cue", "")
		assert_eq(cue, "vehicles")
