class_name FxView
extends Node2D
## Quest 1's effects as flat placeholder ink: nails and rifle rounds in flight, dropped rifles,
## the Robo-tazer's arc ball (the inked fx_arcball loop with an ink + cream zigzag tether back to
## the muzzle), the burst's chained arcs, the radio-static whisper rings, and the crate fire.

const TRACER_TAIL_M: float = 2.5
const ENEMY_TAIL_M: float = 1.2
## A table gun's muzzle flash holds this many ticks after the trigger breaks.
const MUZZLE_TICKS: int = 2

var stage: CollectCallStage
## Whisper rings hold still (no growth, no spin) when set (the settings flag).
var reduced_motion: bool = false
var _whisper_ticks: int = 0
var _arc_ticks: int = 0
var _fire_tex: Texture2D = null
var _atlas: Texture2D = null
var _ball_tex: Texture2D = null
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
		if arena.gun != null:
			if WeaponFxArt.shot(self, s, stage.tick):  # weapon-art's cells first
				continue
			if s.spec == null or not FightAreasArt.shot(self, s, stage.tick):
				_tracer(s)
			continue
		var tail: Vector2 = s.pos - s.vel.normalized() * (0.5 if s.from_rivet else 0.25)
		draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK if s.from_rivet else Ink.VERMILION, 4.0)
	if arena.gun != null and not WeaponFxArt.muzzle(self, arena.rivet, arena.gun):
		_muzzle(arena.rivet, arena.gun)
	if arena.guard_tell != null:
		for h: Fighter in arena.hostiles:
			if h.alive() and GuardTell.telling(h):
				_tell(h, arena.guard_tell.locked(h), arena.rivet.pos)
	for b: ArcBall in arena.balls:
		_ball(b)
	_arcs(arena)
	if arena.areas != null:
		FightAreasArt.draw(self, arena, stage.tick)
	_whispers()
	if stage.crates_burning:
		_fire()


## Lane gunplay: with a table gun wired, every round is a tracer readable at 32 px/m: Rivet's a
## 2.5 m tail, cream core in an ink casing, a cream head; an enemy round (danger) is vermilion in
## the same casing, shorter (ENEMY_TAIL_M), so a strafe can beat it.
func _tracer(s: Shot) -> void:
	var tail_m: float = TRACER_TAIL_M if s.from_rivet else ENEMY_TAIL_M
	var core: Color = Ink.CREAM if s.from_rivet else Ink.VERMILION
	var tail: Vector2 = s.pos - s.vel.normalized() * tail_m
	draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK, 9.0)
	draw_line(Ink.px(tail.lerp(s.pos, 0.3)), Ink.px(s.pos), core, 4.0)
	draw_circle(Ink.px(s.pos), 5.0, core)


## Lane gunplay: the muzzle flash, a small cream star in an ink rim off the claw for the first
## MUZZLE_TICKS ticks after a round leaves (the trigger's cooldown has just been set).
func _muzzle(r: Fighter, gun: GunHand) -> void:
	var t: Trigger = gun.trigger
	if gun.shots_fired == 0 or t.cooldown < t.spec.interval_ticks - MUZZLE_TICKS:
		return
	var at: Vector2 = r.pos + r.facing.normalized() * (r.radius_m + 0.5)
	var pts: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	pts.resize(11)
	for i: int in 10:
		var k: float = 0.55 if i % 2 == 0 else 0.2
		pts[i] = Ink.px(at + Vector2.from_angle(r.facing.angle() + TAU * i / 10.0) * k)
	pts[10] = pts[0]
	draw_colored_polygon(pts.slice(0, 10), Ink.CREAM)
	draw_polyline(pts, Ink.INK, 2.5, true)


## Lane gunplay: a contractor's tell (GuardTell). Tracking: a thin dashed vermilion aim line
## that follows Rivet. Locked (the dodge window): the line goes solid in an ink casing and a cream
## glint sits on the muzzle; the burst will go exactly down it.
func _tell(g: Fighter, locked: bool, target: Vector2) -> void:
	var from: Vector2 = g.pos + g.facing * (g.radius_m + 0.3)
	var to: Vector2 = from + g.facing * minf(g.pos.distance_to(target) + 3.0, 16.0)
	if not locked:
		draw_dashed_line(Ink.px(from), Ink.px(to), Ink.VERMILION, 2.0, 10.0)
		return
	draw_line(Ink.px(from), Ink.px(to), Ink.INK, 7.0)
	draw_line(Ink.px(from), Ink.px(to), Ink.VERMILION, 3.0)
	draw_circle(Ink.px(from), 7.0, Ink.INK)
	draw_circle(Ink.px(from), 4.5, Ink.CREAM)


func _ball(b: ArcBall) -> void:
	var tick: int = stage.tick
	Ink.zigzag(self, b.muzzle, b.pos, 10, tick / 3, Ink.INK)
	Ink.zigzag(self, b.muzzle, b.pos, 10, tick / 3 + 5, Ink.CREAM)
	if _ball_tex == null:
		_ball_tex = QuestArt.shared().texture(&"fx_arcball")
	# 4-frame loop, 4 ticks a frame; the vermilion danger ring sits at ~1.15 m, the old halo
	var src: Rect2 = Rect2(float((tick / 4) % 4) * 256.0, 0.0, 256.0, 256.0)
	var size: Vector2 = Vector2.ONE * 2.8 * Ink.PX_PER_M
	draw_texture_rect_region(_ball_tex, Rect2(Ink.px(b.pos) - size * 0.5, size), src)


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
	if stage.whisper_now:
		_whisper_ticks = 45
	if _whisper_ticks <= 0:
		return
	_whisper_ticks -= 1
	var at: Vector2 = stage.arena.rivet.pos + Vector2(0.0, -0.6)
	for k: int in 3:
		var grow: float = 0.0 if reduced_motion else (45 - _whisper_ticks) * 0.02
		var r: float = (0.9 + k * 0.45 + grow) * Ink.PX_PER_M
		# radio static: broken inked dashes (ink under teal), the gaps shifting per ring and tick
		for d: int in 9:
			var spin: float = 0.0 if reduced_motion else float(stage.tick / 4) * 0.25
			var a0: float = TAU * d / 9.0 + k * 0.4 + spin
			var span: float = 0.42 + 0.18 * sin(float(d * 7 + k * 3))
			draw_arc(Ink.px(at), r, a0, a0 + span, 6, Ink.INK, 6.0, true)
			draw_arc(Ink.px(at), r, a0, a0 + span, 6, Ink.TEAL, 3.0, true)


## The crate fire seen from above (features/fx/art/fx_fire.png, 4 x 2 cells of
## 2.5 m): one wide band over the stack, three loop fires with offset phases, embers flickering.
func _fire() -> void:
	var at: Vector2 = stage.layout.crates_at
	var tick: int = stage.tick
	_fire_cell(Vector2i(2, 1), 2, at + Vector2(0.0, 0.2), 2.0)
	for i: int in 3:
		var frame: int = (tick / 5 + i * 2) % 4
		_fire_cell(Vector2i(frame, 0), 1, at + Vector2(-3.4 + i * 3.4, 0.1 * float(i % 2)), 1.3)
	_fire_cell(Vector2i((tick / 8) % 2, 1), 1, at + Vector2(0.0, -1.6), 2.0)
	if _atlas == null:
		_atlas = QuestArt.shared().texture(&"fx_atlas")
	for k: int in 5:
		var lift: float = float((stage.tick + k * 17) % 60) * 0.04
		var puff: Vector2 = at + Vector2(-3.0 + k * 1.5, -3.5 - lift)
		var size: Vector2 = Vector2.ONE * (2.2 + k * 0.2) * Ink.PX_PER_M
		var src: Rect2 = Rect2(Vector2(k % 4, 2) * 256.0, Vector2(256.0, 256.0))
		var fade: Color = Color(1.0, 1.0, 1.0, 1.0 - lift / 2.4)
		draw_texture_rect_region(_atlas, Rect2(Ink.px(puff) - size * 0.5, size), src, fade)


## One cell (w cells wide) of the fire sheet centred on `at`, `scale` x its 2.5 m cell size.
func _fire_cell(cell: Vector2i, w: int, at: Vector2, scale: float) -> void:
	if _fire_tex == null:
		_fire_tex = QuestArt.shared().texture(&"fx_fire")
	var size: Vector2 = Vector2(2.5 * w, 2.5) * scale * Ink.PX_PER_M
	var src: Rect2 = Rect2(Vector2(cell) * 256.0, Vector2(256.0 * w, 256.0))
	draw_texture_rect_region(_fire_tex, Rect2(Ink.px(at) - size * 0.5, size), src)
