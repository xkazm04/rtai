class_name GroundDropShowcase
extends RefCounted
## n17 npc-react (owner: "weapons after kill are not wrapped in showcase component and not having
## consistent directions"): a dead guard's dropped gun (CombatArena.rifle_drops, the assault-rifle
## pickup) draws the pickup's WeaponShowcase drawing (the arsenal's art stand-in: assault-rifle ->
## machine_pistol, the gun Rivet then holds), keyed by the view's art like every floor pickup,
## stood up for the camera and never spun. One rule for its direction: it lies along the shot, the
## muzzle pointing the way the round flew on screen (mirrored, never turned), where GroundRifle
## places it (back toward the shooter, to one side). Before, the lying-rifle sheet picked one of 8
## headings from a hash of the drop's position. Straight down (no form), `--showcase=off` or ON
## false = GroundRifle's sheet (the before).
const ON: bool = true
const PICKUP: StringName = &"assault-rifle"
## A shot within this of straight up or down the screen keeps the muzzle to +x (no flicker).
const VERTICAL_X: float = 0.05

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


## True when the drawing was drawn at `lies` (m), its muzzle along `shot` (the shot's ground
## direction, from the shooter), `length_m` long; false = no drawing (the caller's sheet).
static func draw(ci: CanvasItem, lies: Vector2, shot: Vector2, length_m: float) -> bool:
	var tex: Texture2D = texture()
	if tex == null:
		return false
	var gk: float = maxf(ViewMode.shared().ground_k(), 0.1)
	var k: float = length_m * Ink.PX_PER_M / float(tex.get_width())
	var size: Vector2 = Vector2(tex.get_width() * k, tex.get_height() * k / gk)
	var at: Vector2 = Ink.px(lies)
	ci.draw_set_transform(at + GroundRifle.SHADOW_OFF, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false, Color(0, 0, 0, GroundRifle.SHADOW.a))
	ci.draw_set_transform(at, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false)
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)
	return true


## +1 when the muzzle (+x in the drawing) points right on screen, -1 when the drawing is mirrored.
static func sign_x(shot: Vector2) -> float:
	return -1.0 if shot.x < -VERTICAL_X else 1.0
