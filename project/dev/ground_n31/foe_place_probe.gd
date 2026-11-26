extends SceneTree
## n31-09 ground: the anchored walk placement alone (StreetCopWalk.Contact, no render). A patrol
## cop (and the gunner) walks two strides per facing; per tick it logs the sim ground point (where
## RigCastShadows / CardContactShadow draw the disc), the placed drawing's sole and torso (anchor
## through the placed transform), the stance origin and the mid-point between the stance's soles.
## Flags: --out=<file.jsonl> [--ppm=32] [--mps=3.2] [--stances=4]
## [--strip=<file in p70/>] (n31-10: "head" = the cell's alpha bbox top through the transform)
## n31-13: every facing walks twice, "glide" false (the foot lock) then true (GLIDE_NO_STEP).
## n31-15: [--share=<0..1>] the glide pass runs at that StreetPatrolPose.glide_share (default 1).
const KNOWN_FLAGS: PackedStringArray = [
	"--out", "--ppm", "--mps", "--stances", "--strip", "--share"
]
const PATROL: String = "p70/cop_patrol_planted8_armed_walk.png"
const OCT: Dictionary[String, Vector2] = {
	"S": Vector2.DOWN,
	"N": Vector2.UP,
	"W": Vector2.LEFT,
	"E": Vector2.RIGHT,
	"SE": Vector2(0.7071, 0.7071),
	"NE": Vector2(0.7071, -0.7071),
	"SW": Vector2(-0.7071, 0.7071),
	"NW": Vector2(-0.7071, -0.7071),
}

var _log: FileAccess
var _stances: int = 4


func _initialize() -> void:
	var ppm: float = float(_arg("--ppm", "32"))
	var mps: float = float(_arg("--mps", "3.2"))
	_stances = int(_arg("--stances", "4"))
	_log = FileAccess.open(_arg("--out", "user://foe_place.jsonl"), FileAccess.WRITE)
	var strip: String = StreetWalkerCards.DIR + "p70/" + _arg("--strip", PATROL.get_file())
	for glide: bool in [false, true]:
		for dir: String in OCT:
			_walk(strip, dir, ppm, mps, glide)
	_log.close()
	quit(0)


func _walk(path: String, dir: String, ppm: float, mps: float, glide: bool) -> void:
	var tex: Texture2D = load(path) as Texture2D
	var img: Image = _image(tex)
	var contact: StreetCopWalk.Contact = _contact(path, glide)
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
			"glide": glide,
			"share": contact.registered.glide_share,
			"t": t,
			"cell": contact.cell,
			"at": _v(at),
			"origin": _v(contact.origin),
			"sole": _v(placed * Vector2(mark.x, mark.y)),
			"torso": _v(placed * Vector2(mark.z, mark.w)),
			"foot": _v(placed * Vector2(mark.x, contact.registered.foot_y(mark.y))),
			"tex_origin": _v(placed.origin),
			"off_px": _v(off * texel),
			"texel": s,
			"shift": _v(contact.registered.stance_shift),
			"eased": _v(contact.registered.eased_landing),
			"body": _v(contact.registered.previous_body),
			"head": _v(placed * _head(img, face.x, contact.cell % contact.drawings, cell_y)),
		}
		var stored: bool = _log.store_line(JSON.stringify(row))
		assert(stored)
		at += OCT[dir] * mps * ppm * SimClock.TICK_DT


func _contact(path: String, glide: bool) -> StreetCopWalk.Contact:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	contact.registered.glide_no_step = glide
	contact.registered.glide_share = float(_arg("--share", "1.0"))
	return contact


func _image(tex: Texture2D) -> Image:
	var img: Image = tex.get_image()
	if img.is_compressed():
		var err: Error = img.decompress()
		assert(err == OK)
	return img


## The cell's topmost opaque row (and its bbox centre column), in the anchors' local frame.
func _head(img: Image, col: int, row: int, cell_y: float) -> Vector2:
	var cell_w: int = img.get_width() / 5
	var cell: Rect2i = Rect2i(col * cell_w, roundi(row * cell_y), cell_w, roundi(cell_y))
	var used: Rect2i = img.get_region(cell).get_used_rect()
	var x: float = used.position.x + used.size.x * 0.5 - cell_w * 0.5
	return Vector2(x, used.position.y - cell_y * StreetCopWalk.FOOT_Y)


func _arg(flag: String, fallback: String) -> String:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with(flag + "="):
			return a.get_slice("=", 1)
	return fallback


func _v(p: Vector2) -> Array[float]:
	return [snappedf(p.x, 0.1), snappedf(p.y, 0.1)]
