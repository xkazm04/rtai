class_name D5HeroHaloInk
extends RefCounted
## d5-close hero scene (iteration 7), dev A/B only (env D5_HALO=ink): the mock's thin
## ink line OUTSIDE the cream sticker rim. One ring sprite (look_d5_halo.gdshader) under every
## halo, z absolute and below the lowest halo, so overlapping halos cover each other's rings.
## Proposal for the characters lane (rig_build.gd _halo).

const SHADER: String = "res://assets/shaders/look_d5_halo.gdshader"
const RING: StringName = &"halo_ink"

const PRINT: String = "res://assets/shaders/look_d5_print.gdshader"
const SHADOW_M: float = 0.09

static var _mat: ShaderMaterial = null


## The dev A/B switches for the hero and arena scenes (both tiers): D5_PRINT=thin swaps the world
## print to look_d5_print; D5_HALO=ink adds the rings (D5_HALO_PX width, D5_HALO_SHADOW=1 shadow).
static func dev_switches(root: Node, look: ShaderMaterial, ppm: float) -> void:
	if OS.get_environment("D5_PRINT") == "thin":
		look.shader = load(PRINT) as Shader
	if OS.get_environment("D5_HALO") == "ink":
		var w: String = OS.get_environment("D5_HALO_PX")
		var sh: float = OS.get_environment("D5_HALO_SHADOW").to_float() * SHADOW_M * ppm
		apply(root, 1.0 if w.is_empty() else w.to_float(), sh)


## Adds the rings once (idempotent); shadow_px = the drop shadow offset in screen px (0 = none).
static func apply(root: Node, line_px: float, shadow_px: float) -> void:
	var halos: Array[Sprite2D] = []
	_collect(root, halos)
	var low: int = 4096  # RenderingServer.CANVAS_ITEM_Z_MAX
	for h: Sprite2D in halos:
		low = mini(low, _abs_z(h))
	if _mat == null:
		_mat = ShaderMaterial.new()
		_mat.shader = load(SHADER) as Shader
	_mat.set_shader_parameter("line_px", line_px)
	_mat.set_shader_parameter("shadow_px", Vector2.ONE * shadow_px)
	_mat.set_shader_parameter("shadow_blur", maxf(1.0, shadow_px * 0.4))
	_mat.set_shader_parameter("shadow_a", 0.4 if shadow_px > 0.0 else 0.0)
	for h: Sprite2D in halos:
		if h.has_node(NodePath(RING)):
			continue
		var r: Sprite2D = Sprite2D.new()
		r.name = RING
		r.texture = h.texture
		r.centered = h.centered
		r.offset = h.offset
		r.material = _mat
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
