extends "res://dev/selftest/city_selftest.gd"
## World lock of every print pass (look_d4's tooth, grime and hatch; the item and part tooth and
## dots, all on world_px): the selftest junction settles at 32 / 48 / 64 px/m, the tree pauses
## (the sim and the rigs hold still), and the camera pans by PAN_M (a whole number of screen px at
## every zoom). With world_px fed every frame the picture moves rigidly: frame B equals frame A
## shifted by the pan, so the share of differing pixels in the overlap is ~0. A screen-locked
## print would swim (planted with --plant-unlocked: world_px held at its pre-pan value). Writes
## world-lock.json (gtai.world-lock/1).
##   godot --path project res://dev/selftest/world_lock.tscn -- --out=<dir> [--plant-unlocked]
##   [--world-only]

const PPMS: Array[int] = [32, 48, 64]
const PAN_M: Vector2 = Vector2(1.25, 0.75)
## A pixel differs when its RGB sum moves by more than this (0..765).
const DIFF_GATE: int = 24
const MAX_SHARE: float = 0.005
const STRIDE: int = 2

var _plant: bool = false
## --world-only hides the actors canvas (the world pass alone); by default the whole frame.
var _actors: bool = true


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--plant-unlocked":
			_plant = true
		elif arg == "--world-only":
			_actors = false
		elif arg.begins_with("--out="):
			_out = arg.substr(6)
		else:
			printerr("world_lock: unknown argument %s" % arg)
			get_tree().quit(2)
			return
	_build()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	_view.process_mode = Node.PROCESS_MODE_ALWAYS
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	var rows: Array[Dictionary] = []
	for ppm: int in PPMS:
		rows.append(await _check(ppm))
	_write(rows)


func _check(ppm: int) -> Dictionary:
	get_tree().paused = false
	_view.process_mode = Node.PROCESS_MODE_ALWAYS
	_city.focus = JUNCTION
	_view.zoom = ppm / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	get_tree().paused = true
	_view.actor_layer().visible = _actors
	var a: Image = await _grab()
	var held: Variant = _print_mat().get_shader_parameter(&"world_px")
	_city.focus = JUNCTION + PAN_M
	await get_tree().process_frame
	if _plant:
		_view.process_mode = Node.PROCESS_MODE_DISABLED
		_print_mat().set_shader_parameter(&"world_px", held)
	var b: Image = await _grab()
	_view.actor_layer().visible = true
	@warning_ignore_start("return_value_discarded")
	a.save_png(_out.path_join("lock-%dppm-a.png" % ppm))
	b.save_png(_out.path_join("lock-%dppm-b.png" % ppm))
	@warning_ignore_restore("return_value_discarded")
	var pan: Vector2i = Vector2i((PAN_M * float(ppm)).round())
	var share: float = _diff_share(a, b, pan)
	var ok: bool = share <= MAX_SHARE
	printerr(
		"world_lock: %d px/m pan %s differing %.4f %s" % [ppm, pan, share, "ok" if ok else "SWIMS"]
	)
	return {"ppm": ppm, "pan_px": [pan.x, pan.y], "differing_share": share, "ok": ok}


## The print pass's material: the ColorRect on CityView's `print` canvas layer.
func _print_mat() -> ShaderMaterial:
	for n: Node in _view.get_children():
		var layer: CanvasLayer = n as CanvasLayer
		if layer != null and layer.layer == RenderLayers.canvas(&"print"):
			for c: Node in layer.get_children():
				if c is ColorRect:
					return (c as ColorRect).material as ShaderMaterial
	return null


func _grab() -> Image:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


## Share of overlap pixels where B(x, y) != A(x + pan): the world moved left/up by the pan.
func _diff_share(a: Image, b: Image, pan: Vector2i) -> float:
	var size: Vector2i = a.get_size()
	var n: int = 0
	var bad: int = 0
	for y: int in range(8, size.y - pan.y - 8, STRIDE):
		for x: int in range(8, size.x - pan.x - 8, STRIDE):
			var ca: Color = a.get_pixel(x + pan.x, y + pan.y)
			var cb: Color = b.get_pixel(x, y)
			var d: float = absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			n += 1
			if d * 255.0 > DIFF_GATE:
				bad += 1
	return float(bad) / float(maxi(n, 1))


func _write(rows: Array[Dictionary]) -> void:
	var ok: bool = true
	for r: Dictionary in rows:
		var row_ok: bool = r["ok"]
		ok = ok and row_ok
	var res: Dictionary = {
		"schema": "gtai.world-lock/1",
		"ok": ok,
		"planted_unlocked": _plant,
		"max_share": MAX_SHARE,
		"frames": rows,
	}
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	var f: FileAccess = FileAccess.open(_out.path_join("world-lock.json"), FileAccess.WRITE)
	var written: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	get_tree().quit(0 if ok and written else 1)
