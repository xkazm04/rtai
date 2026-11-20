class_name GhostBridgeFade
extends RefCounted
## A legacy cell's temporary belt socket and tick-driven cut. Authored spectral sheets bypass it.

const SHADER: Shader = preload("res://features/souls/ghost_fade.gdshader")

var _marker: StringName
var _body: ShaderMaterial
var _line: ShaderMaterial
var _bound: Sprite2D
var _previous: Material
var _old_line: Material
var _cut_cell: Vector2


func _init(marker: StringName) -> void:
	_marker = marker


func sync(spr: Sprite2D, flight: GhostFlight) -> void:
	var cut: float = flight.fade_from()
	if cut <= 0.0 or "_spec_" in spr.texture.resource_path.get_file():
		clear(flight)
		return
	if _body == null:
		_body = _material(false)
		_line = _material(true)
	if not is_instance_valid(_bound) or spr != _bound:
		_bound = spr
		_cut_cell = Vector2.ZERO
		_previous = spr.material
		spr.material = _body
		for child: Node in spr.get_children():
			var copy: Sprite2D = child as Sprite2D
			if copy != null and copy.has_meta(_marker):
				_old_line = copy.material
				copy.material = _line
	var grid: Vector2 = Vector2(spr.hframes, spr.vframes)
	for mat: ShaderMaterial in [_body, _line]:
		mat.set_shader_parameter(&"grid", grid)
		mat.set_shader_parameter(&"fade_from", cut)
		mat.set_shader_parameter(&"flow", flight.hover.tick / 60.0)
	var cell: Vector2 = spr.texture.get_size() / grid
	var signed_cell: Vector2 = Vector2(-cell.x if spr.flip_h else cell.x, cell.y)
	if signed_cell != _cut_cell:
		_cut_cell = signed_cell
		GhostSoulLine.align_cut(spr, cell)
	var belt: Vector2 = spr.offset + cell * Vector2(0.5, 1.0 - cut)
	var width: float = cell.x * absf(spr.global_scale.x) * flight.belt_fraction()
	flight.set_belt(spr.to_global(belt), width)


func clear(flight: GhostFlight) -> void:
	flight.tail.align_socket(Vector2.ZERO, 0.0)
	if is_instance_valid(_bound):
		_bound.material = _previous
		for child: Node in _bound.get_children():
			var copy: Sprite2D = child as Sprite2D
			if copy != null and copy.has_meta(_marker):
				copy.set_instance_shader_parameter(&"cut_shift", null)
				copy.material = _old_line
	_bound = null


static func _material(line: bool) -> ShaderMaterial:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"grain", GhostVapour.grain())
	mat.set_shader_parameter(&"outline", line)
	return mat


## Keep a speaking fallback cell's belt cut while applying the voice colour and scan bands.
static func voice(spr: Sprite2D, wash: ShaderMaterial, phase: float) -> void:
	if spr == null:
		return
	var material: ShaderMaterial = spr.material as ShaderMaterial
	if material != null and material.shader == SHADER:
		material.set_shader_parameter(&"voice_phase", phase)
	else:
		spr.material = wash
