class_name KillSplitFx
extends Node2D
## Copies the posed rig into two masked halves and drives the weapon-specific contact marks.
## The saw holds and shakes the halves before its release. Blades follow the victim's cut line.

const STREAK_TICKS: int = 12
const EDGE_M: float = 0.34
const INK: Color = Color(0.07, 0.06, 0.07)
const CREAM: Color = Color(0.96, 0.92, 0.8)
const RAW: Color = Color(0.62, 0.05, 0.06)
const SHAKE_M: float = 0.035
## The held body's z during the grind (over Rivet's rig parts, which reach +30).
const HELD_Z: int = 40
## The grind's spurts: drops per tick, how long a drop flies (ticks), its speed (m/s).
const DROPS: int = 3
const DROP_LIFE: int = 16
const DROP_MPS: Vector2 = Vector2(2.2, 5.0)


class Grind:
	extends RefCounted
	var halves: Array[Node2D] = []
	var at: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var born: int = 0
	var ticks: int = 0
	var chunks: int = 0  # the row's saw_chunks (KillSawChunks)


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
## The chainsaw kill's read (melee_marks.json `saw`); null = the shipped table on first use.
var saw: SawMarks = null
## serial -> Vector4(at.x, at.y, cut angle, kill tick), metres.
var _streaks: Dictionary[int, Vector4] = {}
## serial -> the streak's (length, width) in metres, from its row (KillSlashStreak).
var _streak_size: Dictionary[int, Vector2] = {}
## serial -> the chainsaw's release burst (at, cut angle, the tick the halves part).
var _releases: Dictionary[int, Vector4] = {}
var _grinds: Dictionary[int, Grind] = {}
var _topples: Dictionary[int, KillSplitHalves.Topple] = {}


## The two halves of `rig` cut along `cut` (unit, world): groups by SignatureKill.PIECE_IDS,
## only HALF_A and HALF_B filled, each centred where its piece starts (SignatureKills offsets).
## Edges by the row (KillCutEdge.along); the line row.cut_up_m above the ground point (the torso).
static func cut(
	rig: CutRig, cut_dir: Vector2, view_ppm: float, row: SignatureKill
) -> Array[Node2D]:
	var out: Array[Node2D] = []
	@warning_ignore("return_value_discarded")
	out.resize(SignatureKill.PIECE_IDS.size())
	var offs: PackedVector2Array = SignatureKills.split_offsets(cut_dir)
	for p: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		var root: Node2D = Node2D.new()
		root.name = SignatureKill.PIECE_IDS[p]
		var o: Vector2 = -offs[p] * view_ppm  # the body's centre in the half's space
		var line: Vector2 = o + lift(row, view_ppm)
		var side: Vector2 = offs[p].normalized()
		var mask: Sprite2D = KillSplitHalves.mask(line, cut_dir, side, view_ppm)
		root.add_child(mask)
		var parts: Array[Node2D] = GibCut.cut(rig, true)
		var body: Node2D = parts[SignatureKill.BODY]
		for g: Node2D in parts:
			if g != body:
				g.free()
		body.position += o
		body.transform = mask.transform.affine_inverse() * body.transform  # undo the stretch
		flatten(body)
		mask.add_child(body)
		root.add_child(KillCutEdge.along(line, cut_dir, EDGE_M * view_ppm, side, row))
		root.set_meta(KillSplitHalves.SHADOW, line + side * KillSplitHalves.SHADOW_IN_M * view_ppm)
		out[p] = root
	return out


## The cut line's lift off the body's ground point (px; screen up).
static func lift(row: SignatureKill, view_ppm: float) -> Vector2:
	return Vector2(0.0, -row.cut_up_m * view_ppm)


## A clip mask only holds children on its own z: the copies' z order becomes tree order.
static func flatten(body: Node2D) -> void:
	var parts: Array[Node] = body.get_children()
	parts.sort_custom(
		func(x: Node, y: Node) -> bool: return (x as CanvasItem).z_index < (y as CanvasItem).z_index
	)
	for i: int in parts.size():
		body.move_child(parts[i], i)
		(parts[i] as CanvasItem).z_index = 0


func add(
	serial: int, at: Vector2, cut_dir: Vector2, row: SignatureKill, parts: Array[Node2D]
) -> void:
	at += lift(row, 1.0)  # metres: the streak and the saw's bite sit on the raised line
	var fall: int = kills.tick + row.hitstop_ticks + row.grind_ticks
	var deg: float = row.split_topple_deg
	var t: KillSplitHalves.Topple = KillSplitHalves.topple(parts, fall, deg, cut_dir.x)
	if t != null:
		_topples[serial] = t
	if row.weapon == &"plasma_sword":
		KillPlasmaArt.attach(self, parts, at, cut_dir, row.cut_up_m)
		return
	if row.grind_ticks <= 0:
		KerfVictim.streak(row, _streaks, serial, Vector4(at.x, at.y, cut_dir.angle(), kills.tick))
		_streak_size[serial] = Vector2(row.streak_m, row.streak_w_m)
		return
	var g: Grind = Grind.new()
	for p: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		if p < parts.size() and parts[p] != null:
			g.halves.append(parts[p])
	g.at = at
	g.dir = cut_dir
	g.born = kills.tick
	g.ticks = row.hitstop_ticks + row.grind_ticks
	g.chunks = row.saw_chunks
	_grinds[serial] = g
	if saw == null:
		saw = SawMarks.shipped()
	if saw.release_m > 0.0:
		_releases[serial] = Vector4(at.x, at.y, cut_dir.angle(), g.born + g.ticks)


func forget(serial: int) -> void:
	for d: Dictionary in [_streaks, _streak_size, _grinds, _releases, _topples]:
		@warning_ignore("return_value_discarded")
		d.erase(serial)


## After KillView placed the halves: a grinding body shakes in one piece; cut halves topple.
func pose() -> void:
	for t: KillSplitHalves.Topple in _topples.values():
		t.pose(kills.tick)
	for serial: int in _grinds.keys():
		var g: Grind = _grinds[serial]
		var age: int = kills.tick - g.born
		for half: Node2D in g.halves:  # held on the saw: over Rivet's claws, then back down
			half.z_index = HELD_Z if age < g.ticks else 0
		if age < 0 or age >= g.ticks or reduced_motion:
			continue
		var amp: float = (saw.shake_m if saw != null else SHAKE_M) * ppm
		var off: Vector2 = Vector2(_h(serial, age) - 0.5, _h(serial, age + 300) - 0.5) * 2.0 * amp
		var turn: float = (_h(serial, age + 700) - 0.5) * 0.12
		for half: Node2D in g.halves:
			half.position += off
			half.rotation += turn
	if not _streaks.is_empty() or not _grinds.is_empty():
		queue_redraw()


func _draw() -> void:
	for serial: int in _grinds.keys():
		var g: Grind = _grinds[serial]  # the thrown chunks, then the spurts and sparks
		var timing: Vector4i = Vector4i(g.born, g.ticks, g.chunks, kills.tick)
		KillSawChunks.draw(self, serial, (g.at - g.dir * 0.12) * ppm, g.dir.angle(), timing, ppm)
		_draw_grind(serial, g)
	for serial: int in _streaks.keys():
		KillSlashStreak.draw(self, _streaks[serial], _streak_size[serial], kills.tick, ppm)
	for serial: int in _releases.keys():
		var r: Vector4 = _releases[serial]
		var age: int = kills.tick - int(r.w)
		if age >= 0 and age < STREAK_TICKS:
			var t: float = float(age) / float(STREAK_TICKS)
			SawMarks.burst(self, Vector2(r.x, r.y) * ppm, saw.release_m * 0.5 * ppm, r.z, t)


## The saw's bite: blood drops spurting out of the cut (each born on a tick, flying
## DROP_LIFE ticks) and short cream sparks off the chain, for the grind and a little after.
func _draw_grind(serial: int, g: Grind) -> void:
	var age: int = kills.tick - g.born
	if age < 0 or age > g.ticks + DROP_LIFE:
		return
	var bite: Vector2 = (g.at - g.dir * 0.12) * ppm
	var back: float = g.dir.angle()  # out through the body, away from the saw (Rivet hides behind)
	var clear: float = (saw.clear_m if saw != null else 0.0) * ppm  # the held body stays readable
	for born: int in range(maxi(0, age - DROP_LIFE), mini(age, g.ticks) + 1):
		var t: float = float(age - born) / 60.0
		for j: int in DROPS:
			var key: int = born * DROPS + j
			var a: float = back + (_h(serial, key + 1100) - 0.5) * 2.8
			var sp: float = lerpf(DROP_MPS.x, DROP_MPS.y, _h(serial, key + 1900))
			var p: Vector2 = bite + Vector2.from_angle(a) * sp * t * ppm * (1.0 - t * 1.2)
			var r: float = (0.06 + 0.05 * _h(serial, key + 2600)) * ppm * (1.0 - t * 2.0)
			if r > 0.6 and p.distance_to(bite) >= clear:
				draw_circle(p, r + 1.2, INK)
				draw_circle(p, r, RAW)
	if age < g.ticks:
		for j: int in 4:
			var a: float = g.dir.angle() + PI * 0.5 + (_h(serial, age * 4 + j + 4000) - 0.5) * 2.2
			var s: Vector2 = Vector2.from_angle(a) * (0.18 + 0.3 * _h(serial, age * 4 + j)) * ppm
			draw_line(bite, bite + s, CREAM, 0.035 * ppm, true)


## A hash in [0, 1) of the serial and a key (the shake and the drops: no dice in render).
static func _h(serial: int, key: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + float(key) * 78.233) * 43758.5453, 1.0)
