class_name ChunkBuild
extends RefCounted
## Working buffer for one chunk while the generator paints it: cell/tile/density maps and five
## draw layers (ground, decals, shadows, props + parked cars, roofs), flattened in that order.

const LAYERS: int = 5
const L_GROUND: int = 0
const L_DECAL: int = 1
const L_SHADOW: int = 2
const L_PROP: int = 3
const L_ROOF: int = 4
const FIRST_BUILDING: int = 14
const LAST_BUILDING: int = 23
const GENERIC_ROOF: int = 65  # the generic roofs, 65-71 (city_textures.json)

var chunk: CityChunk
var district: float = 1.0
var _tex: Array[Array] = []
var _xf: Array[Array] = []


func _init(cx: int, cy: int) -> void:
	chunk = CityChunk.new(cx, cy)
	chunk.tiles = CityChunk.zeros(CityChunk.TILES)
	chunk.cells = CityChunk.zeros(CityChunk.CELLS)
	chunk.dens_ped = CityChunk.zeros(CityChunk.TILES)
	chunk.dens_car = CityChunk.zeros(CityChunk.TILES)
	for i: int in LAYERS:
		var tex: Array[int] = []
		var xf: Array[float] = []
		_tex.append(tex)
		_xf.append(xf)


## One draw command; a shadowed one also gets an offset copy on the shadow layer.
func add(layer: int, t: int, pos: Vector2, rot: float, shadow: bool = false) -> void:
	if shadow:
		var roof: bool = (t >= FIRST_BUILDING and t <= LAST_BUILDING) or t >= GENERIC_ROOF
		var o: float = 0.25 if roof else 0.18
		_push(L_SHADOW, t, Vector2(pos.x + o, pos.y + o), rot, 1.0)
	_push(layer, t, pos, rot, 0.0)


## Stamps a world-metre rect of cells with `code`, clipped to this chunk.
func stamp(r: Rect2, code: int) -> void:
	var n: int = SimConst.CHUNK_CELLS
	var x0: int = maxi(floori(r.position.x) - chunk.cx * n, 0)
	var y0: int = maxi(floori(r.position.y) - chunk.cy * n, 0)
	var x1: int = mini(ceili(r.end.x) - chunk.cx * n, n)
	var y1: int = mini(ceili(r.end.y) - chunk.cy * n, n)
	for y: int in range(y0, y1):
		for x: int in range(x0, x1):
			chunk.cells[y * n + x] = code


## Sets one cell by world cell coordinates (must lie in this chunk).
func set_cell(gx: int, gy: int, code: int) -> void:
	var n: int = SimConst.CHUNK_CELLS
	chunk.cells[(gy - chunk.cy * n) * n + (gx - chunk.cx * n)] = code


## Flattens the layers into the chunk's draw list. The ground layer is sorted by texture (stable,
## by insertion order within a texture) so the 2D batcher can merge it.
func finish() -> CityChunk:
	_sort_ground()
	var all_tex: Array[int] = []
	var all_xf: Array[float] = []
	for layer: int in LAYERS:
		all_tex.append_array(_tex[layer])
		all_xf.append_array(_xf[layer])
	chunk.tex = PackedInt32Array(all_tex)
	chunk.xf = PackedFloat32Array(all_xf)
	return chunk


func _push(layer: int, t: int, pos: Vector2, rot: float, flag: float) -> void:
	_tex[layer].append(t)
	_xf[layer].append_array([pos.x, pos.y, rot, flag])


func _sort_ground() -> void:
	var tex: Array = _tex[L_GROUND]
	var xf: Array = _xf[L_GROUND]
	var order: Array[int] = []
	for i: int in tex.size():
		order.append(i)
	order.sort_custom(
		func(a: int, b: int) -> bool: return tex[a] < tex[b] or (tex[a] == tex[b] and a < b)
	)
	var new_tex: Array[int] = []
	var new_xf: Array[float] = []
	for i: int in order:
		new_tex.append(tex[i])
		new_xf.append_array(xf.slice(i * CityChunk.XF_STRIDE, (i + 1) * CityChunk.XF_STRIDE))
	_tex[L_GROUND] = new_tex
	_xf[L_GROUND] = new_xf
