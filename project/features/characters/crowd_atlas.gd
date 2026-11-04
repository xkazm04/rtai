class_name CrowdAtlas
extends RefCounted
## The baked crowd (LOD 1): every crowd look x clip x frame pre-rendered from the real rig into
## one atlas, for the city's MultiMesh people layer. The layout and the clip table are fixed, so
## they exist (and are testable) without rendering; only `texture` needs a GPU (CrowdBaker).
##   cell = look * FRAMES_PER_LOOK + CLIP_FIRST[clip] + frame;  atlas col = cell % cols, row = look
## clip_table(): (first cell, frame count, fps) per look x clip, in the city's order
## (SimConst: CLIP_VARIANTS = 8 looks, CLIPS = 6: idle walk flee hit death shoot), exactly the
## PackedInt32Array CitySimRender.setup() takes. Integrate: MultiMesh texture = texture, material
## = crowd_material(), instance custom.x = cell, quad size = cell_world_px.

enum Clip { IDLE, WALK, FLEE, HIT, DEATH, SHOOT }

const LOOKS: int = RigVariant.CROWD_COUNT
const CLIPS: int = 6
const FRAMES: Array[int] = [1, 8, 8, 2, 4, 2]
const FPS: Array[int] = [1, 12, 16, 12, 10, 12]
const CLIP_FIRST: Array[int] = [0, 1, 9, 17, 19, 23]
const FRAMES_PER_LOOK: int = 25
const CELL_PX: int = 128
## The bake camera: 48 px/m (zoom 1.5), so a cell covers 128 / 1.5 world px (2.67 m).
const BAKE_ZOOM: float = 1.5
const SHADER_PATH: String = "res://features/characters/crowd_atlas.gdshader"

var texture: Texture2D = null
var baked: bool = false


static func cols() -> int:
	return FRAMES_PER_LOOK


static func rows() -> int:
	return LOOKS


static func cell_world_px() -> float:
	return CELL_PX / BAKE_ZOOM


static func clip_table() -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	for look: int in LOOKS:
		for c: int in CLIPS:
			out.append_array([look * FRAMES_PER_LOOK + CLIP_FIRST[c], FRAMES[c], FPS[c]])
	return out


## The cell for a look playing clip c at clip time t (s): looping clips wrap, hit and death hold
## their last frame (the same rule as the city's CitySimClips.frame_of). A look past the crowd
## cast (RigVariant.SWAT) prints as its atlas_look.
static func cell_for(p_look: int, c: Clip, t: float) -> int:
	var look: int = RigVariant.atlas_look(p_look)
	var n: int = FRAMES[c]
	var f: int = int(t * FPS[c])
	f = mini(f, n - 1) if c == Clip.HIT or c == Clip.DEATH else f % n
	return look * FRAMES_PER_LOOK + CLIP_FIRST[c] + f


## The clip a feed row shows when it is not full-rigged.
static func clip_of(feed: RigFeed, i: int) -> Clip:
	if feed.has_flag(i, RigFeed.Flag.DEAD) or feed.has_flag(i, RigFeed.Flag.DOWN):
		return Clip.DEATH
	if feed.clip[i] == RigClips.Clip.HIT:
		return Clip.HIT
	if feed.has_flag(i, RigFeed.Flag.GUN_OUT):
		return Clip.SHOOT
	if feed.vel[i].length_squared() > 36.0:
		return Clip.FLEE if feed.has_flag(i, RigFeed.Flag.FLEE) else Clip.WALK
	return Clip.IDLE


func crowd_material() -> ShaderMaterial:
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = load(SHADER_PATH) as Shader
	m.set_shader_parameter("cols", cols())
	m.set_shader_parameter("rows", rows())
	return m
