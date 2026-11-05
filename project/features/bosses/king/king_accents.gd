class_name KingAccents
extends Node2D
## The wealth drawn over the rigs at game zoom (render only): at 32 px/m the rig prints flat
## stickers, so the gold in the part art is lost. King's jewelled gold crown sits over his head
## (on the throne and on foot); each standing gang bot wears a gold chain arc across its chest.
## Drawn after KingRigs (a later sibling), in the cast's px like KingBodyView.

const GOLD: Color = Color("#D9A933")
const GOLD_HI: Color = Color("#F6D678")
## King's head sits this far forward of the body centre on the rig (metres, at KingRigs' size).
const HEAD_FWD_M: float = 0.12
## Over every rig part (CutRig parts sit at their own z_index under the rig).
const OVER_RIG_Z: int = 40

var view: KingBodyView = null
var _down_at: int = -1


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if view == null or view.fight == null:
		return
	var f: BossFight = view.fight
	var at: Vector2 = KingBeats.king_px(f, view.windup_px())
	at += f.body.facing * HEAD_FWD_M * Ink.PX_PER_M
	if f.state != BossFight.State.DEFEATED:
		_down_at = -1
		_crown(at, 0.36 * Ink.PX_PER_M, 0.0)
	else:  # the defeat beat: the crown falls off his head and rolls away
		_down_at = f.now() if _down_at < 0 else _down_at
		var fall: Vector3 = KingBeats.crown_fall(f, _down_at)
		_crown(at + Vector2(fall.x, fall.y), 0.36 * Ink.PX_PER_M, fall.z)
	for g: BossFight in view.standing_adds():
		var c: Vector2 = Ink.px(g.body.pos)
		var a: float = g.body.facing.angle()
		draw_arc(c, 0.3 * Ink.PX_PER_M, a - 1.0, a + 1.0, 10, Ink.INK, 5.0)
		draw_arc(c, 0.3 * Ink.PX_PER_M, a - 0.95, a + 0.95, 10, GOLD, 3.0)


## A gold star crown with an ink edge and a dark jewel (vermilion stays the cape's alone).
func _crown(at: Vector2, r: float, spin: float) -> void:
	var pts: Array[Vector2] = []
	for i: int in 10:
		var rr: float = r if i % 2 == 0 else r * 0.6
		pts.append(at + Vector2.from_angle(TAU * float(i) / 10.0 + spin) * rr)
	var poly: PackedVector2Array = PackedVector2Array(pts)
	draw_colored_polygon(poly, GOLD)
	draw_polyline(poly + PackedVector2Array([pts[0]]), Ink.INK, 2.0)
	draw_circle(at, r * 0.32, Ink.INK)
	draw_circle(at + Vector2(-r * 0.08, -r * 0.08), r * 0.12, GOLD_HI)
