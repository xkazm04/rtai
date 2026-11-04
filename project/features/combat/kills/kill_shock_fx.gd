class_name KillShockFx
extends Node2D
## The electro kill (lane brutality, signature style `shock`), render only: the victim's rig copy
## locks up in a stiff convulsion (a hashed shake every tick) while the X-ray flash strobes (the
## body blinks out and weapon-art's skeleton sticker shows in its place, ringed by cream arcs),
## then the body drops stiff (a hard topple along the shot) with smoke rising from the collar.
## Timings: row.stand_ticks = the convulsion, against the sim tick, so a replay shows the same
## frames. No dice: shapes and the shake come from a hash of the serial and the tick.

const XRAY_TEX: Texture2D = preload("res://features/combat/weapons/art/gore/xray.png")
const ARC: Color = Color("#F4E3B5")
const SMOKE: Color = Color(0.09, 0.075, 0.105, 0.5)
## The skeleton's height on the street (metres, a comic oversize), the held first flash right
## after the hit-stop (ticks: cream bones on ink, the beat that reads) and the strobe after it.
const XRAY_M: float = 1.6
const XRAY_HOLD: int = 4
const STROBE: int = 6
const DROP_TICKS: int = 7
const DROP_TURN: float = 0.5
const SMOKE_TICKS: int = 200


class Shock:
	extends RefCounted
	var serial: int = 0
	var body: Node2D = null
	var row: SignatureKill = null
	var born: int = 0
	var dir: Vector2 = Vector2.RIGHT


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _shocks: Array[Shock] = []


func add(serial: int, body: Node2D, row: SignatureKill, dir: Vector2) -> void:
	var s: Shock = Shock.new()
	s.serial = serial
	s.body = body
	s.row = row
	s.born = kills.tick
	s.dir = dir
	@warning_ignore("return_value_discarded")
	_shocks.append(s)


func forget(serial: int) -> void:
	_shocks = _shocks.filter(func(s: Shock) -> bool: return s.serial != serial)


## After KillView placed the bodies: the shake, the strobe and the stiff drop.
func pose() -> void:
	for s: Shock in _shocks:
		var age: int = kills.tick - s.born
		var lock: int = s.row.hitstop_ticks + s.row.stand_ticks
		if age < lock:
			var amp: float = 0.0 if reduced_motion else 0.05 * ppm
			s.body.position += Vector2(_h(s.serial, age) - 0.5, _h(s.serial, age + 500) - 0.5) * amp
			s.body.rotation += (_h(s.serial, age + 900) - 0.5) * 0.25
			s.body.visible = not _xray(s, age)  # print_part writes alpha 1: blink by visibility
		else:
			var k: float = clampf(float(age - lock) / DROP_TICKS, 0.0, 1.0)
			s.body.visible = true
			s.body.position += s.dir * 0.35 * ppm * k
			s.body.rotation += DROP_TURN * k
	queue_redraw()


func _draw() -> void:
	for s: Shock in _shocks:
		var age: int = kills.tick - s.born
		var lock: int = s.row.hitstop_ticks + s.row.stand_ticks
		var p: Vector2 = s.body.position
		if age < lock:
			_arcs(s, p, age)
			if _xray(s, age):
				var h: float = XRAY_M * ppm
				var size: Vector2 = Vector2(h * 0.53, h)
				if age - s.row.hitstop_ticks < XRAY_HOLD:
					_burst(s, p, h * 0.62)
				draw_set_transform(p, s.dir.angle() + PI * 0.5, Vector2.ONE)
				draw_texture_rect(XRAY_TEX, Rect2(-size * 0.5, size), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		elif age < lock + SMOKE_TICKS:
			_smoke(s, p - s.dir * 0.2 * ppm, age, 1.0 - float(age - lock) / SMOKE_TICKS)


## The flash: held XRAY_HOLD ticks, then on for 2 of every STROBE ticks (off under reduced motion).
func _xray(s: Shock, age: int) -> bool:
	var a: int = age - s.row.hitstop_ticks
	return not reduced_motion and a >= 0 and (a < XRAY_HOLD or (a - XRAY_HOLD) % STROBE < 2)


func _arcs(s: Shock, p: Vector2, age: int) -> void:
	for n: int in 4:
		var a0: float = TAU * _h(s.serial, n * 7 + age)
		var pts: PackedVector2Array = []
		for k: int in 5:
			var r: float = (0.25 + 0.12 * k) * ppm
			var jag: float = (_h(s.serial, n * 31 + k + age * 3) - 0.5) * 0.7
			@warning_ignore("return_value_discarded")
			pts.append(p + Vector2.from_angle(a0 + jag + k * 0.18) * r)
		draw_polyline(pts, Ink.INK, 3.2)
		draw_polyline(pts, ARC, 1.4)


## The zap panel behind the held flash: a jagged cream star in an ink rim, so the bones pop.
func _burst(s: Shock, p: Vector2, r: float) -> void:
	var pts: PackedVector2Array = []
	for k: int in 18:
		var rr: float = r * (1.0 if k % 2 == 0 else 0.62 + 0.18 * _h(s.serial, k + 40))
		@warning_ignore("return_value_discarded")
		pts.append(p + Vector2.from_angle(TAU * k / 18.0) * rr)
	draw_colored_polygon(pts, ARC)
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	draw_polyline(pts, Ink.INK, 3.0, true)


func _smoke(s: Shock, p: Vector2, age: int, strength: float) -> void:
	for n: int in 3:
		var t: float = fposmod(float(age) + n * 13.0, 40.0) / 40.0
		var at: Vector2 = p + Vector2((_h(s.serial, n + 70) - 0.5) * 0.2, -0.9 * t) * ppm
		var r: float = (0.06 + 0.16 * t) * ppm
		var a: float = (1.0 - t) * strength
		draw_circle(at, r, Color(SMOKE, SMOKE.a * a))
		draw_arc(at, r, 0.0, TAU, 12, Color(Ink.INK, 0.35 * a), 1.0)


static func _h(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)
