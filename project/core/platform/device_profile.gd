class_name DeviceProfile
extends RefCounted
## The handheld lane's device profile (data/tables/devices.json, gtai.devices/1;
## docs/handheld/LEDGER.md), picked by `--device=<id>` (a dash reads as an underscore). The
## default `desktop` row applies nothing, so the shipped game is untouched. apply() sets the
## window to the device's panel, the frame cap, the vsync mode and the stretch mode; the views may
## read tier and zoom_k. Render and window only: a profile never writes to the sim.

const TABLE: String = "res://data/tables/devices.json"
## The Steam Deck's panel (LCD and OLED alike), what auto_pick() matches.
const DECK_PANEL: Vector2i = Vector2i(1280, 800)
## The longest side of a handheld panel on sale (8.8-inch 2560x1600, LEDGER section 1).
const MAX_PANEL_SIDE: int = 2560
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
## The pad rumble gain (0 = none; HandheldRumble plays the pulses).
var rumble: float = 0.0
## Under viewport stretch, the 2D draw size = the project base x this (1 = the base; E8 study).
var draw_scale: float = 1.0
var tier: StringName = &"full"
## The HUD layout: full (the desktop's) or compact (the handheld card sizes, GhostFormLayout).
var hud: StringName = &"full"
## The drawn prompt glyphs on a non-handheld row: "" (the bracketed text) or kb (the keyboard
## twin, a desktop study row; PadGlyphArt). A handheld row always draws the pad set.
var glyphs: StringName = &""
## The pad aim assist (PadAimAssist: weapons.json `aim_assist` bends the right stick's heading).
var aim_assist: bool = false
## The boss fight's camera frames Rivet and the boss together (BossCam, the clip cam) instead of
## following Rivet: the 7-inch panel at 40 px/m keeps the fight on screen (n9 it6).
var boss_cam: bool = false
## The row fills the screen instead of opening a panel-sized window: set when the device picked
## itself (a real Deck, LaunchArgs); `--device=` on the simulator keeps the window (n9 it10).
var fill_screen: bool = false
var ids: Array[String] = []


## The profile this run was launched with (LaunchArgs.select_device sets it from `--device=`);
## the table's default (desktop) until then.
static func shared() -> DeviceProfile:
	if _shared == null:
		_shared = DeviceProfile.of("")
	return _shared


## This run's camera zoom factor (1 on the desktop): see view_zoom().
static func zoom() -> float:
	return shared().view_zoom()


## Picks this run's profile from a `--device=` value (a dash reads as an underscore).
static func select(flag_value: String) -> DeviceProfile:
	_shared = DeviceProfile.of(flag_value.replace("-", "_"))
	return _shared


## The row a run with no `--device=` picks by itself; "" = the table's default. In order (n10):
## `SteamDeck=0` opts out; Steam's own answer (`hardware`, Platform.hardware()): a Deck is the
## Deck, other Steam hardware (a Machine, a Frame) keeps the desktop; Steam's SteamDeck=1 (n9 it10,
## every game's environment on SteamOS); the firmware model against the rows' `models`. A Deck
## only on the Deck's 1280x800 panel (docked on a TV it keeps the desktop); a Windows handheld
## only up to MAX_PANEL_SIDE (past that it is docked on a large screen).
static func auto_pick(
	steam_deck_env: String,
	screen: Vector2i,
	model: String = "",
	hardware: PlatformBackend.Hardware = PlatformBackend.Hardware.DESKTOP
) -> String:
	var env: String = steam_deck_env.strip_edges()
	if env == "0" or hardware == PlatformBackend.Hardware.STEAM_HARDWARE:
		return ""
	var row: String = "deck" if env == "1" else ""
	if hardware == PlatformBackend.Hardware.STEAM_DECK:
		row = "deck"
	if row == "":
		row = model_row(model)
	if row == "deck":
		var sideways: Vector2i = Vector2i(DECK_PANEL.y, DECK_PANEL.x)
		return row if screen == DECK_PANEL or screen == sideways else ""
	return row if maxi(screen.x, screen.y) <= MAX_PANEL_SIDE else ""


## The row whose `models` names this firmware model (OS.get_model_name: on Windows the SMBIOS
## System Product Name, else the board's); "" when none does. Case-sensitive, as firmware is.
static func model_row(model: String) -> String:
	if model == "":
		return ""
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return ""
	var d: Dictionary = parser.data
	for row: Dictionary in d["devices"]:
		for known: Variant in row.get("models", []):
			if model.contains(str(known)):
				return str(row["id"])
	return ""


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
	var r: float = row.get("rumble", 0.0)
	rumble = r
	var ds: float = row.get("draw_scale", 1.0)
	draw_scale = ds
	tier = StringName(str(row.get("tier", "full")))
	hud = StringName(str(row.get("hud", "full")))
	glyphs = StringName(str(row.get("glyphs", "")))
	aim_assist = row.get("aim_assist", false) == true
	boss_cam = row.get("boss_cam", false) == true


## True for the shipped desktop game (a row that changes nothing).
func is_desktop() -> bool:
	return window_size == Vector2i.ZERO and max_fps < 0 and vsync == "" and stretch_mode == ""


## The camera's px/m factor: zoom_k, times draw_scale when the 2D is drawn smaller and scaled up
## (viewport stretch), so a smaller draw keeps the same framing on the panel (E8).
func view_zoom() -> float:
	if stretch_mode == "viewport" and draw_scale < 1.0:
		return zoom_k * draw_scale
	return zoom_k


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
		if draw_scale < 1.0:
			window.content_scale_size = Vector2i(Vector2(window.content_scale_size) * draw_scale)
	elif stretch_mode == "canvas_items":
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if window_size != Vector2i.ZERO:
		window.mode = window_mode()
		if window.mode == Window.MODE_WINDOWED:
			window.size = window_size
	Log.info("device", "profile %s: %s" % [id, describe()])


## The window mode apply() sets on a row with a panel size: fullscreen on the device itself (a
## Deck in desktop mode would put the taskbar over a 1280x800 window), a window on the simulator.
func window_mode() -> Window.Mode:
	return Window.MODE_FULLSCREEN if fill_screen else Window.MODE_WINDOWED


func describe() -> String:
	return (
		"window %dx%d, max_fps %d, vsync %s, stretch %s, zoom_k %.2f, tier %s, rumble %.2f"
		% [window_size.x, window_size.y, max_fps, vsync, stretch_mode, zoom_k, tier, rumble]
	)
