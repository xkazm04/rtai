extends "res://dev/selftest/city_selftest.gd"
## Golden frames per look profile and zoom (the look half of the `selftest` evidence): the city
## selftest scene (seed 91, the junction riot), run with --fixed-fps 60 so every frame is one sim
## tick, captured for each CASES row, downscaled to GOLDEN_SIZE and diffed against
## tests/golden/look/<look>-<ppm>.png. A frame passes under MAX_MEAN mean abs diff (0..255) and
## MAX_FAR of pixels off by more than FAR. --bless rewrites the goldens. Windowed only. Usage:
##   godot --fixed-fps 60 --path project res://dev/selftest/look_golden.tscn
##     -- --out=<dir> [--bless]

const GOLDEN_DIR: String = "res://tests/golden/look"
const GOLDEN_SIZE: Vector2i = Vector2i(320, 200)
const MAX_MEAN: float = 4.0
const MAX_FAR: float = 0.02
const FAR: float = 48.0 / 255.0
const CASES: Array[Array] = [
	[&"d1", 32],
	[&"d1", 48],
	[&"d4", 32],
	[&"d4", 48],
	[&"d4", 64],
	[&"d5", 48],
	[&"d5", 64],
	[&"auto", 48],
	[&"auto", 56],
	[&"auto", 64],
]

## The cases at any other --site (the block: roofs, cast shadows), saved as <site>-<look>-<ppm>.
const SITE_CASES: Array[Array] = [[&"d4", 32], [&"d4", 48], [&"auto", 64]]

var _bless: bool = false


func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg: String in args:
		if arg == "--bless":
			_bless = true
		elif arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--site="):
			if not set_site(arg.substr(7)):
				return
		else:
			printerr("look_golden: unknown argument %s" % arg)
			get_tree().quit(2)
			return
	_build()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	var rows: Array[Dictionary] = []
	for c: Array in CASES if _site == "junction" else SITE_CASES:
		var look: StringName = c[0]
		var ppm: int = c[1]
		rows.append(await _golden(look, ppm))
	_write(rows)


func _golden(look: StringName, ppm: int) -> Dictionary:
	_view.look_id = look
	_view.zoom = ppm / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	# a look an overlay covers (d5-close's look_d5 present) has its own goldens (-ov)
	var ov: String = "-ov" if LookProfiles.shared().overlay_base(look) != &"" else ""
	var site: String = "" if _site == "junction" else _site + "-"
	var fname: String = "%s%s-%dppm%s.png" % [site, look, ppm, ov]
	@warning_ignore("return_value_discarded")
	img.save_png(_out.path_join("look-" + fname))
	img.resize(GOLDEN_SIZE.x, GOLDEN_SIZE.y, Image.INTERPOLATE_BILINEAR)
	var path: String = ProjectSettings.globalize_path(GOLDEN_DIR.path_join(fname))
	var row: Dictionary = {"look": String(look), "ppm": ppm, "file": "look-" + fname}
	if _bless:
		row["blessed"] = img.save_png(path) == OK
		row["ok"] = row["blessed"]
		return row
	var gold: Image = Image.load_from_file(path) if FileAccess.file_exists(path) else null
	row.merge(GoldenDiff.compare(img, gold, FAR))
	row["ok"] = row["found"] and row["mean"] <= MAX_MEAN and row["far"] <= MAX_FAR
	return row


func _write(rows: Array[Dictionary]) -> void:
	var ok: bool = true
	for r: Dictionary in rows:
		ok = ok and r["ok"]
	var res: Dictionary = {
		"schema": "gtai.look-golden/1",
		"ok": ok,
		"blessed": _bless,
		"max_mean": MAX_MEAN,
		"max_far": MAX_FAR,
		"frames": rows,
		"gpu": RenderingServer.get_video_adapter_name(),
	}
	var f: FileAccess = FileAccess.open(_out.path_join("look-golden-result.json"), FileAccess.WRITE)
	var written: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	if f != null:
		f.close()
	printerr("look_golden: %s" % JSON.stringify(res))
	get_tree().quit(0 if written and ok else 1)
