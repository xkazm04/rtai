class_name KerfView
extends Node2D
## Kerf on the arena's actor layer (lane ghost-powers), render only; reads the pilot's KerfStage
## (looked up each frame: the reel sets it after the views attach). While the soul is on: a thin
## teal ring at Rivet's feet and one teal pip per blink charge behind him. Each blink leaves, for
## cut_hang_s: the straight teal path from where he stood to where he landed with three fading
## afterimages of the Kerf body along it (KerfRig copies, limbs swept, teal-washed, older = fainter;
## pooled), and on a cut the hanging cut line across the target, white-hot in a
## teal glow, at the kill row's diagonal. Reduced motion: no afterimages, no flicker.
## n7-melee: on each cut frame, for cut_flare_s, a cut flare across the target (a long cream slash
## edged in ink, snapping out to full length, and ink sparks thrown along the blink), so a chain of
## three reads as three marks at 32 px/m. A world impact prints in ink and paper (teal stays the
## soul's own marks). --feel=off or cut_flare_s 0 = none (the before clips).

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const WHITE: Color = Color(0.92, 1.0, 0.97)
const CUT_HALF_M: float = 0.95
const CUT_DEG: float = 55.0
const GHOSTS: int = 3
## The afterimage pool (3 per blink, a 3-blink chain inside cut_hang_s) and its teal wash (modulate
## above 1 lifts the dark steel toward the soul colour).
const ECHO_POOL: int = 9
const ECHO_WASH: Color = Color(0.55, 1.75, 1.6)
const ECHO_ALPHA: Vector2 = Vector2(0.2, 0.6)
const CREAM: Color = Color(0.98, 0.94, 0.82)
const FLARE_HALF_M: float = 1.3
const SPARKS: int = 4

var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false
var flare: bool = HitFeel.feel_flag() != "off"
var _echo: Array[KerfRig] = []


func _process(_delta: float) -> void:
	_place_echoes()
	queue_redraw()


func kerf() -> KerfStage:
	return stage.pilot.kerf if stage != null and stage.pilot != null else null


func _draw() -> void:
	var k: KerfStage = kerf()
	if k == null:
		return
	var hang: float = maxf(0.05, k.num(&"cut_hang_s"))
	for i: int in k.trail_tick.size():
		var age: float = (stage.tick - k.trail_tick[i]) * SimClock.TICK_DT
		if age < 0.0 or age > hang:
			continue
		var fade: float = 1.0 - age / hang
		_path(k.trail_from[i] * ppm, k.trail_to[i] * ppm, fade)
		if k.trail_cut[i] != Vector2.INF:
			var dir: Vector2 = (k.trail_to[i] - k.trail_from[i]).normalized()
			_cut(k.trail_cut[i] * ppm, dir.rotated(deg_to_rad(CUT_DEG)), fade, i)
			_flare(k, k.trail_cut[i] * ppm, dir, age)
	if k.on():
		_aura(k)


func _path(a: Vector2, b: Vector2, fade: float) -> void:
	draw_line(a, b, Color(INK, 0.55 * fade), 6.0, true)
	draw_line(a, b, Color(TEAL, 0.9 * fade), 2.5, true)


## The afterimages: the Kerf body left behind along each live blink path, older = fainter.
func _place_echoes() -> void:
	var k: KerfStage = kerf()
	var used: int = 0
	if k != null and not reduced_motion:
		var hang: float = maxf(0.05, k.num(&"cut_hang_s"))
		for i: int in k.trail_tick.size():
			var age: float = (stage.tick - k.trail_tick[i]) * SimClock.TICK_DT
			if age < 0.0 or age > hang:
				continue
			var a: Vector2 = k.trail_from[i] * ppm
			var b: Vector2 = k.trail_to[i] * ppm
			for g: int in GHOSTS:
				if used >= ECHO_POOL:
					break
				var t: float = (g + 0.5) / GHOSTS
				var alpha: float = lerpf(ECHO_ALPHA.x, ECHO_ALPHA.y, t) * (1.0 - age / hang)
				_echo_at(used, a.lerp(b, t), (b - a).angle(), alpha)
				used += 1
	for j: int in range(used, _echo.size()):
		_echo[j].visible = false


func _echo_at(j: int, at: Vector2, angle: float, alpha: float) -> void:
	while _echo.size() <= j:
		var rig: KerfRig = KerfRig.new()
		rig.show_behind_parent = true  # under the path and the cut line
		add_child(rig)
		rig.speed_mps = KerfRig.FAST_MPS
		rig.advance(1.0)  # limbs fully swept: caught mid-blink
		_echo.append(rig)
	var r: KerfRig = _echo[j]
	r.visible = true
	r.position = at
	r.rotation = angle
	r.scale = Vector2.ONE * ppm / KerfRig.PX_PER_M
	r.modulate = Color(ECHO_WASH, alpha)


## The hanging cut: a thin white line across the target with a teal glow, shrinking to its middle.
func _cut(c: Vector2, along: Vector2, fade: float, salt: int) -> void:
	var half: float = CUT_HALF_M * ppm * (0.6 + 0.4 * fade)
	var flick: float = 1.0 if reduced_motion else 0.85 + 0.15 * sin(stage.tick * 1.3 + salt)
	var a: Vector2 = c - along * half
	var b: Vector2 = c + along * half
	draw_line(a, b, Color(TEAL, 0.45 * fade * flick), 7.0, true)
	draw_line(a, b, Color(WHITE, fade), 2.0, true)
	draw_circle(c, 2.5, Color(WHITE, fade))


## The cut flare: full length within 2 ticks, then thinning out over cut_flare_s.
func _flare(k: KerfStage, c: Vector2, dir: Vector2, age: float) -> void:
	var span: float = k.num(&"cut_flare_s")
	if not flare or span <= 0.0 or age > span:
		return
	var t: float = age / span
	var grow: float = minf(1.0, (age + SimClock.TICK_DT) / (2.0 * SimClock.TICK_DT))
	var along: Vector2 = dir.rotated(deg_to_rad(CUT_DEG))
	var half: float = FLARE_HALF_M * ppm * grow
	var w: float = lerpf(5.0, 1.5, t)
	draw_line(c - along * half, c + along * half, Color(INK, 1.0 - t), w + 4.0, true)
	draw_line(c - along * half, c + along * half, Color(CREAM, 1.0 - t * t), w, true)
	for s: int in SPARKS:  # thrown forward along the blink, fanned across the cut
		var off: float = (s - (SPARKS - 1) * 0.5) * 0.35
		var from: Vector2 = c + along * off * ppm
		var to: Vector2 = from + dir.rotated(off * 0.6) * (0.35 + 0.5 * t) * ppm
		draw_line(from + (to - from) * t * 0.6, to, Color(INK, 1.0 - t), 2.0, true)


func _aura(k: KerfStage) -> void:
	var rivet: Fighter = stage.arena.rivet
	var c: Vector2 = rivet.pos * ppm
	draw_arc(c, 0.55 * ppm, 0.0, TAU, 28, Color(TEAL, 0.7), 1.5, true)
	var back: Vector2 = -rivet.facing.normalized()
	var side: Vector2 = back.orthogonal()
	for i: int in k.charges:  # the charges: teal pips in a row behind him
		var at: Vector2 = c + back * 0.75 * ppm + side * (i - (k.charges - 1) * 0.5) * 0.22 * ppm
		draw_circle(at, 3.2, INK)
		draw_circle(at, 2.2, TEAL)
