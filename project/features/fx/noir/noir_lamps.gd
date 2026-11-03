class_name NoirLamps
extends RefCounted
## D-Noir street light (lane noir): the city's lamp posts (the draw list's `lamp_post` props, read
## from the resident chunks) as pools of white light in the noir pass, so the black street is
## carved by light. Render only: reads chunk data, never sim state. Each chunk is scanned once.

const MAX_LAMPS: int = 8
const PROP: String = "lamp_post"
## The lamp art is the arm seen from above, the head (the light) at its +x end: the pool centres
## under the head, over the kerb, not on the post's base (nor on a roof behind it).
const HEAD_M: float = 1.0

var tex_id: int = -1
var _cache: Dictionary[Vector2i, PackedVector2Array] = {}


func _init(texture_table: Dictionary) -> void:
	for row: Dictionary in texture_table.get("textures", []):
		if row.get("name", "") == PROP:
			tex_id = row["id"]


## The lamp heads of one chunk (metres), from its draw list.
static func scan(chunk: CityChunk, id: int) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for k: int in chunk.command_count():
		var o: int = k * CityChunk.XF_STRIDE
		# a lamp is drawn twice: its offset shadow first (xf[3] = 1), then the post itself
		if chunk.tex[k] == id and chunk.xf[o + 3] < 0.5:
			var head: Vector2 = Vector2.from_angle(chunk.xf[o + 2]) * HEAD_M
			@warning_ignore("return_value_discarded")
			out.append(Vector2(chunk.xf[o], chunk.xf[o + 1]) + head)
	return out


## Up to MAX_LAMPS lamps (metres) whose pool of radius reach_m touches the view rect around
## focus (half extents half_m), nearest first.
func near(
	res: CityResidency, focus: Vector2, half_m: Vector2, reach_m: float
) -> PackedVector2Array:
	var view: Rect2 = Rect2(focus - half_m, half_m * 2.0).grow(reach_m)
	var found: Array[Vector2] = []
	for key: Vector2i in res.resident_keys():
		var box: Rect2 = Rect2(Vector2(key) * SimConst.CHUNK_M, Vector2.ONE * SimConst.CHUNK_M)
		if not box.intersects(view):
			continue
		if not _cache.has(key):
			_cache[key] = scan(res.chunk_at(key), tex_id)
		for p: Vector2 in _cache[key]:
			if view.has_point(p):
				found.append(p)
	found.sort_custom(func(a: Vector2, b: Vector2) -> bool: return _closer(a, b, focus))
	var out: PackedVector2Array = PackedVector2Array()
	for i: int in mini(found.size(), MAX_LAMPS):
		@warning_ignore("return_value_discarded")
		out.append(found[i])
	return out


## Lamps in metres -> the pass's screen px (FRAGCOORD space) for a camera at world_px and zoom.
static func to_screen(
	lamps: PackedVector2Array, world_px: Vector2, zoom: float
) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in lamps:
		@warning_ignore("return_value_discarded")
		out.append(p * SimConst.PX_PER_M * zoom - world_px)
	return out


## Drops cached chunks (an evicted chunk may come back with the same data; cheap to rescan).
func forget(key: Vector2i) -> void:
	@warning_ignore("return_value_discarded")
	_cache.erase(key)


static func _closer(a: Vector2, b: Vector2, focus: Vector2) -> bool:
	var da: float = a.distance_squared_to(focus)
	var db: float = b.distance_squared_to(focus)
	return da < db or (da == db and (a.x < b.x or (a.x == b.x and a.y < b.y)))
