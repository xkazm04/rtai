class_name KillNewStyles
extends Node2D
## The n16 deaths (lane kills-new: one death per weapon that had none), render only. KillStyles
## hands every row whose style is in STYLES here: the body copy is wrapped in a lay node and laid
## through the row's pose track each frame (KillTrack), and each style's overlay class draws over
## it (KillSnapArt: the pistol's exit mist; KillStitchArt: the machine pistol's spurts). Ages count
## the sim tick, so a replay draws the same frames. No RNG: shapes come from a hash of the serial
## and the tick.

const STYLES: Array[StringName] = [&"snap", &"stitch", &"pin", &"shred", &"cook", &"torch"]
## Body metas set at the cut: the feet (body-local px) and the standing height (px).
const FEET: StringName = &"kill_feet"
const HEIGHT: StringName = &"kill_height"


class Death:
	extends RefCounted
	var serial: int = 0
	var root: Node2D = null
	var lay: Node2D = null
	## The body copy under the lay node, and its drawn fall grid (null: none).
	var body: Node2D = null
	var cells: Sprite2D = null
	var row: SignatureKill = null
	var extra: KillTrackRows.Extra = null
	var born: int = 0
	var dir: Vector2 = Vector2.RIGHT
	var fall: Vector2 = Vector2.RIGHT
	## Body-local px: the feet the figure pivots on, and its standing height.
	var feet: Vector2 = Vector2.ZERO
	var height: float = 0.0
	## This frame's body-local px -> layer px (the placement and the track), for the overlays.
	var xf: Transform2D = Transform2D.IDENTITY
	## Layer px this frame: the head (the track's pose applied), for the overlays.
	var head_px: Vector2 = Vector2.ZERO
	var feet_px: Vector2 = Vector2.ZERO
	## Metres to the wall behind him the pin carries him onto (-1: none; KillPinArt).
	var wall_m: float = -1.0
	## The loose headgear's tumble cells (KillLooseArt; null: none).
	var loose: Texture2D = null


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _deaths: Array[Death] = []
var _shred: KillShredArt = KillShredArt.new()


static func owns(style: StringName) -> bool:
	return STYLES.has(style)


func bind(p_kills: SignatureKills, p_ppm: float, p_reduced_motion: bool) -> void:
	kills = p_kills
	ppm = p_ppm
	reduced_motion = p_reduced_motion


## KillStyles.parts' share: the body copy, with the victim's drawn fall grid where he has one
## (KillFallCells, facing the row's fall), wrapped for the track.
func parts(
	rig: CutRig, serial: int, row: SignatureKill, groups: Array[Node2D], dir: Vector2
) -> void:
	if row.style == &"shred" and not row.whole_body():
		_shred.keep(serial, groups)
	var body: Node2D = groups[SignatureKill.BODY]
	if not row.whole_body() or body == null:
		return
	var d: Vector2 = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	var extra: KillTrackRows.Extra = KillTrackRows.of(row.id)
	var cells: Sprite2D = KillFallCells.attach(
		rig, body, KillTrack.fall_vec(d, extra.fall, _side(serial)), extra
	)
	KillLooseArt.attach(rig, body, extra)
	var hat: Node2D = groups[SignatureKill.HAT]
	if cells != null and hat != null:  # on a card the "cap" copy is the whole drawn figure
		hat.free()
		groups[SignatureKill.HAT] = null
	if rig != null:  # the drawn feet (KillFallCells.feet_of); his drawn height is the art's
		body.set_meta(FEET, KillFallCells.feet_of(rig, body))
		body.set_meta(HEIGHT, KillFallCells.height_px(rig, ppm))
	groups[SignatureKill.BODY] = KillTrack.wrap_body(body)


## KillStyles.take's share: the placed body (a wrapped root) starts its track.
func add(serial: int, root: Node2D, row: SignatureKill, at: Vector2, dir: Vector2) -> void:
	if row.style == &"shred" and not row.whole_body():
		_shred.add(serial, row, dir, kills.tick)
	if root == null or root.get_child_count() == 0:
		return
	var d: Death = Death.new()
	d.serial = serial
	d.root = root
	d.lay = root.get_child(0) as Node2D
	d.row = row
	d.extra = KillTrackRows.of(row.id)
	d.born = kills.tick
	d.dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	d.fall = KillTrack.fall_vec(d.dir, d.extra.fall, _side(serial))
	d.body = d.lay.get_child(0) as Node2D if d.lay.get_child_count() > 0 else null
	d.cells = KillFallCells.of(d.body)
	d.loose = KillLooseArt.of(d.body)
	var m: Array = KillTrack.measure(d.lay, ppm)
	d.feet = d.body.get_meta(FEET, m[0]) if d.body != null else m[0]
	d.height = d.body.get_meta(HEIGHT, m[1]) if d.body != null else m[1]
	if row.style == &"pin":
		d.wall_m = KillPinArt.wall_behind(kills, at, d.dir, d.extra.num("wall_m", 1.4))
	_deaths.append(d)
	if row.style == &"shred":
		_shred.add_death(d)


## The side a sideways fall takes (alternating kill by kill).
static func _side(serial: int) -> float:
	return 1.0 if serial % 2 == 0 else -1.0


func forget(serial: int) -> void:
	_deaths = _deaths.filter(func(d: Death) -> bool: return d.serial != serial)
	_shred.forget(serial)


## After KillView placed the bodies: each figure laid by its track at its age.
func pose() -> void:
	_shred.pose(kills.tick, ppm, reduced_motion)
	for d: Death in _deaths:
		var age: int = kills.tick - d.born
		var p: Vector3 = KillTrack.sample(d.extra.track, age)
		if d.row.style == &"pin":
			p.x += KillPinArt.writhe(d, age)
		elif d.row.style == &"cook":
			p.x += KillCookArt.tremble(d, age, reduced_motion)
		var b: Transform2D = KillTrack.basis(d.dir, d.fall, p, d.extra.lie_len)
		var slide: Vector2 = d.dir * d.extra.slide_m * ppm * clampf(p.z, 0.0, 1.0)
		if d.row.style == &"pin":
			slide += KillPinArt.shift(d, age, ppm)
		if _drawn(d, age):  # the drawn fall takes over the lie: the track keeps only its lean
			var lean: float = p.x * KillDeathCells.lean_of(d)  # own cells: drawn, unless fx cells_lean
			b = KillTrack.basis(d.dir, d.fall, Vector3(lean, 1.0, 0.0), 1.0)
		KillTrack.lay(d.lay, d.feet, b, slide)
		d.xf = d.root.transform * d.lay.transform
		d.feet_px = d.xf * d.feet
		d.head_px = d.xf * (d.feet + Vector2(0.0, -d.height * 0.9))
	queue_redraw()


## True once the victim's drawn fall grid shows (from the row's `cells_at` tick); its rows step
## from `fall_at` (default cells_at) over `cells_ticks`, and a style may turn its facing (the
## stitch's whirl). The copy of his standing card hides.
func _drawn(d: Death, age: int) -> bool:
	if d.cells == null:
		return false
	if KillDeathCells.owns(d.cells):  # the death's own drawn frames, from their start ticks
		return KillDeathCells.step(d, age)
	if d.wall_m >= 0.0:
		return false
	if not d.extra.fx.has("cells_at"):
		return false
	var at: int = roundi(d.extra.num("cells_at", 0.0))
	var on: bool = age >= at
	show_cells(d, on)
	if not on:
		return false
	var from: float = d.extra.num("fall_at", float(at))
	var u: float = maxf(0.0, float(age) - from) / maxf(1.0, d.extra.num("cells_ticks", 20))
	d.cells.frame_coords = Vector2i(d.cells.frame_coords.x, KillFallCells.row_at(d.cells, u))
	if d.row.style == &"stitch":
		KillFallCells.face(d.cells, KillStitchArt.facing(d, age))
	return true


## The grid shows and the copy of his standing card hides (`on`), or the other way round.
static func show_cells(d: Death, on: bool) -> void:
	for ch: Node in d.body.get_children():
		(ch as CanvasItem).visible = on == (ch == d.cells)


func _draw() -> void:
	_shred.draw(self, kills.tick)
	for d: Death in _deaths:
		var age: int = kills.tick - d.born
		KillLooseArt.draw(self, d, age)
		if d.row.style == &"snap":
			KillSnapArt.draw(self, d, age)
		elif d.row.style == &"stitch":
			KillStitchArt.draw(self, d, age)
		elif d.row.style == &"pin":
			KillPinArt.draw(self, d, age)
		elif d.row.style == &"cook":
			KillCookArt.draw(self, d, age)
		elif d.row.style == &"torch":
			KillTorchArt.draw(self, d, age)


## A stable 0..1 hash of a kill serial and a number (no dice).
static func h(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)
