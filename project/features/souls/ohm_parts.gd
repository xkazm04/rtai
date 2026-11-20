class_name OhmParts
extends RefCounted
## Legacy shell and limb sprites in the rig's body frame.

const ART: String = "res://features/souls/art/ohm/"


static func limb(body: Node2D, name: String) -> Sprite2D:
	var s: Sprite2D = _sprite(body, name)
	s.centered = false
	s.offset = Vector2(0.0, -s.texture.get_height() * 0.5)
	return s


static func part(body: Node2D, name: String, length_m: float) -> Sprite2D:
	var s: Sprite2D = _sprite(body, name)
	var long_px: int = maxi(s.texture.get_width(), s.texture.get_height())
	s.scale = Vector2.ONE * length_m * SimConst.PX_PER_M / float(long_px)
	return s


static func _sprite(body: Node2D, name: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ART + name + ".png") as Texture2D
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	body.add_child(s)
	return s
