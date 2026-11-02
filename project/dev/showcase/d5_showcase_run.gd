class_name D5ShowcaseRun
extends RigShowcaseRun
## d5-close evidence: the F-09b cast (Rivet, two cops, peds on D4 pavement and asphalt) at 32, 48,
## 54, 56, 64 and 96 px/m, each zoom shot three times from the SAME pose: "d4" (D4 parts, no
## D5 print), "d5p" (the D5 character tier only) and "d5" (D5 tier + the look_d5 world print at
## its zoom_amount from look_d5.params.json). Writes <out>/<tier>-<ppm>ppm.png and a Rivet crop
## <tier>-<ppm>ppm-rivet.png. Windowed only (needs a GPU).

const D5_ZOOMS: Array[float] = [1.0, 1.5, 1.6875, 1.75, 2.0, 3.0]
const RIVET_BOX_M: Vector2 = Vector2(3.6, 3.6)
const PARAMS: String = "res://assets/shaders/look_d5.params.json"
const TIERS: Array[String] = ["d4", "d5p", "d5"]

## Zooms to shoot and the camera centre (world px); subclasses change them.
var zooms: Array[float] = D5_ZOOMS
var cam: Vector2 = Vector2.ZERO
var overlay: ShaderMaterial = ShaderMaterial.new()
var _stops: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	super._ready()
	var copy: BackBufferCopy = BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	_post.add_child(copy)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.shader = load("res://assets/shaders/look_d5.gdshader") as Shader
	rect.material = overlay
	_post.add_child(rect)
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(PARAMS)) == OK and json.data is Dictionary:
		var data: Dictionary = json.data
		var world: Dictionary = data.get("world", {})
		for key: String in world:
			var v: Variant = world[key]
			overlay.set_shader_parameter(key, _vec(v) if v is Array else v)
		var stops: Array = data.get("zoom_amount", [])
		for s: Variant in stops:
			@warning_ignore("return_value_discarded")
			_stops.append(_vec(s))


## The look_d5 world amount at zoom z (piecewise linear over the params' stops, clamped).
func amount_at(z: float) -> float:
	var out: float = 0.0
	for k: int in _stops.size():
		var s: Vector2 = _stops[k]
		if z >= s.x:
			out = s.y
		elif k > 0:
			var p: Vector2 = _stops[k - 1]
			return lerpf(p.y, s.y, (z - p.x) / (s.x - p.x))
	return out


static func _vec(v: Variant) -> Vector2:
	var a: Array = v
	var x: float = a[0]
	var y: float = a[1]
	return Vector2(x, y)


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in zooms:
		_frame_at(z)
		for t: int in SETTLE_TICKS:
			_pose(t)
			_rigs.step_ticks(1)
			await get_tree().process_frame
		for tier: String in TIERS:
			RigDetail.enabled = tier != "d4"
			_tier(tier)
			overlay.set_shader_parameter("amount", amount_at(z) if tier == "d5" else 0.0)
			_rigs.step_ticks(0)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_d5("%s-%dppm" % [tier, roundi(z * PX)], z) and ok
	RigDetail.enabled = true
	return 0 if ok else 1


## Hook: called before each tier is shot (the hero scene swaps its roofs here).
func _tier(_name: String) -> void:
	pass


func _frame_at(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, (view * 0.5 - cam * z).round())
	_world.transform = xf
	_actors.transform = xf
	_rigs.zoom = z
	var wpx: Vector2 = (cam * z).round() - view * 0.5
	_look.set_shader_parameter("world_px", wpx)
	overlay.set_shader_parameter("world_px", wpx)


func _save_d5(name: String, z: float) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var ok: bool = img.save_png(out_dir.path_join(name + ".png")) == OK
	var view: Vector2 = Vector2(img.get_size())
	var at: Vector2 = view * 0.5 + (_rigs.feed.pos[0] - cam) * z
	var size: Vector2 = RIVET_BOX_M * PX * z
	var r: Rect2i = Rect2i(Vector2i(at - size * 0.5), Vector2i(size)).intersection(
		Rect2i(Vector2i.ZERO, img.get_size())
	)
	var crop: Image = img.get_region(r)
	var k: int = maxi(1, roundi(360.0 / maxf(1.0, float(r.size.y))))
	crop.resize(r.size.x * k, r.size.y * k, Image.INTERPOLATE_NEAREST)
	return crop.save_png(out_dir.path_join(name + "-rivet.png")) == OK and ok
