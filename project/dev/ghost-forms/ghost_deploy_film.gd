extends SceneTree

const KNOWN_FLAGS: PackedStringArray = [
	"--form", "--ppm", "--out", "--stills", "--position", "--real-speed"
]
const RUN_TICKS: int = 1443


func _initialize() -> void:
	_open.call_deferred()


func _open() -> void:
	var take: GDScript = load("res://dev/ghost-forms/ghost_deploy_take.gd")
	var node: Node = take.new()
	root.add_child(node)
