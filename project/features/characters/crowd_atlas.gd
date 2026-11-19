class_name CrowdAtlas
extends RefCounted
## The baked crowd (LOD 1): every crowd look x clip x frame pre-rendered from the real rig into
## one atlas, for the city's MultiMesh people layer. The layout and the clip table are fixed, so
## they exist (and are testable) without rendering; only `texture` needs a GPU (CrowdBaker).
##   cell = look * FRAMES_PER_LOOK + CLIP_FIRST[clip] + frame;  atlas col = cell % cols, row = look
## clip_table(): (first cell, frame count, fps) per look x clip, in the city's order
## (SimConst: CLIP_VARIANTS = 8 looks, CLIPS = 6: idle walk flee hit death shoot), exactly the
## PackedInt32Array CitySimRender.setup() takes. Integrate: MultiMesh texture = texture, material
## = crowd_material(), custom.x = cell, custom.y = actor slot + 1 (0 = bake size).

enum Clip { IDLE, WALK, FLEE, HIT, DEATH, SHOOT }

const LOOKS: int = RigVariant.CROWD_COUNT
const CLIPS: int = 6
const FRAMES: Array[int] = [1, 8, 8, 2, 4, 2]
const FPS: Array[int] = [1, 12, 16, 12, 10, 12]
const CLIP_FIRST: Array[int] = [0, 1, 9, 17, 19, 23]
const FRAMES_PER_LOOK: int = 25
## Ten 16-texel blocks a side. All 25 columns fit a 4096-wide texture at 64 px/m.
const CELL_PX: int = 160
const BAKE_ZOOM: float = 2.0
## Projected texels from the tile's top left to the actor. The raised walker grows up
## from its feet; the p70 fall extends right from the point where the walker stood.
const CENTRE: Vector2i = Vector2i(CELL_PX / 2, CELL_PX / 2)
const FLAT: Vector2i = Vector2i(72, 77)  # rightward gun and 156-texel top-view sprawl
const STANDING: Vector2i = Vector2i(CENTRE.x, 132)
const FALLING: Vector2i = Vector2i(32, 108)
## A prone p70 sprite extends over 2.5 m to the right. Keep its vertical samples at 64 px/m.
const FALL_X: float = 0.625
const SHADER_PATH: String = "res://features/characters/crowd_atlas.gdshader"

var texture: Texture2D = null
var baked: bool = false
var bake_view: ViewMode


static func cols() -> int:
	return FRAMES_PER_LOOK


static func rows() -> int:
	return LOOKS


static func cell_world_px() -> float:
	return CELL_PX / BAKE_ZOOM


static func anchor(view: ViewMode, clip: Clip) -> Vector2i:
	if not view.cards:
		return FLAT
	if clip == Clip.DEATH:
		return FALLING if drawn_fall(view) else CENTRE
	return STANDING


static func drawn_fall(view: ViewMode) -> bool:
	return view.cards and view.art == "p70"


static func bake_scale(view: ViewMode, clip: Clip) -> Vector2:
	var zoom: Vector2 = view.zoom_of(BAKE_ZOOM)
	if clip == Clip.DEATH and drawn_fall(view):
		zoom.x *= FALL_X
	return zoom


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
	configure_material(m)
	return m


## Also used by prints that include crowd_atlas_vertex.gdshaderinc and supply a fragment shader.
func configure_material(m: ShaderMaterial) -> void:
	var view: ViewMode = bake_view if bake_view != null else ViewMode.shared()
	m.set_shader_parameter("cols", cols())
	m.set_shader_parameter("rows", rows())
	m.set_shader_parameter("snap_dead", StreetDeadHeading.ENABLED and view.cards)
	m.set_shader_parameter("standing_shift", Vector2(CENTRE - anchor(view, Clip.IDLE)) / CELL_PX)
	m.set_shader_parameter("fall_shift", Vector2(CENTRE - anchor(view, Clip.DEATH)) / CELL_PX)
	m.set_shader_parameter("ground_k", view.ground_k())
	m.set_shader_parameter("drawn_fall", drawn_fall(view))
	m.set_shader_parameter("fall_x", FALL_X if drawn_fall(view) else 1.0)
	m.set_shader_parameter("slot_sizes", view.cards)
	if view.cards:
		var scales: PackedFloat32Array = PackedFloat32Array()
		var baked_scale: float = StreetCrowdCards.body_scale(-1)
		for slot: int in SimConst.CAP:
			@warning_ignore("return_value_discarded")
			scales.append(StreetCrowdCards.body_scale(slot) / baked_scale)
		m.set_shader_parameter("body_scales", scales)
	m.set_shader_parameter("head_even", StreetDeadHeading.HEAD_DEG)
	m.set_shader_parameter("head_odd", StreetDeadHeading.HEAD_DEG_ODD)
