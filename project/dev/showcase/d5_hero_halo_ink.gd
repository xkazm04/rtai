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
const RULE_DIR: String = "res://features/city/art/d5/roofs/rule/"
const PX_PER_M: float = 32.0  # zoom 1.0

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
		_mat.set_shader_parameter("rim_px", OS.get_environment("D5_HALO_RIM").to_float())
		_mat.set_shader_parameter("fade", fade_at(ppm / PX_PER_M))


## The ring's strength at a camera zoom: CutRig._on_view shrinks the halos by
## hk = 1 - smoothstep(0.12, 0.3, SC * zoom) and hides them below hk 0.01 (constants copied);
## the ring fades over hk 0.01..0.30 so it is gone exactly where the halo goes (no pop).
static func fade_at(zoom: float) -> float:
	var hk: float = 1.0 - smoothstep(0.12, 0.3, CutRig.SC * zoom)
	return clampf((hk - 0.01) / 0.29, 0.0, 1.0)


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


## The ruled roof hatch overlay (with D5_PRINT=thin; D5_ROOF_RULE_FADE=0 turns it off):
## full at 48 px/m and below, gone at 64, where the baked rule read as a mechanical
## pattern (iteration 7, item41).
static func roof_rule(roofs: Array[Sprite2D], tier: String, ppm: float) -> void:
	var on: bool = OS.get_environment("D5_PRINT") == "thin"
	on = on and OS.get_environment("D5_ROOF_RULE_FADE") != "0" and tier == "d5"
	var a: float = clampf((64.0 - ppm) / 16.0, 0.0, 1.0)
	for r: Sprite2D in roofs:
		var ov: Sprite2D = r.get_node_or_null(^"rule") as Sprite2D
		var path: String = RULE_DIR + r.texture.resource_path.get_file()
		if ov == null and ResourceLoader.exists(path):
			ov = Sprite2D.new()
			ov.name = &"rule"
			ov.texture = load(path) as Texture2D
			ov.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			r.add_child(ov)
		if ov != null:
			ov.visible = on and a > 0.0
			ov.modulate.a = a
