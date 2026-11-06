class_name GangShades
extends Node2D
## it18: the gang's visor shades as their own part over the helmet (render only). At 32 px/m the
## part print's sticker LOD keeps the helmet's cream dome and loses the art's black visor crescent,
## so the target's shades are drawn here, on the head sprite: an ink wraparound crescent at the
## dome's front (the art faces +x) with a gold frame and a cream glint. A child of the head sprite,
## it turns, shoves, falls and inks out with the head. MODE 0 = the it14-it17 bare dome.

## 0 = no shades (it17); 1 = the drawn wraparound shades.
const MODE: int = 1
## The helmet art's dome, as a share of the head texture (gang/helmet.png: centre a touch behind
## the texture's middle, radius about 0.38 of its width).
const DOME_X: float = -0.04
const DOME_R: float = 0.38
## The crescent: its centre line (share of the dome radius), its width, its half span (rad).
const BAND_R: float = 0.74
const BAND_W: float = 0.44
const SPAN: float = 1.0
## The gold frame along the crescent's inner edge (share of the dome radius).
const FRAME_W: float = 0.12
const GOLD: Color = Color("#D9A933")
const GLINT: Color = Color("#F2E8D5")


## Puts the shades on a gang rig's head sprite (no-op at MODE 0).
static func dress(rig: CutRig) -> void:
	if MODE <= 0 or rig.head_spr == null:
		return
	var s: GangShades = GangShades.new()
	s.z_index = KingAccents.OVER_RIG_Z + 1  # over the gang's chain: from above the head is highest
	rig.head_spr.add_child(s)


func _draw() -> void:
	var spr: Sprite2D = get_parent() as Sprite2D
	if spr == null or spr.texture == null:
		return
	var size: Vector2 = spr.texture.get_size()
	var c: Vector2 = spr.offset + size * 0.5 + Vector2(DOME_X * size.x, 0.0)
	var r: float = DOME_R * size.x
	var w: float = BAND_W * r
	var mid: float = BAND_R * r
	draw_arc(c, mid - w * 0.5, -SPAN, SPAN, 16, GOLD, FRAME_W * r * 2.0)
	draw_arc(c, mid, -SPAN * 1.05, SPAN * 1.05, 16, Ink.INK, w)
	draw_circle(c + Vector2.from_angle(-SPAN * 0.45) * mid, w * 0.22, GLINT)
