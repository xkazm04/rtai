class_name GhostBondRing
extends Node2D
## Inside the portrait rim, leaving the outer deploy cooldown and number key visible.

const TOP: float = -PI * 0.5
const READY_GAP: float = PI / 12.0
const TEAL: Color = Color("#55e3ce")
const TRACK: Color = Color("#64877f")
const INK: Color = Color("#172525")
const STROKE: float = 2.3

var hud: GhostFormHud
var bond: GhostBond


static func mount(strip: GhostFormHud, progress: GhostBond) -> GhostBondRing:
	var ring: GhostBondRing = GhostBondRing.new()
	ring.hud = strip
	ring.bond = progress
	strip.add_child(ring)
	@warning_ignore("return_value_discarded")
	strip.draw.connect(ring.queue_redraw)
	return ring


static func fill_fraction(progress: GhostBond, id: StringName) -> float:
	if not progress.enabled or progress.master_at <= 0.0:
		return 0.0
	return clampf(progress.value(id) / progress.master_at, 0.0, 1.0)


## At threshold a diamond occupies the open crown until the player takes the card.
func angles(id: StringName) -> Vector2:
	if bond.ready(id):
		return Vector2(TOP + READY_GAP, TOP + TAU - READY_GAP)
	return Vector2(TOP, TOP + TAU * fill_fraction(bond, id))


func _draw() -> void:
	if not bond.enabled:
		return
	var layout: GhostFormLayout = hud.layout
	var shown: Array[StringName] = hud.shown_chips()
	for i: int in shown.size():
		var id: StringName = shown[i]
		if not hud.locked.get(id, true):
			var center: Vector2 = layout.chip_center(hud.get_viewport_rect().size.y, i)
			_chip(id, center, layout.chip_r - 3.5)


func _chip(id: StringName, center: Vector2, radius: float) -> void:
	draw_arc(center, radius, TOP, TOP + TAU, 65, INK, STROKE + 2.0, true)
	draw_arc(center, radius, TOP, TOP + TAU, 65, TRACK, 1.0, true)
	var span: Vector2 = angles(id)
	if span.y <= span.x:
		return
	draw_arc(center, radius, span.x, span.y, 65, TEAL, STROKE, true)
	if bond.ready(id):
		var crown: Vector2 = center + Vector2.UP * radius
		var diamond: PackedVector2Array = [
			crown + Vector2.UP * 5.0,
			crown + Vector2.RIGHT * 4.0,
			crown + Vector2.DOWN * 5.0,
			crown + Vector2.LEFT * 4.0
		]
		draw_colored_polygon(diamond, TEAL)
		draw_circle(crown, 1.5, INK, true, -1.0, true)
