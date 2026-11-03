class_name BloodSplatMesh
extends MultiMeshInstance2D
## The landed droplets of the blood (BloodDecals splats) as one MultiMesh (lane d5-combat): each
## splat is a quad in units of its radius, rotated along its travel, and fx_blood_splat.gdshader
## draws the same teardrop + satellites + lobes BloodMarks.splat drew with ~11 draw_circle calls
## (61 ms for 400 splats on the CPU, the riot budget's worst line). A splat is written once, into
## its ring slot, when it lands; the shader fades it from its birth tick (the `tick` uniform), so
## a frame where nothing lands writes no instance at all. Drawn behind its BloodFx's pools.
## Instance data: colour, custom = (elongation, seed, detail, birth tick).

const SHADER: String = "res://assets/shaders/fx_blood_splat.gdshader"
## The quad in splat radii: the satellites run up to ~5.2 r ahead, the core and lobes ~1 r round.
const QUAD_MIN: Vector2 = Vector2(-1.5, -1.6)
const QUAD_MAX: Vector2 = Vector2(5.9, 1.6)
const STRIDE: int = 16

## Instances written since boot (evidence: the buffer is touched only when splats land).
var written: int = 0
## The fluid's ground colour (BloodFx.use_splat_mesh sets it).
var colour: Color = Color.WHITE
var _buf: PackedFloat32Array = PackedFloat32Array()
var _mat: ShaderMaterial = ShaderMaterial.new()
var _dirty: bool = false


func _init(capacity: int) -> void:
	show_behind_parent = true
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	var quad: QuadMesh = QuadMesh.new()
	quad.size = QUAD_MAX - QUAD_MIN
	var mid: Vector2 = (QUAD_MAX + QUAD_MIN) * 0.5
	quad.center_offset = Vector3(mid.x, mid.y, 0.0)
	mm.mesh = quad
	# world px run to the tens of thousands: never cull on a stale buffer AABB (as CrowdLayers)
	mm.custom_aabb = AABB(Vector3(-1e7, -1e7, -10), Vector3(2e7, 2e7, 20))
	mm.instance_count = capacity
	multimesh = mm
	_mat.shader = load(SHADER)
	_mat.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	material = _mat
	@warning_ignore("return_value_discarded")
	_buf.resize(capacity * STRIDE)
	mm.buffer = _buf


## The fade (BloodFx `decal` table: ticks before it starts, ticks it takes, the floor).
func set_fade(after: int, fade: int, min_alpha: float) -> void:
	_mat.set_shader_parameter(&"fade_after", float(after))
	_mat.set_shader_parameter(&"fade_ticks", float(maxi(fade, 1)))
	_mat.set_shader_parameter(&"min_alpha", min_alpha)


## A rim `w` splat radii wide in `tone` round each splat (oil's cream rim); 0 = none.
func set_halo(w: float, tone: Color) -> void:
	_mat.set_shader_parameter(&"halo", w)
	_mat.set_shader_parameter(&"halo_tone", Vector3(tone.r, tone.g, tone.b))


## The print grain's world lock (CityView.world_px) and the tick the fade reads.
func update(world_px: Vector2, tick: int) -> void:
	_mat.set_shader_parameter(&"world_px", world_px)
	_mat.set_shader_parameter(&"tick", float(tick))
	if _dirty:
		multimesh.buffer = _buf
		_dirty = false


## Splat slot `i`: at `at` (px), radius `r`, landed moving `dir` (length = elongation), born on
## tick `born`, in `colour`; its wobble seed is BloodMarks.seed_of(at). r = 0 empties the slot.
func put(i: int, at: Vector2, r: float, dir: Vector2, born: int) -> void:
	var c: Color = colour
	var s: float = BloodMarks.seed_of(at)
	var e: float = clampf(dir.length(), 0.0, 1.0)
	var x: Vector2 = Vector2.from_angle(dir.angle() if e > 0.0 else 0.0) * r
	var o: int = i * STRIDE
	var v: PackedFloat32Array = [
		x.x,
		-x.y,
		0.0,
		at.x,
		x.y,
		x.x,
		0.0,
		at.y,
		c.r,
		c.g,
		c.b,
		c.a,
		e,
		s,
		1.0 if r >= 1.5 else 0.0,
		float(born)
	]
	for k: int in STRIDE:
		_buf[o + k] = v[k]
	_dirty = true
	written += 1
