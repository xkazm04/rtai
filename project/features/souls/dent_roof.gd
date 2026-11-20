class_name DentRoof
extends RefCounted
## The rotation-set cells pivot at ground centre. Lift the mark through the same camera as the hood.

const INK: Color = Color("#182628")
const YELLOW: Color = Color("#F3C442")
const STEEL: Color = Color("#B6C9C7")
const SLOT: Color = Color("#435658")


static func centre(ground_m: Vector2, ppm: float, vm: ViewMode, height_m: float) -> Vector2:
	var lift: Vector2 = vm.lift_px(height_m) if vm.cards else Vector2.ZERO
	return ground_m * ppm + lift * (ppm / SimConst.PX_PER_M)


static func disc(canvas: DentStrapCanvas, c: Vector2, yaw: float, ppm: float, soul: Color) -> void:
	var alpha: float = soul.a
	var look: DentLook = DentLook.shipped()
	var r: float = look.disc_m * ppm * 0.5
	var rim: float = look.strap_edge_m * ppm
	canvas.circle(c, r + rim * 2.0, Color(soul, look.disc_rim_alpha * alpha))
	canvas.circle(c, r + rim, Color(INK, alpha))
	canvas.circle(c, r, Color(INK, alpha))
	for half: int in 2:
		var quarter: PackedVector2Array = [c]
		for i: int in 13:
			var a: float = yaw + PI * half + (PI * 0.5 * i / 12.0)
			@warning_ignore("return_value_discarded")
			quarter.append(c + Vector2.from_angle(a) * r)
		canvas.polygon(quarter, Color(YELLOW, alpha))


static func buckle(
	canvas: DentStrapCanvas, c: Vector2, yaw: float, ppm: float, alpha: float
) -> void:
	var look: DentLook = DentLook.shipped()
	var size: Vector2 = Vector2.ONE * look.buckle_m * ppm
	var edge: float = look.strap_edge_m * ppm
	var plate: Rect2 = Rect2(-size * 0.5, size)
	canvas.pose(c, yaw)
	canvas.rect(plate.grow(edge), Color(INK, alpha))
	canvas.rect(plate, Color(STEEL, alpha))
	canvas.rect(plate.grow(-edge), Color(SLOT, alpha))
	canvas.line(
		Vector2(-0.34, -0.23) * size, Vector2(0.34, -0.23) * size, Color(Color.WHITE, alpha), edge
	)
	canvas.pose(Vector2.ZERO, 0.0)
