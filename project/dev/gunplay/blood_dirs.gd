extends SceneTree
## Dev check (lane gunplay): CombatBlood.kill_human sprayed along 8 directions on a plain floor,
## stepped 120 ticks, one PNG. Reproduces the vertical blood bar of N/S hits (human-reactions
## REQUEST 1). godot --rendering-driver d3d12 --path project -s res://dev/gunplay/blood_dirs.gd
##   -- --out=<png>

const STEPS: int = 330
## Top row: four blows due south (a claw from the north); bottom row: E, SE, W, N.
const DIRS: Array[Vector2] = [
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2(1, 1),
	Vector2.LEFT,
	Vector2.UP
]

var _blood: Node2D = null  # CombatBlood (loaded late: it needs the LaunchArgs autoload)
var _tick: int = 0
var _out: String = "user://blood_dirs.png"


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
	var floor_rect: ColorRect = ColorRect.new()
	floor_rect.color = Color(0.42, 0.4, 0.38)
	floor_rect.position = Vector2(-700, -400)
	floor_rect.size = Vector2(1400, 800)
	floor_rect.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	root.add_child(floor_rect)
	var cam: Camera2D = Camera2D.new()
	root.add_child(cam)
	var cls: GDScript = load("res://features/fx/combat_blood.gd")
	_blood = cls.new()
	root.add_child(_blood)


func _process(_delta: float) -> bool:
	_tick += 1
	if _tick % 30 == 1 and _tick / 30 < DIRS.size():
		var k: int = _tick / 30
		var at: Vector2 = Vector2(-450 + (k % 4) * 300, -200 + (k / 4) * 300)
		_blood.call(&"kill_human", at, DIRS[k])
	_blood.call(&"step", _tick, Vector2.ZERO)
	if _tick < STEPS:
		return false
	var img: Image = root.get_texture().get_image()
	var err: Error = img.save_png(_out)
	if err != OK:
		push_error("blood_dirs: cannot save %s" % _out)
	return true
