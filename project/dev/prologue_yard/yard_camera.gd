class_name YardCamera
extends RefCounted


static func center(plan: PrologueYard, location: String, film_tick: int = -1) -> Vector2:
	if location == "mid":
		if film_tick >= 0:
			return Vector2(35.21, 19.93) if film_tick < 3900 else Vector2(45.72, 17.55)
		return plan.rivet_start
	if location == "gate":
		return plan.gate
	var east: float = plan.street.end.x
	var x: float = (plan.gate.x + east) * 0.5 if film_tick >= 0 else east
	return Vector2(x, plan.street.get_center().y)


static func hide_hud(view: PrologueView) -> void:
	for layer: CanvasLayer in view.find_children("*", "CanvasLayer", false, false):
		if layer.layer == RenderLayers.canvas(&"hud"):
			layer.hide()


static func place(view: PrologueView, at: Vector2, ppm: int) -> void:
	view.px_per_m = float(ppm)
	view.print_stage.zoom = float(ppm) / SimConst.PX_PER_M
	view.print_stage.place(at)
	view.print_stage.camera.force_update_scroll()
