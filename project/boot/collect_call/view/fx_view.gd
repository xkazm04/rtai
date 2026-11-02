class_name FxView
extends Node2D
## Quest 1's effects as flat placeholder ink: nails and rifle rounds in flight, dropped rifles,
## the Robo-tazer's arc ball (a fat cream ball in a vermilion halo with a zigzag tether back to
## the muzzle), the burst's chained arcs, the radio-static whisper rings, and the crate fire.

var stage: CollectCallStage
var _whisper_ticks: int = 0
var _arc_ticks: int = 0
var _arc_seen: int = 0


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null:
		return
	var arena: CombatArena = stage.arena
	for d: Vector2 in arena.rifle_drops:
		draw_line(Ink.px(d + Vector2(-0.4, 0.1)), Ink.px(d + Vector2(0.4, -0.1)), Ink.INK, 5.0)
	for s: Shot in arena.shots:
		var tail: Vector2 = s.pos - s.vel.normalized() * (0.5 if s.from_rivet else 0.25)
		draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK if s.from_rivet else Ink.VERMILION, 4.0)
	for b: ArcBall in arena.balls:
		_ball(b)
	_arcs(arena)
	_whispers()
	if stage.crates_burning:
		_fire()


func _ball(b: ArcBall) -> void:
	var tick: int = stage.tick
	Ink.zigzag(self, b.muzzle, b.pos, 10, tick / 3, Ink.VERMILION)
	Ink.zigzag(self, b.muzzle, b.pos, 10, tick / 3 + 5, Ink.CREAM)
	var r: float = 0.6 * Ink.PX_PER_M
	draw_circle(Ink.px(b.pos), r * 1.9, Color(Ink.VERMILION, 0.35))
	draw_arc(Ink.px(b.pos), r * 1.5, 0.0, TAU, 32, Ink.VERMILION, 5.0, true)
	draw_circle(Ink.px(b.pos), r, Ink.CREAM)
	for k: int in 4:
		var a: float = float(tick) * 0.3 + k * 1.57
		var tip: Vector2 = b.pos + Vector2.from_angle(a) * 0.55
		Ink.zigzag(self, b.pos, tip, 3, tick + k, Ink.VERMILION)


func _arcs(arena: CombatArena) -> void:
	if arena.burst_arcs.size() != _arc_seen:
		_arc_seen = arena.burst_arcs.size()
		_arc_ticks = 40
	if _arc_ticks <= 0 or arena.burst_arcs.is_empty():
		return
	_arc_ticks -= 1
	var path: Array = arena.burst_arcs[-1]
	for i: int in path.size() - 1:
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		Ink.zigzag(self, a, b, 7, stage.tick + i, Ink.VERMILION)
		Ink.zigzag(self, a, b, 7, stage.tick + i + 9, Ink.CREAM)


func _whispers() -> void:
	if stage.cues.get("static-whisper-burst", false):
		_whisper_ticks = 45
	if _whisper_ticks <= 0:
		return
	_whisper_ticks -= 1
	var at: Vector2 = stage.arena.rivet.pos + Vector2(0.0, -0.6)
	for k: int in 3:
		var r: float = (0.9 + k * 0.45 + (45 - _whisper_ticks) * 0.02) * Ink.PX_PER_M
		draw_arc(Ink.px(at), r, 0.0, TAU, 24, Color(Ink.TEAL, 0.8), 2.0, true)


## Flames stand over the whole stack: vermilion tongues with cream cores and an ink rim,
## swaying on the tick, with embers and smoke rising off them.
func _fire() -> void:
	var at: Vector2 = stage.layout.crates_at
	var t: float = float(stage.tick)
	for i: int in 9:
		var base: Vector2 = at + Vector2(-4.4 + i * 1.1, 1.4)
		var h: float = 2.6 + sin(t * 0.21 + i * 1.7) * 0.7 + float(i % 2) * 0.6
		var sway: float = sin(t * 0.13 + i) * 0.35
		var outer: PackedVector2Array = _flame(base, 0.75, h, sway)
		draw_colored_polygon(outer, Ink.VERMILION)
		draw_polyline(outer, Ink.INK, 2.5, true)
		draw_colored_polygon(_flame(base, 0.35, h * 0.55, sway * 0.6), Ink.CREAM)
	for k: int in 12:
		var rise: float = float((stage.tick + k * 23) % 90) / 90.0
		var drift: float = sin(t * 0.1 + k) * 0.3
		var ember: Vector2 = at + Vector2(-4.0 + k * 0.75 + drift, -1.0 - rise * 4.0)
		draw_circle(Ink.px(ember), 4.0, Ink.CREAM if k % 2 == 0 else Ink.VERMILION)
	for k: int in 5:
		var lift: float = float((stage.tick + k * 17) % 60) * 0.04
		var puff: Vector2 = at + Vector2(-3.0 + k * 1.5, -3.5 - lift)
		draw_circle(Ink.px(puff), 26.0 + k * 3.0, Color(Ink.INK, 0.22))


## A tongue of flame on `base`: wide at the foot, bulging, then a swaying point.
func _flame(base: Vector2, w: float, h: float, sway: float) -> PackedVector2Array:
	var pts: Array[Vector2] = [
		Ink.px(base + Vector2(-w, 0.0)),
		Ink.px(base + Vector2(-w * 1.1, -h * 0.35)),
		Ink.px(base + Vector2(-w * 0.45 + sway * 0.5, -h * 0.7)),
		Ink.px(base + Vector2(sway, -h)),
		Ink.px(base + Vector2(w * 0.45 + sway * 0.5, -h * 0.7)),
		Ink.px(base + Vector2(w * 1.1, -h * 0.35)),
		Ink.px(base + Vector2(w, 0.0)),
	]
	return PackedVector2Array(pts)
