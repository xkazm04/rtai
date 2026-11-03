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
## A new beat at most once per BEAT_GAP ticks (1 s); kills inside the gap keep their blood but
## get no beat. Photosensitivity: the full beat also spends from `budget` (shared with the muzzle
## light); when the budget is spent or flashes are off, the beat is the CALM one: no flash, the
## held pose framed by an ink border only (no paper gutters), the hit-stop unchanged.
const BEAT_GAP: int = 60

var sequence: PackedInt32Array = PackedInt32Array([1, 3, 2])
## After the sequence: the held panel, this many ticks (a comic panel border around the kill).
var panel_ticks: int = 0
## The panel's half size in screen uv.
var panel_half: Vector2 = Vector2(0.36, 0.38)
## What mode 4 hides (the world canvas, the noir pass); empty = mode 4 inks the whole frame.
var hide_on_flash: Array[Node] = []
## The shared flash budget (stepped here; the host hands it to MuzzleFlash too).
var budget: FlashBudget = null
var _calm: bool = false
var _shown: Dictionary[Node, bool] = {}
var _clear: Color = Color.BLACK
var _keyed: bool = false
var _left: int = 0
var _since: int = BEAT_GAP
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
	budget = FlashBudget.from_params(d)
	var imp: Variant = d.get("impact", {})
	if imp is Dictionary:
		var u: Dictionary = imp
		var seq: Array = u.get("sequence", [])
		if not seq.is_empty():
			sequence = PackedInt32Array(seq)
		panel_ticks = u.get("panel_ticks", panel_ticks)
		var half: Array = u.get("panel_half", [])
		if half.size() == 2:
			var hx: float = half[0]
			var hy: float = half[1]
			panel_half = Vector2(hx, hy)


## Starts the beat (shown this frame: call step_ticks before fire() each tick), the burst
## centred on `screen_uv`.
func fire(screen_uv: Vector2) -> void:
	_since = 0
	_calm = not budget.spend(FlashBudget.BEAT_COST)
	_left = _seq_len() + panel_ticks
	_mat.set_shader_parameter(&"gutter", 0.0 if _calm else 1.0)
	_mat.set_shader_parameter(&"center", screen_uv)
	var gutter: Vector2 = panel_half + Vector2(0.03, 0.04)
	var c: Vector2 = screen_uv.clamp(gutter, Vector2.ONE - gutter)
	_mat.set_shader_parameter(&"panel_center", c)
	_mat.set_shader_parameter(&"panel_half", panel_half)
	if not _keyed:
		_shown.clear()
		for n: Node in hide_on_flash:
			_shown[n] = n.get(&"visible")
	_show()


func active() -> bool:
	return _left > 0


## False inside BEAT_GAP ticks of the last beat (the caller skips the beat and its hit-stop).
func can_fire() -> bool:
	return _since >= BEAT_GAP


## True when the last beat was the calm (non-flashing) one.
func calm() -> bool:
	return _calm


func step_ticks(n: int) -> void:
	_since += n
	budget.step_ticks(n)
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
		var k: int = _seq_len() + panel_ticks - _left
		_mat.set_shader_parameter(&"mode", sequence[k] if k < _seq_len() else 0)
		_mat.set_shader_parameter(&"panel", 1.0 if k >= _seq_len() else 0.0)
	var k_now: int = _seq_len() + panel_ticks - _left
	var flash: bool = _left > 0 and k_now < _seq_len() and sequence[k_now] == SILHOUETTE
	_key(flash and not hide_on_flash.is_empty())


func _seq_len() -> int:
	return 0 if _calm else sequence.size()


func _key(on: bool) -> void:
	if on == _keyed:
		return
	_keyed = on
	if on:
		_clear = RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(KEY if on else _clear)
	for n: Node in _shown:
		n.set(&"visible", false if on else _shown[n])
