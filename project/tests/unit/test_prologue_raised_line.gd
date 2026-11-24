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


func test_raised_line_is_the_shipped_default_and_line_fire_one_flag_away() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	assert_eq(PrologueYard.from_stage(stage).dressing.id, "raised_line")
	LaunchArgs.parse(["--yard-dressing=line_fire"])
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	LaunchArgs.parse()
	assert_eq(plan.dressing.id, "line_fire")


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
	assert_true(arched.erase("ground"))
	assert_true(raised.erase("ground"))
	assert_eq(str(arched), str(raised), "only the ground differs from raised_line")
	var arched_ground: Array = _row("arched_line")["ground"]
	var raised_ground: Array = _row("raised_line")["ground"]
	for i: int in arched_ground.size():
		var a_row: Dictionary = arched_ground[i]
		var r_row: Dictionary = raised_ground[i]
		for key: String in ["rect_m", "texture", "tiled"]:
			assert_eq(str(a_row.get(key)), str(r_row.get(key)), key)
