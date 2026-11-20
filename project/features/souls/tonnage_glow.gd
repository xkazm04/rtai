class_name TonnageGlow
extends RefCounted
## The additive sprite inherits the inked sprite's transform, visibility and pose opacity.

const GLOW_GAIN: float = 1.0
const GLOW_BODY_ALPHA: float = 0.88
const GLOW_IMPACT_ALPHA: float = 0.55
const GLOW_COLOR: Color = HaulerLook.TEAL
const GLOW_FILL_ALPHA: float = 0.42 * GLOW_GAIN
const GLOW_HALO_ALPHA: float = 0.62 * GLOW_GAIN
const GLOW_DIAMETER_M: float = 5.6
## The painted torso centre relative to the tilted cell's baseline, in atlas pixels.
const GLOW_CELL_CENTRE: Vector2 = Vector2(0.0, -108.0)

static var _add: CanvasItemMaterial


static func body_alpha(pose: TonnagePose) -> float:
	if pose.act and pose.column != TonnagePose.Act.RAISE:
		return GLOW_IMPACT_ALPHA
	return GLOW_BODY_ALPHA


static func on_body(source: Sprite2D) -> Sprite2D:
	var light: Sprite2D = Sprite2D.new()
	light.centered = source.centered
	light.texture = source.texture
	light.offset = source.offset
	light.texture_filter = source.texture_filter
	light.material = _material()
	light.self_modulate = Color(GLOW_COLOR, GLOW_FILL_ALPHA)
	source.add_child(light)
	return light


static func halo() -> Sprite2D:
	var pool: Sprite2D = GhostRim.soft_glow(
		GLOW_COLOR, GLOW_HALO_ALPHA, GLOW_DIAMETER_M * SimConst.PX_PER_M
	)
	pool.material = _material()
	# Let even a guard or blood decal directly beside the body occlude the haze.
	pool.z_as_relative = false
	pool.z_index = RenderLayers.z(&"blood") - 1
	return pool


static func _material() -> CanvasItemMaterial:
	if _add == null:
		_add = CanvasItemMaterial.new()
		_add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _add
