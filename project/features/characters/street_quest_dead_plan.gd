class_name StreetQuestDeadPlan
extends RefCounted
## n9 world: quest 1's dead dock contractors in the plan-view lying poses (the dead redesigned,
## "they lay down like in the bed now"). The contractors are not rigs (QuestGuardCast keeps them on
## the cast view), so StreetDeadPlan never reached them: every corpse at Dock 9 was the one
## forward-fallen frame of contractor_fall.png. Under a card view with the strip present, a corpse
## draws one of five plan poses (StreetDeadPlan's A-E layout) flat on the ground, the head along
## the blow (away from the way he faced: he faced Rivet when shot), the pose picked as
## StreetDeadPlan.pick (neighbours within NEAR_M differ), turned by the spot's SPREAD pick and the
## id's jitter, the pelvis PELVIS_K of standing along the blow. Stateless per frame, render only.
## No strip (or ENABLED false) = StreetQuestCards.draw_down's drawn frame (the before).

const ENABLED: bool = true
const PATH: String = "res://features/characters/art/view/plan/dead_contractor.png"
## The quest's fighter ids live apart from the rigs' actor ids in StreetDeadPlan's neighbour memory.
const ID_BASE: int = -1000000

static var _tex: Texture2D = null
static var _looked: bool = false


## Draws the dead guard `h` at `at_px` in a plan pose; false = no strip or no card view (the
## caller draws the drawn frame or the sprite).
static func draw(
	canvas: CanvasItem, at_px: Vector2, h: Fighter, px_per_m: float, tint: Color
) -> bool:
	if not ENABLED or not ViewMode.shared().cards or _strip() == null:
		return false
	if tint.a <= 0.0:
		return true  # decayed away (StreetQuestCorpses)
	var t: Transform2D = transform_of(at_px, h, px_per_m)
	var w: float = _tex.get_width() / float(StreetDeadPlan.POSES)
	var hgt: float = float(_tex.get_height())
	var pose: int = StreetDeadPlan.pick(ID_BASE - h.id, &"", at_px)
	canvas.draw_set_transform_matrix(t)
	canvas.draw_texture_rect_region(
		_tex, Rect2(-w * 0.5, -hgt * 0.5, w, hgt), Rect2(w * pose, 0.0, w, hgt), tint
	)
	canvas.draw_set_transform(Vector2.ZERO)
	return true


## The corpse's ground transform: the cell centre (the pelvis) along the blow, the head along it.
static func transform_of(at_px: Vector2, h: Fighter, px_per_m: float) -> Transform2D:
	var blow: Vector2 = blow_of(at_px, h.facing)
	var pose: int = StreetDeadPlan.pick(ID_BASE - h.id, &"", at_px)
	var hv: int = StreetDeadPlan._hash(ID_BASE - h.id)
	var flip: bool = (hv & 1) == 1
	var head: float = StreetDeadPlan.HEAD_ANGLE[pose]
	if flip:
		head = PI - head
	var jitter: float = StreetDeadPlan.JITTER_RAD * (float(posmod(hv >> 4, 1001)) / 500.0 - 1.0)
	var s: float = StreetQuestCards.body_m() * px_per_m / StreetWalkerFall.STILL_PX
	var pelvis: float = StreetDeadPlan.PELVIS_K * StreetWalkerFall.STILL_PX * s
	var at: Vector2 = at_px + blow * pelvis
	return Transform2D(blow.angle() - head + jitter, Vector2(-s if flip else s, s), 0.0, at)


## The blow's direction on the ground: away from the facing, turned by the spot's spread pick.
static func blow_of(at_px: Vector2, facing: Vector2) -> Vector2:
	var f: Vector2 = facing.normalized() if facing.length() > 0.0 else Vector2.RIGHT
	return (-f).rotated(StreetQuestCards.spread_of(at_px))


static func _strip() -> Texture2D:
	if not _looked:
		_looked = true
		_tex = load(PATH) as Texture2D if ResourceLoader.exists(PATH) else null
	return _tex
