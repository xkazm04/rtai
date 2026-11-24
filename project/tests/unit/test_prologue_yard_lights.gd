extends GutTest


## Record what the yard hands the renderer. Keep the real pool so expiry is tested too.
class Recorder:
	extends LightLayer
	var positions: Array[Vector2] = []
	var ids: Array[StringName] = []

	func add(kind: StringName, pos_px: Vector2, angle: float, tick: int) -> int:
		positions.append(pos_px)
		ids.append(kind)
		return super.add(kind, pos_px, angle, tick)


func test_legacy_dressings_have_no_local_grade_or_lights() -> void:
	for id: String in ["plain", "torn_line"]:
		var look: PrologueYardDressing = PrologueYardDressing.resolve(id)
		assert_null(look.lights, id)
		assert_eq(look.ground_shade, 1.0, id)


func test_ground_shade_modulates_only_the_floor_drawing() -> void:
	var skins: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plain: Dictionary = skins.raw["dressings"]["plain"]
	plain["ground_shade"] = 0.57
	stage.raw["yard"]["dressing"] = "plain"
	var floor_view: PrologueFloor = autofree(PrologueFloor.new())
	floor_view.plan = PrologueYard.from_stage(stage, skins)
	floor_view._ready()
	assert_eq(floor_view.self_modulate, Color(0.57, 0.57, 0.57))
	assert_eq(floor_view.modulate, Color.WHITE, "children keep their own ink")


func test_dusk_registers_the_grade_and_decodes_both_inks_from_the_row() -> void:
	var layer: Recorder = autofree(Recorder.new())
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var row: Dictionary = table.raw["dressings"]["line_fire"]["lights"]
	var lights: PrologueYardLights = PrologueYardDressing.resolve("line_fire", "", table).lights
	lights.install(layer)
	assert_eq(layer.grade, &"dusk")
	assert_eq(layer.grades[layer.grade], table.object(row, "grade"))
	assert_false(LightLayer.is_identity(layer.grades[layer.grade]))
	assert_eq(lights.kinds.size(), 4)
	for source: Dictionary in table.array(row, "kinds"):
		var key: StringName = StringName(table.text(source, "id"))
		var kind: Dictionary = layer.kinds[key]
		var base: Color = kind["color"]
		var alternate: Color = kind["alt_color"]
		assert_eq(base, Color(table.text(source, "color")))
		assert_eq(alternate, Color(table.text(source, "alt_color")))
		for ink: Color in [base, alternate]:
			assert_between(ink.h * 360.0, 30.0, 55.0, String(key))
			if String(key).begins_with("yard_lamp"):
				assert_lt(ink.s, 0.5, "warm pale lamp")
		assert_lte(table.num(kind, "flicker_hz"), 2.5)
		assert_eq(table.integer(kind, "life_ticks"), 0)
	assert_true(table.ok(), str(table.errors()))


func test_pools_land_at_each_fixture_in_world_pixels_and_hold_through_the_fight() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var yard: PrologueYard = PrologueYard.from_stage(stage)
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var dressing_id: String = str(stage.raw["yard"]["dressing"])
	assert_eq(dressing_id, "arched_line", "the shipped default yard")
	var row: Dictionary = table.raw["dressings"][dressing_id]["lights"]
	var layer: Recorder = autofree(Recorder.new())
	yard.dressing.lights.install(layer)
	var ids: Array[String] = []
	for pool: Dictionary in table.array(row, "pools"):
		var at: Vector2 = table.vec(pool, "at")
		var id: String = table.text(pool, "id")
		assert_true(_in_yard_or_front(yard, at), id)
		assert_eq(layer.positions[ids.size()], at * SimConst.PX_PER_M, id)
		assert_eq(layer.ids[ids.size()], StringName(table.text(pool, "kind")), id)
		assert_false(id in ids, id)
		ids.append(id)
	assert_eq(layer.ids.count(&"yard_fire"), 1, "conveyor door")
	assert_eq(layer.ids.count(&"yard_hall_mouth"), 2, "burst door, collapsed wall")
	assert_eq(layer.ids.count(&"yard_fire_mid"), 4, "arm cable, pickup, skip, conveyor tail")
	assert_eq(layer.ids.count(&"yard_lamp"), 3)
	assert_eq(layer.ids.count(&"yard_lamp_gate"), 1)
	layer.step(11701, Vector2.ZERO)
	assert_eq(layer.active, ids.size())
	assert_eq(layer.dropped, 0)


func _in_yard_or_front(yard: PrologueYard, at: Vector2) -> bool:
	if yard.yard.has_point(at):
		return true
	for bay: PrologueYardDressing.Piece in yard.dressing.factory_front:
		if Rect2(bay.at - bay.size_m * 0.5, bay.size_m).has_point(at):
			return true
	return false
