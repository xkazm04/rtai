class_name RivetStrike
extends RefCounted
## n11 (the owner's "melee attack follows always only one direction"): a bare-claw strike plays the
## library's drawn strike grid (`rivet_strike.png`, tools/art/rivet_strike.py: 8 rows in the walk
## grid's facing order, columns wind-up, strike, follow-through), so the arm itself goes where he
## aims in all eight octants. Without the grid (or under --rivet-swipe=off) the old cells stand.

const STRIP: String = "rivet_strike.png"
const COLS: int = 3
const ROWS: int = 8
## The foot line above the cell's bottom (the tool prints it: a claw struck below his feet).
const FOOT_PX: Dictionary[String, float] = {"p70": 26.0, "p55": 14.0}
## A punch clip has no phases of its own: the share of it spent on wind-up, and the strike's end.
const PUNCH_WINDUP: float = 0.25
const PUNCH_CUT: float = 0.6


## The strike grid under `art` while a bare claw strikes, else `path`.
static func path_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not RivetSwipe.enabled or path.is_empty() or weapon != &"" or not _striking(rig):
		return path
	var grid: String = RivetStrips.DIR + art + "/" + STRIP
	return grid if RivetStrips.has_file(grid) else path


static func _striking(rig: CutRig) -> bool:
	if rig.dead or (rig.react != null and rig.react.dying) or rig.clips.rolling():
		return false
	return rig.clips.strike_t >= 0.0 or rig.clips.active() == RigClips.Clip.PUNCH


## True when `card` shows the strike grid.
static func shows(card: Sprite2D) -> bool:
	return card != null and str(card.get_meta(RivetFrames.ON, "")).ends_with("/" + STRIP)


## The grid's column (0 wind-up, 1 strike, 2 follow-through) for the clip's progress.
static func col_of(clips: RigClips) -> int:
	if clips.strike_t >= 0.0:
		var ph: Vector3 = clips.strike_ph
		return 0 if clips.strike_t < ph.x else (1 if clips.strike_t < ph.x + ph.y else 2)
	var k: float = 1.0 - clips.punch_t / maxf(clips.punch_len, 0.001)
	return 0 if k < PUNCH_WINDUP else (1 if k < PUNCH_CUT else 2)


## Poses a drawn whole-figure strip (a knock, a strike); false: the caller poses a facing strip.
static func placed(rig: CutRig, card: Sprite2D, s: float, h_px: float) -> bool:
	if RivetKnock.shows(card):
		RivetKnock.place(rig, card, s, h_px)
		return true
	if not shows(card):
		return false
	card.hframes = COLS
	card.vframes = ROWS
	card.frame = RivetFrames.BASE_OCT[RivetFrames.oct_of(rig)] * COLS + col_of(rig.clips)
	card.flip_h = false
	var cell: Vector2 = card.texture.get_size() / Vector2(COLS, ROWS)
	var foot: float = FOOT_PX.get(ViewMode.shared().art, RivetFrames.PAD_PX)
	card.offset = Vector2(-cell.x * 0.5, foot - cell.y)
	card.global_rotation = 0.0
	card.global_scale = Vector2(s, s)
	card.global_position = rig.global_position
	rig.set_meta(RigCastShadows.CAST_HIP, h_px / RigCastShadows.BODY_IN_HIPS)
	return true
