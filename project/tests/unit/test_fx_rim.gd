extends GutTest
## The FX sheet cell's ink rim (fx.json atlas `rim` -> FxPool custom.w -> fx_ink sheet()): a paper
## cell on a cream body (n-d4's crackle on Rivet) needs an ink edge to read; no rim = unchanged.


func _first_rim(k: Dictionary) -> float:
	return FxPool.custom_of(k, 0, 0.5).a


func _kind() -> Dictionary:
	return {
		"color": Color.WHITE,
		"drag": 0.0,
		"grow": 0.0,
		"life_ticks": 30.0,
		"shape_id": 4.0,
		"size_m": 1.0,
	}


func test_a_rimmed_cell_carries_its_rim_to_the_shader() -> void:
	var k: Dictionary = _kind()
	k["rim"] = 0.04
	assert_almost_eq(_first_rim(k), 0.04, 1e-3)


func test_no_rim_keeps_the_cell_as_drawn() -> void:
	assert_eq(_first_rim(_kind()), 0.0)


func test_the_shipped_crackle_has_a_rim_and_the_shader_reads_it() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FxSystem.TABLE))
	var rim: float = 0.0
	for row: Dictionary in d["kinds"]:
		if row["id"] == "crackle":
			var a: Dictionary = row["atlas"]
			rim = a.get("rim", 0.0)
	assert_gt(rim, 0.0, "the crackle reads on Rivet's cream body")
	var code: String = (load(FxSystem.SHADER) as Shader).code
	assert_string_contains(code, "custom.w")
