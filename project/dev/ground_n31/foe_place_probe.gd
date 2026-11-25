extends SceneTree
## n31-09 ground: the anchored walk placement alone (StreetCopWalk.Contact, no render). A patrol
## cop (and the gunner) walks two strides per facing; per tick it logs the sim ground point (where
## RigCastShadows / CardContactShadow draw the disc), the placed drawing's sole and torso (anchor
## through the placed transform), the stance origin and the mid-point between the stance's soles.
## Flags: --out=<file.jsonl> [--ppm=32] [--mps=3.2] [--stances=4]
const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--mps", "--stances"]
const PATROL: String = "p70/cop_patrol_planted8_armed_walk.png"
const OCT: Dictionary[String, Vector2] = {
	"S": Vector2.DOWN, "N": Vector2.UP, "W": Vector2.LEFT, "E": Vector2.RIGHT
}

var _log: FileAccess
var _stances: int = 4


func _initialize() -> void:
	var ppm: float = float(_arg("--ppm", "32"))
	var mps: float = float(_arg("--mps", "3.2"))
	_stances = int(_arg("--stances", "4"))
	_log = FileAccess.open(_arg("--out", "user://foe_place.jsonl"), FileAccess.WRITE)
	for dir: String in OCT:
		_walk(StreetWalkerCards.DIR + PATROL, dir, ppm, mps)
	_log.close()
	quit(0)


func _walk(path: String, dir: String, ppm: float, mps: float) -> void:
	var tex: Texture2D = load(path) as Texture2D
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	var cell_y: float = tex.get_height() / float(contact.drawings)
	var s: float = 1.7 * ppm * StreetCopWalk.fill_of(path) * 1.0 / cell_y
	var face: Vector2i = RigHeadCard.frame_of(OCT[dir].angle())
	var texel: Vector2 = Vector2(s, s)
	var at: Vector2 = Vector2(1000, 1000)
	var stance: float = contact.step_m * (contact.drawings >> 1) * ppm
	var ticks: int = ceili(_stances * stance / (mps * ppm * SimClock.TICK_DT)) + 1
	for t: int in ticks:
		var placed: Transform2D = contact.place(at, face, texel, ppm)
		var mark: Vector4 = contact.registered.marks[
			face.x * contact.drawings + contact.cell % contact.drawings
		]
		var off: Vector2 = -Vector2(tex.get_width() / 5.0 * 0.5, cell_y * StreetCopWalk.FOOT_Y)
		var row: Dictionary = {
			"dir": dir,
			"t": t,
			"cell": contact.cell,
			"at": _v(at),
			"origin": _v(contact.origin),
			"sole": _v(placed * Vector2(mark.x, mark.y)),
			"torso": _v(placed * Vector2(mark.z, mark.w)),
			"tex_origin": _v(placed.origin),
			"off_px": _v(off * texel),
			"texel": s,
			"shift": _v(contact.registered.stance_shift),
			"eased": _v(contact.registered.eased_landing),
			"body": _v(contact.registered.previous_body),
		}
		var stored: bool = _log.store_line(JSON.stringify(row))
		assert(stored)
		at += OCT[dir] * mps * ppm * SimClock.TICK_DT


func _arg(flag: String, fallback: String) -> String:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with(flag + "="):
			return a.get_slice("=", 1)
	return fallback


func _v(p: Vector2) -> Array[float]:
	return [snappedf(p.x, 0.1), snappedf(p.y, 0.1)]
