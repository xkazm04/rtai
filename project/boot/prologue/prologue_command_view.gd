class_name PrologueCommandView
extends Node2D
## Equipment and the commander's order tell at gameplay scale. BossBar reads the same
## human fighter as the combat arena, including its checkpoint replacement.

const RIFLE: Texture2D = preload("res://features/combat/weapons/art/assault_rifle/held.png")
const SHIELD: Texture2D = preload("res://features/characters/art/view/p70/riot_shield_card.png")
const PP: float = SimConst.PX_PER_M

var _battle: PrologueBattle
var _stage: ArenaStage
var _bar: BossBar
var _meter: BossFight


func attach(view: PrologueView, stage: ArenaStage) -> void:
	_stage = stage
	_battle = view.encounter.battle
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


func _process(_dt: float) -> void:
	var boss: Fighter = _battle.formation.boss
	_bar.visible = boss != null and boss.alive()
	if _bar.visible:
		_meter.body = boss
		_meter.state = BossFight.State.IDLE if boss.exposed else BossFight.State.TRANSITION
		_bar.fight = _meter
	queue_redraw()


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
			draw_texture_rect(
				SHIELD, Rect2(-size_m * 0.5 * PP, size_m * PP), false, Color("afc7df")
			)
		else:
			draw_texture_rect(RIFLE, Rect2(0, -0.13 * PP, 1.0 * PP, 0.26 * PP), false)
	draw_set_transform(Vector2.ZERO)
	if line.boss != null and line.boss.alive():
		_marker(line.boss)


func _marker(boss: Fighter) -> void:
	var at: Vector2 = boss.pos * PP
	var radius: float = 0.91 * PP
	if _battle.due_tick >= 0:
		var issued: int = _battle.orders.back()["tick"]
		var since: int = _stage.tick - issued
		var span: int = since + _battle.due_tick - _stage.tick
		var progress: float = float(since + 1) / maxi(span, 1)
		draw_arc(at, radius, 0, TAU, 48, Ink.INK, 0.16 * PP, true)
		draw_arc(at, radius, -PI / 2, -PI / 2 + TAU * progress, 48, Ink.VERMILION, 0.10 * PP, true)
		var above: Vector2 = at + Vector2.UP * 1.60 * PP
		draw_circle(above, 0.48 * PP, Ink.INK, true, -1, true)
		draw_circle(above, 0.39 * PP, Ink.VERMILION, true, -1, true)
		draw_line(
			above - Vector2.DOWN * 0.24 * PP,
			above + Vector2.DOWN * 0.06 * PP,
			Ink.CREAM,
			0.10 * PP,
			true
		)
		draw_circle(above + Vector2.DOWN * 0.20 * PP, 0.06 * PP, Ink.CREAM)
	elif boss.exposed:
		for i: int in 4:
			draw_arc(at, radius, i * PI / 2, i * PI / 2 + 0.6, 8, Ink.CREAM, 0.07 * PP, true)
