class_name DentHit
extends RefCounted
## The spectral body's reaction about its belt, with the tether attached to the current palm.

## Palm centres on the open-handed HIT card. A live strap or string follows these for ten ticks.
const HIT_PALMS_55: Array[Vector4] = [
	Vector4(198, 84, 70, 84),
	Vector4(205, 77, 80, 96),
	Vector4(163, 56, 195, 96),
	Vector4(148, 54, 215, 63),
	Vector4(46, 54, 204, 52)
]
const HIT_PALMS_70: Array[Vector4] = [
	Vector4(210, 91, 65, 92),
	Vector4(216, 73, 78, 104),
	Vector4(193, 63, 196, 116),
	Vector4(164, 43, 213, 70),
	Vector4(55, 67, 216, 65)
]


## The flight mount has already posed the body. Rotate it in projected screen space.
static func apply(body: DentBody, rivet: Fighter, facing: float, tick: int) -> int:
	var age: int = tick - rivet.hurt_tick if rivet != null and rivet.hurt_tick >= 0 else -1
	var pulse: bool = age in [0, 1, 4, 5] and not body.reduced_motion
	body.drawn.flight.tail.modulate.a = 0.45 if pulse else 1.0
	if age < 0 or age >= GhostDrawn.HIT_TICKS:
		return age
	var tip: float = GhostRecoil.tilt(age, facing, GhostRecoil.lean_of("dent"), rivet.hurt_dir)
	var projection: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
	var screen: Transform2D = body.global_transform.scaled(projection)
	var pose: Transform2D = screen.rotated(tip).scaled(Vector2.ONE / projection)
	pose.origin = body.global_position
	body.global_transform = pose
	return age


static func grip(sprite: Sprite2D, art: String, index: int) -> Vector2:
	var pair: Vector4 = (HIT_PALMS_55 if art == "p55" else HIT_PALMS_70)[sprite.frame_coords.y]
	var left: bool = (index == 0) != sprite.flip_h
	var cell: Vector2 = Vector2(pair.x, pair.y) if left else Vector2(pair.z, pair.w)
	if sprite.flip_h:
		cell.x = sprite.get_rect().size.x - cell.x
	return sprite.to_global(sprite.offset + cell)
