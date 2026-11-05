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

## The ink keyline outside a cut rig's cream halos (keyline()): its width as a fraction of the
## halo across a limb, along it and round a body part; its z sits under every halo (-16, -1).
const KEY_ACROSS: float = 0.35
const KEY_ALONG: float = 0.03
const KEY_BODY: float = 0.09
const KEY_Z: int = -17
const KEYLINE: StringName = &"keyline"
const KEY_SHADER: String = "res://features/souls/ghost_keyline.gdshader"

## false (dev `--no-rim`): the rigs draw no rim (the A/B before).
static var enabled: bool = true
## false (dev `--no-keyline`): no ink keyline (the A/B before).
static var keyline_on: bool = true
static var _key_mat: ShaderMaterial = null


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


## Adds an ink keyline under each of `rig`'s cream halos (RigBuild), a child of the halo so it
## follows its scale and hides with it at close-up zooms: Dent's beige dummy on the cream kerb.
static func keyline(rig: CutRig) -> void:
	if not keyline_on:
		return
	if _key_mat == null:
		_key_mat = ShaderMaterial.new()
		_key_mat.shader = load(KEY_SHADER) as Shader
	for i: int in rig.halos.size():
		var h: Sprite2D = rig.halos[i]
		var k: Sprite2D = Sprite2D.new()
		k.name = KEYLINE
		k.texture = h.texture
		k.centered = h.centered
		k.offset = h.offset
		k.material = _key_mat
		k.z_index = KEY_Z - h.z_index  # relative: every keyline under every halo
		var is_body: bool = rig.halo_limb[i] == RigBuild.HALO_BODY
		k.scale = Vector2(1.0 + KEY_ALONG, 1.0 + KEY_ACROSS)
		if is_body:
			k.scale = Vector2.ONE * (1.0 + KEY_BODY)
		h.add_child(k)


## Keeps the keylines on their halos' art after a part swap (RigBuild.set_tex re-textures the halo).
static func sync_keyline(rig: CutRig) -> void:
	for h: Sprite2D in rig.halos:
		if h.get_child_count() > 0 and h.get_child(0) is Sprite2D:
			var k: Sprite2D = h.get_child(0) as Sprite2D
			k.texture = h.texture
			k.offset = h.offset
