class_name GhostRim
extends RefCounted
## ghost-forms: the characters' cream sticker rim (RigBuild's halo: the same texture through the
## HALO part material, a cream silhouette) under a light ghost's parts, so thin limbs hold on
## asphalt at 32 px/m the way the cops' and Rivet's do. The rim is a child of its part drawn under
## every part (z RIM_Z), so the rims merge into one outline behind the body.

const RIM_Z: int = -16
## The rim's extra width across a limb and along it, and around a body part (fractions of the part).
const LIMB_ACROSS: float = 0.5
const LIMB_ALONG: float = 0.04
const BODY_K: float = 0.07

## false (dev `--no-rim`): the rigs draw no rim (the A/B before).
static var enabled: bool = true


## Adds a rim under limb sprite `src` (pivot at its near joint, centred across).
static func limb(src: Sprite2D) -> void:
	_add(src, Vector2(1.0 + LIMB_ALONG, 1.0 + LIMB_ACROSS))


## Adds a rim under body sprite `src` (centred).
static func body(src: Sprite2D) -> void:
	_add(src, Vector2.ONE * (1.0 + BODY_K))


static func _add(src: Sprite2D, k: Vector2) -> void:
	if not enabled:
		return
	var h: Sprite2D = Sprite2D.new()
	h.name = RigBuild.HALO
	h.texture = src.texture
	h.centered = src.centered
	h.offset = src.offset
	h.flip_v = src.flip_v
	h.texture_filter = src.texture_filter
	h.material = PartMaterials.get_mat(PartMaterials.PartKind.HALO, false, 0)
	h.z_index = RIM_Z
	h.scale = k
	src.add_child(h)
