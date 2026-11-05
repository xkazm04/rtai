class_name BossView
extends Node2D
## A boss's body on screen. The base draws a plain ink disc with a facing tick (a boss with no
## art yet); a boss's own look lives in `features/bosses/<id>/<id>_body_view.gd` (extends
## BossView, found by that path), drawn in the print with the cast. attach() lays the three boss
## views on the arena's CollectCallView: the telegraph under the actors, the body with them,
## the bar on the HUD layer. Render only (SIM-03): every view reads the fight each frame.

var fight: BossFight = null
var adds: BossAdds = null


static func attach(view: Node, hook: BossHook) -> void:
	var v: CollectCallView = view as CollectCallView
	if v == null:
		return
	var tell: BossTellView = BossTellView.new()
	tell.fight = hook.fight
	tell.adds = hook.adds
	var body: BossView = make(hook.fight.spec.id)
	body.fight = hook.fight
	body.adds = hook.adds
	if v.print_stage != null:  # on the actors' layer like the cast rigs: true colours, no ink snap
		tell.z_index = RenderLayers.z(&"actors") - 1
		tell.scale = v.cast_view.scale
		v.print_stage.actor_layer().add_child(tell)
		body.z_index = RenderLayers.z(&"actors")
		body.scale = v.cast_view.scale
		v.print_stage.actor_layer().add_child(body)
	else:
		v.add_child(tell)
		v.add_child(body)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	v.add_child(layer)
	var bar: BossBar = BossBar.new()
	bar.fight = hook.fight
	layer.add_child(bar)


## The boss's own body view, or the base disc.
static func make(boss_id: StringName) -> BossView:
	var path: String = "res://features/bosses/%s/%s_body_view.gd" % [boss_id, boss_id]
	if ResourceLoader.exists(path):
		var scr: GDScript = load(path) as GDScript
		var obj: Variant = scr.new() if scr != null and scr.can_instantiate() else null
		if obj is BossView:
			return obj
		Log.warn("bosses", "%s does not extend BossView" % path)
	return BossView.new()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if fight == null:
		return
	var at: Vector2 = Ink.px(fight.body.pos)
	var r: float = fight.body.radius_m * Ink.PX_PER_M
	draw_circle(at, r, Ink.INK)
	draw_line(at, at + fight.body.facing * r * 1.3, Ink.CREAM, 4.0)
	for f: BossFight in standing_adds():
		draw_circle(Ink.px(f.body.pos), f.body.radius_m * Ink.PX_PER_M, Ink.INK)


## The adds still up (a downed add leaves the floor in this first pass).
func standing_adds() -> Array[BossFight]:
	var out: Array[BossFight] = []
	if adds != null:
		for f: BossFight in adds.fights:
			if f.state != BossFight.State.DEFEATED:
				out.append(f)
	return out
