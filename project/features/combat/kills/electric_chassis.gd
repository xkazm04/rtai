class_name ElectricChassis
extends RefCounted
## Carry the visible shield or turret cel across contact with its fitted scale and facing.
## These live cards are siblings of their hidden rig, outside the articulated cut.


static func card_of(rig: CutRig, victim: StringName) -> Sprite2D:
	if rig == null or victim not in [&"shield_robot", &"sentry_turret"]:
		return null
	var key: StringName = (
		FoeShieldCardView.CARD if victim == &"shield_robot" else FoeTurretCardView.CARD
	)
	if not rig.has_meta(key):
		return null
	var live: Sprite2D = rig.get_meta(key)
	if not live.visible or live.texture == null:
		return null
	var card: Sprite2D = GibCut._copy(live)
	card.scale = live.scale
	card.rotation = live.rotation
	for child: Node in live.get_children():
		if child is Sprite2D and (child as Sprite2D).visible:
			var apron: Sprite2D = GibCut._copy(child as Sprite2D)
			apron.transform = (child as Sprite2D).transform
			card.add_child(apron)
	return card


## The struck chest has a gunmetal pressure plate and an optic over the gap between the arms.
static func fit_core(chassis: Node2D, ppm: float, joint_m: float, side: float) -> void:
	var core: Sprite2D = _plate(FoeShieldView.TORSO, 0.91 * ppm)
	core.position = Vector2.UP * joint_m * ppm
	core.z_index = 25
	chassis.add_child(core)
	var cap: Sprite2D = _plate(FoeTurretView.HEAD, 0.49 * ppm)
	cap.position = core.position + Vector2(0.04 * side, -0.28) * ppm
	cap.z_index = 26
	chassis.add_child(cap)


static func _plate(texture: Texture2D, width: float) -> Sprite2D:
	var plate: Sprite2D = Sprite2D.new()
	plate.texture = texture
	plate.scale = Vector2.ONE * width / texture.get_width()
	return plate
