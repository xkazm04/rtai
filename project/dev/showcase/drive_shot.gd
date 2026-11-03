extends Node
## The 48 px/m car-drive frame (d5-city proof): runs the real city bench drive (World +
## CitySystem + CityView + BenchDriver, Rivet in a car) and saves the screen at a few fixed
## ticks next to the bench JSON (<out>.<tick>.png). Windowed only; one sim tick per frame.
##   godot --rendering-driver d3d12 --fixed-fps 60 --path project res://dev/showcase/drive_shot.tscn
##     -- --scenario=drive --secs=20 --zoom=1.5 --out=<dir>/drive.json

const BENCH: PackedScene = preload("res://dev/bench/city_bench.tscn")
const SHOT_FRAMES: Array[int] = [480, 720, 960]

var _frame: int = 0
var _out: String = "user://drive.json"


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
	add_child(BENCH.instantiate())


func _process(_delta: float) -> void:
	_frame += 1
	if not SHOT_FRAMES.has(_frame):
		return
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = "%s.%d.png" % [_out.get_basename(), _frame]
	var err: Error = img.save_png(path)
	Log.info("drive_shot", "saved %s (%s)" % [path, error_string(err)])
	if _frame == SHOT_FRAMES[-1]:
		get_tree().quit(0)
