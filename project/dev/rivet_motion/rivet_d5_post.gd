class_name RivetD5Post
extends RefCounted
## rivet-motion: the D5 world print over a dev clip, the recipe of D5ShowcaseRun (a viewport
## back-buffer copy, then look_d5 with look_d5.params.json's world parameters, its amount taken
## from the params' zoom_amount stops at the clip's zoom). Added after the clip's look_d4 rect.

const PARAMS: String = "res://assets/shaders/look_d5.params.json"


## Adds the print to `post` (after its look_d4 rect); returns the overlay for world_px updates.
static func attach(post: CanvasLayer, zoom: float, world_px: Vector2) -> ShaderMaterial:
	var copy: BackBufferCopy = BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	post.add_child(copy)
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/look_d5.gdshader") as Shader
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.material = mat
	post.add_child(rect)
	var json: JSON = JSON.new()
	var stops: Array = []
	if json.parse(FileAccess.get_file_as_string(PARAMS)) == OK and json.data is Dictionary:
		var data: Dictionary = json.data
		var world: Dictionary = data.get("world", {})
		for key: String in world:
			var v: Variant = world[key]
			mat.set_shader_parameter(key, _vec(v) if v is Array else v)
		stops = data.get("zoom_amount", [])
	mat.set_shader_parameter("amount", _amount(stops, zoom))
	mat.set_shader_parameter("world_px", world_px)
	return mat


## Piecewise linear over the [zoom, amount] stops, clamped (D5ShowcaseRun.amount_at).
static func _amount(stops: Array, z: float) -> float:
	var out: float = 0.0
	for k: int in stops.size():
		var s: Vector2 = _vec(stops[k])
		if z >= s.x:
			out = s.y
		elif k > 0:
			var p: Vector2 = _vec(stops[k - 1])
			return lerpf(p.y, s.y, (z - p.x) / (s.x - p.x))
	return out


static func _vec(v: Variant) -> Vector2:
	var a: Array = v if v is Array else [0.0, 0.0]
	var x: float = a[0]
	var y: float = a[1]
	return Vector2(x, y)
