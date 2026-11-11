class_name GroundDropShowcase
extends RefCounted
## n17 npc-react (owner: "weapons after kill are not wrapped in showcase component and not having
## consistent directions"): a dead guard's dropped gun (CombatArena.rifle_drops, the assault-rifle
## pickup) draws the pickup's WeaponShowcase drawing (the arsenal's art stand-in: assault-rifle ->
## machine_pistol, the gun Rivet then holds), keyed by the view's art like every floor pickup,
## stood up for the camera and never spun. One rule for its direction: it lies along the shot, the
## muzzle pointing the way the round flew on screen (mirrored, never turned), PAST_M beyond his
## feet on the side away from his body (StreetDeadRests; an own-cell death publishes none and the
## pistol snap falls toward the shooter: -shot). GroundRifle's spot back toward the shooter lay
## under the snap's corpse (film drop_068c_d0), a spot across the shot under a diagonal one (film
## drop_4394_swat32). Before: the sheet at one of 8 headings hashed from the position.
## Straight down (no form), `--showcase=off` or ON
## false = GroundRifle's sheet (the before).
const ON: bool = true
const PICKUP: StringName = &"assault-rifle"
## A shot within this of straight up or down the screen keeps the muzzle to +x (no flicker).
const VERTICAL_X: float = 0.05
## How far (m) past his feet, away from his body, the gun's middle lies.
const PAST_M: float = 0.75
## A published rest whose feet lie within this (m) of the drop is his.
const MATCH_M: float = 1.5

static var _showcase: WeaponShowcase = null
static var _art: StringName = &""


## The drawing a drop shows at the view's form (null: none, the caller draws its sheet).
static func texture() -> Texture2D:
	var form: String = WeaponShowcase.form_of(ViewMode.shared())
	if not ON or form == "":
		return null
	if _showcase == null:
		_showcase = WeaponShowcase.new()
		_art = ArsenalTable.shipped().art_id(PICKUP)
	return _showcase.texture(_art, form)


## True when the drawing was drawn beside the drop at `at` (m), its muzzle along `shot` (the
## shot's ground direction, from the shooter), `length_m` long; false = none (the caller's sheet).
static func draw(ci: CanvasItem, at: Vector2, shot: Vector2, length_m: float) -> bool:
	var tex: Texture2D = texture()
	if tex == null:
		return false
	var lies: Vector2 = lies_at(at, shot)
	var gk: float = maxf(ViewMode.shared().ground_k(), 0.1)
	var k: float = length_m * Ink.PX_PER_M / float(tex.get_width())
	var size: Vector2 = Vector2(tex.get_width() * k, tex.get_height() * k / gk)
	var px: Vector2 = Ink.px(lies)
	ci.draw_set_transform(px + GroundRifle.SHADOW_OFF, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false, Color(0, 0, 0, GroundRifle.SHADOW.a))
	ci.draw_set_transform(px, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false)
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)
	return true


## Where the gun lies for a drop at `at` (m) after a shot along `shot`: past his feet, away
## from his body.
static func lies_at(at: Vector2, shot: Vector2) -> Vector2:
	var body: Vector2 = body_dir(at)
	if body == Vector2.ZERO:
		body = -shot.normalized()
	return at - body * PAST_M


## The way the body lying at a drop `at` (m) reaches from its feet (unit; ZERO: no published rest
## within MATCH_M).
static func body_dir(at: Vector2) -> Vector2:
	var best: float = MATCH_M
	var dir: Vector2 = Vector2.ZERO
	for r: Vector4 in StreetDeadRests.all.values():
		var feet: Vector2 = Vector2(r.x, r.y) / Ink.PX_PER_M
		var chest: Vector2 = Vector2(r.z, r.w) / Ink.PX_PER_M
		if feet.distance_to(at) < best and chest != feet:
			best = feet.distance_to(at)
			dir = (chest - feet).normalized()
	return dir


## +1 when the muzzle (+x in the drawing) points right on screen, -1 when the drawing is mirrored.
static func sign_x(shot: Vector2) -> float:
	return -1.0 if shot.x < -VERTICAL_X else 1.0
