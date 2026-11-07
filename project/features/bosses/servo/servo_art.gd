class_name ServoArt
extends RefCounted
## d8 bosses: Servo's part art per view row (render only). Parts drawn for an angled view's pitch
## live in art/p<pitch>/ (p55 for `tilt`, from servo_55.png: ochre enamel, tan steel, copper
## hoses; tools/art/servo_parts_pitch.py cuts them to today's part sizes, so ServoRig's scale
## holds). A part with no file for the pitch, and every part straight down (`top`), loads today's.

const DIR: String = "res://features/bosses/servo/art/p%d/%s.png"
const FALLBACK_PITCH: int = 55
## Under a view with lift Servo stands: his upper body (pelvis, wings, torso, head) draws this many
## metres over his feet and the legs and pad arms stretch up to it (they lay flat as a decal
## beside an upright Rivet). 0 = flat under every view.
const STAND_M: float = 1.6
## The stood body's footprint for its cast shadow (m: across the wings, along the facing).
const FOOT_M: Vector2 = Vector2(4.4, 2.4)


## The texture path ServoRig loads for part `n` under the active view: keyed by the row's art
## (ViewMode.art_pitch, so the combined view swaps with its cards, not mid-ease). n8: a row with
## art but no part for its pitch (p70) takes the nearest drawn pitch's (FALLBACK_PITCH) before
## today's: the boss palette at every angled pitch. A lab row without art keeps d8's lookup.
static func path(n: StringName) -> String:
	var vm: ViewMode = ViewMode.shared()
	return path_at(n, vm.art_pitch(), not vm.art.is_empty())


static func path_at(n: StringName, pitch_deg: float, fallback: bool = false) -> String:
	if pitch_deg < 90.0:
		var p: String = DIR % [roundi(pitch_deg), n]
		if ResourceLoader.exists(p):
			return p
		var f: String = DIR % [FALLBACK_PITCH, n]
		if fallback and ResourceLoader.exists(f):
			return f
	return ServoRig.ART % n


## The view's art key ServoRig last loaded under (a change reloads the parts).
static func key() -> String:
	return ViewMode.shared().art


## The textures of parts `names` under the active view (path()).
static func parts(names: Array[StringName]) -> Dictionary[StringName, Texture2D]:
	var out: Dictionary[StringName, Texture2D] = {}
	for n: StringName in names:
		out[n] = load(path(n)) as Texture2D
	return out


## Under a view with lift: draws the stood body's cast shadow (its footprint FOOT_M, across x
## along, swept down-right by its height like the arena props') at the ground point `o_m`, and
## returns the upper body's lift (metres of the rig's canvas at `px` per metre). ZERO and nothing
## drawn straight down (`top` draws today's rig).
static func stand(ci: CanvasItem, o_m: Vector2, fwd: Vector2, px: float) -> Vector2:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift() or STAND_M <= 0.0:
		return Vector2.ZERO
	var a: Vector2 = fwd.orthogonal() * FOOT_M.x * 0.5 * px
	var b: Vector2 = fwd * FOOT_M.y * 0.5 * px
	var c: Vector2 = o_m * px
	var off: Vector2 = view.cast_dir() * STAND_M * view.cast_k * px
	RigCastShadows.sweep(ci, PackedVector2Array([c - a - b, c + a - b, c + a + b, c - a + b]), off)
	return stand_m(ci, o_m, px)


## The upper body's lift alone (nothing drawn) at the ground point `o_m`: ZERO straight down.
static func stand_m(ci: CanvasItem, o_m: Vector2, px: float) -> Vector2:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift() or STAND_M <= 0.0:
		return Vector2.ZERO
	return view.lift_at(ci.get_global_transform() * (o_m * px), STAND_M) / SimConst.PX_PER_M
