class_name GauntletFloor
extends ArenaFloorView
## Street paint under the arena's solid props. Only a change in the retained blocks invalidates
## the floor between view-mode changes. The camera and actors use the same metre coordinates.

var street: GauntletStreet
var _previous_solid: Callable


func _ready() -> void:
	super._ready()
	_previous_solid = StreetDeadPlan.solid
	StreetDeadPlan.solid = street.pose_solid_px
	@warning_ignore("return_value_discarded")
	street.window_changed.connect(_window_changed)


func _exit_tree() -> void:
	if street != null and StreetDeadPlan.solid == street.pose_solid_px:
		StreetDeadPlan.solid = _previous_solid


func _window_changed() -> void:
	if _static != null:
		_static.queue_redraw()


func _ground(ci: CanvasItem, _arena: ArenaStage) -> void:
	var first: GauntletSegment = street.window[0]
	if is_zero_approx(first.start_x):
		# Beyond the street's closed west gate, the city still fills the camera at spawn.
		ci.draw_set_transform(Ink.px(Vector2(-first.length_m, 0.0)))
		GauntletFrontage.draw(ci, first)
		ci.draw_set_transform(Vector2.ZERO)
		var road: Rect2 = first.road_bounds(0.0)
		var gate: Rect2 = Rect2(-1.0, road.position.y, 1.0, road.size.y)
		ArenaFloorStatic.barrier(ci, GauntletFrontage.px(gate))
	for block: GauntletSegment in street.window:
		GauntletFrontage.draw(ci, block)
		GauntletLandmarks.ground(ci, block)
	for block: GauntletSegment in street.window:
		GauntletLandmarks.furniture(ci, block)
