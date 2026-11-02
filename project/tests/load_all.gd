extends SceneTree
## Loads every .gd/.tscn/.tres under res:// except addons/ (TST-04 import job).
## A script nobody tests still has to compile under warnings-as-errors. Exits 1 on any failure.

const SKIP_DIRS: PackedStringArray = ["res://addons", "res://.godot"]
const EXTENSIONS: PackedStringArray = ["gd", "tscn", "tres"]


func _initialize() -> void:
	var paths: Array[String] = []
	_collect("res://", paths)
	var failed: int = 0
	for path: String in paths:
		if not _loads(path):
			failed += 1
			printerr("load_all: FAILED %s" % path)
	printerr("load_all: %d loaded, %d failed" % [paths.size(), failed])
	quit(1 if failed > 0 else 0)


## load() hands back a script object even when it failed to compile, so check it compiled.
func _loads(path: String) -> bool:
	var res: Resource = load(path)
	if res is Script:
		var script: Script = res as Script
		return script.can_instantiate() or script.is_abstract()
	return res != null


func _collect(dir: String, out: Array[String]) -> void:
	if SKIP_DIRS.has(dir.trim_suffix("/")):
		return
	for file: String in DirAccess.get_files_at(dir):
		if EXTENSIONS.has(file.get_extension()):
			out.append(dir.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir):
		_collect(dir.path_join(sub), out)
