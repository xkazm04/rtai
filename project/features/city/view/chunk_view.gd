class_name ChunkView
extends RefCounted
## Draws resident chunks (WLD-02 stage 2): one chunk at a time, nearest first, its draw list
## recorded into pooled RenderingServer canvas items, one per world render layer (ground,
## ground_decals, building_shadows, props, roofs: core/render/README.md) per 64 m quadrant so
## off-screen quadrants cull, time-sliced to BUDGET_US per frame. Items are cleared
## and pooled, never freed mid-run (pooling cut the worst swap frame 6.1 -> 1.8 ms in the spike,
## WLD-05). Render only: the sim's residency is CityResidency.

const R_DRAW: float = 190.0
const BUDGET_US: int = 1500
## The world canvas bands a chunk draws into, bottom up; a command's band comes from its class.
const BANDS: Array[StringName] = [
	&"ground", &"ground_decals", &"building_shadows", &"props", &"roofs"
]
const BAND_OF_CLASS: Dictionary[String, int] = {
	"ground": 0, "decal": 1, "prop": 3, "vehicle": 3, "building": 4
}
const SHADOW_BAND: int = 2
## The parapet ink core (n-d5's D5HeroParapets): each building's silhouette again in solid ink,
## offset cast_shadows.json parapet_core_m down-right, just above the hatched shadow (z + 1): it
## shows as an ink band along the down-right edges that face open ground (a neighbour roof, on
## the roofs band, covers it on the inner edges).
const CORE_BAND: int = 5
const ITEMS: int = 4 * 6
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.45)
const CORE: Color = Color(0.09, 0.075, 0.106, 1.0)
## AST-03: the world art carries mipmaps and is drawn below 1:1.
const MIPMAP_FILTER: RenderingServer.CanvasItemTextureFilter = (
	RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
)

var frame_us: int = 0
var frame_cmds: int = 0
var frame_swapped: bool = false
var activated: int = 0
var released: int = 0
## lifted roofs over south faces under an angled view (null when flat: `top` untouched)
var lift: ChunkLift = null
var _parent: RID
var _tex: CityTextures
var _drawn: Dictionary[Vector2i, Array] = {}
var _pool: Array[RID] = []
var _active: Vector2i = Vector2i(-1, -1)
var _k: int = 0
var _band_of: PackedByteArray = PackedByteArray()
## The building_shadows band's material and per-texture extra cast offset (CastShadows).
var _shadow_mat: ShaderMaterial = null
var _shadow_extra: PackedVector2Array = PackedVector2Array()
var _shadow_zoom: float = 1.0
## the parapet core's offset from the baked building shadow command (px); _core_on = drawn
var _core_px: Vector2 = Vector2.ZERO
var _core_on: bool = false
var _is_building: Array[bool] = []


func _init(parent: RID, textures: CityTextures) -> void:
	_parent = parent
	_tex = textures
	for cls: String in textures.classes:
		var band: int = BAND_OF_CLASS.get(cls, 3)
		@warning_ignore("return_value_discarded")
		_band_of.append(band)
		_is_building.append(cls == "building")
	var casts: CastShadows = CastShadows.load_table()
	_shadow_mat = casts.material()
	_shadow_extra = casts.extra_px(textures.classes, SimConst.PX_PER_M, textures.names)
	_core_on = casts.parapet_core_m > 0.0
	_core_px = Vector2.ONE * (casts.parapet_core_m - casts.baked_m(&"building")) * SimConst.PX_PER_M
	lift = ChunkLift.make(textures, _is_building)


## zoom: the camera zoom (1 = 32 px/m); the shadow strokes keep their screen spacing above 64 px/m.
func update(focus: Vector2, res: CityResidency, zoom: float = 1.0) -> void:
	var t0: int = Time.get_ticks_usec()
	if _shadow_mat != null and zoom != _shadow_zoom:
		_shadow_zoom = zoom
		_shadow_mat.set_shader_parameter(&"zoom", zoom)
	frame_cmds = 0
	frame_swapped = false
	if lift != null and lift.stale():  # a live pitch settled: redraw every chunk
		_active = Vector2i(-1, -1)
		for key: Vector2i in _drawn.keys():
			_release(key)
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
		var c: int = lift.nth(_k, chunk) if lift != null else _k
		var t: int = chunk.tex[c]
		var o: int = c * CityChunk.XF_STRIDE
		var pos: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1])
		var shadow: bool = chunk.xf[o + 3] > 0.5
		var q: int = (1 if pos.x - origin.x >= 64.0 else 0) + (2 if pos.y - origin.y >= 64.0 else 0)
		var item: RID = items[q + 4 * (SHADOW_BAND if shadow else _band_of[t])]
		var sz: Vector2 = _tex.size_px[t]
		var at: Vector2 = pos * SimConst.PX_PER_M + (_shadow_extra[t] if shadow else Vector2.ZERO)
		if lift != null and _is_building[t] and not shadow:
			at = lift.face(item, t, chunk.xf[o + 2], at)
		RenderingServer.canvas_item_add_set_transform(item, Transform2D(chunk.xf[o + 2], at))
		RenderingServer.canvas_item_add_texture_rect(
			item, Rect2(-sz * 0.5, sz), _tex.rids[t], false, SHADOW if shadow else Color.WHITE
		)
		if shadow and _core_on and _is_building[t]:
			var core_item: RID = items[q + 4 * CORE_BAND]
			_core(core_item, t, chunk.xf[o + 2], pos * SimConst.PX_PER_M)
		_k += 1
		frame_cmds += 1
		if (_k & 31) == 0 and Time.get_ticks_usec() - t0 > BUDGET_US:
			return
	activated += 1
	_active = Vector2i(-1, -1)


## A shadow command's building silhouette in solid ink at the parapet core offset (`at`: the
## shadow command's position in px, which carries the baked offset).
func _core(item: RID, t: int, rot: float, at: Vector2) -> void:
	var sz: Vector2 = _tex.size_px[t]
	RenderingServer.canvas_item_add_set_transform(item, Transform2D(rot, at + _core_px))
	RenderingServer.canvas_item_add_texture_rect(
		item, Rect2(-sz * 0.5, sz), _tex.rids[t], false, CORE
	)


func _take_items() -> Array:
	var items: Array = []
	for q: int in ITEMS:
		var item: RID = (
			_pool.pop_back() if not _pool.is_empty() else RenderingServer.canvas_item_create()
		)
		RenderingServer.canvas_item_set_parent(item, _parent)
		var band: int = q >> 2
		var z: int = (
			RenderLayers.z(BANDS[band])
			if band < CORE_BAND
			else RenderLayers.z(&"building_shadows") + 1
		)
		RenderingServer.canvas_item_set_z_index(item, z)
		RenderingServer.canvas_item_set_default_texture_filter(item, MIPMAP_FILTER)
		var shadow_band: bool = (q >> 2) == SHADOW_BAND and _shadow_mat != null
		RenderingServer.canvas_item_set_material(
			item, _shadow_mat.get_rid() if shadow_band else RID()
		)
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
