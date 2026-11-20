class_name OhmJars
extends Sprite2D
## Child of the painted sprite. An identity local transform keeps the mask registered through
## banking, recoil, and camera squash. Flipping the same source UVs preserves the RGB jar IDs.

var _ink: ShaderMaterial = ShaderMaterial.new()
var _reflections: Array[Sprite2D] = []


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


## Enlarge each glass and its painted bezel together, keeping their original mask UVs.
## The rim samples stop at the outer black stroke, leaving the hoses on the back plate.
func top_circles(body: Sprite2D, mask: Texture2D, circles: Array) -> PackedVector2Array:
	var vents: PackedVector2Array = []
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ink.set_shader_parameter(&"circles", true)
	_ink.set_shader_parameter(&"teal", Color("#19ffe1"))
	_ink.set_shader_parameter(&"full", Color("#68fff1"))
	_ink.set_shader_parameter(&"amber", OhmBoltDraw.AMBER)
	for jar: Dictionary in circles:
		var centre: Vector2 = DataTable.new().vec(jar, "center_px")
		var radius: float = jar.radius_px
		var rim: Polygon2D = _rim(body.texture, centre, radius * 1.46)
		rim.position = (body.offset + centre) * Vector2(1.0, 1.20)
		rim.scale = Vector2.ONE * 1.40
		add_child(rim)
		var glass: Polygon2D = Polygon2D.new()
		glass.texture = mask
		glass.polygon = rim.polygon
		glass.uv = rim.uv
		glass.material = _ink
		rim.add_child(glass)
		var glint: Sprite2D = GhostRim.soft_glow(Color.WHITE, 0.95, radius * 1.05)
		glint.position = Vector2(-0.30, -0.36) * radius
		glint.scale.y *= 0.64
		glint.rotation = -0.60
		glint.self_modulate.a = 0.0
		glass.add_child(glint)
		_reflections.append(glint)
		@warning_ignore("return_value_discarded")
		vents.append(body.transform * (rim.transform * (Vector2.LEFT * radius)))
	return vents


static func _rim(source: Texture2D, centre: Vector2, radius: float) -> Polygon2D:
	var rim: Polygon2D = Polygon2D.new()
	var points: PackedVector2Array = []
	var texels: PackedVector2Array = []
	for i: int in 32:
		var point: Vector2 = Vector2.from_angle(TAU * i / 32.0) * radius
		@warning_ignore("return_value_discarded")
		points.append(point)
		@warning_ignore("return_value_discarded")
		texels.append(centre + point)
	rim.texture = source
	rim.polygon = points
	rim.uv = texels
	return rim


func light(fill: Vector3, flash: float, vent: float) -> void:
	_ink.set_shader_parameter(&"fill", fill)
	_ink.set_shader_parameter(&"flash", flash)
	_ink.set_shader_parameter(&"vent", vent)
	for i: int in _reflections.size():
		var tint: Color = Color("#ffe4a4") if vent > 0.0 else Color("#c9fff6")
		_reflections[i].self_modulate = Color(tint, maxf(fill[i], vent))
