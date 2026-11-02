extends GutTest
## Every print shader's per-pixel noise (paper tooth, grime, hatch, dot screens, fade dither) is
## locked to the world: a shader that reads FRAGCOORD reads it only as `FRAGCOORD.xy + world_px`
## (the camera's world offset, set every frame), never alone - a screen-locked hash swims when the
## camera pans (dev/selftest/world_lock.gd measures it in frames). Comments are ignored.

const ROOTS: PackedStringArray = ["res://assets/shaders", "res://features"]
const LOCKED: String = "FRAGCOORD.xy + world_px"


func test_fragcoord_is_always_world_locked() -> void:
	var checked: int = 0
	for path: String in _shaders():
		var code: String = _code(FileAccess.get_file_as_string(path))
		var uses: int = code.count("FRAGCOORD")
		if uses == 0:
			continue
		checked += 1
		assert_eq(code.count(LOCKED), uses, "%s: FRAGCOORD without + world_px" % path)
		assert_true(code.contains("uniform vec2 world_px"), "%s: declares world_px" % path)
	assert_gt(checked, 3, "the print shaders were found")


func _shaders() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var todo: PackedStringArray = ROOTS.duplicate()
	while not todo.is_empty():
		var dir: String = todo[todo.size() - 1]
		todo.remove_at(todo.size() - 1)
		for sub: String in DirAccess.get_directories_at(dir):
			@warning_ignore("return_value_discarded")
			todo.append(dir.path_join(sub))
		for f: String in DirAccess.get_files_at(dir):
			if f.ends_with(".gdshader"):
				@warning_ignore("return_value_discarded")
				out.append(dir.path_join(f))
	return out


## The shader text with // line comments removed.
func _code(text: String) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for line: String in text.split("\n"):
		var at: int = line.find("//")
		@warning_ignore("return_value_discarded")
		lines.append(line if at < 0 else line.substr(0, at))
	return "\n".join(lines)
