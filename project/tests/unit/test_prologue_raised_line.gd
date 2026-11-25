extends GutTest

const ART: String = "res://boot/prologue/art/raised_line/"
const BELT: Dictionary[String, String] = {
	"conveyor_door": "belt_straight_a.png",
	"conveyor_feed": "belt_curve_e.png",
	"conveyor_turn": "belt_straight_b.png",
	"conveyor_return": "belt_curve_w.png",
	"conveyor_bend": "belt_straight_a_m.png",
	"conveyor_tail": "belt_torn.png",
}


func _row(id: String) -> Dictionary:
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	return table.raw["dressings"][id]


func test_raised_line_resolves_with_its_own_ground_and_the_light() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("raised_line")
	assert_eq(look.id, "raised_line")
	assert_eq(look.ground_shade, 0.81)
	assert_not_null(look.lights)
	assert_eq(look.ground.size(), 2)
	assert_eq(look.ground[0].texture, ART + "floor_tile.png")
	assert_true(look.ground[0].tiled)
	assert_eq(look.ground[1].texture, ART + "floor_stains.png")


func test_six_conveyor_rows_wear_the_raised_belt_on_unchanged_boxes() -> void:
	var raised: Dictionary = {}
	for row: Dictionary in _row("raised_line")["layout"]["cover"]:
		raised[row["id"]] = row
	for row: Dictionary in _row("line_fire")["layout"]["cover"]:
		var mine: Dictionary = raised[row["id"]]
		assert_eq(str(mine["at"]), str(row["at"]), str(row["id"]))
		assert_eq(str(mine["size_m"]), str(row["size_m"]), str(row["id"]))
	for id: String in BELT:
		var cover: Dictionary = raised[id]
		var art: String = cover["art"]
		assert_eq(art, ART + BELT[id], id)
		assert_true(ResourceLoader.exists(art), id)


func test_hangers_overhang_without_blocking_and_pads_are_gone() -> void:
	var ids: Array[String] = []
	for piece: Dictionary in _row("raised_line")["layout"]["debris"]:
		var id: String = piece["id"]
		ids.append(id)
		assert_false(id.begins_with("pad_"), id)
	assert_eq(ids.filter(func(i: String) -> bool: return i.begins_with("hang_")).size(), 5)
	var cover_ids: Array[String] = []
	for row: Dictionary in _row("raised_line")["layout"]["cover"]:
		var cover_id: String = row["id"]
		cover_ids.append(cover_id)
	for id: String in ids:
		assert_false(id in cover_ids, id)


func test_arched_line_is_the_shipped_default_and_raised_line_one_flag_away() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	assert_eq(PrologueYard.from_stage(stage).dressing.id, "arched_line")
	LaunchArgs.parse(["--yard-dressing=raised_line"])
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	LaunchArgs.parse()
	assert_eq(plan.dressing.id, "raised_line")


func test_extra_stacks_sit_at_the_west_edge_with_their_own_art() -> void:
	var found: Dictionary[String, String] = {}
	for row: Dictionary in _row("raised_line")["layout"]["cover"]:
		var id: String = row["id"]
		if id.begins_with("stack_"):
			found[id] = row["art"]
	assert_eq(found.size(), 2)
	assert_eq(found["stack_broken_sw"], ART + "pallet_broken.png")
	assert_eq(found["stack_double_west"], ART + "pallet_double.png")


func test_arched_line_is_raised_line_with_a_darker_warmer_floor_only() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("arched_line")
	assert_eq(look.id, "arched_line")
	assert_eq(look.ground_shade, 0.81)
	assert_eq(look.ground.size(), 2)
	assert_eq(look.ground[0].texture, ART + "floor_tile.png")
	assert_eq(look.ground[1].texture, ART + "floor_stains.png")
	assert_eq(look.ground[0].tint, Color("ffe0c8ff"))
	assert_eq(look.ground[1].wash, Color("f6dca880"))
	assert_ne(look.ground[0].tint, PrologueYardDressing.resolve("raised_line").ground[0].tint)
	var arched: Dictionary = _row("arched_line").duplicate(true)
	var raised: Dictionary = _row("raised_line").duplicate(true)
	assert_true(arched.erase("ground_impression"))
	assert_true(arched.erase("roof_glow"), "arched_line alone has the roof glow")
	for key: String in ["ground", "layout", "over_print", "factory_front", "lights"]:
		assert_true(arched.erase(key))
		assert_true(raised.erase(key))
	assert_eq(
		str(arched),
		str(raised),
		"only ground, layout art, over-print, hall front, roof glow and lights differ"
	)
	var arched_ground: Array = _row("arched_line")["ground"]
	var raised_ground: Array = _row("raised_line")["ground"]
	for i: int in arched_ground.size():
		var a_row: Dictionary = arched_ground[i]
		var r_row: Dictionary = raised_ground[i]
		for key: String in ["rect_m", "texture", "tiled"]:
			assert_eq(str(a_row.get(key)), str(r_row.get(key)), key)


func test_arched_line_lays_the_brown_tile_as_a_second_impression_and_raised_line_does_not() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("arched_line")
	assert_not_null(look.impression)
	assert_eq(look.impression.texture, ART.replace("raised_line", "arched_line") + "floor_tile.png")
	assert_true(look.impression.tiled)
	assert_eq(look.impression.tile_size, Vector2(8, 8))
	assert_eq(look.impression.rect.end, look.ground[0].rect.end)
	assert_almost_eq(look.impression.rect.position.y, -1.1, 0.001, "starts at the hall wall base")
	assert_eq(look.impression.tint, Color("ffffff8c"))
	assert_null(PrologueYardDressing.resolve("raised_line").impression)
	assert_false(_row("raised_line").has("ground_impression"))


func test_arched_line_front_burns_at_the_burst_and_collapsed_bays_with_mouth_lights() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("arched_line")
	var arts: Array[String] = []
	for piece: PrologueYardDressing.Piece in look.factory_front:
		arts.append(piece.art.get_file())
	assert_true(arts.has("hall_tall_burst_bay.png") and arts.has("hall_tall_collapsed_bay.png"))
	assert_false(arts.has("burst_bay.png") or arts.has("collapsed_bay.png"))
	var lights: Dictionary = _row("arched_line")["lights"]
	var mouths: Array[String] = []
	for pool: Dictionary in lights["pools"]:
		if pool["kind"] == "yard_hall_mouth":
			mouths.append(str(pool["id"]))
	assert_eq(mouths, ["burst_door", "collapsed_wall"])
	var raised: Array = _row("raised_line")["factory_front"]
	assert_true(
		str(raised).contains("line_fire/burst_bay.png"), "raised_line keeps the shipped front"
	)


func _cover(id: String) -> Dictionary[String, Dictionary]:
	var rows: Dictionary[String, Dictionary] = {}
	for row: Dictionary in _row(id)["layout"]["cover"]:
		rows[str(row["id"])] = row
	return rows


func test_arched_line_keeps_the_six_boxes_and_hangs_its_belt_as_arch_pieces() -> void:
	var arched: Dictionary[String, Dictionary] = _cover("arched_line")
	var raised: Dictionary[String, Dictionary] = _cover("raised_line")
	for id: String in BELT:
		assert_eq(str(arched[id]["at"]), str(raised[id]["at"]), id)
		assert_eq(str(arched[id]["size_m"]), str(raised[id]["size_m"]), id)
	var over: Array = _row("arched_line")["over_print"]
	var arches: int = 0
	for piece: Dictionary in _row("arched_line")["layout"]["debris"]:
		var id: String = piece["id"]
		assert_false(id.begins_with("hang_"), id)
		assert_false(arched.has(id), id + " must not block")
		if id.begins_with("arch_"):
			arches += 1
			assert_true(over.has(id), id + " draws over the print")
			assert_true(ResourceLoader.exists(str(piece["art"])), id)
	assert_eq(arches, 6)
