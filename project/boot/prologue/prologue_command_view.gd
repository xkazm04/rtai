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
	_dress.visible = dress_shown(_bar.visible, CastCards.current(&"sergeant_mulroney") != null)
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
	var cues: Array[StringName] = sound_cues(_dress.pump, fired, _heard_shot, _heard_pump)
	if &"shotgun" in cues:
		_heard_shot = fired
	if &"shotgun_pump" in cues:
		_heard_pump = fired
	for cue: StringName in cues:
		@warning_ignore("return_value_discarded")
		_audio.cue(cue, boss.pos, _stage.tick)


## The dress stands in only while the bar shows and no Mulroney card is drawing him.
static func dress_shown(bar_visible: bool, has_card: bool) -> bool:
	return bar_visible and not has_card


## One report per discharge, one rack per stroke once the slide is past half way.
## A negative pump means no cycle is running.
static func sound_cues(
	pump: float, fired: int, heard_shot: int, heard_pump: int
) -> Array[StringName]:
	var cues: Array[StringName] = []
	if pump < 0.0:
		return cues
	if heard_shot != fired:
		cues.append(&"shotgun")
	if pump >= 0.5 and heard_pump != fired:
		cues.append(&"shotgun_pump")
	return cues


func _draw() -> void:
	var line: PrologueFormation = _battle.formation
	for h: Fighter in line.members:
		if not h.alive():
			continue
		var at: Vector2 = h.pos * PP
		draw_set_transform(at, h.facing.angle())
		if h in line.shields:
			var braced: bool = line.braced(h)
			var pose: Transform2D = shield_pose(at, h.facing, braced)
			var size_m: Vector2 = shield_size_m(braced, ViewMode.shared().ground_k())
			draw_set_transform(pose.origin, pose.get_rotation())
			draw_texture_rect(
				SHIELD, Rect2(-size_m * 0.5 * PP, size_m * PP), false, Color("afc7df")
			)
		elif h != line.boss:
			draw_texture_rect(RIFLE, rifle_rect(), false)
	draw_set_transform(Vector2.ZERO)
	if line.boss != null and line.boss.alive():
		_marker(line.boss)


func _marker(boss: Fighter) -> void:
	var ordering: bool = _battle.due_tick >= 0
	var open: bool = _stage.tick < _battle.exposed_until
	var kind: StringName = marker_kind(ordering, open, _dress.pump >= 0.0)
	if kind == &"none":
		return
	var zoom_x: float = get_global_transform_with_canvas().x.length()
	var k: float = marker_scale(zoom_x)
	var neck: Vector2 = neck_of(boss.pos)
	var at: Vector2 = disc_center(neck, k)
	var stem: PackedVector2Array = stem_ends(neck)
	draw_line(stem[0], stem[1], Ink.INK, 4, true)
	draw_line(stem[0], stem[1], Ink.CREAM, 1.5, true)
	draw_set_transform(at, 0.0, Vector2.ONE * k)
	draw_circle(Vector2.ZERO, MARK_RADIUS, Ink.INK, true, -1, true)
	if kind == &"pump":
		_pump_marker()
	elif kind == &"order":
		_order_marker()
	else:
		for side: int in [-1, 1]:
			var arms: PackedVector2Array = chevron(side)
			draw_line(arms[0], arms[1], Ink.CREAM, 2.4, true)
			draw_line(arms[1], arms[2], Ink.CREAM, 2.4, true)
		draw_circle(Vector2.ZERO, 3.2, Ink.CREAM, true, -1, true)
	draw_set_transform(Vector2.ZERO)
	_name_plate(plate_edge(at, k))


## Keep the original close-up and hold the play-camera disc at least 1.6 metres across.
static func marker_scale(zoom_x: float) -> float:
	return maxf(1.0, PLAY_DIAMETER / (2.0 * MARK_RADIUS * zoom_x))


## Ordering beats pumping; an open window alone shows the chevrons.
static func marker_kind(ordering: bool, open: bool, pumping: bool) -> StringName:
	if ordering:
		return &"order"
	if pumping:
		return &"pump"
	return &"open" if open else &"none"


## The marker hangs over the commander's neck, its tail pointing down at him.
static func neck_of(boss_pos: Vector2) -> Vector2:
	return boss_pos * PP + Vector2.UP * 2.1 * PP


## A scaled disc grows upward, so its bottom edge stays where the close-up disc ended.
static func disc_center(neck: Vector2, k: float) -> Vector2:
	return neck + Vector2.UP * MARK_RADIUS * (k - 1.0)


## An open window shows two chevrons pointing outward, one each side of the centre dot.
static func chevron(side: int) -> PackedVector2Array:
	var tip: Vector2 = Vector2.RIGHT * side * 12
	return [tip + Vector2(-side * 3, -7), tip, tip + Vector2(-side * 3, 7)]


## The name plate hangs off the right rim of the (scaled) disc.
static func plate_edge(at: Vector2, k: float) -> Vector2:
	return at + Vector2.RIGHT * MARK_RADIUS * k


static func stem_ends(neck: Vector2) -> PackedVector2Array:
	return [neck + Vector2.DOWN * 15, neck + Vector2.DOWN * 27]


## Shield offset in front of a braced holder; lowered, it hangs at the holder's side.
static func shield_pose(at: Vector2, facing: Vector2, braced: bool) -> Transform2D:
	if braced:
		return Transform2D(facing.x * 0.25, at + facing * 0.42 * PP)
	return Transform2D(facing.x * 0.6, at + facing.orthogonal() * 0.38 * PP)


static func shield_size_m(braced: bool, ground_k: float) -> Vector2:
	var size_m: Vector2 = Vector2(0.84, 1.05 / ground_k)
	return size_m if braced else size_m * Vector2(0.42, 0.76)


## The slung rifle, centred on the holder's facing axis and a metre long.
static func rifle_rect() -> Rect2:
	return Rect2(0, -0.13 * PP, 1.0 * PP, 0.26 * PP)


## Fraction of the order's wait gone, counting the issuing tick; full from the due tick on.
static func order_progress(tick: int, issued: int, due: int) -> float:
	return minf(float(tick - issued + 1) / (due - issued), 1.0)


## A clock arc starts at twelve o'clock and sweeps clockwise by `fraction` of a turn.
static func arc_angle(fraction: float) -> float:
	return -PI / 2 + TAU * fraction


func _order_marker() -> void:
	var issued: int = _battle.orders.back()["tick"]
	var progress: float = order_progress(_stage.tick, issued, _battle.due_tick)
	draw_arc(Vector2.ZERO, 14, 0, TAU, 48, Color("#735955"), 3, true)
	draw_arc(Vector2.ZERO, 14, arc_angle(0.0), arc_angle(progress), 48, Ink.VERMILION, 4, true)
	draw_line(Vector2.UP * 8, Vector2.DOWN, Ink.CREAM, 4, true)
	draw_circle(Vector2.DOWN * 6, 2.4, Ink.CREAM, true, -1, true)


func _name_plate(edge: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var name_text: String = tr("Mulroney")
	var size_px: Vector2 = font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
	var box: Rect2 = plate_rect(edge, size_px.x)
	draw_rect(box, Ink.INK)
	draw_string(
		font, box.position + Vector2(6, 16), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Ink.CREAM
	)


static func plate_rect(edge: Vector2, text_width: float) -> Rect2:
	return Rect2(edge + Vector2(-1, -10), Vector2(text_width + 12, 21))


## The slide sits forward at pull 0 and rides back to the rear of the rail at pull 1.
static func slide_rect(pump: float) -> Rect2:
	return Rect2(lerpf(4, -11, PrologueCommanderDress.rack_travel(pump)), -3, 7, 8)


## The ring left to run drains as the cycle completes.
static func arc_end(pump: float) -> float:
	return arc_angle(1.0 - pump)


## The cream slide racks back then forward during the opening between blasts.
func _pump_marker() -> void:
	draw_line(Vector2(-11, -2), Vector2(11, -2), Ink.CREAM, 2, true)
	var slide: Rect2 = slide_rect(_dress.pump)
	draw_rect(slide, Ink.CREAM)
	draw_line(slide.position + Vector2(3, 2), slide.position + Vector2(3, 6), Ink.INK, 1.5)
	draw_arc(Vector2.ZERO, 14, arc_angle(0.0), arc_end(_dress.pump), 48, Ink.CREAM, 2, true)
