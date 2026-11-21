class_name GauntletView
extends CollectCallView
## CombatBlood asks for the victim's position on actor_killed, before CombatArena announces
## kill_landed and the street settles the fighter. Use the same free spot for both deposits.

var _street: GauntletStreet


func _init(street: GauntletStreet) -> void:
	_street = street
	var floor_view: GauntletFloor = GauntletFloor.new()
	floor_view.street = street
	stage_view.free()
	stage_view = floor_view


func _ready() -> void:
	super._ready()
	if blood != null:
		# The quest's pool hook reads the victim again before the fighter is moved.
		# With no second lookup, both human blood and machine oil use _locate's free point.
		blood.pool_at = Callable()
		# A wall smear spreads around its contact. Reserve the same road-side margin as a pose.
		blood.solid = _street.pose_solid_px
		if blood.oil != null:
			blood.oil.solid = _street.pose_solid_px


## The shipped ghost strip draws the selected cost in teal even with all ghosts locked.
## Keep its portraits, cost and timing while rendering the separate gauge notch in ink.
func style_ghost_meter(hud: GhostFormHud) -> void:
	var ink: ShaderMaterial = ShaderMaterial.new()
	ink.shader = preload("res://features/gauntlet/gauntlet_meter.gdshader")
	var layout: GhostFormLayout = hud.layout
	ink.set_shader_parameter(&"meter_band_px", layout.margin + layout.card_h - layout.bar_y + 6.0)
	hud.material = ink


## Inspection uses the actor canvas so the print pass cannot erase the thin white outlines.
func show_solid_bounds() -> void:
	var overlay: Node2D = Node2D.new()
	overlay.z_index = 4095
	print_stage.actor_layer().add_child(overlay)
	@warning_ignore("return_value_discarded")
	overlay.draw.connect(_draw_solids.bind(overlay))
	@warning_ignore("return_value_discarded")
	_street.window_changed.connect(overlay.queue_redraw)


func _draw_solids(overlay: Node2D) -> void:
	for box: Rect2 in (_stage as ArenaStage).walls.boxes:
		var rect: Rect2 = Rect2(box.position * SimConst.PX_PER_M, box.size * SimConst.PX_PER_M)
		overlay.draw_rect(rect, Ink.INK, false, 4.0)
		overlay.draw_rect(rect, Color.WHITE, false, 2.0)


func _locate(id: int) -> Vector2:
	var arena: CombatArena = _stage.arena
	if id != arena.rivet.id:
		for foe: Fighter in arena.hostiles:
			if foe.id == id:
				return _street.rest.body_position(foe)
	return super._locate(id)
