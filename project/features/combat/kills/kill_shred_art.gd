class_name KillShredArt
extends RefCounted
## The Gatling's death (lane kills-new, style `shred`), render only. The row throws his six rig
## parts held together for `grind_ticks` (GibSim's grind hold, as the chainsaw and the shard gun
## hold theirs): the stream holds him upright, each part shaken back along the shot (`shake_m`),
## and every `scrap_every` ticks a torn scrap (cloth or flesh, a cream bone fleck in it) leaves a
## part with a red spurt and flies `scrap_m` along the stream to lie on the street. At the release
## what is left drops in a heap at his feet: the view pulls each part to a slot around the feet
## and lays it flat over `heap_ticks` (the sim's pieces barely move: the row's launch is slow).
## Under --reduced-motion the shake halves. No RNG: shapes from KillNewStyles.h.

const CLOTH: Color = Color("#2B3448")
const FLESH: Color = Color("#8E1A1A")
const BONE: Color = Color("#EFE3C8")
## The heap's slots about the feet (m: along the shot, across it), one per rig part.
const HEAP: Array[Vector2] = [
	Vector2(0.15, -0.1),
	Vector2(0.0, 0.05),
	Vector2(-0.1, 0.22),
	Vector2(0.2, -0.25),
	Vector2(-0.18, -0.08),
	Vector2(0.05, 0.25),
]


class Shred:
	extends RefCounted
	var serial: int = 0
	var parts: Array[Node2D] = []
	var born: int = 0
	var dir: Vector2 = Vector2.RIGHT
	var extra: KillTrackRows.Extra = null
	var hold: int = 24
	## Layer px at the release: each part's place and the feet the heap gathers at.
	var from: Array[Vector2] = []
	var feet: Vector2 = Vector2.ZERO
	## Each scrap's start (layer px, at its tear tick).
	var tears: Array[Vector2] = []
	## The whole-body shred (the row throws `body`): the death the track and fall grid lay; the
	## scraps tear from his figure between feet and head.
	var death: KillNewStyles.Death = null


var _shreds: Array[Shred] = []
var _kept: Dictionary[int, Array] = {}


## KillStyles.parts' share: the six part groups kept for the shake and the heap.
func keep(serial: int, groups: Array[Node2D]) -> void:
	var six: Array[Node2D] = []
	for i: int in SignatureKill.BODY:
		six.append(groups[i] if i < groups.size() else null)
	_kept[serial] = six


func add(serial: int, row: SignatureKill, dir: Vector2, tick: int) -> void:
	var s: Shred = Shred.new()
	s.serial = serial
	var kept: Array = _kept.get(serial, [])
	s.parts.assign(kept)
	@warning_ignore("return_value_discarded")
	_kept.erase(serial)
	s.born = tick
	s.dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	s.extra = KillTrackRows.of(row.id)
	s.hold = row.grind_ticks
	_shreds.append(s)


## The whole-body shred: the scraps tear off the death's figure while the track shakes it.
func add_death(d: KillNewStyles.Death) -> void:
	var s: Shred = Shred.new()
	s.serial = d.serial
	s.born = d.born
	s.dir = d.dir
	s.extra = d.extra
	s.hold = roundi(d.extra.num("cells_at", 24.0))
	s.death = d
	_shreds.append(s)


func forget(serial: int) -> void:
	@warning_ignore("return_value_discarded")
	_kept.erase(serial)
	_shreds = _shreds.filter(func(s: Shred) -> bool: return s.serial != serial)


## After KillView placed the parts: the shake while held, the heap after.
func pose(tick: int, ppm: float, reduced_motion: bool) -> void:
	for s: Shred in _shreds:
		var age: int = tick - s.born
		if s.death != null:
			_tear(s, mini(age, s.hold - 1))
		elif age < s.hold:
			_shake(s, age, ppm * s.extra.num("shake_m", 0.06) * (0.5 if reduced_motion else 1.0))
			_tear(s, age)
		else:
			_heap(s, age - s.hold, ppm)


func _shake(s: Shred, age: int, amp: float) -> void:
	for i: int in s.parts.size():
		var p: Node2D = s.parts[i]
		if p == null or not is_instance_valid(p):
			continue
		var kick: float = 1.0 if (age + i) % 2 == 0 else 0.35
		var across: float = (KillNewStyles.h(s.serial * 7 + i, age) - 0.5) * 0.8
		p.position += (s.dir * kick + s.dir.orthogonal() * across) * amp
		p.rotation += (KillNewStyles.h(s.serial + i, age + 50) - 0.5) * 0.12


## Records where each scrap tears (the part it leaves, this tick).
func _tear(s: Shred, age: int) -> void:
	var every: int = maxi(1, roundi(s.extra.num("scrap_every", 3.0)))
	var count: int = roundi(s.extra.num("scraps", 8.0))
	while s.tears.size() < count and s.tears.size() * every <= age:
		var at: Vector2 = s.tears.back() if not s.tears.is_empty() else Vector2.ZERO
		if s.death != null:  # a point of his figure, hip to neck
			var up: float = 0.3 + 0.55 * KillNewStyles.h(s.serial, s.tears.size() + 330)
			at = s.death.feet_px.lerp(s.death.head_px, up)
		elif not s.parts.is_empty():
			var p: Node2D = s.parts[s.tears.size() * 5 % s.parts.size()]
			if p != null and is_instance_valid(p):
				at = p.position
		s.tears.append(at)


func _heap(s: Shred, age: int, ppm: float) -> void:
	if s.from.is_empty():
		_release(s)
	var k: float = clampf(float(age) / maxf(1.0, s.extra.num("heap_ticks", 10.0)), 0.0, 1.0)
	var e: float = k * k  # dropping: slow off the stream, fast onto the street
	for i: int in s.parts.size():
		var p: Node2D = s.parts[i]
		if p == null or not is_instance_valid(p):
			continue
		var slot: Vector2 = s.feet + _local(s.dir, HEAP[i % HEAP.size()]) * ppm
		p.position = s.from[i].lerp(slot, e)
		p.rotation += (PI * 0.5 if i % 2 == 0 else -PI * 0.5) * e


## The release: each part's place now and the feet (the legs' mean, else the parts').
func _release(s: Shred) -> void:
	var legs: Vector2 = Vector2.ZERO
	var n: int = 0
	for i: int in s.parts.size():
		var p: Node2D = s.parts[i]
		var at: Vector2 = p.position if p != null and is_instance_valid(p) else Vector2.ZERO
		s.from.append(at)
		if i >= 4 and p != null and is_instance_valid(p):
			legs += at
			n += 1
	s.feet = legs / float(n) if n > 0 else s.from[0]


static func _local(dir: Vector2, m: Vector2) -> Vector2:
	return dir * m.x + dir.orthogonal() * m.y


func draw(ci: KillNewStyles, tick: int) -> void:
	for s: Shred in _shreds:
		for n: int in s.tears.size():
			_scrap(ci, s, n, tick - s.born - n * maxi(1, roundi(s.extra.num("scrap_every", 3.0))))


## Scrap `n`, `a` ticks after it tore: a spurt at the tear, then the scrap flying and lying.
func _scrap(ci: KillNewStyles, s: Shred, n: int, a: int) -> void:
	var ppm: float = ci.ppm
	var spread: float = (KillNewStyles.h(s.serial, n + 300) - 0.5) * 0.9
	var run: float = s.extra.num("scrap_m", 1.4) * (0.5 + 0.5 * KillNewStyles.h(s.serial, n + 310))
	var u: float = clampf(float(a) / 10.0, 0.0, 1.0)
	var to: Vector2 = s.dir.rotated(spread) * run * ppm * (1.0 - (1.0 - u) * (1.0 - u))
	var at: Vector2 = s.tears[n] + to
	if a < 4:  # the spurt off the tear
		var r: float = ppm * 0.07 * (1.0 - float(a) / 4.0) + 1.0
		ci.draw_circle(s.tears[n] + s.dir * ppm * 0.12 * float(a), r, KillMarkArt.BLOOD)
	var size: float = ppm * s.extra.num("scrap_size_m", 0.1)
	size *= 0.7 + 0.6 * KillNewStyles.h(s.serial, n + 320)
	var pts: PackedVector2Array = PackedVector2Array()
	for v: int in 5:
		var ang: float = TAU * float(v) / 5.0 + float(a) * 0.5 * (1.0 - u)
		var rr: float = size * (0.6 + 0.5 * KillNewStyles.h(s.serial * 3 + n, v))
		@warning_ignore("return_value_discarded")
		pts.append(at + Vector2.from_angle(ang) * rr)
	var flesh: bool = n % 3 == 1
	ci.draw_colored_polygon(pts, FLESH if flesh else CLOTH)
	ci.draw_polyline(pts + PackedVector2Array([pts[0]]), Ink.INK, maxf(1.0, ppm * 0.015))
	if flesh:
		ci.draw_circle(at, size * 0.28, BONE)
