class_name RiotShieldCard
extends RefCounted
## Lane n8 street: the riot cop's shield as an upright frosted plate under a card view. Straight
## down the shield is a crescent part on the forearm (RigArm); seen from a raised camera that reads
## as a thin white arc on the ground. Under a view row with `cards` and a plate for its art
## (StreetCardSets.SHIELD), the crescent hides and a plate card stands where it was: drawn opaque,
## as tall as it is cut, its width following how much of its face turns to the camera (side-on,
## held angled: EDGE_K), in front of the body when nearer the camera than the chest, else behind.
## Render only; straight down, or under art with no plate, nothing here runs.

## The plate's width over the torso part's shoulder span (its texture height: the top-down torso
## lies across the facing), front-on.
const WIDTH_K: float = 0.8
## The narrowest share of the width the plate keeps side-on (held angled, never a bare edge).
const EDGE_K: float = 0.45
## Below the head card (head_z) facing the camera; under the torso facing away.
const BACK_Z: int = 1
static var _tex: Dictionary[String, Texture2D] = {}


## Each pose step under a tilt (CutRig.drive), after RigHeadCard.
static func step(rig: CutRig) -> void:
	var shield: Sprite2D = rig.sides[BodyPlan.L].shield
	if shield == null:
		return
	var art: String = ViewMode.shared().art
	var card: Sprite2D = rig.torso.get_node_or_null(^"shield_card") as Sprite2D
	if card != null and str(card.get_meta(&"art", "")) != art:
		card.name = &"shield_card_dropped"
		card.queue_free()
		card = null
	var path: String = StreetCardSets.shield_for(art)
	if not ViewMode.shared().cards or path.is_empty():
		return
	if card == null:
		card = _build(rig, path, art)
	card.visible = shield.visible
	shield.visible = false
	if card.visible:
		_place(rig, card, shield)


static func _build(rig: CutRig, path: String, art: String) -> Sprite2D:
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var card: Sprite2D = Sprite2D.new()
	card.name = &"shield_card"
	card.texture = _tex[path]
	card.set_meta(&"art", art)
	rig.torso.add_child(card)
	return card


static func _place(rig: CutRig, card: Sprite2D, shield: Sprite2D) -> void:
	var fwd: Vector2 = Vector2.RIGHT.rotated(rig.global_rotation)
	var w_world: float = rig.torso_spr.texture.get_height() * absf(rig.torso_spr.global_scale.y)
	var s: float = w_world * WIDTH_K / card.texture.get_width()
	var face: float = maxf(absf(fwd.y), EDGE_K)
	card.global_rotation = 0.0
	card.global_scale = Vector2(s * face, s / ViewMode.shared().ground_k())
	card.global_position = shield.global_position
	card.flip_h = fwd.x < 0.0
	var near: bool = shield.global_position.y > rig.torso.global_position.y
	card.z_index = rig.plan.head_z - 1 if near else BACK_Z
