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
	var bar: float = progress.master_at_for(id)
	if not progress.enabled or bar <= 0.0:
		return 0.0
	return clampf(progress.value(id) / bar, 0.0, 1.0)


## At threshold a diamond occupies the open crown until the player takes the card.
func angles(id: StringName) -> Vector2:
	if bond.ready(id):
		return Vector2(TOP + READY_GAP, TOP + TAU - READY_GAP)
	return Vector2(TOP, TOP + TAU * fill_fraction(bond, id))


## The ring's whole drawing as data: one dictionary per call, in draw order, kind arc | poly | dot.
## _draw replays it, so a test sees what is drawn without a renderer.
func plan(view_height: float) -> Array[Dictionary]:
	var cmds: Array[Dictionary] = []
	if not bond.enabled:
		return cmds
	var layout: GhostFormLayout = hud.layout
	var shown: Array[StringName] = hud.shown_chips()
	for i: int in shown.size():
		var id: StringName = shown[i]
		if not hud.locked.get(id, true):
			var center: Vector2 = layout.chip_center(view_height, i)
			cmds.append_array(chip_plan(id, center, layout.chip_r - 3.5))
	return cmds


func chip_plan(id: StringName, center: Vector2, radius: float) -> Array[Dictionary]:
	var cmds: Array[Dictionary] = [
		_arc(center, radius, Vector2(TOP, TOP + TAU), INK, STROKE + 2.0),
		_arc(center, radius, Vector2(TOP, TOP + TAU), TRACK, 1.0)
	]
	var span: Vector2 = angles(id)
	if span.y <= span.x:
		return cmds
	cmds.append(_arc(center, radius, span, TEAL, STROKE))
	if bond.ready(id):
		var crown: Vector2 = center + Vector2.UP * radius
		(
			cmds
			. append(
				{
					&"kind": &"poly",
					&"points":
					PackedVector2Array(
						[
							crown + Vector2.UP * 5.0,
							crown + Vector2.RIGHT * 4.0,
							crown + Vector2.DOWN * 5.0,
							crown + Vector2.LEFT * 4.0
						]
					),
					&"color": TEAL,
				}
			)
		)
		cmds.append({&"kind": &"dot", &"center": crown, &"radius": 1.5, &"color": INK})
	return cmds


func _draw() -> void:
	for cmd: Dictionary in plan(hud.get_viewport_rect().size.y):
		_replay(cmd)


func _replay(cmd: Dictionary) -> void:
	var color: Color = cmd[&"color"]
	match cmd[&"kind"]:
		&"arc":
			var center: Vector2 = cmd[&"center"]
			var radius: float = cmd[&"radius"]
			var from: float = cmd[&"from"]
			var to: float = cmd[&"to"]
			var width: float = cmd[&"width"]
			draw_arc(center, radius, from, to, 65, color, width, true)
		&"poly":
			var points: PackedVector2Array = cmd[&"points"]
			draw_colored_polygon(points, color)
		&"dot":
			var dot: Vector2 = cmd[&"center"]
			var dot_r: float = cmd[&"radius"]
			draw_circle(dot, dot_r, color, true, -1.0, true)


static func _arc(
	center: Vector2, radius: float, span: Vector2, color: Color, width: float
) -> Dictionary:
	return {
		&"kind": &"arc",
		&"center": center,
		&"radius": radius,
		&"from": span.x,
		&"to": span.y,
		&"color": color,
		&"width": width,
	}
