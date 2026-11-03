extends GutTest
## d5-close: every D5 art PNG is AI-assisted, so each one needs a line in the Steam AI-provenance
## log (steam/ai-provenance/2026-11.jsonl, outside res://) before it can ship or be store-marked.

const LOG: String = "steam/ai-provenance/2026-11.jsonl"
const ART_ROOT: String = "res://features"


func _repo_root() -> String:
	return ProjectSettings.globalize_path("res://").path_join("..").simplify_path()


func _logged_files() -> Dictionary[String, bool]:
	var out: Dictionary[String, bool] = {}
	var text: String = FileAccess.get_file_as_string(_repo_root().path_join(LOG))
	assert_ne(text, "", "provenance log readable")
	for line: String in text.split("\n", false):
		var parsed: Variant = JSON.parse_string(line)
		if parsed is Dictionary:
			var row: Dictionary = parsed
			out[str(row.get("file", ""))] = true
	return out


func _d5_pngs(dir: String, out: Array[String]) -> void:
	for sub: String in DirAccess.get_directories_at(dir):
		_d5_pngs(dir.path_join(sub), out)
	if not dir.contains("/art/d5"):
		return
	for file: String in DirAccess.get_files_at(dir):
		if file.get_extension() == "png":
			out.append(dir.path_join(file).replace("res://", "project/"))


func test_every_d5_png_has_a_provenance_line() -> void:
	var pngs: Array[String] = []
	_d5_pngs(ART_ROOT, pngs)
	assert_gt(pngs.size(), 0, "found the D5 art")
	var logged: Dictionary[String, bool] = _logged_files()
	var missing: Array[String] = []
	for png: String in pngs:
		if not logged.has(png):
			missing.append(png)
	assert_eq(missing, [] as Array[String], "D5 PNGs without a provenance line")
