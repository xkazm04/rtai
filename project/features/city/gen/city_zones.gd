class_name CityZones
extends RefCounted
## The district's zones and its zone map (city_district.json, gtai.city-district/2): which zone
## row paints each chunk. The ONE source of a chunk's zone (zone-progression-linting: single-
## sourcing): the generator paints from it, other features (police counts, places) read it via
## CityGen.zones / CitySystem, nobody keeps a parallel table. Chunks are 2 x 2 street periods,
## so a zone boundary always runs along a street.

var rows: Array[CityZone] = []
var _by_chunk: PackedInt32Array = PackedInt32Array()
var _chunks: int = SimConst.CITY_CHUNKS


## Today's city: one `mixed` zone everywhere (the v14 look).
func _init() -> void:
	rows.append(CityZone.new())
	var n: int = _by_chunk.resize(_chunks * _chunks)
	assert(n == OK)
	_by_chunk.fill(0)


## Reads `zones` (rows) and `zone_map` ({default, rects: [{zone, chunks: [x, y, w, h]}]}, later
## rects win) from a district row; a district without zones keeps the single default zone.
static func from_district(district: Dictionary) -> CityZones:
	var z: CityZones = CityZones.new()
	var zone_rows: Array = district.get("zones", [])
	if zone_rows.is_empty():
		return z
	z.rows.clear()
	for row: Dictionary in zone_rows:
		z.rows.append(CityZone.from_row(row))
	var map: Dictionary = district.get("zone_map", {})
	z._by_chunk.fill(maxi(z.index_of(StringName(str(map.get("default", "mixed")))), 0))
	for rect: Dictionary in map.get("rects", []):
		var chunks: Array = rect["chunks"]
		z._paint_rect(z.index_of(StringName(str(rect["zone"]))), chunks)
	return z


func index_of(zone_id: StringName) -> int:
	for i: int in rows.size():
		if rows[i].id == zone_id:
			return i
	return -1


func of_chunk(cx: int, cy: int) -> CityZone:
	return rows[_by_chunk[_index(cx, cy)]]


func id_of_chunk(cx: int, cy: int) -> StringName:
	return of_chunk(cx, cy).id


## The zone of a world tile (8 m); tiles off the map take the nearest edge chunk's zone.
func of_tile(t: Vector2i) -> CityZone:
	var n: int = SimConst.CHUNK_TILES
	return of_chunk(floori(float(t.x) / n), floori(float(t.y) / n))


func _index(cx: int, cy: int) -> int:
	return clampi(cy, 0, _chunks - 1) * _chunks + clampi(cx, 0, _chunks - 1)


func _paint_rect(zone: int, chunks: Array) -> void:
	if zone < 0 or chunks.size() != 4:
		return
	var r: Array[int] = CityZone.ints(chunks)
	for cy: int in range(maxi(r[1], 0), mini(r[1] + r[3], _chunks)):
		for cx: int in range(maxi(r[0], 0), mini(r[0] + r[2], _chunks)):
			_by_chunk[cy * _chunks + cx] = zone
