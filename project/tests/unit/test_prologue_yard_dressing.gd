extends GutTest

const ART: String = "res://features/city/art/decals/scorch.png"
const STAMP: Dictionary = {"art": ART, "at": [2, -1], "size_m": [4, 6], "rotation_deg": 90}


func _fixture() -> DataTable:
	var skins: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var rows: Dictionary = skins.object(skins.raw, "dressings")
	rows["factory"] = {
		"cover": {"burnt_van": {"art": ART, "crop": {"origin": [0.1, 0.2], "size": [0.4, 0.5]}}},
		"decals": [],
		"factory_front": [STAMP],
		"outside": [STAMP.merged({"flip": true})]
	}
	return skins


func test_plain_is_the_shipped_default() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	assert_eq(plan.dressing.id, "plain")
	assert_true(plan.dressing.use_stage_decals)
	assert_eq(plan.dressing.ground.size(), 1)
	var layer: PrologueYardDressing.Ground = plan.dressing.ground[0]
	assert_eq(layer.texture, "res://features/city/art/d5/ground/quay_apron.png")
	assert_eq(layer.rect, plan.yard)
	assert_true(layer.tiled)
	assert_eq(layer.tile_size, Vector2(8, 8))
	assert_eq(layer.tint, Color.WHITE)
	assert_eq(layer.wash, Color("37333046"))


func test_override_loads_paint_layers_and_preserves_piece_transforms() -> void:
	var skins: DataTable = _fixture()
	var look: PrologueYardDressing = PrologueYardDressing.resolve("plain", "factory", skins)
	assert_eq(look.id, "factory")
	assert_false(look.use_stage_decals)
	assert_eq(look.ground.size(), 1)
	assert_eq(look.cover["burnt_van"].crop, Rect2(0.1, 0.2, 0.4, 0.5))
	assert_eq(look.cover["burnt_van"].art, ART)
	assert_eq(look.factory_front.size(), 1)
	assert_eq(look.outside.size(), 1)
	var wall: PrologueYardDressing.Piece = look.factory_front[0]
	assert_eq(wall.art, ART)
	assert_eq(wall.at, Vector2(2, -1))
	assert_eq(wall.size_m, Vector2(4, 6))
	assert_almost_eq(wall.rotation, PI / 2.0, 0.00001)
	assert_false(wall.flip)
	assert_eq(wall.tint, Color.WHITE)
	assert_true(look.outside[0].flip)
	assert_true(skins.ok())


func test_unknown_override_logs_and_falls_back_to_plain() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("factory", "missing", _fixture())
	assert_eq(look.id, "plain")
	assert_true(look.use_stage_decals)
	assert_true(Log.recent().has("[ERROR] prologue-yard: unknown dressing 'missing', using plain"))


func test_dressing_cannot_move_a_footprint_or_add_cover() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plain: PrologueYard = PrologueYard.from_stage(stage)
	var skins: DataTable = _fixture()
	var skin: Dictionary = skins.raw["dressings"]["factory"]["cover"]
	var van: Dictionary = skin["burnt_van"]
	van.merge({"at": [99, 99], "size_m": [80, 80]})
	skin["extra"] = {"art": ART}
	stage.raw["yard"]["dressing"] = "factory"
	var dressed: PrologueYard = PrologueYard.from_stage(stage, skins)
	assert_eq(dressed.dressing.id, "factory")
	assert_eq(dressed.wrecks.size(), plain.wrecks.size())
	assert_eq(dressed.fences, plain.fences)
	assert_eq(dressed.gate, plain.gate)
	assert_eq(dressed.rivet_start, plain.rivet_start)
	for i: int in plain.wrecks.size():
		assert_eq(dressed.wrecks[i].footprint, plain.wrecks[i].footprint)
	var props: Array[ArenaStation.Prop] = dressed.stations.stations[0].props
	assert_eq(props.size(), plain.stations.stations[0].props.size())
	for i: int in props.size():
		var original: ArenaStation.Prop = plain.stations.stations[0].props[i]
		assert_eq(props[i].at, original.at)
		assert_eq(props[i].size, original.size)
		assert_eq(props[i].kind, original.kind)


func test_launch_override_wins_over_stage_choice() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	LaunchArgs.parse(["--yard-dressing=factory"])
	var plan: PrologueYard = PrologueYard.from_stage(stage, _fixture())
	LaunchArgs.parse()
	assert_eq(plan.dressing.id, "factory")


func test_art_without_crop_uses_the_whole_image_and_decal_lists_replace_stage_marks() -> void:
	var skins: DataTable = _fixture()
	var row: Dictionary = skins.raw["dressings"]["factory"]
	row["cover"] = {"burnt_van": {"art": ART}}
	row["decals"] = [STAMP]
	row["ground"] = [
		{"texture": ART, "rect_m": {"origin": [-2, 3], "size": [4, 6]}, "tiled": false}
	]
	var look: PrologueYardDressing = PrologueYardDressing.resolve("factory", "", skins)
	assert_eq(look.cover["burnt_van"].crop, Rect2(0, 0, 1, 1))
	assert_eq(look.ground.size(), 1)
	assert_eq(look.ground[0].rect, Rect2(-2, 3, 4, 6))
	assert_false(look.ground[0].tiled)
	assert_eq(look.ground[0].wash, Color("00000000"))
	assert_false(look.use_stage_decals)
	assert_eq(look.decals.size(), 1)
	assert_eq(look.decals[0].art, ART)


func test_invalid_layer_reports_the_table_read_error() -> void:
	var skins: DataTable = _fixture()
	var row: Dictionary = skins.raw["dressings"]["factory"]
	row["ground"] = [{"tiled": false, "rect_m": {"origin": [0, 0], "size": [4, 6]}}]
	var look: PrologueYardDressing = PrologueYardDressing.resolve("factory", "", skins)
	assert_eq(look.id, "factory")
	assert_false(skins.ok())
	var recent: PackedStringArray = Log.recent()
	assert_string_contains(recent[-1], "[ERROR] prologue-yard:")
	assert_string_contains(recent[-1], "texture: not a string")


func test_torn_line_loads_the_actual_art_and_keeps_the_crossing_clear() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("plain", "torn_line")
	var plain: PrologueYardDressing = PrologueYardDressing.resolve("plain")
	var data: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var yard: PrologueYard = PrologueYard.from_stage(data)
	assert_false(look.use_stage_decals)
	assert_eq(look.cover.size(), yard.wrecks.size() - 1)
	assert_false(look.cover.has("broken_impeller"))
	for wreck: PrologueYard.Wreck in yard.wrecks:
		if wreck.id != "broken_impeller":
			assert_true(ResourceLoader.exists(look.cover[wreck.id].art), wreck.id)
	var concrete: PrologueYardDressing.Ground = look.ground[0]
	assert_true(ResourceLoader.exists(concrete.texture))
	assert_false(concrete.tiled)
	assert_true(concrete.rect.encloses(yard.yard.grow_individual(0, 0, 0, -0.01)))
	assert_eq(concrete.rect.end.y, yard.sidewalk.position.y)
	assert_eq(look.factory_front.size(), 2)
	assert_gt(look.outside.size(), plain.outside.size())
	var inherited: int = look.outside.size() - plain.outside.size()
	for i: int in plain.outside.size():
		assert_eq(look.outside[inherited + i].at, plain.outside[i].at)
		assert_eq(look.outside[inherited + i].art, plain.outside[i].art)
	var pieces: Array[PrologueYardDressing.Piece] = look.decals + look.factory_front + look.outside
	for piece: PrologueYardDressing.Piece in pieces:
		assert_true(ResourceLoader.exists(piece.art), piece.art)
		var box: Rect2 = Rect2(-piece.size_m * 0.5, piece.size_m)
		var bounds: Rect2 = Transform2D(piece.rotation, piece.at) * box
		assert_false(bounds.intersects(yard.street), piece.art)
	assert_lt(look.decals[0].tint.a, 1.0)


func test_ochre_plate_tracks_the_floor_scale_and_keeps_the_street_frontage_uncoloured() -> void:
	var host: Node2D = add_child_autofree(Node2D.new())
	host.scale = Vector2.ONE * 2.0
	var plan: PrologueYard = PrologueYard.new()
	plan.dressing = PrologueYardDressing.resolve("plain", "torn_line")
	var paint: PrologueYardPaint = PrologueYardPaint.new()
	paint.attach_ochre(host, plan)
	var layer: CanvasLayer = host.get_child(0) as CanvasLayer
	assert_true(layer.follow_viewport_enabled)
	assert_eq(layer.layer, RenderLayers.canvas(&"actors"))
	var ink: Node2D = layer.get_child(0) as Node2D
	assert_eq(ink.transform, host.global_transform)
	var material: ShaderMaterial = ink.material as ShaderMaterial
	var strength: float = material.get_shader_parameter(&"strength")
	assert_eq(strength, plan.dressing.ochre_strength)
	for piece: PrologueYardDressing.Piece in plan.dressing.outside:
		assert_eq(piece.ochre, piece.at.y < 0.0)
