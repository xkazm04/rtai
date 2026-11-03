class_name SimArrays
extends RefCounted
## Sized, filled packed arrays for the reference sim (resize() returns an error code, which the
## strict warning set will not let a caller drop), and the names of the float64 state fields.

const ACTOR_F64: Array[String] = [
	"px",
	"py",
	"hx",
	"hy",
	"v",
	"vmax",
	"phase",
	"t1",
	"t2",
	"sx",
	"sy",
	"lane",
	"nlane",
	"jx",
	"jy",
	"stuck",
]
const PROJ_F64: Array[String] = ["qx", "qy", "qvx", "qvy", "qt"]


static func u8(n: int) -> PackedByteArray:
	var a: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	a.resize(n)
	a.fill(0)
	return a


static func f64(n: int) -> PackedFloat64Array:
	var a: PackedFloat64Array = PackedFloat64Array()
	@warning_ignore("return_value_discarded")
	a.resize(n)
	a.fill(0.0)
	return a


static func i32(n: int, value: int) -> PackedInt32Array:
	var a: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	a.resize(n)
	a.fill(value)
	return a


static func f32(n: int) -> PackedFloat32Array:
	var a: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	a.resize(n)
	a.fill(0.0)
	return a


## Allocates every actor and projectile array of a state (all zero; dir/ndir/res -1).
static func alloc_actors(s: CitySimState) -> void:
	var n: int = SimConst.CAP
	s.alive = SimArrays.u8(n)
	s.kind = SimArrays.u8(n)
	s.tier = SimArrays.u8(n)
	s.mode = SimArrays.u8(n)
	s.variant = SimArrays.u8(n)
	s.flags = SimArrays.u8(n)
	for f: String in SimArrays.ACTOR_F64:
		s.set(f, SimArrays.f64(n))
	s.dir = SimArrays.i32(n, -1)
	s.ndir = SimArrays.i32(n, -1)
	s.res = SimArrays.i32(n, -1)
	s.qalive = SimArrays.u8(SimConst.PCAP)
	for f: String in SimArrays.PROJ_F64:
		s.set(f, SimArrays.f64(SimConst.PCAP))


## Stamps one chunk's tile and cell maps into a state (and bumps its map version).
static func copy_chunk(
	s: CitySimState, cx: int, cy: int, tiles: PackedByteArray, cells: PackedByteArray
) -> void:
	s.map_version += 1
	var nt: int = SimConst.CHUNK_TILES
	var nc: int = SimConst.CHUNK_CELLS
	for ly: int in nt:
		for lx: int in nt:
			s.tiles[(cy * nt + ly) * SimConst.TW + cx * nt + lx] = tiles[ly * nt + lx]
	var base: int = cy * nc * SimConst.W + cx * nc
	for ly: int in nc:
		var row: int = base + ly * SimConst.W
		var src: int = ly * nc
		for lx: int in nc:
			s.cells[row + lx] = cells[src + lx]


## The parity / replay snapshot of a sim state (CitySimBackend.snapshot()).
static func snapshot(s: CitySimState) -> PackedFloat64Array:
	var out: PackedFloat64Array = PackedFloat64Array()
	for i: int in SimConst.CAP:
		if s.alive[i] == 0:
			continue
		(
			out
			. append_array(
				[
					i,
					s.kind[i],
					s.mode[i],
					s.tier[i],
					s.px[i],
					s.py[i],
					s.hx[i],
					s.hy[i],
					s.v[i],
					s.phase[i],
					s.t1[i],
					s.t2[i],
					s.dir[i],
					s.ndir[i],
				]
			)
		)
	for k: int in SimConst.PCAP:
		if s.qalive[k] != 0:
			out.append_array([SimConst.SNAP_PROJ_BASE + k, s.qx[k], s.qy[k]])
	return out
