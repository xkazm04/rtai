class_name D5HeroDecals
extends RefCounted
## d5-close hero scene (iteration 3): the D5 BIG STREET DECALS (features/city/art/d5/decals/), the
## "large world surfaces" where hand-drawn grime survives at gameplay zoom: a stencilled union fist,
## STRIKE road paint, a chalk robot outline and a scorch mark. Laid on the world layer, so the world
## print (look_d4 + look_d5) prints them like the tiles. A proposal for the city lane; dev evidence.
## Iteration 4 adds the D5 plan-view lamp post (props/), its arm over the street like the mock's
## (the D4 lamp read as a spoon lying on the pavement; D5HeroRun hides it in the "d5" tier).

const DIR: String = "res://features/city/art/d5/"
## art (under DIR) -> [x m, y m, length m along the art's long axis, rotation deg]
const SPOTS: Array[Array] = [
	["decals/union_fist_stencil", -1.0, -9.3, 2.8, 0.0],
	["decals/strike_paint", 0.0, -6.2, 4.4, 0.0],
	["decals/chalk_robot", 6.2, 1.2, 2.4, 80.0],
	["decals/scorch", 14.2, -1.6, 2.2, 0.0],
	["props/lamp_post", 3.2, -6.8, 3.2, 180.0],
]


## Returns the decal sprites, hidden (the "d5" tier shows them); a missing file is skipped.
static func place(parent: Node, px: float) -> Array[Node2D]:
	var out: Array[Node2D] = []
	for spot: Array in SPOTS:
		var name: String = spot[0]
		var path: String = DIR + name + ".png"
		if not ResourceLoader.exists(path):
			continue
		var s: Sprite2D = Sprite2D.new()
		s.texture = load(path) as Texture2D
		var x: float = spot[1]
		var y: float = spot[2]
		var length: float = spot[3]
		var deg: float = spot[4]
		var long_px: float = maxf(s.texture.get_width(), s.texture.get_height())
		s.scale = Vector2.ONE * length * px / long_px
		s.position = Vector2(x, y) * px
		s.rotation_degrees = deg
		s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		s.visible = false
		parent.add_child(s)
		out.append(s)
	return out
