class_name KillCharFx
extends Node2D
## The burn char (lane brutality, signature style `burn`), render only: the victim's rig copy
## turned to a charred ink silhouette with flickering cream ember cracks, smoke wisps rising off
## it, then the crumble (the body fades and sinks while ash flakes peel off downwind) onto the
## ash heap KillView prints under the bodies. Timings come from the row (stand_ticks,
## crumble_ticks) against the sim tick, so a replay shows the same frames. Shapes vary by a hash
## of the kill serial, never dice. World px at `ppm`, drawn above the gib layer.

const ASH: Color = Color("#5E5652")
const EMBER: Color = Color("#F4E3B5")
const EMBER_CORE: Color = Color("#E9A23B")
const SMOKE: Color = Color(0.09, 0.075, 0.105, 0.62)
const FLAKES: int = 34
const WISPS: int = 6
const SMOKE_TAIL: int = 150
const FLAKE_LIFE: float = 70.0
## A vaporised body's shadow: the char print burnt into the street, the paving showing through.
const SHADOW_A: float = 0.8
## One wind over the whole street (screen right and up a little), so every heap leans the same way.
const WIND: Vector2 = Vector2(0.94, -0.34)
const ASH_TEX: Texture2D = preload("res://features/combat/weapons/art/gore/ash.png")
## One shared char print for every burnt copy (the fade rides on the group's modulate alpha).
const CHAR_SHADER: Shader = preload("res://features/combat/kills/kill_char.gdshader")

static var _char_mat: ShaderMaterial = null
## The vaporise shadow's print: the same char, no lit rim (a shadow burnt into the street).
static var _shadow_mat: ShaderMaterial = null


class Burn:
	extends RefCounted
	var serial: int = 0
	var body: Node2D = null
	var row: SignatureKill = null
	var born: int = 0
	## The mini-nuke's vaporise: the char print stays as a shadow (no embers, smoke or crumble).
	var shadow: bool = false


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _burns: Array[Burn] = []


## The char print warmed at load: the first burn or vaporise kill built the material and drew
## the shader's first sprite on its kill frame (1.6-1.9 ms, CONTENDED). One faint speck, 6 frames.
func _ready() -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = ASH_TEX
	s.scale = Vector2.ONE * 0.02
	s.self_modulate.a = 0.02
	add_child(s)
	_char(self)
	var t: SceneTreeTimer = get_tree().create_timer(0.1)
	@warning_ignore("return_value_discarded")
	t.timeout.connect(s.queue_free)


## Takes over the BODY group of a burn kill: its sprites turn to char now.
func add(serial: int, body: Node2D, row: SignatureKill) -> void:
	var b: Burn = Burn.new()
	b.serial = serial
	b.body = body
	b.row = row
	b.born = kills.tick
	b.shadow = row.style == &"vaporise"
	_char(body, b.shadow)
	@warning_ignore("return_value_discarded")
	_burns.append(b)


func forget(serial: int) -> void:
	_burns = _burns.filter(func(b: Burn) -> bool: return b.serial != serial)


## After KillView placed the bodies: the crumble fades and sinks each burnt body.
func pose() -> void:
	for b: Burn in _burns:
		if b.shadow:
			b.body.modulate.a = SHADOW_A
			continue
		var k: float = _crumble(b)
		b.body.modulate.a = 1.0 - smoothstep(0.15, 1.0, k)
		b.body.scale *= 1.0 - 0.18 * k
	queue_redraw()


func _draw() -> void:
	for b: Burn in _burns:
		if b.shadow:
			continue
		var age: int = kills.tick - b.born
		var p: Vector2 = b.body.position
		var k: float = _crumble(b)
		if k < 0.7:
			_embers(b, p, age, 1.0 - k / 0.7)
		var tail: float = 1.0 - clampf(float(age - _end(b)) / SMOKE_TAIL, 0.0, 1.0)
		if tail > 0.0:
			_smoke(b, p, age, tail * (1.0 - 0.5 * k))
		if k > 0.0:
			_flakes(b, p, age)


## The ash heap of a burn mark (under the bodies): it grows in as the body crumbles.
static func pile(ci: CanvasItem, m: KillMarks.Mark, tick: int, px_m: float) -> void:
	if m.ash_m <= 0.0:
		return
	var k: float = clampf(float(tick - m.tick - m.ash_from) / 45.0, 0.0, 1.0)
	if k <= 0.0:
		return
	var size: Vector2 = Vector2(2.0, 1.25) * m.ash_m * px_m * (0.55 + 0.45 * k)
	var c: Vector2 = m.at * px_m + Vector2(0.0, 0.1 * px_m)
	ci.draw_texture_rect(ASH_TEX, Rect2(c - size * 0.5, size), false, Color(1, 1, 1, k))


## 0 while the body stands, rising to 1 over the crumble.
func _crumble(b: Burn) -> float:
	var t0: int = b.born + b.row.hitstop_ticks + b.row.stand_ticks
	return clampf(float(kills.tick - t0) / maxf(1.0, float(b.row.crumble_ticks)), 0.0, 1.0)


func _end(b: Burn) -> int:
	return b.row.hitstop_ticks + b.row.stand_ticks + b.row.crumble_ticks


func _embers(b: Burn, p: Vector2, age: int, strength: float) -> void:
	for n: int in 10:
		var h1: float = _h(b.serial, n)
		var h2: float = _h(b.serial, n + 40)
		var o: Vector2 = Vector2.from_angle(h1 * TAU) * (0.06 + 0.22 * h2) * ppm
		var c: Vector2 = p + o.rotated(b.body.rotation)
		var flick: float = 1.0 if reduced_motion else 0.55 + 0.45 * sin(float(age) * 0.45 + n * 1.9)
		var a: float = clampf(strength * flick, 0.0, 1.0)
		var d: Vector2 = Vector2.from_angle(h2 * TAU + b.body.rotation) * 0.1 * ppm
		var crack: PackedVector2Array = [c - d, c + d.rotated(0.9) * 0.6, c + d]
		draw_polyline(crack, Color(EMBER_CORE, a * 0.9), 3.6)
		draw_polyline(crack, Color(EMBER, a), 1.6)


func _smoke(b: Burn, p: Vector2, age: int, strength: float) -> void:
	for n: int in WISPS:
		var period: float = 46.0 + 10.0 * _h(b.serial, n + 80)
		var t: float = fposmod(float(age) + n * 9.0, period) / period
		var jx: float = (_h(b.serial, n + 90) - 0.5) * 0.4
		var at: Vector2 = p + (Vector2(jx, -1.3 * t) + WIND * 0.5 * t) * ppm
		var r: float = (0.14 + 0.34 * t) * ppm
		var a: float = (1.0 - t) * strength
		draw_circle(at, r, Color(SMOKE, SMOKE.a * a))
		draw_arc(at, r, 0.0, TAU, 14, Color(Ink.INK, 0.35 * a), 1.0)


func _flakes(b: Burn, p: Vector2, age: int) -> void:
	var t0: int = b.row.hitstop_ticks + b.row.stand_ticks
	for n: int in FLAKES:
		var start: float = t0 + float(b.row.crumble_ticks) * 0.85 * _h(b.serial, n + 120)
		var t: float = (float(age) - start) / FLAKE_LIFE
		if t < 0.0 or t > 1.0:
			continue
		var o: Vector2 = Vector2.from_angle(_h(b.serial, n + 160) * TAU) * 0.3 * ppm
		var reach: float = (0.4 + 1.3 * _h(b.serial, n + 200)) * ppm
		var lift: float = -0.35 * ppm * sin(PI * t)
		var at: Vector2 = p + o + WIND * reach * (1.0 - pow(1.0 - t, 2.0)) + Vector2(0.0, lift)
		var s: float = (0.05 + 0.06 * _h(b.serial, n + 240)) * ppm * (1.0 - 0.4 * t)
		var rot: float = float(age) * 0.12 * (1.0 + _h(b.serial, n))
		var q: PackedVector2Array = []
		for c: int in 4:
			@warning_ignore("return_value_discarded")
			q.append(
				at + Vector2.from_angle(rot + c * PI * 0.5) * s * (1.0 if c % 2 == 0 else 0.55)
			)
		var hot: bool = n % 6 == 0 and t < 0.5
		var a: float = 1.0 - smoothstep(0.75, 1.0, t)
		KillPoly.fill(self, q, Color(EMBER if hot else ASH, a))
		@warning_ignore("return_value_discarded")
		q.append(q[0])
		draw_polyline(q, Color(Ink.INK, a * 0.8), 1.0)


## The sprites of a burnt body: the print material swapped for the char print.
static func _char(n: Node, shadow: bool = false) -> void:
	if _char_mat == null:
		_char_mat = ShaderMaterial.new()
		_char_mat.shader = CHAR_SHADER
		_shadow_mat = ShaderMaterial.new()
		_shadow_mat.shader = CHAR_SHADER
		_shadow_mat.set_shader_parameter(&"rim_px", 0.0)
	for ch: Node in n.get_children():
		var s: Sprite2D = ch as Sprite2D
		if s != null:
			s.material = _shadow_mat if shadow else _char_mat
			s.self_modulate = Color.WHITE
			s.modulate = Color.WHITE
		_char(ch, shadow)


static func _h(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)
