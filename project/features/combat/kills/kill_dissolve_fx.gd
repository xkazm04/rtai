class_name KillDissolveFx
extends Node2D
## The ray gun kill (lane brutality, style `dissolve`), render only. KillDissolveMask.wrap()
## puts the victim's body copy under an elliptic clip mask; the body glows stiff for
## row.stand_ticks, then the mask shrinks over row.crumble_ticks, so the body is eaten from its
## outline inward by a hot cream ring while echo rings ripple outward and fade. Glowing motes fall
## onto a dust pile that is left with the empty uniform (a crumpled blue cloth) and the cap (the
## row's hat piece) lying by it. Timings against the sim tick, shapes from a hash of the kill
## serial: no dice, a replay shows the same.

const INK: Color = Color(0.07, 0.06, 0.07)
const HOT: Color = Color(1.0, 0.96, 0.78)
const GOLD: Color = Color("#E9A23B")
## The mask's starting radius (metres) for a body with no sprites to measure (a blob).
const BODY_R_M: float = 0.62
const ECHOES: int = 3
## The stiff lock's glow over the body (the part print ignores modulate tints): a hot cream wash.
const GLOW_A: float = 0.62
const MOTES: int = 26


class Dissolve:
	extends RefCounted
	var serial: int = 0
	var root: Node2D = null
	var row: SignatureKill = null
	var born: int = 0
	var at: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
## Callable(serial: int) -> float: the kill's body sink (KillView.body_sink): the pile shrinks.
var fade: Callable = Callable()
var _all: Array[Dissolve] = []


func add(serial: int, root: Node2D, row: SignatureKill, at: Vector2, dir: Vector2) -> void:
	var d: Dissolve = Dissolve.new()
	d.serial = serial
	d.root = root
	d.row = row
	d.born = kills.tick
	d.at = at
	d.dir = dir
	_all.append(d)


func forget(serial: int) -> void:
	_all = _all.filter(func(d: Dissolve) -> bool: return d.serial != serial)


## After KillView placed the bodies: the mask shrinks (its child undoes the scale).
func pose() -> void:
	for d: Dissolve in _all:
		var mask: Sprite2D = d.root.get_node_or_null("mask") as Sprite2D
		if mask == null:
			continue
		var ell: Rect2 = _ell(d)
		var k: float = 1.0 - _eat(d)
		mask.position = ell.position
		mask.scale = (ell.size * 2.0 * k).max(Vector2.ONE * 0.01) / KillDissolveMask.MASK_PX
		var body: Node2D = mask.get_child(0) as Node2D
		body.transform = mask.transform.affine_inverse()
		mask.visible = ell.size.y * k > 0.5
	if not _all.is_empty():
		queue_redraw()


func _ell(d: Dissolve) -> Rect2:
	return KillDissolveMask.ell_of(d.root, BODY_R_M * ppm)


## n16: what is left of a kill's `piece` (1 .. 0 as the rings eat the body; 1 for any other piece
## or kill): its shadow shrinks with it (the eaten man's shadow hung on the street, rg64_w/d).
func left(serial: int, piece: int) -> float:
	for d: Dissolve in _all:
		if d.serial == serial and piece == SignatureKill.BODY:
			return 1.0 - _eat(d)
	return 1.0


## 0 while the body stands glowing, rising to 1 as the rings eat it.
func _eat(d: Dissolve) -> float:
	var t0: int = d.born + d.row.hitstop_ticks + d.row.stand_ticks
	return clampf(float(kills.tick - t0) / maxf(1.0, float(d.row.crumble_ticks)), 0.0, 1.0)


## The lock's glow: rises over the first half of the lock, pulsing (steady under reduced motion).
func _glow(d: Dissolve) -> float:
	var age: int = kills.tick - d.born - d.row.hitstop_ticks
	if age < 0:
		return 0.0
	var k: float = clampf(float(age) / maxf(1.0, float(d.row.stand_ticks) * 0.5), 0.0, 1.0)
	var pulse: float = 1.0 if reduced_motion else 0.75 + 0.25 * sin(float(age) * 0.6)
	return k * pulse


func _draw() -> void:
	for d: Dissolve in _all:
		var e: float = _eat(d)
		var ell: Rect2 = _ell(d)
		_pile(d, e)
		# The rings and motes are drawn as circles of radius ell.size.x in the ellipse's own frame.
		var sx: float = d.root.scale.x
		var squash: Vector2 = Vector2(sx, sx * ell.size.y / maxf(ell.size.x, 0.01))
		draw_set_transform(d.root.transform * ell.position, d.root.rotation, squash)
		if e < 1.0:
			_rings(d, ell.size.x, e)
		_motes(d, ell.size.x, e)
		draw_set_transform(Vector2.ZERO)


## The glow on the eating edge plus echo rings rippling outward (none under reduced motion).
func _rings(d: Dissolve, r0: float, e: float) -> void:
	var c: Vector2 = Vector2.ZERO
	var r: float = r0 * (1.0 - e)
	var age: int = kills.tick - d.born
	var pulse: float = 1.0 if reduced_motion else 0.8 + 0.2 * sin(float(age) * 0.7)
	if e <= 0.0:  # the stiff glow before the rings start: the body lit from inside
		var g: float = _glow(d)
		draw_circle(c, r * 0.82, Color(HOT, GLOW_A * g))
		draw_arc(c, r * 0.9, 0.0, TAU, 32, Color(HOT, 0.85 * g), maxf(0.06 * ppm, 2.0), true)
		draw_arc(c, r * 0.9 + 2.0, 0.0, TAU, 32, Color(INK, 0.7 * g), 2.0, true)
		return
	draw_arc(c, r + 2.0, 0.0, TAU, 32, INK, 3.5, true)
	draw_arc(c, r, 0.0, TAU, 32, Color(HOT, pulse), maxf(0.07 * ppm, 2.0), true)
	if reduced_motion:
		return
	for n: int in ECHOES:
		var k: float = fposmod(e * 3.0 + float(n) / ECHOES, 1.0)
		var er: float = r + k * 0.7 * ppm
		draw_arc(c, er, 0.0, TAU, 32, Color(GOLD, 0.6 * (1.0 - k)), 0.035 * ppm * (1.0 - k) + 1.0)


## The dust heap grows with the eating, drawn out along the ray (KillDustPile).
func _pile(d: Dissolve, e: float) -> void:
	var f: float = fade.call(d.serial) if fade.is_valid() else 1.0  # CorpseDecay: sinks away
	var g: float = clampf(e * 1.4, 0.0, 1.0) * f
	if g <= 0.0:
		return
	var glow: float = clampf(1.6 - e * 0.6 - float(kills.tick - d.born) / 900.0, 0.25, 1.0)
	if not KillRemainsArt.plain():  # n16: the drawn ash heap with the skull (A7)
		var kind: String = str(d.root.get_meta(KillXray.KIND, ""))
		var k: Vector3 = Vector3(g, ppm, glow)
		KillRemainsArt.draw(self, d.at * ppm, d.dir, k, KillRemainsArt.set_of(kind))
		return
	KillDustPile.draw(self, d.serial, d.at * ppm, d.dir, g, ppm, glow)


## Glowing motes shed off the eating edge, falling to the pile.
func _motes(d: Dissolve, r0: float, e: float) -> void:
	if e <= 0.0 or e >= 1.0 or reduced_motion:
		return
	var c: Vector2 = Vector2.ZERO
	var r: float = r0 * (1.0 - e)
	var age: int = kills.tick - d.born
	for n: int in MOTES:
		var a: float = _h(d.serial, n + 200) * TAU + float(age) * 0.02
		var k: float = fposmod(_h(d.serial, n + 300) + float(age) / 40.0, 1.0)
		var at: Vector2 = c + Vector2.from_angle(a) * r * (1.0 - k * 0.6)
		draw_circle(at, (0.03 * ppm + 1.0) * (1.0 - k), Color(GOLD.lerp(HOT, k), 1.0 - k))


static func _h(serial: int, key: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + float(key) * 78.233) * 43758.5453, 1.0)
