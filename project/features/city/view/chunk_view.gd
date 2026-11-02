class_name ChunkView
extends RefCounted
## Draws resident chunks (WLD-02 stage 2): one chunk at a time, nearest first, its draw list
## recorded into 8 pooled RenderingServer canvas items (4 ground + 4 overlay, one per 64 m
## quadrant so off-screen quadrants cull), time-sliced to BUDGET_US per frame. Items are cleared
## and pooled, never freed mid-run (pooling cut the worst swap frame 6.1 -> 1.8 ms in the spike,
## WLD-05). Render only: the sim's residency is CityResidency.

const R_DRAW: float = 190.0
const BUDGET_US: int = 1500
const ITEMS: int = 8
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.45)

var frame_us: int = 0
var frame_cmds: int = 0
var frame_swapped: bool = false
var activated: int = 0
var released: int = 0
var _parent: RID
var _tex: CityTextures
var _drawn: Dictionary[Vector2i, Array] = {}
var _pool: Array[RID] = []
var _active: Vector2i = Vector2i(-1, -1)
var _k: int = 0


func _init(parent: RID, textures: CityTextures) -> void:
	_parent = parent
	_tex = textures


func update(focus: Vector2, res: CityResidency) -> void:
	var t0: int = Time.get_ticks_usec()
	frame_cmds = 0
	frame_swapped = false
	for key: Vector2i in _drawn.keys():
		if (
			key != _active
			and (not res.is_resident(key) or CityResidency.rect_dist(key, focus) > R_DRAW + 64.0)
		):
			_release(key)
	if _active == Vector2i(-1, -1):
		_active = _nearest_undrawn(focus, res)
		_k = 0
		if _active != Vector2i(-1, -1):
			_drawn[_active] = _take_items()
	if _active != Vector2i(-1, -1):
		frame_swapped = true
		_slice(res.chunk_at(_active), t0)
	frame_us = Time.get_ticks_usec() - t0


func drawn_count() -> int:
	return _drawn.size()


func _nearest_undrawn(focus: Vector2, res: CityResidency) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: float = R_DRAW
	for key: Vector2i in res.resident_keys():
		var d: float = CityResidency.rect_dist(key, focus)
		if not _drawn.has(key) and d < best_d:
			best_d = d
			best = key
	return best


func _slice(chunk: CityChunk, t0: int) -> void:
	if chunk == null:
		_active = Vector2i(-1, -1)
		return
	var items: Array = _drawn[_active]
	var origin: Vector2 = Vector2(_active) * SimConst.CHUNK_M
	var n: int = chunk.command_count()
	while _k < n:
		var t: int = chunk.tex[_k]
		var o: int = _k * CityChunk.XF_STRIDE
		var pos: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1])
		var shadow: bool = chunk.xf[o + 3] > 0.5
		var q: int = (1 if pos.x - origin.x >= 64.0 else 0) + (2 if pos.y - origin.y >= 64.0 else 0)
		var item: RID = items[q + (4 if t > 13 or shadow else 0)]
		var sz: Vector2 = _tex.size_px[t]
		RenderingServer.canvas_item_add_set_transform(
			item, Transform2D(chunk.xf[o + 2], pos * SimConst.PX_PER_M)
		)
		RenderingServer.canvas_item_add_texture_rect(
			item, Rect2(-sz * 0.5, sz), _tex.rids[t], false, SHADOW if shadow else Color.WHITE
		)
		_k += 1
		frame_cmds += 1
		if (_k & 31) == 0 and Time.get_ticks_usec() - t0 > BUDGET_US:
			return
	activated += 1
	_active = Vector2i(-1, -1)


func _take_items() -> Array:
	var items: Array = []
	for q: int in ITEMS:
		var item: RID = (
			_pool.pop_back() if not _pool.is_empty() else RenderingServer.canvas_item_create()
		)
		RenderingServer.canvas_item_set_parent(item, _parent)
		RenderingServer.canvas_item_set_z_index(item, 0 if q < 4 else 1)
		items.append(item)
	return items


func _release(key: Vector2i) -> void:
	for item: RID in _drawn[key]:
		RenderingServer.canvas_item_clear(item)
		_pool.append(item)
	@warning_ignore("return_value_discarded")
	_drawn.erase(key)
	released += 1
	frame_swapped = true


## Frees every canvas item this view created (WLD-05: the creator frees).
func dispose() -> void:
	for key: Vector2i in _drawn.keys():
		_release(key)
	for item: RID in _pool:
		RenderingServer.free_rid(item)
	_pool.clear()
