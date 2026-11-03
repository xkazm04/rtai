class_name D5HeroHaloInk
extends RefCounted
## d5-close hero scene (iteration 7), dev A/B only (env D5_HALO=ink): the mock's thin
## ink line OUTSIDE the cream sticker rim. One ring sprite (look_d5_halo.gdshader) under every
## halo, z absolute and below the lowest halo, so overlapping halos cover each other's rings.
## Proposal for the characters lane (rig_build.gd _halo).

const SHADER: String = "res://assets/shaders/look_d5_halo.gdshader"
const RING: StringName = &"halo_ink"


## Adds the rings once (idempotent).
static func apply(root: Node, line_px: float) -> void:
	var halos: Array[Sprite2D] = []
	_collect(root, halos)
	var low: int = 4096  # RenderingServer.CANVAS_ITEM_Z_MAX
	for h: Sprite2D in halos:
		low = mini(low, _abs_z(h))
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(SHADER) as Shader
	mat.set_shader_parameter("line_px", line_px)
	for h: Sprite2D in halos:
		if h.has_node(NodePath(RING)):
			continue
		var r: Sprite2D = Sprite2D.new()
		r.name = RING
		r.texture = h.texture
		r.centered = h.centered
		r.offset = h.offset
		r.material = mat
		r.z_as_relative = false
		r.z_index = low - 1
		h.add_child(r)


static func _collect(n: Node, out: Array[Sprite2D]) -> void:
	for c: Node in n.get_children():
		var rig: CutRig = c as CutRig
		if rig != null:
			out.append_array(rig.halos)
		else:
			_collect(c, out)


static func _abs_z(ci: CanvasItem) -> int:
	var z: int = ci.z_index
	var p: CanvasItem = ci.get_parent() as CanvasItem
	while ci.z_as_relative and p != null:
		z += p.z_index
		ci = p
		p = ci.get_parent() as CanvasItem
	return z
