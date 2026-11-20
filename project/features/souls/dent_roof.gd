class_name DentRoof
extends RefCounted
## The rotation-set cells pivot at ground centre. Lift the mark through the same camera as the hood.

const INK: Color = Color("#182628")
const YELLOW: Color = Color("#F3C442")
const STEEL: Color = Color("#B6C9C7")
const SLOT: Color = Color("#435658")


static func centre(ground_m: Vector2, ppm: float, vm: ViewMode) -> Vector2:
	var lift: Vector2 = vm.lift_px(VehicleView.CAR_H_M) if vm.cards else Vector2.ZERO
	return ground_m * ppm + lift * (ppm / SimConst.PX_PER_M)


static func disc(canvas: CanvasItem, c: Vector2, yaw: float, ppm: float, alpha: float) -> void:
	var look: DentLook = DentLook.shipped()
	var r: float = look.disc_m * ppm * 0.5
	var rim: float = look.strap_edge_m * ppm
	canvas.draw_circle(
		c, r + rim * 2.0, Color(HaulerLook.TEAL, look.disc_rim_alpha * alpha), true, -1.0, true
	)
	canvas.draw_circle(c, r + rim, Color(INK, alpha), true, -1.0, true)
	canvas.draw_circle(c, r, Color(INK, alpha))
	for half: int in 2:
		var quarter: PackedVector2Array = [c]
		for i: int in 13:
			var a: float = yaw + PI * half + (PI * 0.5 * i / 12.0)
			@warning_ignore("return_value_discarded")
			quarter.append(c + Vector2.from_angle(a) * r)
		canvas.draw_colored_polygon(quarter, Color(YELLOW, alpha))


static func buckle(canvas: CanvasItem, c: Vector2, yaw: float, ppm: float, alpha: float) -> void:
	var look: DentLook = DentLook.shipped()
	var size: Vector2 = Vector2.ONE * look.buckle_m * ppm
	var edge: float = look.strap_edge_m * ppm
	var plate: Rect2 = Rect2(-size * 0.5, size)
	canvas.draw_set_transform(c, yaw)
	canvas.draw_rect(plate.grow(edge), Color(INK, alpha))
	canvas.draw_rect(plate, Color(STEEL, alpha))
	canvas.draw_rect(plate.grow(-edge), Color(SLOT, alpha))
	canvas.draw_line(
		Vector2(-0.34, -0.23) * size, Vector2(0.34, -0.23) * size, Color(Color.WHITE, alpha), edge
	)
	canvas.draw_set_transform(Vector2.ZERO)
