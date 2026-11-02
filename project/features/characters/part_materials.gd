class_name PartMaterials
extends RefCounted
## The part print materials, SHARED by every rig (per-rig materials would break 2D batching):
## one per (part kind, hit tint, palette swap). set_view() adapts them all to the screen scale.

enum PartKind { PART, LIMB, COLLAR, CORE, HALO }

const SHADER_PATH: String = "res://features/characters/print_part.gdshader"
## Below this many screen px per part px, Rivet's limbs, collar and core print as flat stickers.
const LOD_BELOW: float = 0.13
const LIMB_FILL: float = 0.40

static var view_px: float = 0.1
## The live flat-sticker threshold (the look profile's parts_flat_below; LOD_BELOW by default).
static var flat_below: float = LOD_BELOW
static var world_px: Vector2 = Vector2.ZERO
static var _shader: Shader = null
static var _mats: Dictionary[int, ShaderMaterial] = {}


static func get_mat(kind: PartKind, tint: bool, swap: int) -> ShaderMaterial:
	var key: int = int(kind) * 100 + (10 if tint else 0) + swap
	if not _mats.has(key):
		if _shader == null:
			_shader = load(SHADER_PATH) as Shader
		var m: ShaderMaterial = ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("silhouette", 1.0 if kind == PartKind.HALO else 0.0)
		m.set_shader_parameter("lod_fill", _lod_fill(kind))
		m.set_shader_parameter("limb_fill", LIMB_FILL)
		m.set_shader_parameter("is_limb", 1.0 if kind == PartKind.LIMB else 0.0)
		m.set_shader_parameter("tint", 1.0 if tint else 0.0)
		m.set_shader_parameter("swap", swap)
		_apply_view(m, kind)
		m.set_shader_parameter("world_px", world_px)
		_mats[key] = m
	return _mats[key]


## The look profile's flat-sticker threshold; re-applied to every material on the next set_view.
static func set_flat_below(threshold: float) -> void:
	if not is_equal_approx(threshold, flat_below):
		flat_below = threshold
		view_px = -1.0


## Called once a frame by CharacterRigs: zoom = the camera zoom (1.0 = 32 px/m).
static func set_view(zoom: float) -> void:
	var px: float = CutRig.SC * zoom
	if absf(px - view_px) < 0.002 and not _mats.is_empty():
		return
	view_px = px
	for key: int in _mats:
		@warning_ignore("integer_division")
		_apply_view(_mats[key], (key / 100) as PartKind)


## Called every frame by the host: the camera's world offset in screen px, so the part tooth and
## shadow dots stay locked to the world while the camera pans.
static func set_world_px(px: Vector2) -> void:
	if px == world_px:
		return
	world_px = px
	for key: int in _mats:
		_mats[key].set_shader_parameter("world_px", px)


static func material_count() -> int:
	return _mats.size()


static func _apply_view(m: ShaderMaterial, kind: PartKind) -> void:
	m.set_shader_parameter("px_scale", view_px)
	var lod_kind: bool = kind == PartKind.LIMB or kind == PartKind.COLLAR or kind == PartKind.CORE
	m.set_shader_parameter("limb_lod", 1.0 if lod_kind and view_px < flat_below else 0.0)


static func _lod_fill(kind: PartKind) -> float:
	if kind == PartKind.COLLAR:
		return 1.0
	if kind == PartKind.CORE:
		return 2.0
	return 0.0
