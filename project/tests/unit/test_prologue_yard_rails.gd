extends GutTest
## What blocks looks raised and fills its box; what lies in a gap is thin and walks over.

const RAILS: PackedStringArray = [
	"res://boot/prologue/art/line_fire/torn_end.png",
	"res://boot/prologue/art/line_fire/straight_east.png",
	"res://boot/prologue/art/line_fire/straight_west.png",
	"res://boot/prologue/art/line_fire/bent_rail.png",
]

var plan: PrologueYard


func before_each() -> void:
	plan = PrologueYard.from_stage(DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA))


func _conveyors() -> Array[PrologueYard.Wreck]:
	var rows: Array[PrologueYard.Wreck] = []
	for wreck: PrologueYard.Wreck in plan.wrecks:
		if wreck.id.begins_with("conveyor_"):
			rows.append(wreck)
	return rows


func test_each_blocking_section_is_a_heavy_rail() -> void:
	var rows: Array[PrologueYard.Wreck] = _conveyors()
	assert_eq(rows.size(), 6)
	for wreck: PrologueYard.Wreck in rows:
		assert_true(wreck.art in RAILS, "%s draws %s" % [wreck.id, wreck.art])
	assert_eq(rows[0].art, RAILS[0], "the door end is torn")
	assert_eq(rows[5].art, RAILS[0], "the tail end is torn")


func test_each_section_has_a_footing_pad_exactly_on_its_box() -> void:
	for wreck: PrologueYard.Wreck in _conveyors():
		var pad: PrologueYard.Wreck = null
		for mark: PrologueYard.Wreck in plan.debris:
			if mark.id == "pad_" + wreck.id.trim_prefix("conveyor_"):
				pad = mark
		assert_not_null(pad, wreck.id)
		assert_eq(pad.footprint, wreck.footprint, wreck.id)


func test_loose_belt_lies_only_in_the_gaps() -> void:
	var seen: int = 0
	for mark: PrologueYard.Wreck in plan.debris:
		if not (mark.id.begins_with("belt_") or mark.id.begins_with("roller_")):
			continue
		seen += 1
		for wreck: PrologueYard.Wreck in _conveyors():
			assert_false(
				wreck.footprint.has_point(mark.footprint.get_center()), mark.id + " in " + wreck.id
			)
	assert_gt(seen, 0)
