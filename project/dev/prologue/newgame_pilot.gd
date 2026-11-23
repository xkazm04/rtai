extends SceneTree
## Run the actual slice main scene with a driver beside it. The driver loads after the
## autoloads, as in the other SceneTree film entries.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--film-dir", "--result", "--seed"]
const FIXED_FPS: int = 60


func _initialize() -> void:
	var driver: GDScript = load("res://dev/prologue/prologue_menu_film.gd") as GDScript
	var control: Node = driver.new()
	root.add_child(control)
