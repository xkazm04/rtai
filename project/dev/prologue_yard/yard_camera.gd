class_name YardCamera
extends RefCounted


static func center(plan: PrologueYard, location: String, film_tick: int = -1) -> Vector2:
	if location == "mid":
		if film_tick >= 0:
			return Vector2(35.21, 19.93) if film_tick < 3900 else Vector2(45.72, 17.55)
		return plan.rivet_start
	if location == "gate":
		return Vector2(30, 14.2) if ViewMode.shared().id == &"tilt" else plan.gate
	if location == "front":
		return Vector2(26, 3)
	if location == "roof":
		return Vector2(14, -8)
	if location == "west":
		return Vector2(plan.yard.position.x, plan.rivet_start.y)
	var harbor: Vector2 = Vector2(plan.street.end.x, plan.street.get_center().y)
	return harbor if film_tick < 0 else Vector2((plan.gate.x + harbor.x) * 0.5, harbor.y)


static func hide_hud(view: PrologueView) -> void:
	for layer: CanvasLayer in view.find_children("*", "CanvasLayer", false, false):
		if layer.layer == RenderLayers.canvas(&"hud"):
			layer.hide()


static func place(view: PrologueView, at: Vector2, ppm: int) -> void:
	view.px_per_m = float(ppm)
	view.print_stage.zoom = float(ppm) / SimConst.PX_PER_M
	view.print_stage.place(at)
	view.print_stage.camera.force_update_scroll()
