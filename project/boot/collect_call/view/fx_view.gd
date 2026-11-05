class_name FxView
extends Node2D
## Quest 1's effects as flat placeholder ink: nails and rifle rounds in flight, dropped rifles,
## the Robo-tazer's arc ball (the inked fx_arcball loop with an ink + cream zigzag tether back to
## the muzzle), the burst's chained arcs, the radio-static whisper rings, and the crate fire.

const ENEMY_TAIL_M: float = 1.2

var stage: CollectCallStage
## Whisper rings hold still (no growth, no spin) when set (the settings flag).
var reduced_motion: bool = false
var _whisper_ticks: int = 0
var _arc_ticks: int = 0
var _fire_tex: Texture2D = null
var _atlas: Texture2D = null
var _ball_tex: Texture2D = null
var _arc_seen: int = 0
## Lane gunplay: shells, smoke, impacts and per-weapon muzzles of a table bullet gun.
var _gun_fx: GunFx = null
## n5-look: Rivet's weapon FX cells in colour (null: fx_colour_dir is "", the ink cells).
var _colour: WeaponFxColour = null
var _colour_tried: bool = false
## n7-melee: the plasma sword's deflect marks (DeflectMarks, melee_marks.json).
var _deflects: DeflectMarks = null
## n7-melee: Tonnage's plate sparks (PlateSparks, ghost_attacks.json tonnage plate_*).
var _plates: PlateSparks = null
## perf-city: the retained ground marks (FxGround.enabled; null = drawn here every frame).
var _ground: FxGround = null


func _ready() -> void:
	if FxGround.enabled:
		_ground = FxGround.new()
		add_child(_ground)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null:
		return
	var arena: CombatArena = stage.arena
	_colour_begin()
	if _ground == null:
		for d: Vector2 in arena.rifle_drops:
			draw_line(Ink.px(d + Vector2(-0.4, 0.1)), Ink.px(d + Vector2(0.4, -0.1)), Ink.INK, 5.0)
	_under(arena)
	_shots(arena)
	if arena.gun != null:
		_gun_over(arena)
	if arena.guard_tell != null:
		for h: Fighter in arena.hostiles:
			if h.alive() and GuardTell.telling(h):
				_tell(h, arena.guard_tell.locked(h), arena.rivet.pos)
	for b: ArcBall in arena.balls:
		_ball(b)
	_arcs(arena)
	if arena.areas != null:
		FightAreasArt.draw(self, arena, stage.tick)
	if _deflects == null or _deflects.arena != arena:
		_deflects = DeflectMarks.attach(arena)
	_deflects.draw(self, stage.tick)
	if _plates != null:
		_plates.draw(self, stage.tick)
	_last()


## The table gun's floor (shells, scuffs, scorch) under everything else; the retained ground
## layer (FxGround) holds the scuffs and scorch when it is on.
func _under(arena: CombatArena) -> void:
	if arena.gun != null:
		if _gun_fx == null:
			_gun_fx = GunFx.new()
		_gun_fx.step(arena, stage.tick)
		var gun: GunHand = arena.gun
		var art: bool = _art_gun(gun)
		GunFxArt.draw_under(self, _gun_fx, stage.tick, not art, not _art_mag(gun), _ground == null)
	if _ground != null:
		_ground.sync(arena, _gun_fx if arena.gun != null else null, stage.tick)


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


## n5-look: the colour canvas made on the first draw, cleared each frame, and lent to WeaponFxArt
## for this draw only (another canvas drawing cells is never redirected).
func _colour_begin() -> void:
	if not _colour_tried:
		_colour_tried = true
		_colour = WeaponFxColour.attach(self, WeaponFxArt.art().fx_colour_dir)
	if _colour != null:
		_colour.begin(material as ShaderMaterial)
	WeaponFxArt.colour = _colour


## The whisper rings and the crate fire (ink), then the colour canvas goes back.
func _last() -> void:
	_whispers()
	if stage.crates_burning:
		_fire()
	WeaponFxArt.colour = null


func _exit_tree() -> void:
	if _colour != null:
		_colour.release()
	_colour = null


## Showcase merge r4: weapon-art's cells own Rivet's muzzle flash and brass for a gun they have
## art for; GunFx draws those otherwise, and always its smoke, impacts, magazines and the
## hostiles' muzzle stars (one flash, one set of shells on screen).
func _gun_over(arena: CombatArena) -> void:
	var art: bool = _art_gun(arena.gun)
	if art:
		@warning_ignore("return_value_discarded")
		WeaponFxArt.muzzle(self, arena.rivet, arena.gun, stage.tick)
	GunFxArt.draw_over(self, _gun_fx, arena, stage.tick, not art)


func _art_gun(gun: GunHand) -> bool:
	if not WeaponFxArt.enabled or gun.trigger == null or gun.trigger.spec == null:
		return false
	return WeaponFxArt.art().has(gun.trigger.spec.id)


## Showcase glue: weapon-art's WeaponMagView drops this gun's own magazine (under --rigs).
func _art_mag(gun: GunHand) -> bool:
	if WeaponMagView.live <= 0 or not _art_gun(gun):
		return false
	return WeaponFxArt.art().part_texture(gun.trigger.spec.id, "mag") != null


## Lane gunplay: the table gun's presentation, made on first use, so another lane can set a hook
## on it before the first shot (human-reactions: `view.fx_view.gun_fx().shield_test = ...`).
func gun_fx() -> GunFx:
	if _gun_fx == null:
		_gun_fx = GunFx.new()
	return _gun_fx


func _plates_begin(arena: CombatArena) -> void:
	var h: HaulerStage = stage.pilot.hauler if stage.pilot != null else null
	if _plates == null or _plates.hauler != h:
		_plates = PlateSparks.make(h) if h != null else null
	if _plates != null:
		_plates.prune(arena.shots)


## The rounds in flight (n7-melee: Tonnage's plates stop an enemy round at their edge first).
func _shots(arena: CombatArena) -> void:
	_plates_begin(arena)
	for s: Shot in arena.shots:
		if _plates != null:
			var tail_m: float = ENEMY_TAIL_M if arena.gun != null else PlateSparks.DASH_M
			var at: Vector2 = _plates.edge(s, arena.rivet.pos, tail_m, stage.tick)
			if at != Vector2.INF:
				PlateSparks.tracer(self, s, at, tail_m, arena.gun != null)
				continue
		if arena.gun != null:
			if WeaponFxArt.shot(self, s, stage.tick):  # weapon-art's cells first
				continue
			if s.spec == null or not FightAreasArt.shot(self, s, stage.tick):
				GunFxArt.tracer(self, _gun_fx, s, ENEMY_TAIL_M)
			continue
		var tail: Vector2 = s.pos - s.vel.normalized() * (0.5 if s.from_rivet else 0.25)
		draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK if s.from_rivet else Ink.VERMILION, 4.0)
