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


func test_line_fire_stays_the_shipped_default() -> void:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	assert_eq(PrologueYard.from_stage(stage).dressing.id, "line_fire")
