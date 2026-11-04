extends "res://dev/ghost-forms/forms_lineup_run.gd"
## ghost-forms: the transformation from straight above, driven by the real GhostForms state machine
## and SoulPowers costs: base Rivet stands, Q (press_transform) at tick 20 morphs him into Tonnage
## (stage 0: Rivet with the burst and the seams; stage 1: the press unfolds from its in-between
## pose), Tonnage stamps forward, Q again at hold_ticks morphs back. GhostMorphFx draws the burst,
## seams, steam and sparks; its beat() punches the frame zoom. One body, centred.

const PRESS_AT: int = 20

var hold_ticks: int = 150
var reduced_motion: bool = false
var _forms: GhostForms = null
var _fx: GhostMorphFx = GhostMorphFx.new()
var _t: int = 0
var _z: float = 1.0
var _y_m: float = 0.0
var _hud: GhostFormHud = GhostFormHud.new()


func _ready() -> void:
	super._ready()
	_forms = GhostForms.new(
		GhostFormTable.load_default(), SoulPowers.new(PowerTable.load_default())
	)
	_tonnage.position = Vector2.ZERO
	_tonnage.visible = false
	_fx.reduced_motion = reduced_motion
	_fx.reach_m = 2.4
	_actors.add_child(_fx)
	var hud_layer: CanvasLayer = CanvasLayer.new()
	hud_layer.layer = 3
	add_child(hud_layer)
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(_hud)
	for id: StringName in _forms.table.order:
		var key: String = _forms.table.form(id).name_key
		var word: String = tr(key)
		_hud.names[id] = word if word != key else String(id).capitalize()


func _tick() -> void:
	_t += 1
	if _t == PRESS_AT or _t == PRESS_AT + hold_ticks:
		Log.info(&"ghost-forms", "Q at %d: %s" % [_t, _forms.press_transform()])
	_forms.powers.tick()
	_forms.tick()
	_hud.sync(_forms)
	var in_form: bool = _forms.current() == &"tonnage"
	var moving: bool = walk and (in_form or _forms.settled())
	_y_m -= (2.2 if in_form else 1.4) * SimClock.TICK_DT if moving else 0.0
	_show(moving)
	_rigs.step_ticks(1)
	_tonnage.speed_mps = 2.2 if moving and in_form else 0.0
	_tonnage.advance(SimClock.TICK_DT)
	_frame(_z)
	await get_tree().process_frame


## Who is on screen this tick: Rivet, Tonnage (unfolding), and the effects.
func _show(moving: bool) -> void:
	var busy: bool = not _forms.settled()
	var k: float = _forms.k()
	var stage: int = _forms.stage()
	var entering: bool = _forms.phase == GhostForms.ENTERING
	var big: bool = _forms.current() == &"tonnage" or (busy and (stage == 1) == entering)
	_tonnage.visible = big
	_tonnage.unfold = 1.0 if not busy else (k - 0.5) * 2.0 if entering else 1.0 - k * 2.0
	_tonnage.position = Vector2(0.0, _y_m) * PX
	_fx.position = _tonnage.position
	_fx.show_progress(busy, k, stage, _forms.phase == GhostForms.SWITCHING)
	_z = _fx.beat()
	var f: RigFeed = _rigs.feed
	f.count = 0 if big else 1
	f.pos[0] = _tonnage.position
	f.clip[0] = RigClips.Clip.NONE
	f.face[0] = -PI * 0.5
	f.flags[0] = 0
	f.vel[0] = Vector2(0.0, -1.4 * PX) if moving and not big else Vector2.ZERO
	_rigs.focus = _tonnage.position


func _frame(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var focus: Vector2 = Vector2(0.0, _y_m * PX) * z * _zoom_base
	var xf: Transform2D = Transform2D(0.0, Vector2.ONE * z * _zoom_base, 0.0, view * 0.5 - focus)
	_world.transform = xf
	_actors.transform = xf
	_rigs.zoom = z * _zoom_base
	_look.set_shader_parameter("world_px", -(view * 0.5 - focus))


func _crop(_z_unused: float) -> Rect2i:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var half: Vector2 = Vector2(4.0, 3.0) * PX * _zoom_base
	return Rect2i(Vector2i(view * 0.5 - half), Vector2i(half * 2.0))
