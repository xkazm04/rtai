class_name ImpactFrame
extends CanvasLayer
## D-Noir comic impact frames (lane noir): on a big hit the panel holds 1-3 frames of a comic
## beat (inverted panel, white flash with ink silhouettes, a speed-line burst) above the noir
## pass. The sequence is data (look_noir.params.json `impact.sequence`, one mode per tick).
## Stepped on the fixed tick (step_ticks). Render only.

const SHADER: String = "res://assets/shaders/look_noir_impact.gdshader"
const LAYER: int = 11
## Mode 4 (the silhouette flash): the world and the noir pass are hidden for that tick and the
## clear colour is this key, so every non-key pixel is an actor (or blood) and prints as ink.
const KEY: Color = Color(0.0, 1.0, 0.0)
const SILHOUETTE: int = 4

var sequence: PackedInt32Array = PackedInt32Array([1, 3, 2])
## What mode 4 hides (the world canvas, the noir pass); empty = mode 4 inks the whole frame.
var hide_on_flash: Array[Node] = []
var _shown: Dictionary[Node, bool] = {}
var _clear: Color = Color.BLACK
var _keyed: bool = false
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
	if not _keyed:
		_shown.clear()
		for n: Node in hide_on_flash:
			_shown[n] = n.get(&"visible")
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
	var flash: bool = _left > 0 and sequence[sequence.size() - _left] == SILHOUETTE
	_key(flash and not hide_on_flash.is_empty())


func _key(on: bool) -> void:
	if on == _keyed:
		return
	_keyed = on
	if on:
		_clear = RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(KEY if on else _clear)
	for n: Node in _shown:
		n.set(&"visible", false if on else _shown[n])
