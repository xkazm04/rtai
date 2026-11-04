class_name PickupLook
extends RefCounted
## How a gun lying on the ground (rivet-arsenal's PickupsView) is drawn. The rigs' PART print
## posterizes the pickup's mid-tone rust and steel to near-black at 48 px/m and below, so a hand
## cannon on its paper disc read as an ink smudge (it21, same finding as the held guns at 06:15).
## Default: the pickup's own flat fills, unprinted, inside an ink outline (the D5 line the print
## would have given it). `--pickup-print=on` keeps the PART print (the before, same-tick A/B).

## World px of ink around the pickup's silhouette.
const OUTLINE_WORLD_PX: float = 1.0
const OUTLINE_DIRS: int = 8

static var printed: bool = OS.get_cmdline_user_args().has("--pickup-print=on")


## Sets `s` (texture and scale already set) to the pickup look: the PART print with
## `--pickup-print=on`, else flat fills with ink silhouettes drawn behind it.
static func dress(s: Sprite2D) -> void:
	if printed:
		s.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		return
	var ink: Color = PaletteTokens.shared().color(&"ink")
	for i: int in OUTLINE_DIRS:
		var o: Sprite2D = Sprite2D.new()
		o.name = "Ink%d" % i
		o.texture = s.texture
		o.centered = s.centered
		o.offset = s.offset
		o.modulate = ink
		o.show_behind_parent = true
		var reach: float = OUTLINE_WORLD_PX / maxf(s.scale.x, 0.0001)
		o.position = Vector2.from_angle(TAU * i / OUTLINE_DIRS) * reach
		s.add_child(o)
