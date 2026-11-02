class_name ImpactFrame
extends CanvasLayer
## D-Noir comic impact frames (lane noir): on a big hit the panel holds 1-3 frames of a comic
## beat (inverted panel, white flash with ink silhouettes, a speed-line burst) above the noir
## pass. The sequence is data (look_noir.params.json `impact.sequence`, one mode per tick).
## Stepped on the fixed tick (step_ticks). Render only.

const SHADER: String = "res://assets/shaders/look_noir_impact.gdshader"
const LAYER: int = 11

var sequence: PackedInt32Array = PackedInt32Array([1, 3, 2])
var _left: int = 0
var _rect: ColorRect = ColorRect.new()
var _mat: ShaderMaterial = ShaderMaterial.new()


func _init() -> void:
	layer = LAYER
	_mat.shader = load(SHADER) as Shader
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.visible = false
	add_child(_rect)
	var d: Dictionary = NoirLook.read_params(NoirLook.PARAMS)
	var imp: Variant = d.get("impact", {})
	if imp is Dictionary:
		var u: Dictionary = imp
		var seq: Array = u.get("sequence", [])
		if not seq.is_empty():
			sequence = PackedInt32Array(seq)


## Starts the beat (shown this frame: call step_ticks before fire() each tick), the burst
## centred on `screen_uv`.
func fire(screen_uv: Vector2) -> void:
	_left = sequence.size()
	_mat.set_shader_parameter(&"center", screen_uv)
	_show()


func active() -> bool:
	return _left > 0


func step_ticks(n: int) -> void:
	if _left <= 0:
		return
	_left = maxi(_left - n, 0)
	_show()


func _show() -> void:
	_rect.visible = _left > 0
	if _left > 0:
		var view: Vector2 = (
			_rect.get_viewport_rect().size if _rect.is_inside_tree() else Vector2(16, 9)
		)
		_mat.set_shader_parameter(&"aspect", view.x / maxf(view.y, 1.0))
		var k: int = sequence.size() - _left
		_mat.set_shader_parameter(&"mode", sequence[k])
