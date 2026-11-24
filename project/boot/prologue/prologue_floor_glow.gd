class_name PrologueFloorGlow
extends CanvasLayer
## Warm light laid on the ground under the actors: one additive radial sprite per pool, clipped to
## the yard rect so no glow lands on the hall front or the void. It sits on the actors canvas,
## ahead of the actor layer in the tree, so it draws after the print pass (which would posterise
## it) and under every actor. Render only. A kind whose floor_glow strength is 0 draws nothing.

const TEXTURE_PX: int = 128
const SPRITE_PREFIX: String = "Glow_"

static var _texture: GradientTexture2D = null
static var _material: CanvasItemMaterial = null


static func attach(stage: PrintStage, lights: PrologueYardLights, yard: Rect2) -> void:
	var node: PrologueFloorGlow = build(lights, yard)
	stage.add_child(node)
	stage.move_child(node, stage.actor_layer().get_index())


static func build(lights: PrologueYardLights, yard: Rect2) -> PrologueFloorGlow:
	var node: PrologueFloorGlow = PrologueFloorGlow.new()
	node.name = "FloorGlow"
	node.layer = RenderLayers.canvas(&"actors")
	node.follow_viewport_enabled = true
	for pool: PrologueYardLights.Pool in lights.pools:
		var glow: Dictionary = lights.floor_glow(pool.kind)
		var strength: float = glow.get("strength", 0.0)
		if strength <= 0.0:
			continue
		var sprite: Sprite2D = node._sprite(pool, glow, yard)
		if sprite != null:
			node.add_child(sprite)
	return node


func _sprite(pool: PrologueYardLights.Pool, glow: Dictionary, yard: Rect2) -> Sprite2D:
	var radius: float = glow["radius_m"]
	var square: Rect2 = Rect2(pool.at_m - Vector2(radius, radius), Vector2(radius, radius) * 2.0)
	var clipped: Rect2 = square.intersection(yard)
	if not clipped.has_area():
		return null
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = SPRITE_PREFIX + String(pool.id)
	sprite.texture = _radial()
	sprite.material = _additive()
	sprite.centered = false
	sprite.region_enabled = true
	var k: float = float(TEXTURE_PX) / square.size.x
	sprite.region_rect = Rect2((clipped.position - square.position) * k, clipped.size * k)
	sprite.position = clipped.position * SimConst.PX_PER_M
	sprite.scale = Vector2.ONE * (SimConst.PX_PER_M / k)
	var tint: Color = glow["color"]
	var strength: float = glow["strength"]
	sprite.modulate = Color(tint.r * strength, tint.g * strength, tint.b * strength, 1.0)
	return sprite


static func _radial() -> GradientTexture2D:
	if _texture == null:
		var ramp: Gradient = Gradient.new()
		ramp.offsets = PackedFloat32Array([0.0, 0.3, 0.65, 1.0])
		ramp.colors = PackedColorArray(
			[Color(1, 1, 1, 1), Color(1, 1, 1, 0.62), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0)]
		)
		_texture = GradientTexture2D.new()
		_texture.gradient = ramp
		_texture.fill = GradientTexture2D.FILL_RADIAL
		_texture.fill_from = Vector2(0.5, 0.5)
		_texture.fill_to = Vector2(1.0, 0.5)
		_texture.width = TEXTURE_PX
		_texture.height = TEXTURE_PX
	return _texture


static func _additive() -> CanvasItemMaterial:
	if _material == null:
		_material = CanvasItemMaterial.new()
		_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _material
