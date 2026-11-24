class_name PrologueCommandView
extends Node2D
## Equipment and the commander's order tell at gameplay scale. BossBar reads the same
## human fighter as the combat arena, including its checkpoint replacement.

const RIFLE: Texture2D = preload("res://features/combat/weapons/art/assault_rifle/held.png")
const SHIELD: Texture2D = preload("res://features/characters/art/view/p70/riot_shield_card.png")
const PP: float = SimConst.PX_PER_M
const MARK_RADIUS: float = 17.0
const PLAY_DIAMETER: float = 52.0

var _battle: PrologueBattle
var _stage: ArenaStage
var _pose: Callable
var _dress: PrologueCommanderDress = PrologueCommanderDress.new()
var _audio: AudioService
var _heard_shot: int = -1
var _heard_pump: int = -1
var _bar: BossBar
var _meter: BossFight


func attach(view: PrologueView, stage: ArenaStage, pose: Callable, master_seed: int) -> void:
	_pose = pose
	_stage = stage
	_battle = view.encounter.battle
	_audio = AudioService.new(AudioTables.shipped(), master_seed)
	_audio.listener_fn = func() -> Vector2: return stage.arena.rivet.pos
	view.add_child(_audio)
	_meter = BossFight.new(_battle.spec, null, Vector2.ZERO)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	view.add_child(layer)
	_bar = BossBar.new()
	_bar.visible = false
	layer.add_child(_bar)
	var drops: PickupsView = PickupsView.new()
	drops.carry = stage.pilot.carry
	drops.z_index = RenderLayers.z(&"actors") + 62
	view.print_stage.actor_layer().add_child(drops)
	z_index = RenderLayers.z(&"actors") + 61
	view.print_stage.actor_layer().add_child(self)
	_dress.visible = false
	add_child(_dress)


func _process(_dt: float) -> void:
	var boss: Fighter = _battle.formation.boss
	_bar.visible = boss != null and boss.alive()
	_dress.visible = _bar.visible and CastCards.current(&"sergeant_mulroney") == null
	if _bar.visible:
		var progress: float = _battle.fire.shotgun.pump_progress(_stage.tick)
		FoeCastView.set_pump(boss, progress, progress == 0.0)
		_dress.pump = progress
		if _dress.visible:
			_pose.call(_dress, boss)
		_sound(boss)
		_meter.body = boss
		_meter.state = BossFight.State.IDLE if boss.exposed else BossFight.State.TRANSITION
		_bar.fight = _meter
	queue_redraw()


func _sound(boss: Fighter) -> void:
	if _dress.pump < 0.0:
		return
	var fired: int = _battle.fire.shotgun.shot_ticks.back()
	if _heard_shot != fired:
		_heard_shot = fired
		@warning_ignore("return_value_discarded")
		_audio.cue(&"shotgun", boss.pos, _stage.tick)
	if _dress.pump >= 0.5 and _heard_pump != fired:
		_heard_pump = fired
		@warning_ignore("return_value_discarded")
		_audio.cue(&"shotgun_pump", boss.pos, _stage.tick)


func _draw() -> void:
	var line: PrologueFormation = _battle.formation
	for h: Fighter in line.members:
		if not h.alive():
			continue
		var at: Vector2 = h.pos * PP
		draw_set_transform(at, h.facing.angle())
		if h in line.shields:
			var size_m: Vector2 = Vector2(0.84, 1.05 / ViewMode.shared().ground_k())
			draw_set_transform(at + h.facing * 0.42 * PP, h.facing.x * 0.25)
			if not line.braced(h):
				size_m *= Vector2(0.42, 0.76)
				draw_set_transform(at + h.facing.orthogonal() * 0.38 * PP, h.facing.x * 0.6)
			draw_texture_rect(
				SHIELD, Rect2(-size_m * 0.5 * PP, size_m * PP), false, Color("afc7df")
			)
		elif h != line.boss:
			draw_texture_rect(RIFLE, Rect2(0, -0.13 * PP, 1.0 * PP, 0.26 * PP), false)
	draw_set_transform(Vector2.ZERO)
	if line.boss != null and line.boss.alive():
		_marker(line.boss)


func _marker(boss: Fighter) -> void:
	var ordering: bool = _battle.due_tick >= 0
	var open: bool = _stage.tick < _battle.exposed_until
	var pumping: bool = _dress.pump >= 0.0
	if not ordering and not open and not pumping:
		return
	var zoom_x: float = get_global_transform_with_canvas().x.length()
	var k: float = marker_scale(zoom_x)
	var neck: Vector2 = boss.pos * PP + Vector2.UP * 2.1 * PP
	var at: Vector2 = neck + Vector2.UP * MARK_RADIUS * (k - 1.0)
	draw_line(neck + Vector2.DOWN * 15, neck + Vector2.DOWN * 27, Ink.INK, 4, true)
	draw_line(neck + Vector2.DOWN * 15, neck + Vector2.DOWN * 27, Ink.CREAM, 1.5, true)
	draw_set_transform(at, 0.0, Vector2.ONE * k)
	draw_circle(Vector2.ZERO, MARK_RADIUS, Ink.INK, true, -1, true)
	if pumping and not ordering:
		_pump_marker()
	elif ordering:
		_order_marker()
	else:
		for side: int in [-1, 1]:
			var tip: Vector2 = Vector2.RIGHT * side * 12
			draw_line(tip + Vector2(-side * 3, -7), tip, Ink.CREAM, 2.4, true)
			draw_line(tip, tip + Vector2(-side * 3, 7), Ink.CREAM, 2.4, true)
		draw_circle(Vector2.ZERO, 3.2, Ink.CREAM, true, -1, true)
	draw_set_transform(Vector2.ZERO)
	_name_plate(at + Vector2.RIGHT * MARK_RADIUS * k)


## Keep the original close-up and hold the play-camera disc at least 1.6 metres across.
static func marker_scale(zoom_x: float) -> float:
	return maxf(1.0, PLAY_DIAMETER / (2.0 * MARK_RADIUS * zoom_x))


func _order_marker() -> void:
	var issued: int = _battle.orders.back()["tick"]
	var progress: float = float(_stage.tick - issued + 1) / (_battle.due_tick - issued)
	draw_arc(Vector2.ZERO, 14, 0, TAU, 48, Color("#735955"), 3, true)
	draw_arc(
		Vector2.ZERO, 14, -PI / 2, -PI / 2 + TAU * minf(progress, 1.0), 48, Ink.VERMILION, 4, true
	)
	draw_line(Vector2.UP * 8, Vector2.DOWN, Ink.CREAM, 4, true)
	draw_circle(Vector2.DOWN * 6, 2.4, Ink.CREAM, true, -1, true)


func _name_plate(edge: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var name_text: String = tr("Mulroney")
	var size_px: Vector2 = font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
	var box: Rect2 = Rect2(edge + Vector2(-1, -10), Vector2(size_px.x + 12, 21))
	draw_rect(box, Ink.INK)
	draw_string(
		font, box.position + Vector2(6, 16), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Ink.CREAM
	)


## The cream slide racks back then forward during the opening between blasts.
func _pump_marker() -> void:
	var pull: float = PrologueCommanderDress.rack_travel(_dress.pump)
	draw_line(Vector2(-11, -2), Vector2(11, -2), Ink.CREAM, 2, true)
	var slide: Rect2 = Rect2(lerpf(4, -11, pull), -3, 7, 8)
	draw_rect(slide, Ink.CREAM)
	draw_line(slide.position + Vector2(3, 2), slide.position + Vector2(3, 6), Ink.INK, 1.5)
	draw_arc(Vector2.ZERO, 14, -PI / 2, -PI / 2 + TAU * (1.0 - _dress.pump), 48, Ink.CREAM, 2, true)
