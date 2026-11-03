class_name BloodStains
extends Node2D
## D-Noir blood on the bodies (lane noir): a kill soaks the victim with red stains and a hit
## leaves small spots on the player, drawn ABOVE the rigs and following each body (the pools and
## splats stay on the ground, under them). Stains sit a little toward the exit side of the hit.
## Data: blood_fx.json `stain`. Positions come from `locate`: Callable(id: int) -> Vector2 in
## this node's px, or Vector2.INF. Scatter is a counter hash (no RNG stream, no sim state).
## Stepped on the fixed tick. Render only.

const Z: int = 20

var locate: Callable = Callable()
var _p: Dictionary = {}
var _max: int = 48
var _grow: int = 24
var _tick: int = 0
var _k: int = 0
var _id: PackedInt32Array = PackedInt32Array()
var _off: PackedVector2Array = PackedVector2Array()
var _dir: PackedVector2Array = PackedVector2Array()
var _r: PackedFloat32Array = PackedFloat32Array()
var _born: PackedInt32Array = PackedInt32Array()
var _blood: Color = Color(0.64, 0.02, 0.035)
var _dark: Color = Color(0.46, 0.0, 0.03)


func _init() -> void:
	z_index = Z
	var d: Dictionary = NoirLook.read_params(BloodFx.PARAMS)
	_p = d.get("stain", {})
	_max = _p.get("max_stains", _max)
	_grow = _p.get("grow_ticks", _grow)
	var c: Dictionary = d.get("colour", {})
	_blood = _col(c.get("blood", []), _blood)
	_dark = _col(c.get("blood_dark", []), _dark)


## Stains body `id` after a hit travelling along `dir`; `kind` is a row of the `stain` table.
func mark(id: int, dir: Vector2, kind: String) -> void:
	var row: Dictionary = _p.get(kind, {})
	var spots: int = row.get("spots", 0)
	var r: Array = row.get("r_px", [2.0, 4.0])
	var spread: float = row.get("spread_px", 4.0)
	var exit: float = row.get("exit_px", 2.0)
	var n: Vector2 = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	for i: int in spots:
		var jitter: Vector2 = Vector2(_rand() - 0.5, _rand() - 0.5) * 2.0 * spread
		var r0: float = r[0]
		var r1: float = r[1]
		var off: Vector2 = n * exit * (0.4 + _rand()) + jitter
		_add(id, off, n.rotated((_rand() - 0.5) * 1.2), lerpf(r0, r1, _rand()))


## Stains on body `id` now (tests, evidence).
func count(id: int) -> int:
	var c: int = 0
	for v: int in _id:
		c += 1 if v == id else 0
	return c


func step_ticks(n: int) -> void:
	_tick += n
	queue_redraw()


func _add(id: int, off: Vector2, dir: Vector2, r: float) -> void:
	if _id.size() >= _max:
		_id.remove_at(0)
		_off.remove_at(0)
		_dir.remove_at(0)
		_r.remove_at(0)
		_born.remove_at(0)
	@warning_ignore("return_value_discarded")
	_id.append(id)
	@warning_ignore("return_value_discarded")
	_off.append(off)
	@warning_ignore("return_value_discarded")
	_dir.append(dir)
	@warning_ignore("return_value_discarded")
	_r.append(r)
	@warning_ignore("return_value_discarded")
	_born.append(_tick)


func _draw() -> void:
	if not locate.is_valid():
		return
	for i: int in _id.size():
		var at: Vector2 = locate.call(_id[i])
		if at == Vector2.INF:
			continue
		var g: float = clampf(float(_tick - _born[i]) / maxf(_grow, 1.0), 0.3, 1.0)
		var r: float = _r[i] * g
		draw_circle(at + _off[i], r * 1.15, _dark)
		BloodMarks.splat(self, at + _off[i], r, _dir[i] * 0.45, _blood)


func _rand() -> float:
	_k += 1
	return fposmod(sin(_k * 91.3458 + 7.13) * 47453.5453, 1.0)


static func _col(raw: Variant, fallback: Color) -> Color:
	if not raw is Array:
		return fallback
	var v: Array = raw
	if v.size() < 3:
		return fallback
	var r: float = v[0]
	var g: float = v[1]
	var b: float = v[2]
	return Color(r, g, b)
