extends GutTest
## n7-melee: the shipped quest 1 (the windows-slice export) leaves dev/ out, so a dev class named
## anywhere in quest 1's static closure breaks the build: quest1_game.gd fails to compile and the
## game never starts (65dd07e1 did that: MeleeFeel -> ReactLink -> PlasmaScorchView -> ArenaRigs).
## This walks the global class names each script names (comments stripped) from the slice's main
## scene script and fails on any script under res://dev/. Run-time load() by path (quest 1's
## guarded --rigs) is not a static reference and is not walked.

const ROOT: String = "res://boot/quest1_game.gd"


func test_quest_one_never_names_a_dev_class() -> void:
	var classes: Dictionary[String, String] = _classes()
	var bad: Array[String] = _dev_reached(ROOT, classes)
	assert_eq(bad, [] as Array[String], "dev classes on quest 1's path: %s" % [bad])


func test_the_walk_catches_a_planted_dev_class() -> void:
	var classes: Dictionary[String, String] = _classes()
	classes["MeleeFeel"] = "res://dev/arena/arena_rigs.gd"  # as if MeleeFeel lived in dev/
	assert_false(_dev_reached(ROOT, classes).is_empty(), "MeleeFeel is on quest 1's path")


func _classes() -> Dictionary[String, String]:
	var out: Dictionary[String, String] = {}
	for row: Dictionary in ProjectSettings.get_global_class_list():
		out[str(row["class"])] = str(row["path"])
	return out


## The dev scripts reached from `root` (as "Class <- referrer").
func _dev_reached(root: String, classes: Dictionary[String, String]) -> Array[String]:
	var word: RegEx = RegEx.create_from_string("\\b[A-Z][A-Za-z0-9_]+\\b")
	var seen: Dictionary[String, bool] = {root: true}
	var todo: Array[String] = [root]
	var bad: Array[String] = []
	while not todo.is_empty():
		var path: String = todo.pop_back()
		for m: RegExMatch in word.search_all(_code(path)):
			var target: String = classes.get(m.get_string(), "")
			if target == "" or seen.has(target):
				continue
			seen[target] = true
			if target.begins_with("res://dev/"):
				bad.append("%s <- %s" % [m.get_string(), path])
			else:
				todo.append(target)
	return bad


## `path`'s source with comments and string literals blanked (a name in a doc line is no reference).
func _code(path: String) -> String:
	var lines: PackedStringArray = []
	var strip: RegEx = RegEx.create_from_string('"[^"]*"|#.*$')
	for line: String in FileAccess.get_file_as_string(path).split("\n"):
		@warning_ignore("return_value_discarded")
		lines.append(strip.sub(line, "", true))
	return "\n".join(lines)
