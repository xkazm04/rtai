extends GutTest


func _lights(strengths: Dictionary) -> PrologueYardLights:
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var row: Dictionary = table.raw["dressings"]["line_fire"]["lights"]
	for kind: Dictionary in row["kinds"]:
		if strengths.has(kind["id"]):
			kind["floor_glow"]["strength"] = strengths[kind["id"]]
	return PrologueYardLights.new(table, row)


func _yard() -> Rect2:
	return Rect2(0, 0, 60, 32)


func test_one_glow_per_pool_with_strength_and_only_on_the_floor() -> void:
	var lights: PrologueYardLights = _lights({"yard_fire_mid": 0.2, "yard_lamp_gate": 0.2})
	var glow: PrologueFloorGlow = autofree(PrologueFloorGlow.build(lights, _yard()))
	assert_eq(glow.get_child_count(), lights.pools.size())
	for pool: PrologueYardLights.Pool in lights.pools:
		var sprite: Sprite2D = glow.get_node_or_null(PrologueFloorGlow.SPRITE_PREFIX + pool.id)
		assert_not_null(sprite, String(pool.id))
		var box: Rect2 = Rect2(sprite.position, sprite.region_rect.size * sprite.scale)
		assert_true(Rect2(Vector2.ZERO, _yard().size * SimConst.PX_PER_M).grow(0.5).encloses(box))


func test_strength_zero_removes_the_glow_nodes_of_that_kind() -> void:
	var off: PrologueFloorGlow = autofree(PrologueFloorGlow.build(_lights({}), _yard()))
	var all_off: Dictionary = {}
	for id: String in ["yard_fire", "yard_fire_mid", "yard_lamp", "yard_lamp_gate"]:
		all_off[id] = 0.0
	var none: PrologueFloorGlow = autofree(PrologueFloorGlow.build(_lights(all_off), _yard()))
	assert_eq(none.get_child_count(), 0)
	assert_gt(off.get_child_count(), 0)


func test_glow_canvas_is_ahead_of_the_actor_layer() -> void:
	var stage: PrintStage = add_child_autofree(PrintStage.new())
	PrologueFloorGlow.attach(stage, _lights({}), _yard())
	var glow: Node = stage.get_node("FloorGlow")
	assert_eq((glow as CanvasLayer).layer, RenderLayers.canvas(&"actors"))
	assert_lt(glow.get_index(), stage.actor_layer().get_index())
