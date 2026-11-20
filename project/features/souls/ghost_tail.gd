class_name GhostTail
extends Node2D
## A ribbon of linked ground points. Height is projected separately so the tip returns to ground.

const TEAL: Color = Color(0.18, 0.77, 0.71)

var emerge: float = 1.0:
	set(k):
		emerge = k
		_wisps.visible = k >= 0.95
		_dirty = true
		queue_redraw()
var _row: GhostHoverRow.Tail
var _chain: PackedVector2Array = []
var _vertices: PackedVector2Array = []
var _indices: PackedInt32Array = []
var _uvs: PackedVector2Array = []
var _vapour: ShaderMaterial = ShaderMaterial.new()
var _wisps: GhostTailWisps
var _clock: int = 0
var _socket: Vector2 = Vector2.ZERO
var _socket_width: float = 0.0
var _height_m: float = 0.0
var _dirty: bool = true
var _last_up: Vector2 = Vector2.INF


func _init(row: GhostHoverRow.Tail) -> void:
	_row = row
	_vapour.shader = preload("res://features/souls/ghost_tail.gdshader")
	_vapour.set_shader_parameter(&"grain", GhostVapour.grain())
	_vapour.set_shader_parameter(&"strands", row.strands)
	_vapour.set_shader_parameter(&"fray", row.fray)
	material = _vapour
	_wisps = GhostTailWisps.new(row.wisps)
	add_child(_wisps)
	@warning_ignore("return_value_discarded")
	_vertices.resize((row.segments + 1) * 2)
	for i: int in row.segments + 1:
		var k: float = float(i) / row.segments
		_uvs.append_array([Vector2(k, 0.0), Vector2(k, 1.0)])
		if i < row.segments:
			var j: int = 2 * i
			_indices.append_array([j, j + 1, j + 2, j + 1, j + 3, j + 2])


## root_px is the body-frame anchor already rotated and translated into world pixels.
func reset(root_px: Vector2, facing: float, lift_m: float) -> void:
	_chain.clear()
	_clock = -1
	_wisps.clear()
	align_socket(Vector2.ZERO, 0.0)
	step(root_px, facing, 0.0, lift_m, 1)


func step(root_px: Vector2, facing: float, speed_mps: float, lift_m: float, ticks: int) -> void:
	if ticks <= 0:
		return
	var back: Vector2 = -Vector2.from_angle(facing)
	var length_m: float = _row.length_m + speed_mps * _row.stretch_k
	var link: float = length_m * SimConst.PX_PER_M / _row.segments
	if _chain.is_empty():
		for i: int in _row.segments + 1:
			@warning_ignore("return_value_discarded")
			_chain.append(root_px + back * link * i)
	_height_m = lift_m
	for i: int in ticks:
		_chain[0] = root_px
		for j: int in range(1, _chain.size()):
			var behind: Vector2 = _chain[j - 1].direction_to(_chain[j])
			var dir: Vector2 = back.slerp(behind, _row.swing_k) if behind != Vector2.ZERO else back
			_chain[j] = _chain[j - 1] + dir * link
		_clock += 1
		_dirty = true
		_shed(back, speed_mps)
	_vapour.set_shader_parameter(&"flow", float(_clock) / _row.flow_ticks)
	queue_redraw()


## A shared legacy cell attaches at its cut edge. A rig's own art uses its authored anchor.
func align_socket(offset_px: Vector2, width_px: float) -> void:
	if offset_px != _socket or width_px != _socket_width:
		_socket = offset_px
		_socket_width = width_px
		_dirty = true
		queue_redraw()


func _shed(back: Vector2, speed_mps: float) -> void:
	if _row.wisps <= 0:
		return
	var interval: int = ceili(float(GhostTailWisps.LIFE) / _row.wisps)
	var edge: Vector2 = Vector2.ZERO
	var drift: Vector2 = Vector2.ZERO
	if _clock % interval == 0:
		_update_geometry()
		var birth: int = floori(float(_clock) / interval)
		var j: int = _row.segments - 1 - posmod(birth, maxi(1, floori(_row.segments / 3.0)))
		var side: float = -1.0 if birth % 2 == 0 else 1.0
		edge = _vertices[j * 2 + birth % 2]
		drift = back * (0.5 + minf(speed_mps, 14.0) * 0.14)
		drift += back.orthogonal() * side * (0.25 + _row.spread_m)
	var tip: Vector2 = _centre(_row.segments, ViewMode.shared().lift_px(_height_m * emerge))
	_wisps.follow_tip(tip, _row.length_m * SimConst.PX_PER_M)
	_wisps.step(_clock, edge, drift * SimConst.PX_PER_M)


## Snapshots in world canvas pixels, including the root's height projection.
func points() -> PackedVector2Array:
	_update_geometry()
	var centres: PackedVector2Array = []
	@warning_ignore("return_value_discarded")
	centres.resize(_chain.size())
	for i: int in _chain.size():
		var midpoint: Vector2 = (_vertices[2 * i] + _vertices[2 * i + 1]) * 0.5
		centres[i] = to_global(midpoint)
	return centres


func half_widths() -> PackedFloat32Array:
	_update_geometry()
	var widths: PackedFloat32Array = []
	@warning_ignore("return_value_discarded")
	widths.resize(_chain.size())
	for i: int in _chain.size():
		var across: Vector2 = _vertices[2 * i + 1] - _vertices[2 * i]
		widths[i] = global_transform.basis_xform(across).length() * 0.5
	return widths


func _update_geometry() -> void:
	var up: Vector2 = ViewMode.shared().lift_px(_height_m * emerge)
	if not _dirty:
		if up == _last_up:
			return
		queue_redraw()  # An overlay sampled a new camera pitch between sim ticks.
	_dirty = false
	_last_up = up
	var root: Vector2 = _chain[0] + up + _socket
	var previous_edge: Vector2 = Vector2.ZERO
	for i: int in _chain.size():
		var k: float = float(i) / _row.segments
		var centre: Vector2 = root.lerp(_centre(i, up), emerge)
		var before: int = maxi(0, i - 1)
		var after: int = mini(_row.segments, i + 1)
		var axis: Vector2 = _centre(after, up) - _centre(before, up)
		var width: float = (
			maxf(_socket_width / SimConst.PX_PER_M, _row.width_m) * (1.0 - k + 0.12 * sin(k * PI))
		)
		width += 1.4 * _row.spread_m * sin(k * PI) * (1.0 - k)
		width *= (1.0 + _row.fray * 0.22 * sin(i * 2.4))
		var edge: Vector2 = (
			axis.normalized().orthogonal() * width * SimConst.PX_PER_M * 0.5 * emerge
		)
		if edge.dot(previous_edge) < 0.0:
			edge = -edge
		_vertices[2 * i] = centre - edge
		_vertices[2 * i + 1] = centre + edge
		previous_edge = edge


func _centre(i: int, up: Vector2) -> Vector2:
	var k: float = float(i) / _row.segments
	var arch: float = sin(k * PI)
	var tangent: Vector2 = _chain[maxi(0, i - 1)].direction_to(_chain[mini(i + 1, _row.segments)])
	var curl: float = sin(k * TAU * 1.4 - TAU * _clock / _row.flow_ticks) * _row.curl_m
	var offset: Vector2 = tangent.orthogonal() * curl * arch * SimConst.PX_PER_M
	return (
		_chain[i]
		+ (up + _socket) * (1.0 - k)
		+ ViewMode.shared().lift_px(maxf(_row.rise_m * arch, -_height_m * emerge * (1.0 - k)))
		+ offset
		+ _belt_trail(k, up)
	)


## In the tilted bridge the sprite is a vertical billboard. Let the plume clear its hem
## even when the ground trail points back into the torso in screen space.
func _belt_trail(k: float, up: Vector2) -> Vector2:
	if _socket_width <= 0.0:
		return Vector2.ZERO
	var root: Vector2 = _chain[0] + up + _socket
	var run: Vector2 = _chain[-1] - _chain[0]
	if ViewMode.shared().is_flat():
		return (_socket + run.normalized() * _socket_width * 1.4) * k
	var down: float = maxf(0.0, root.y + _socket_width * 1.15 - _chain[-1].y)
	var fall: float = sin(k * PI) * _socket_width * 0.15
	var head_on: float = maxf(0.0, -run.y - absf(run.x))
	var sweep: float = (run.x * 1.1 - head_on * 1.45) * k
	return Vector2(sweep, down * k + fall)


func _draw() -> void:
	if emerge <= 0.0 or _chain.is_empty():
		return
	_update_geometry()
	RenderingServer.canvas_item_add_triangle_array(
		get_canvas_item(), _indices, _vertices, PackedColorArray(), _uvs
	)
