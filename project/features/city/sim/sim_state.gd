class_name CitySimState
extends RefCounted
## Struct-of-arrays state of the GDScript reference sim, plus the world maps and the shared LCG.
## Mirrors native/sim_core's state field for field; the parity gate compares them exactly.

const DX: Array[float] = [1.0, 0.0, -1.0, 0.0]  # E S W N (+y is south)
const DY: Array[float] = [0.0, 1.0, 0.0, -1.0]
const LANE_OFF: Array[float] = [2.0, -2.0, -2.0, 2.0]  # lane = road centre + LANE_OFF[dir]
## 16 headings from integer vectors normalised with sqrt (exact in both runtimes; decimal
## literals are not: GDScript and MSVC round the same literal apart in the last bit).
const DIR16I: Array[int] = [
	1,
	0,
	12,
	5,
	1,
	1,
	5,
	12,
	0,
	1,
	-5,
	12,
	-1,
	1,
	-12,
	5,
	-1,
	0,
	-12,
	-5,
	-1,
	-1,
	-5,
	-12,
	0,
	-1,
	5,
	-12,
	1,
	-1,
	12,
	-5,
]

var ra: float = 80.0
var rb: float = 160.0
var riot_r: float = 14.0
var time: float = 0.0
var rs: int = 1
var dir16x: PackedFloat64Array
var dir16y: PackedFloat64Array
# actors
var alive: PackedByteArray
var kind: PackedByteArray
var tier: PackedByteArray
var mode: PackedByteArray
var variant: PackedByteArray
var flags: PackedByteArray
var px: PackedFloat64Array
var py: PackedFloat64Array
var hx: PackedFloat64Array
var hy: PackedFloat64Array
var v: PackedFloat64Array
var vmax: PackedFloat64Array
var phase: PackedFloat64Array
var t1: PackedFloat64Array
var t2: PackedFloat64Array
var sx: PackedFloat64Array
var sy: PackedFloat64Array
var lane: PackedFloat64Array
var nlane: PackedFloat64Array
var jx: PackedFloat64Array
var jy: PackedFloat64Array
var stuck: PackedFloat64Array
var dir: PackedInt32Array
var ndir: PackedInt32Array
var res: PackedInt32Array
# projectiles
var qalive: PackedByteArray
var qx: PackedFloat64Array
var qy: PackedFloat64Array
var qvx: PackedFloat64Array
var qvy: PackedFloat64Array
var qt: PackedFloat64Array
# world: 8 m tiles, 1 m cells, junction reservation owners (slot + 1)
var tiles: PackedByteArray
var cells: PackedByteArray
var owner: PackedInt32Array
var counters: PackedInt32Array
## Points outside the sim traffic brakes for (x, y pairs, at most OBST_MAX; set_obstacles()).
var obst: PackedFloat64Array = PackedFloat64Array()
## Bumped by every chunk stamp or clear (the flow field rebuilds on a change).
var map_version: int = 0


func init(seed_value: int) -> void:
	rs = seed_value & 0xFFFFFFFF
	time = 0.0
	obst = PackedFloat64Array()
	map_version = 0
	dir16x = SimArrays.f64(16)
	dir16y = SimArrays.f64(16)
	for k: int in 16:
		var ix: float = DIR16I[k * 2]
		var iy: float = DIR16I[k * 2 + 1]
		var l: float = sqrt(ix * ix + iy * iy)
		dir16x[k] = ix / l
		dir16y[k] = iy / l
	SimArrays.alloc_actors(self)
	tiles = SimArrays.u8(SimConst.TW * SimConst.TW)
	cells = SimArrays.u8(SimConst.W * SimConst.W)
	owner = SimArrays.i32(SimConst.TW * SimConst.TW, 0)
	counters = SimArrays.i32(SimConst.CN_COUNT, 0)


## The shared 32-bit LCG: identical sequence in GDScript and C++.
func rnd() -> float:
	rs = (rs * SimConst.LCG_MUL + SimConst.LCG_ADD) & 0xFFFFFFFF
	return float(rs >> 8) / 16777216.0


func cell_at(x: float, y: float) -> int:
	var ix: int = floori(x)
	var iy: int = floori(y)
	if ix < 0 or iy < 0 or ix >= SimConst.W or iy >= SimConst.W:
		return 0
	return cells[iy * SimConst.W + ix]


func tile_at(x: float, y: float) -> int:
	var ix: int = floori(x / 8.0)
	var iy: int = floori(y / 8.0)
	if ix < 0 or iy < 0 or ix >= SimConst.TW or iy >= SimConst.TW:
		return 0
	return tiles[iy * SimConst.TW + ix]


func spawn(spec: PackedFloat64Array) -> int:
	for i: int in SimConst.CAP:
		if alive[i] != 0:
			continue
		var k: int = int(spec[SimConst.SP_KIND])
		var fl: int = int(spec[SimConst.SP_FLAGS])
		alive[i] = 1
		kind[i] = k
		tier[i] = 1
		variant[i] = int(spec[SimConst.SP_VARIANT])
		flags[i] = fl
		mode[i] = SimConst.M_RIOT if (fl & SimConst.F_RIOTER) != 0 else SimConst.M_WALK
		_place(i, spec)
		t2[i] = 1.0 if k == SimConst.K_COP else 0.0
		dir[i] = int(spec[SimConst.SP_DIR])
		ndir[i] = -1
		res[i] = -1
		return i
	return -1


func kill(i: int) -> void:
	alive[i] = 0
	var r: int = res[i]
	if r >= 0 and owner[r] == i + 1:
		owner[r] = 0
	res[i] = -1
	counters[SimConst.CN_DESPAWNED] += 1


func fire(x: float, y: float, vx: float, vy: float, ttl: float) -> void:
	for k: int in SimConst.PCAP:
		if qalive[k] == 0:
			qalive[k] = 1
			qx[k] = x
			qy[k] = y
			qvx[k] = vx
			qvy[k] = vy
			qt[k] = ttl
			return


func _place(i: int, spec: PackedFloat64Array) -> void:
	var x: float = spec[SimConst.SP_X]
	var y: float = spec[SimConst.SP_Y]
	px[i] = x
	py[i] = y
	hx[i] = spec[SimConst.SP_DX]
	hy[i] = spec[SimConst.SP_DY]
	v[i] = 0.0
	vmax[i] = spec[SimConst.SP_VMAX]
	phase[i] = 0.0
	t1[i] = 0.0
	sx[i] = x
	sy[i] = y
	lane[i] = spec[SimConst.SP_LANE]
	nlane[i] = lane[i]
	jx[i] = 0.0
	jy[i] = 0.0
	stuck[i] = 0.0
