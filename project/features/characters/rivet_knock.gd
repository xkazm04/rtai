class_name RivetKnock
extends RefCounted
## n9 rivet it7 (the owner's "cars knock Rivet down"): while world's car knock is on his rig
## (KNOCK = CityCharacters.KNOCK_META: Vector3(car heading x, y, the hit's sim tick), set while the
## body lies, beside RigFeed.Flag.DOWN), the drawn figure plays the library's knock-down strip
## (`rivet_knock.png`, tools/art/rivet_knock.py: rows toward / away / right / left = the throw in
## screen space, columns impact / tumble / slide / down) instead of the death sprawl. The column
## steps on the time since the hit (the slide decelerates over the 1.2 s down); the lying cells turn
## by the heading's angle off the row's axis (<= 45 deg, the library's rule for the diagonals).
## --rivet-knock=off keeps the death sprawl (the it6 look).
enum Row { TOWARD = 0, AWAY = 1, RIGHT = 2, LEFT = 3 }

const STRIP: String = "rivet_knock.png"
const KNOCK: StringName = &"rivet_knock"
const T0: StringName = &"rivet_knock_t0"
const CELLS: int = 4
## The first tick of each column (impact, tumble, slide, down) since the hit, at 60 Hz.
const FROM_TICK: PackedInt32Array = [0, 6, 24, 54]
## The cast shadow's height while thrown, in standing heights (a lying body casts a low one).
const SHADOW: float = 0.3
const AXIS: PackedFloat32Array = [PI * 0.5, -PI * 0.5, 0.0, PI]
static var enabled: bool = true


## The knock strip under `art` while the knock is on (and `path`, the drawn figure, is), else `path`.
static func path_or(rig: CutRig, art: String, path: String) -> String:
	if not enabled or path.is_empty() or not rig.has_meta(KNOCK):
		return path
	var knock: String = RivetStrips.DIR + art + "/" + STRIP
	return knock if ResourceLoader.exists(knock) else path


## True when `card` shows the knock strip.
static func shows(card: Sprite2D) -> bool:
	return card != null and str(card.get_meta(RivetFrames.ON, "")).ends_with("/" + STRIP)


## The row for car heading `h` (ground, y toward the camera): the dominant screen axis.
static func row_of(h: Vector2) -> int:
	if absf(h.x) >= absf(h.y):
		return Row.RIGHT if h.x >= 0.0 else Row.LEFT
	return Row.TOWARD if h.y > 0.0 else Row.AWAY


## The column `ticks` after the hit.
static func col_of(ticks: int) -> int:
	var col: int = 0
	for i: int in CELLS:
		col = i if ticks >= FROM_TICK[i] else col
	return col


## The lying cells' turn: the heading's angle off its row's axis (0 on the impact cell).
static func turn_of(h: Vector2, col: int) -> float:
	if col == 0 or h == Vector2.ZERO:
		return 0.0
	return wrapf(h.angle() - AXIS[row_of(h)], -PI, PI)


## Poses `card` (scale `s`, the figure's) on the knock strip: the cell centre on his ground point.
static func place(rig: CutRig, card: Sprite2D, s: float, h_px: float) -> void:
	var k: Vector3 = rig.get_meta(KNOCK, Vector3.ZERO)
	var t0: Vector2 = rig.get_meta(T0, Vector2(-1.0, 0.0))
	if t0.x != k.z:  # a new knock: count from this pose step (CutRig.drive runs on the tick)
		t0 = Vector2(k.z, rig.t_alive)
		rig.set_meta(T0, t0)
	var head: Vector2 = Vector2(k.x, k.y)
	var col: int = col_of(roundi((rig.t_alive - t0.y) / SimClock.TICK_DT))
	card.hframes = CELLS
	card.vframes = CELLS
	card.frame = row_of(head) * CELLS + col
	card.flip_h = false
	var w: float = card.texture.get_width() / float(CELLS)
	card.offset = Vector2(-w * 0.5, -w * 0.5)
	card.global_rotation = turn_of(head, col)
	card.global_scale = Vector2(s, s)
	card.global_position = rig.global_position
	rig.set_meta(RigCastShadows.CAST_HIP, h_px * SHADOW / RigCastShadows.BODY_IN_HIPS)
