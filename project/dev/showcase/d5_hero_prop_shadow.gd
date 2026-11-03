class_name D5HeroPropShadow
extends RefCounted
## d5-close hero scene (iteration 8): hatched cast shadows for props and parked cars, as the
## mock draws them (crates, bins, cars all throw a pen-hatched shadow down-right). One sibling
## sprite per prop with the prop's own silhouette (look_d5_shadow takes the sprite alpha), offset
## down-right by the prop's shadow length, drawn under the prop on the world layer so the look_d4
## print inks it like the building shadows. "d5" tier only (the caller toggles visibility).
## Proposal for the city lane; D5_PROP_SHADOW=0 turns it off for A/B frames.

const SHADER: String = "res://assets/shaders/look_d5_shadow.gdshader"
## node / texture name -> shadow length in metres (a stylised height, like the roofs' 1.1 m)
const LENGTH_M: Dictionary[String, float] = {
	"dumpster": 0.45,
	"fire_hydrant": 0.25,
	"payphone": 0.4,
	"trash_can": 0.25,
	"police_barrier": 0.25,
	"crate_stack": 0.45,
	"planter": 0.3,
	"bench": 0.2,
	"mailbox": 0.3,
	"vending_machine": 0.45,
	"cruiser": 0.4,
	"sedan_dark": 0.4,
}
## round props on a flat base plate (the plate has no height, so its silhouette is the wrong
## shadow): name -> [radius m, length m], a capsule from the prop's centre down-right
const ROUND: Dictionary[String, Array] = {"traffic_cone": [0.15, 0.55]}
const TINT: float = 0.5
const STROKE: float = 0.8

static var _mats: Array[ShaderMaterial] = []


## Adds a shadow under every sprite in parent whose name or texture file is in LENGTH_M;
## returns the shadows (hidden; the tier switch shows them).
static func place(parent: Node, px: float) -> Array[Node2D]:
	var out: Array[Node2D] = []
	if OS.get_environment("D5_PROP_SHADOW") == "0":
		return out
	for n: Node in parent.get_children():
		var s: Sprite2D = n as Sprite2D
		if s == null or s.texture == null:
			continue
		var key: String = s.texture.resource_path.get_file().get_basename()
		if not LENGTH_M.has(key) and not ROUND.has(key):
			key = String(s.name).rstrip("0123456789")
		if LENGTH_M.has(key):
			out.append(_shadow(s, LENGTH_M[key] * px))
		elif ROUND.has(key):
			out.append(_capsule(s, ROUND[key], px))
	return out


## The camera zoom for the stroke period (as the building shadows).
static func set_zoom(zoom: float) -> void:
	for m: ShaderMaterial in _mats:
		m.set_shader_parameter("zoom", zoom)


static func _capsule(s: Sprite2D, shape: Array, px: float) -> Polygon2D:
	var rad_m: float = shape[0]
	var len_m: float = shape[1]
	var r: float = rad_m * px
	var c1: Vector2 = Vector2.ONE * len_m * px * 0.7071
	var d: Vector2 = Vector2.ONE.normalized()
	var n: Vector2 = d.orthogonal()
	var pts: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	pts.resize(26)
	for i: int in 13:
		var a: float = -PI * 0.5 + PI * i / 12.0
		pts[i] = c1 + (d * cos(a) + n * sin(a)) * r
		pts[13 + i] = (d * cos(a + PI) + n * sin(a + PI)) * r
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = pts
	poly.position = s.position
	poly.material = _material()
	poly.visible = false
	var parent: Node = s.get_parent()
	parent.add_child(poly)
	parent.move_child(poly, s.get_index())
	return poly


static func _material() -> ShaderMaterial:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(SHADER) as Shader
	mat.set_shader_parameter("tint", TINT)
	mat.set_shader_parameter("stroke", STROKE)
	_mats.append(mat)
	return mat


static func _shadow(s: Sprite2D, len_px: float) -> Sprite2D:
	var sh: Sprite2D = Sprite2D.new()
	sh.texture = s.texture
	sh.scale = s.scale
	sh.rotation = s.rotation
	sh.position = s.position + Vector2.ONE * len_px * 0.7071
	sh.texture_filter = s.texture_filter
	sh.material = _material()
	sh.visible = false
	var parent: Node = s.get_parent()
	parent.add_child(sh)
	parent.move_child(sh, s.get_index())
	return sh
