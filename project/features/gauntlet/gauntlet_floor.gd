class_name GauntletFloor
extends ArenaFloorView
## Street paint under the arena's solid props. Only a change in the retained blocks invalidates
## the floor between view-mode changes. The camera and actors use the same metre coordinates.

var street: GauntletStreet


func _ready() -> void:
	super._ready()
	@warning_ignore("return_value_discarded")
	street.window_changed.connect(_window_changed)


func _window_changed() -> void:
	if _static != null:
		_static.queue_redraw()


func _ground(ci: CanvasItem, arena: ArenaStage) -> void:
	for block: GauntletSegment in street.window:
		var road: Rect2 = Rect2(Ink.px(block.bounds.position), Ink.px(block.bounds.size))
		ci.draw_rect(road, Ink.CREAM.darkened(0.28))
		for x: int in range(2, int(block.length_m), 5):
			var at: Vector2 = Vector2(block.start_x + x, 0.0)
			var dash: Rect2 = Rect2(at - Vector2(0, 0.07), Vector2(2.0, 0.14))
			if not block.crossing.intersects(dash):
				ci.draw_rect(Rect2(Ink.px(dash.position), Ink.px(dash.size)), Ink.CREAM)
		_crossing(ci, block.crossing)
	_props(ci, arena)


func _crossing(ci: CanvasItem, paint: Rect2) -> void:
	var y: float = paint.position.y
	while y < paint.end.y:
		var stripe: Vector2 = Vector2(paint.size.x, minf(0.5, paint.end.y - y))
		ci.draw_rect(Rect2(Ink.px(Vector2(paint.position.x, y)), Ink.px(stripe)), Ink.CREAM)
		y += 1.0
