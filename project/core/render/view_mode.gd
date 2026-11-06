class_name ViewMode
extends RefCounted
## The view lab's camera projection (data/tables/view.json, gtai.view/1; docs/view-lab/PLAN.md),
## picked by `--view=<id>`. The default `top` is the shipped 90-degree orthographic view and is
## bit-identical: zoom_of() returns the plain uniform zoom and is_flat() is true. A tilted view
## foreshortens the ground plane by sin(pitch) on screen y through the camera's zoom, so every
## world canvas (floor, actors, FX, lights, markers) and the mouse's ground point go through the
## one canvas transform. lift_px() is how far a height of h metres rises up the screen (the 2.5D
## actors). Render only: a view reads the sim and never writes to it.

const TABLE: String = "res://data/tables/view.json"
const FLAG: String = "--view"
## The sun's ground direction for cast shadows: down-right, as CastShadows offsets the city's.
const CAST_DIR: Vector2 = Vector2(0.70710678, 0.70710678)

static var _shared: ViewMode = null
## The camera's ground point in world px (PrintStage.place sets it each frame; read by lift_at).
static var eye: Vector2 = Vector2.ZERO

var id: StringName = &"top"
var pitch_deg: float = 90.0
var height_k: float = 0.0
## The upright facing cards (RigHeadCard) under a tilt; false = the top-down head art only.
var cards: bool = false
## top_lift: a straight-down PERSPECTIVE camera this many metres above the ground
## (0 = orthographic): a height lifts away from the camera's ground point, so walls and bodies
## lean out from the screen centre.
var eye_h_m: float = 0.0
## Cast shadows by height (RigCastShadows, KingCarStack, the arena props): a shadow's length per
## unit of height, thrown down-right (CAST_DIR, the city's building shadows' direction); 0 = none.
var cast_k: float = 0.0
var ids: Array[String] = []


## The view this run was launched with (`--view=<id>`; an unknown id falls back to the default).
static func shared() -> ViewMode:
	if _shared == null:
		_shared = ViewMode.of(_flag_value(OS.get_cmdline_user_args()))
	return _shared


## The view row `want` from the table ("" = the table's default).
static func of(want: String) -> ViewMode:
	var v: ViewMode = ViewMode.new()
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return v
	var d: Dictionary = parser.data
	var pick: String = want if want != "" else str(d["default"])
	for row: Dictionary in d["views"]:
		v.ids.append(str(row["id"]))
		if str(row["id"]) == pick:
			v.id = StringName(pick)
			v.pitch_deg = row["pitch_deg"]
			v.height_k = row["height_k"]
			v.cards = row.get("cards", false) == true and v.pitch_deg < 90.0
			var eye_h: float = row.get("eye_h_m", 0.0)
			v.eye_h_m = eye_h
			var cast: float = row.get("cast_k", 0.0)
			v.cast_k = cast
	if want != "" and not v.ids.has(want):
		Log.warn("view", "unknown --view=%s; drawing %s" % [want, v.id])
	return v


static func _flag_value(args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with(FLAG + "="):
			return arg.substr(FLAG.length() + 1)
	return ""


## True for a straight-down view (no projection at all: today's game).
func is_flat() -> bool:
	return pitch_deg >= 90.0


## Screen y per ground y (1 straight down).
func ground_k() -> float:
	return 1.0 if is_flat() else sin(deg_to_rad(pitch_deg))


## A screen offset over the ground (e.g. Rivet to the cursor) unprojected onto the ground plane, in
## screen px at the x scale: the tilt squashed its y by ground_k (straight down: unchanged, exact).
func ground_of(screen_d: Vector2) -> Vector2:
	return Vector2(screen_d.x, screen_d.y / ground_k())


## Screen y per metre of height, in world px at 1x zoom (0 straight down).
func lift_k() -> float:
	return 0.0 if is_flat() else cos(deg_to_rad(pitch_deg)) * height_k


## The camera zoom for a uniform zoom `z`: exactly Vector2.ONE * z when flat.
func zoom_of(z: float) -> Vector2:
	if is_flat():
		return Vector2.ONE * z
	return Vector2(z, z * ground_k())


## The sun's ground direction (unit) for the cast shadows.
func cast_dir() -> Vector2:
	return CAST_DIR


## Any height cue at all (a tilt or a perspective eye); false = today's flat draw.
func has_lift() -> bool:
	return not is_flat() or eye_h_m > 0.0


## Screen offset per px of height at the ground point `at` (world px): radial from the eye under a
## perspective top_lift, else straight up the screen (ZERO when flat).
func up_at(at: Vector2) -> Vector2:
	if eye_h_m > 0.0:
		return (at - eye) / (eye_h_m * SimConst.PX_PER_M)
	if is_flat():
		return Vector2.ZERO
	return Vector2(0.0, -lift_k() / ground_k())


## lift_px at a ground point: the same under a tilt, radial under a perspective top_lift.
func lift_at(at: Vector2, h_m: float) -> Vector2:
	return up_at(at) * h_m * SimConst.PX_PER_M if eye_h_m > 0.0 else lift_px(h_m)


## How far up the screen (world px, before the camera's y zoom) a height of `h_m` metres draws.
func lift_px(h_m: float) -> Vector2:
	if is_flat():
		return Vector2.ZERO
	return Vector2(0.0, -h_m * SimConst.PX_PER_M * lift_k() / ground_k())
