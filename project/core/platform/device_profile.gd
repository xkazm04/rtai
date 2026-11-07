class_name DeviceProfile
extends RefCounted
## The handheld lane's device profile (data/tables/devices.json, gtai.devices/1;
## docs/handheld/LEDGER.md), picked by `--device=<id>` (a dash reads as an underscore). The
## default `desktop` row applies nothing, so the shipped game is untouched. apply() sets the
## window to the device's panel, the frame cap, the vsync mode and the stretch mode; the views may
## read tier and zoom_k. Render and window only: a profile never writes to the sim.

const TABLE: String = "res://data/tables/devices.json"
const VSYNC: Dictionary[String, DisplayServer.VSyncMode] = {
	"adaptive": DisplayServer.VSYNC_ADAPTIVE,
	"disabled": DisplayServer.VSYNC_DISABLED,
	"enabled": DisplayServer.VSYNC_ENABLED,
	"mailbox": DisplayServer.VSYNC_MAILBOX,
}

static var _shared: DeviceProfile = null

var id: StringName = &"desktop"
var window_size: Vector2i = Vector2i.ZERO
## Engine.max_fps; -1 = not set by the profile (the engine's own, uncapped).
var max_fps: int = -1
var vsync: String = ""
var stretch_mode: String = ""
var zoom_k: float = 1.0
var tier: StringName = &"full"
var ids: Array[String] = []


## The profile this run was launched with (LaunchArgs.select_device sets it from `--device=`);
## the table's default (desktop) until then.
static func shared() -> DeviceProfile:
	if _shared == null:
		_shared = DeviceProfile.of("")
	return _shared


## Picks this run's profile from a `--device=` value (a dash reads as an underscore).
static func select(flag_value: String) -> DeviceProfile:
	_shared = DeviceProfile.of(flag_value.replace("-", "_"))
	return _shared


## The device row `want` from the table ("" = the table's default).
static func of(want: String) -> DeviceProfile:
	var p: DeviceProfile = DeviceProfile.new()
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return p
	var d: Dictionary = parser.data
	var pick: String = want if want != "" else str(d["default"])
	for row: Dictionary in d["devices"]:
		p.ids.append(str(row["id"]))
		if str(row["id"]) == pick:
			p._read(row)
	if want != "" and not p.ids.has(want):
		Log.warn("device", "unknown --device=%s; using %s" % [want, p.id])
	return p


func _read(row: Dictionary) -> void:
	id = StringName(str(row["id"]))
	var w: int = row.get("window_w", 0)
	var h: int = row.get("window_h", 0)
	window_size = Vector2i(w, h)
	var fps: int = row.get("max_fps", -1)
	max_fps = fps
	vsync = str(row.get("vsync", ""))
	stretch_mode = str(row.get("stretch_mode", ""))
	var k: float = row.get("zoom_k", 1.0)
	zoom_k = k
	tier = StringName(str(row.get("tier", "full")))


## True for the shipped desktop game (a row that changes nothing).
func is_desktop() -> bool:
	return window_size == Vector2i.ZERO and max_fps < 0 and vsync == "" and stretch_mode == ""


func is_handheld() -> bool:
	return tier == &"handheld"


## Applies the window, frame cap, vsync and stretch mode to `window` (headless: the cap only).
func apply(window: Window) -> void:
	if max_fps >= 0:
		Engine.max_fps = max_fps
	if window == null or DisplayServer.get_name() == "headless":
		return
	if vsync != "":
		var mode: DisplayServer.VSyncMode = VSYNC.get(vsync, DisplayServer.VSYNC_ENABLED)
		DisplayServer.window_set_vsync_mode(mode)
	if stretch_mode == "viewport":
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	elif stretch_mode == "canvas_items":
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if window_size != Vector2i.ZERO:
		window.mode = Window.MODE_WINDOWED
		window.size = window_size
	Log.info("device", "profile %s: %s" % [id, describe()])


func describe() -> String:
	return (
		"window %dx%d, max_fps %d, vsync %s, stretch %s, zoom_k %.2f, tier %s"
		% [window_size.x, window_size.y, max_fps, vsync, stretch_mode, zoom_k, tier]
	)
