extends GutTest
## The owner's note (2026-11-09): "there is collision with player which should not happen". A
## person knocked down in the city (M_DOWN) lies on the ground and looks like a body, and the
## player body must treat them like one: Rivet's path is the path he takes over empty pavement,
## and walking over them does not shove them along the ground.

const SPRINT: Vector2 = Vector2(9.0, 0.0)  # over the 7.5 m/s tackle line
const WALK: Vector2 = Vector2(3.0, 0.0)  # under the tackle line
const LEAD_M: float = 2.0
const SPRINT_TICKS: int = 30
const SETTLE_TICKS: int = 40
const BACK_M: float = 1.5


func _stage() -> BodiesStage:
	var st: BodiesStage = BodiesStage.new()
	assert_eq(st.setup(20.0), "", "the stage has a sidewalk band")
	return st


func _sprint_path(with_person: bool) -> PackedVector2Array:
	var st: BodiesStage = _stage()
	if with_person:
		@warning_ignore("return_value_discarded")
		st.stand(st.band + Vector2(LEAD_M, 0.0))
	var path: PackedVector2Array = PackedVector2Array()
	for _t: int in SPRINT_TICKS:
		st.tick(SPRINT)
		@warning_ignore("return_value_discarded")
		path.append(st.body.pos)
	if with_person:
		assert_eq(st.knocks.size(), 1, "the sprint knocked the person down")
	return path


func test_a_sprint_over_a_downed_person_is_a_sprint_over_nothing() -> void:
	var bare: PackedVector2Array = _sprint_path(false)
	var over: PackedVector2Array = _sprint_path(true)
	var worst: float = 0.0
	for i: int in bare.size():
		worst = maxf(worst, bare[i].distance_to(over[i]))
	assert_lt(worst, 0.001, "the downed person changed Rivet's path by %.3f m" % worst)


func test_walking_over_a_downed_person_does_not_move_them() -> void:
	var st: BodiesStage = _stage()
	var slot: int = st.stand(st.band + Vector2(LEAD_M, 0.0))
	for _t: int in SPRINT_TICKS:
		st.tick(SPRINT)
	for _t: int in SETTLE_TICKS:
		st.tick(Vector2.ZERO)
	var lying: PackedFloat64Array = st.person(slot)
	assert_eq(int(lying[1]), SimConst.M_DOWN, "still on the ground")
	var rest: Vector2 = Vector2(lying[2], lying[3])
	# Rivet goes back to just past them and walks across where they lie
	st.body.pos = rest + Vector2(-BACK_M, 0.0)
	for _t: int in 20:
		st.tick(WALK)
		var p: PackedFloat64Array = st.person(slot)
		if int(p[1]) != SimConst.M_DOWN:
			break
		assert_lt(Vector2(p[2], p[3]).distance_to(rest), 0.001, "Rivet shoved the downed person")
