class_name OhmJars
extends Sprite2D
## Child of the painted sprite. An identity local transform keeps the mask registered through
## banking, recoil, and camera squash. Flipping the same source UVs preserves the RGB jar IDs.

var _ink: ShaderMaterial = ShaderMaterial.new()


func _init() -> void:
	_ink.shader = load("res://features/souls/ohm_jars.gdshader") as Shader
	material = _ink
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func match_cell(src: Sprite2D, mask: Texture2D) -> void:
	if texture != mask or hframes != src.hframes or vframes != src.vframes:
		frame = 0
		texture = mask
		hframes = src.hframes
		vframes = src.vframes
	region_enabled = src.region_enabled
	region_rect = src.region_rect
	centered = src.centered
	offset = src.offset
	frame = src.frame
	flip_h = src.flip_h
	flip_v = src.flip_v


func bounds(top_px: Vector3, bottom_px: Vector3) -> void:
	_ink.set_shader_parameter(&"top_px", top_px)
	_ink.set_shader_parameter(&"bottom_px", bottom_px)


func top_circles() -> void:
	_ink.set_shader_parameter(&"circles", true)


func light(fill: Vector3, flash: float, vent: float) -> void:
	_ink.set_shader_parameter(&"fill", fill)
	_ink.set_shader_parameter(&"flash", flash)
	_ink.set_shader_parameter(&"vent", vent)
