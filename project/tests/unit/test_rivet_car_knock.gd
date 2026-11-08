extends GutTest
## n9 cars knock Rivet down (bodies.json car_hit): the sim's car hit in body_result() starts the
## knock (a slide along the car's heading, the lying time, the damage in the Event); while he lies
## a second hit is ignored, and the spec carries the table's car-hit speed (off in the ghost tank).

var _got: Array[Vector4] = []


func before_each() -> void:
	_got.clear()


func _on_knocked(heading: Vector2, speed: float, damage: float) -> void:
	_got.append(Vector4(heading.x, heading.y, speed, damage))


func _hit(speed: float, heading: Vector2) -> PackedFloat64Array:
	var r: PackedFloat64Array = SimArrays.f64(SimConst.BR_HEAD)
	r[SimConst.BR_X] = 10.0
	r[SimConst.BR_Y] = 20.0
	r[SimConst.BR_HIT] = speed
	r[SimConst.BR_HHX] = heading.x
	r[SimConst.BR_HHY] = heading.y
	return r


func _body() -> RivetBody:
	var bus: EventBus = EventBus.new()
	autofree(bus)
	assert_eq(bus.rivet_knocked.connect(_on_knocked), OK)
	var b: RivetBody = RivetBody.new(BodyTable.load_default(), Vector2(10.0, 20.0))
	b.bind(bus)
	return b


func test_the_spec_carries_the_car_hit_speed_on_foot_only() -> void:
	var b: RivetBody = _body()
	var t: BodyTable = b.table
	assert_gte(t.car_hit.x, 0.0, "bodies.json car_hit.speed_mps (0 = off)")
	assert_eq(b.spec(Vector2(10.0, 20.0))[SimConst.BD_CAR_HIT], t.car_hit.x)
	t.car_hit.x = 5.0
	assert_eq(b.spec(Vector2(10.0, 20.0))[SimConst.BD_CAR_HIT], 5.0)
	b.body_class = &"rivet_ghost"
	assert_eq(b.spec(Vector2(10.0, 20.0))[SimConst.BD_CAR_HIT], 0.0)


func test_a_hit_knocks_him_along_the_heading_with_damage() -> void:
	var b: RivetBody = _body()
	b.take(_hit(12.0, Vector2(0.0, 1.0)))
	assert_true(b.knocked())
	assert_eq(_got.size(), 1)
	var ch: Vector4 = b.table.car_hit
	assert_almost_eq(_got[0].w, ch.w * (12.0 - ch.x * 0.5), 1e-9)
	var s: PackedFloat64Array = b.spec(Vector2(99.0, 99.0))  # input ignored while knocked
	assert_eq(s[SimConst.BD_X], 10.0)
	assert_gt(s[SimConst.BD_Y], 20.0, "slides along +y, the car's heading")


func test_no_second_hit_while_down_and_he_gets_up() -> void:
	var b: RivetBody = _body()
	b.take(_hit(12.0, Vector2(1.0, 0.0)))
	b.take(_hit(15.0, Vector2(1.0, 0.0)))
	assert_eq(_got.size(), 1)
	var ticks: int = ceili(b.table.car_hit.z / SimClock.TICK_DT) + 1
	for _t: int in ticks:
		@warning_ignore("return_value_discarded")
		b.spec(b.pos)
	assert_false(b.knocked())


func test_no_hit_no_knock() -> void:
	var b: RivetBody = _body()
	b.take(_hit(0.0, Vector2.ZERO))
	assert_false(b.knocked())
	assert_eq(_got.size(), 0)
