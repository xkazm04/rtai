class_name CrowdBakeDetail
extends RefCounted
## The D5 part overlays for the crowd atlas's D5 twin (d5-cast, 2026-11-03): RigDetail's tier on a
## baker stage rig, with the baker's own materials at full amount, independent of the live view
## (RigDetail.active and its shared materials follow the camera every frame). Same rules as
## RigDetail.sync: one overlay per part from art/d5/<art_dir>/, none on palette-swapped parts.

const NAME: StringName = &"d5_bake"


## [plain, tinted] look_d5_part materials at full amount for a bake at zoom.
static func materials(zoom: float) -> Array[ShaderMaterial]:
	var out: Array[ShaderMaterial] = []
	var sh: Shader = load(RigDetail.SHADER_PATH) as Shader
	for t: int in 2:
		var m: ShaderMaterial = ShaderMaterial.new()
		m.shader = sh
		m.set_shader_parameter("tint", float(t))
		m.set_shader_parameter("px_scale", CutRig.SC * zoom)
		m.set_shader_parameter("amount", 1.0)
		out.append(m)
	return out


## Keeps one overlay per part on the D5 art of the texture the part shows now.
static func sync(rig: CutRig, mats: Array[ShaderMaterial]) -> void:
	if not RigDetail.has_d5(rig.plan.art_dir):
		return
	var dir: String = RigDetail.D5_DIR + rig.plan.art_dir
	for i: int in rig.sprites.size():
		var spr: Sprite2D = rig.sprites[i]
		var o: Sprite2D = spr.get_node_or_null(NodePath(String(NAME))) as Sprite2D
		if o == null:
			o = Sprite2D.new()
			o.name = NAME
			o.centered = false
			o.texture_filter = RigDetail.FILTER_MIPS
			spr.add_child(o)
		o.material = mats[1 if rig.is_tinted() else 0]
		o.visible = rig.sprite_swaps[i] == 0
		if o.get_meta(&"src", null) != spr.texture:
			o.set_meta(&"src", spr.texture)
			var part: String = spr.texture.resource_path.get_file().get_basename()
			o.texture = PartLibrary.texture(dir, part) if RigDetail.has_part(dir, part) else null
		o.offset = spr.offset
