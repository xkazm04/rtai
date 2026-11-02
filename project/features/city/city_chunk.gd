class_name CityChunk
extends RefCounted
## One 128 m chunk of city data (AST-11 payload): the 8 m tile codes, the 1 m cell map, per-tile
## spawn densities and the draw list (texture id + x, y, rotation, shadow flag per command), in
## draw order. Positions are metres in world space (+y is south).

const TILES: int = SimConst.CHUNK_TILES * SimConst.CHUNK_TILES
const CELLS: int = SimConst.CHUNK_CELLS * SimConst.CHUNK_CELLS
const XF_STRIDE: int = 4

var cx: int = 0
var cy: int = 0
var tiles: PackedByteArray = PackedByteArray()
var cells: PackedByteArray = PackedByteArray()
var dens_ped: PackedByteArray = PackedByteArray()
var dens_car: PackedByteArray = PackedByteArray()
var tex: PackedInt32Array = PackedInt32Array()
var xf: PackedFloat32Array = PackedFloat32Array()


func _init(p_cx: int = 0, p_cy: int = 0) -> void:
	cx = p_cx
	cy = p_cy


static func zeros(n: int) -> PackedByteArray:
	var a: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	a.resize(n)
	return a


func key() -> Vector2i:
	return Vector2i(cx, cy)


func command_count() -> int:
	return tex.size()


## Spawn density 0..255 of the tile under world point (x, y), for people or cars.
func density(x: float, y: float, car: bool) -> int:
	var lx: int = floori(x / SimConst.TILE_M) - cx * SimConst.CHUNK_TILES
	var ly: int = floori(y / SimConst.TILE_M) - cy * SimConst.CHUNK_TILES
	if lx < 0 or ly < 0 or lx >= SimConst.CHUNK_TILES or ly >= SimConst.CHUNK_TILES:
		return 0
	var i: int = ly * SimConst.CHUNK_TILES + lx
	return dens_car[i] if car else dens_ped[i]


## The payload as plain packed arrays (decoded only with bytes_to_var, never *_with_objects).
func to_payload() -> Dictionary:
	return {
		"cx": cx,
		"cy": cy,
		"tiles": tiles,
		"cells": cells,
		"dens_ped": dens_ped,
		"dens_car": dens_car,
		"tex": tex,
		"xf": xf,
	}


## Rebuilds a chunk from a decoded payload; null when any field is missing or mis-sized.
static func from_payload(d: Dictionary) -> CityChunk:
	var types: Dictionary[String, int] = {
		"cx": TYPE_INT,
		"cy": TYPE_INT,
		"tiles": TYPE_PACKED_BYTE_ARRAY,
		"cells": TYPE_PACKED_BYTE_ARRAY,
		"dens_ped": TYPE_PACKED_BYTE_ARRAY,
		"dens_car": TYPE_PACKED_BYTE_ARRAY,
		"tex": TYPE_PACKED_INT32_ARRAY,
		"xf": TYPE_PACKED_FLOAT32_ARRAY,
	}
	for field: String in types:
		if typeof(d.get(field)) != types[field]:
			return null
	var p_cx: int = d["cx"]
	var p_cy: int = d["cy"]
	var c: CityChunk = CityChunk.new(p_cx, p_cy)
	c.tiles = d["tiles"]
	c.cells = d["cells"]
	c.dens_ped = d["dens_ped"]
	c.dens_car = d["dens_car"]
	c.tex = d["tex"]
	c.xf = d["xf"]
	return c if c.is_well_formed() else null


func is_well_formed() -> bool:
	return (
		tiles.size() == TILES
		and cells.size() == CELLS
		and dens_ped.size() == TILES
		and dens_car.size() == TILES
		and xf.size() == tex.size() * XF_STRIDE
	)
