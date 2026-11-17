class_name GroundDropShowcase
extends RefCounted
## n17 npc-react (owner: "weapons after kill are not wrapped in showcase component and not having
## consistent directions"): a dead guard's dropped gun (CombatArena.rifle_drops, the assault-rifle
## pickup) draws the pickup's WeaponShowcase drawing (the arsenal's art stand-in: assault-rifle ->
## machine_pistol, the gun Rivet then holds), keyed by the view's art like every floor pickup,
## stood up for the camera and never spun. One rule for its direction: it lies along the shot, the
## muzzle pointing the way the round flew on screen (mirrored, never turned), PAST_M beyond his
## feet on the side away from his body (StreetDeadRests); with no rest (gibbed, an own-cell death)
## SIDE_M across the shot on the camera side (along it lay in the gib's spray, film
## dra_rocket_launcher t218). GroundRifle's spot back toward the shooter lay
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
## With no rest: how far (m) across the shot line, on the camera's side, the gun lies.
const SIDE_M: float = 0.6
## A published rest whose feet lie within this (m) of the drop is his.
const MATCH_M: float = 1.5
## n17 (film dr_machine_pistol t190 -> t191: the gun jumped ~1 m from across the shot to past his
## feet when his corpse published its rest at the lying frame): a drop's spot is fixed at its first
## draw, so a dropped gun never moves. LATCH false = recomputed each draw (the before).
const LATCH: bool = true
const LATCH_MAX: int = 256

static var _showcase: WeaponShowcase = null
static var _art: StringName = &""
## (drop m, shot) -> where it lies (m), from its first draw.
static var _lies: Dictionary[Vector4, Vector2] = {}


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
## from his body; no body: across the shot, screen down (straight down the screen: to the right).
static func lies_at(at: Vector2, shot: Vector2) -> Vector2:
	var key: Vector4 = Vector4(at.x, at.y, shot.x, shot.y)
	if LATCH and _lies.has(key):
		return _lies[key]
	if _lies.size() >= LATCH_MAX:  # a long session's old drops (they decay long before)
		_lies.clear()
	_lies[key] = place(at, shot)
	return _lies[key]


## lies_at's rule, unlatched.
static func place(at: Vector2, shot: Vector2) -> Vector2:
	var body: Vector2 = body_dir(at)
	if body != Vector2.ZERO:
		return at - body * PAST_M
	var side: Vector2 = shot.normalized().orthogonal()
	if side.y < 0.0 or (is_zero_approx(side.y) and side.x < 0.0):
		side = -side
	return at + side * SIDE_M


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
