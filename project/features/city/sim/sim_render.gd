class_name CitySimRender
extends RefCounted
## The reference sim's MultiMesh writer: every visible actor into five 2D-transform buffers
## (people, people shadows, cars, car shadows, bullets; RL_STRIDE floats per instance: 2x4
## transform rows, colour, custom x = atlas cell), one upload per layer per frame. Render output
## is not sim state: parity and replay never read it. Only the fallback path uses this writer;
## the game draws through the native one.

const S_PED: float = 122.88
const S_SHADOW: float = 25.6
const CAR_L: float = 204.8
const CAR_W: float = 102.4
const INK: Color = Color(0.09, 0.075, 0.106, 1.0)
const BULLET: Color = Color(1.0, 0.85, 0.4, 1.0)

var counts: PackedInt32Array = SimArrays.i32(SimConst.RL_COUNT, 0)
var _s: CitySimState
var _mms: Array[RID] = []
var _clips: PackedInt32Array = PackedInt32Array()
var _layers: Array[Array] = []


func _init(state: CitySimState) -> void:
	_s = state


func setup(mms: Array[RID], clips: PackedInt32Array) -> void:
	_mms = mms
	_clips = clips


func write(vx0: float, vy0: float, vx1: float, vy1: float) -> void:
	if _mms.size() != SimConst.RL_COUNT:
		return
	_layers.clear()
	for k: int in SimConst.RL_COUNT:
		var layer: Array[float] = []
		_layers.append(layer)
	var view: Rect2 = Rect2(vx0, vy0, vx1 - vx0, vy1 - vy0)
	var pxm: float = SimConst.PX_PER_M
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0 or not view.has_point(Vector2(_s.px[i], _s.py[i])):
			continue
		var pos: Vector2 = Vector2(_s.px[i] * pxm, _s.py[i] * pxm)
		var h: Vector2 = Vector2(_s.hx[i], _s.hy[i])
		var k: int = _s.kind[i]
		if k == SimConst.K_PED or k == SimConst.K_COP:
			_put(
				SimConst.RL_PED_SHADOWS,
				Vector2.RIGHT,
				Vector2(S_SHADOW, S_SHADOW),
				pos + Vector2(2, 3)
			)
			_tint(SimConst.RL_PED_SHADOWS, Color(INK, 0.3), 0)
			_put(SimConst.RL_PEDS, h, Vector2(S_PED, S_PED), pos)
			_tint(SimConst.RL_PEDS, Color.WHITE, _frame_cell(i))
		else:
			_put(SimConst.RL_CARS, h, Vector2(CAR_L, CAR_W), pos)
			_tint(SimConst.RL_CARS, Color.WHITE, _s.variant[i])
			_put(SimConst.RL_CAR_SHADOWS, h, Vector2(CAR_L, CAR_W), pos + Vector2(5.12, 5.12))
			_tint(SimConst.RL_CAR_SHADOWS, Color(INK, 0.45), _s.variant[i])
	_write_bullets(view)
	_upload()


func _write_bullets(view: Rect2) -> void:
	var pxm: float = SimConst.PX_PER_M
	for k: int in SimConst.PCAP:
		if _s.qalive[k] != 0 and view.has_point(Vector2(_s.qx[k], _s.qy[k])):
			var pos: Vector2 = Vector2(_s.qx[k] * pxm, _s.qy[k] * pxm)
			_put(SimConst.RL_BULLETS, Vector2.RIGHT, Vector2(9.6, 9.6), pos)
			_tint(SimConst.RL_BULLETS, BULLET, 0)


## Transform rows: x axis = heading * size.x, y axis = perpendicular * size.y, origin pos.
func _put(layer: int, h: Vector2, size: Vector2, pos: Vector2) -> void:
	var out: Array = _layers[layer]
	out.append_array(
		[h.x * size.x, -h.y * size.y, 0.0, pos.x, h.y * size.x, h.x * size.y, 0.0, pos.y]
	)


func _tint(layer: int, c: Color, cell: int) -> void:
	var out: Array = _layers[layer]
	out.append_array([c.r, c.g, c.b, c.a, float(cell), 0.0, 0.0, 0.0])


func _upload() -> void:
	for k: int in SimConst.RL_COUNT:
		var floats: Array = _layers[k]
		var buf: PackedFloat32Array = PackedFloat32Array(floats)
		var cap: int = SimConst.PCAP if k == SimConst.RL_BULLETS else SimConst.CAP
		@warning_ignore("return_value_discarded")
		buf.resize(cap * SimConst.RL_STRIDE)
		RenderingServer.multimesh_set_buffer(_mms[k], buf)
		@warning_ignore("integer_division")
		var n: int = floats.size() / SimConst.RL_STRIDE
		RenderingServer.multimesh_set_visible_instances(_mms[k], n)
		counts[k] = n


func _frame_cell(i: int) -> int:
	var cl: int = CitySimClips.clip_of(_s, i)
	var b: int = (_s.variant[i] * SimConst.CLIPS + cl) * 3
	if b + 2 >= _clips.size():
		return 0
	var cnt: int = maxi(_clips[b + 1], 1)
	return _clips[b] + CitySimClips.frame_of(_s, i, cl, Vector2i(cnt, _clips[b + 2]))
