class_name ShotDraw
extends RefCounted
## Each FX view owns a colour canvas for hostile ammunition. Its normal item print maps
## deep amber back to vermilion. Clear this canvas whenever its parent redraws, including
## the first frame after Rivet puts the gun away.

const LAYER: StringName = &"_enemy_round_canvas"

var _rid: RID


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _rid.is_valid():
		RenderingServer.free_rid(_rid)


static func core(s: Shot) -> Color:
	return Ink.CREAM if s.from_rivet else enemy_ink(s.size if s.size_known else Shot.SMALL, false)


static func rim(s: Shot) -> Color:
	return Ink.INK if s.from_rivet else enemy_ink(s.size if s.size_known else Shot.SMALL, true)


static func enemy_ink(size: StringName, casing: bool) -> Color:
	if size == Shot.LARGE:
		return EnemyRoundLook.LARGE_RIM if casing else EnemyRoundLook.LARGE_CORE
	return EnemyRoundLook.SMALL_RIM if casing else EnemyRoundLook.SMALL_CORE


static func _canvas(ci: CanvasItem) -> RID:
	if ci.has_meta(LAYER):
		var existing: ShotDraw = ci.get_meta(LAYER)
		return existing._rid
	var layer: ShotDraw = ShotDraw.new()
	layer._rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(layer._rid, ci.get_canvas_item())
	ci.set_meta(LAYER, layer)
	@warning_ignore("return_value_discarded")
	ci.draw.connect(RenderingServer.canvas_item_clear.bind(layer._rid))
	return layer._rid


static func tracer(ci: CanvasItem, s: Shot, tail: Vector2, head: Vector2, widths: Vector2) -> void:
	if s.from_rivet:
		ci.draw_line(Ink.px(tail), Ink.px(head), Ink.INK, widths.x)
		ci.draw_line(Ink.px(tail.lerp(head, 0.3)), Ink.px(head), Ink.CREAM, widths.y)
		ci.draw_circle(Ink.px(head), widths.y + 1.0, Ink.CREAM)
		return
	var rid: RID = _canvas(ci)
	var fill: Color = core(s)
	RenderingServer.canvas_item_add_line(rid, Ink.px(tail), Ink.px(head), rim(s), widths.x)
	RenderingServer.canvas_item_add_line(
		rid, Ink.px(tail.lerp(head, 0.3)), Ink.px(head), fill, widths.y
	)
	RenderingServer.canvas_item_add_circle(rid, Ink.px(head), widths.y + 1.0, fill)


## Narrow flashes can snap to a degenerate polygon.
static func flash(
	ci: CanvasItem, pts: PackedVector2Array, width: float, hostile: bool = false
) -> void:
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.append(pts[0])
	if not hostile:
		ci.draw_colored_polygon(pts, Ink.CREAM)
		ci.draw_polyline(ring, Ink.INK, width, true)
		return
	var rid: RID = _canvas(ci)
	RenderingServer.canvas_item_add_polygon(rid, pts, PackedColorArray([EnemyRoundLook.MUZZLE]))
	RenderingServer.canvas_item_add_polyline(rid, ring, PackedColorArray([Ink.INK]), width, true)
