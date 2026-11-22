extends GutTest

const GOLD: String = "res://tests/golden/prologue/"
const OWNER: String = "C:/Users/kazda/kiro/gtai-n23/prologue/"
## Stable ids in owner order. A copy edit never changes a save, line cue or translation key.
const OWNER_IDS: PackedStringArray = [
	"b1_arrival",
	"b1_l01_warden_three_down",
	"b1_dir_mulroney_radio",
	"b1_l02_rivet_three",
	"b1_l03_cop_gary",
	"b1_dir_power_down",
	"b1_dir_witness",
	"b1_l04_winnick_dale",
	"b1_l05_rivet_plant",
	"b1_l06_ghosts_kill",
	"b1_l07_rivet_shut_up",
	"b1_dir_dale_closer",
	"b1_l08_rivet_shut_up",
	"b1_dir_dale_falls",
	"b2_reinforcements",
	"b2_l01_mulroney_line_up",
	"b2_stage_contact",
	"b2_l02_cop_arrest",
	"b2_l03_rivet_laws",
	"b2_l04_ghosts_kill",
	"b2_l05_mulroney_shoot",
	"b2_stage_combat",
	"b3_exit",
	"b3_l01_rivet_voices",
	"b3_stage_phone_rings",
	"b3_l02_rivet_phone",
	"b3_l03_fax_son",
	"b3_l04_rivet_interrupts",
	"b3_l05_fax_talent",
	"b3_l06_rivet_asks",
	"b3_l07_rivet_quiet",
	"b3_l08_fax_hideout",
	"b3_l09_rivet_alright",
	"b3_l10_fax_channel",
	"b3_stage_communicator",
	"b3_stage_channel_rings",
	"b3_l11_fax_location",
]


func _json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func test_owner_and_drafts_in_direction_order_with_stable_ids() -> void:
	var owner: Array = _json(GOLD + "dialog.owner.json")["rows"]
	var drafts: Dictionary = _json(GOLD + "drafts.json")
	var table: Dictionary = _json(PrologueLines.TABLE)
	var expected: Array[Dictionary] = []
	var beat: float = 0.0
	var draft_rows: Array = drafts["lines"]
	assert_eq(owner.size(), OWNER_IDS.size())
	for i: int in owner.size():
		var row: Dictionary = owner[i]
		beat += 1 if row["k"] == "beat" else 0
		expected.append(row.merged({"id": OWNER_IDS[i], "beat": beat}))
		for draft: Dictionary in draft_rows:
			if draft["for_direction"] == row["t"]:
				assert_eq(str(row["k"]), "dir")
				expected.append(_draft(draft).merged({"k": "line", "beat": beat}))
	var actual: Array = table["rows"]
	assert_eq_deep(actual, expected)
	assert_eq(expected.size(), owner.size() + draft_rows.size())
	var places: Array[Dictionary] = []
	for place: Dictionary in drafts["places"]:
		places.append(_draft(place))
	var actual_places: Array = table["places"]
	assert_eq_deep(actual_places, places)
	var seen: Dictionary[String, bool] = {}
	for row: Dictionary in expected + places:
		assert_false(seen.has(row["id"]), str(row["id"]))
		seen[row["id"]] = true


func _draft(source: Dictionary) -> Dictionary:
	return source.merged({"id": str(source["id"]).replace("-", "_")}, true)


func test_golden_files_are_byte_identical_to_owner_sources() -> void:
	for name_in_dir: String in ["dialog.owner.json", "drafts.json"]:
		if not FileAccess.file_exists(OWNER + name_in_dir):
			pending("Owner source is unavailable at " + OWNER + name_in_dir)
			return
		assert_eq(
			FileAccess.get_file_as_bytes(GOLD + name_in_dir),
			FileAccess.get_file_as_bytes(OWNER + name_in_dir),
			name_in_dir
		)


func test_stage_boundaries_are_first_and_last_spoken_lines() -> void:
	var rows: Array = _json(PrologueLines.TABLE)["rows"]
	var stage: Dictionary = _json("res://data/tables/prologue_stage.json")
	var checkpoints: Array[String] = []
	for beat: Dictionary in stage["beats"]:
		var spoken: Array[String] = []
		for row: Dictionary in rows:
			if row["beat"] == beat["beat"] and row["k"] == "line":
				spoken.append(row["id"])
		assert_eq(str(beat["first_line"]), spoken[0])
		assert_eq(str(beat["last_line"]), spoken[-1])
		assert_false(checkpoints.has(beat["checkpoint"]))
		checkpoints.append(beat["checkpoint"])
	assert_eq(checkpoints.size(), 3)


func test_only_spoken_rows_are_displayed_and_reported() -> void:
	var lines: PrologueLines = PrologueLines.new()
	var id: String = "b1_l01_warden_three_down"
	assert_true(lines.show_line(id))
	assert_eq(lines.subtitle.words, str(_json(GOLD + "dialog.owner.json")["rows"][1]["t"]))
	assert_false(lines.show_line("b2_stage_combat"))
	assert_true(lines.show_line("draft_mulroney_radio"))
	assert_eq(lines.shown, [id, "draft_mulroney_radio"])
	assert_eq(lines.beats, [1])
