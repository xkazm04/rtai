class_name CityGen
extends RefCounted
## Deterministic city generator (ported from the cityscale spike's gen.gd). A pure function of
## the district (seed) and the texture table: the same inputs give byte-identical chunks, which
## AST-12 checks by baking twice and against a golden hash list. Street layout: a 64 m period
## (kerb, road, kerb + a 5 x 5 tile block); junctions are 3 x 3 tiles; blocks are buildings or
## plazas by seed.

## Bump when the output of any generator code changes (it is stamped into every chunk header).
const GENERATOR_VERSION: int = 9
const PERIOD: int = 8

var seed_value: int = 1
var district_id: String = ""
var sizes: Array[Vector2] = []
var solid: Array[bool] = []
var _tiles: TilePainter = null


func _init(p_seed: int, texture_table: Dictionary) -> void:
	seed_value = p_seed
	var rows: Array = texture_table.get("textures", [])
	for row: Dictionary in rows:
		var size_m: Array = row["size_m"]
		var w: float = size_m[0]
		var h: float = size_m[1]
		sizes.append(Vector2(w, h))
		var is_solid: bool = row["solid"]
		solid.append(is_solid)
	_tiles = TilePainter.new()


## Loads the authored district + texture table from data/tables (DAT-02).
static func from_tables(district_path: String, textures_path: String) -> CityGen:
	var district: Dictionary = read_json(district_path)
	var textures: Dictionary = read_json(textures_path)
	if district.is_empty() or textures.is_empty():
		return null
	var p_seed: float = district.get("seed", 1.0)
	var gen: CityGen = CityGen.new(int(p_seed), textures)
	gen.district_id = str(district.get("id", ""))
	return gen


static func h32(value: int) -> int:
	var x: int = value & 0xFFFFFFFF
	x = ((x ^ (x >> 16)) * 0x45D9F3B) & 0xFFFFFFFF
	x = ((x ^ (x >> 16)) * 0x45D9F3B) & 0xFFFFFFFF
	return x ^ (x >> 16)


## Hash noise in [0, 1) for a lattice point (a, b, c) and a salt.
func rnd(a: int, b: int, c: int, salt: int) -> float:
	var inner: int = h32(a * 73856093 + h32(b * 19349663 + h32(c * 83492791 + salt)))
	var h: int = h32(seed_value * 0x9E3779B1 + inner)
	return float(h & 0xFFFFFF) / 16777216.0


func gen_chunk(cx: int, cy: int) -> CityChunk:
	var b: ChunkBuild = ChunkBuild.new(cx, cy)
	b.district = 0.45 + 0.55 * rnd(cx >> 2, cy >> 2, 0, 11)
	var n: int = SimConst.CHUNK_TILES
	for ly: int in n:
		for lx: int in n:
			b.chunk.tiles[ly * n + lx] = _tiles.paint(self, b, cx * n + lx, cy * n + ly)
	return b.finish()


static func read_json(path: String) -> Dictionary:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return {}
	var d: Dictionary = parser.data
	return d
