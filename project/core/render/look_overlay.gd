class_name LookOverlay
extends Control
## A print layer over the D4 world print (look_profiles.json `overlays`, core/render/README.md):
## a BackBufferCopy of the printed frame + a full-rect ColorRect with the overlay shader (the
## d5-close lane's look_d5 "Inked Grime"), on the `print_overlay` band of the `print` canvas,
## under the actors. Its `amount` comes from the look id and the zoom (amount_ppm stops); at
## amount 0 it is hidden, so the gameplay frame pays nothing. Render only.

var spec: Dictionary = {}
var amount: float = 0.0
var stops: PackedVector2Array = PackedVector2Array()
var _mat: ShaderMaterial = ShaderMaterial.new()


## Builds the overlay for one `overlays` row (the caller checked the shader exists).
static func create(row: Dictionary) -> LookOverlay:
	var o: LookOverlay = LookOverlay.new()
	o.spec = row
	o.z_index = RenderLayers.z(&"print_overlay")
	o.mouse_filter = Control.MOUSE_FILTER_IGNORE
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	var copy: BackBufferCopy = BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	o.add_child(copy)
	var rect: ColorRect = ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	var path: String = row["shader"]
	o._mat.shader = load(path)
	o._mat.set_shader_parameter(&"grime_tex", GrimeLattice.texture())  # used if it declares it
	rect.material = o._mat
	o.add_child(rect)
	var ramp: Array = row["amount_ppm"]
	o.stops = ramp_stops(ramp)
	o._apply_params()
	o.visible = false
	return o


## The overlay amount for look `id` at `ppm`: 1 for a `full_looks` id, the amount_ppm ramp for a
## `zoom_looks` id, 0 otherwise (and for `off`).
static func amount_for(
	row: Dictionary, ramp: PackedVector2Array, id: StringName, ppm: float
) -> float:
	var full: Array = row["full_looks"]
	if full.has(String(id)):
		return 1.0
	var zoomed: Array = row["zoom_looks"]
	if zoomed.has(String(id)):
		return ramp_at(ramp, ppm)
	return 0.0


## Piecewise linear over (ppm, amount) stops sorted by ppm, clamped at both ends.
static func ramp_at(ramp: PackedVector2Array, x: float) -> float:
	if ramp.is_empty():
		return 0.0
	if x <= ramp[0].x:
		return ramp[0].y
	for k: int in range(1, ramp.size()):
		if x <= ramp[k].x:
			var a: Vector2 = ramp[k - 1]
			var b: Vector2 = ramp[k]
			return lerpf(a.y, b.y, (x - a.x) / maxf(b.x - a.x, 0.0001))
	return ramp[ramp.size() - 1].y


static func ramp_stops(rows: Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for s: Array in rows:
		var x: float = s[0]
		var y: float = s[1]
		@warning_ignore("return_value_discarded")
		out.append(Vector2(x, y))
	return out


## Per frame: the amount for `id` at `ppm`, and world_px (grain and hatch locked to the world).
func update(id: StringName, ppm: float, world_px: Vector2) -> void:
	amount = amount_for(spec, stops, id, ppm)
	visible = amount > 0.001
	if visible:
		_mat.set_shader_parameter(&"amount", amount)
		_mat.set_shader_parameter(&"world_px", world_px)


func _apply_params() -> void:
	var path: String = spec["params"]
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var key: String = spec["params_key"]
	var u: Dictionary = d.get(key, {})
	for k: String in u:
		_mat.set_shader_parameter(StringName(k), LookParams.uniform_value(u[k]))
