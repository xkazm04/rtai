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
## it19: a plan corpse lies opaque (as the rigs' StreetDeadPlan) through the linger, and fades with
## the decay as before; at the cast view's 0.8 the heaped bodies showed through each other.
## false = the cast view's DOWN_FADE alpha (it16).
const OPAQUE: bool = true
## it19: the fall into the pose (the cast view pops a guard from standing to lying): over FALL_TICKS
## from the killing blow the body slides SLIDE_M along the blow into its rest, turns TWIST_RAD into
## it and lands from StreetDeadPlan.LAND_SCALE, eased out. FALL_TICKS 0 = the it16 pop.
const FALL_TICKS: int = 24
const SLIDE_M: float = 0.6
const TWIST_RAD: float = 0.35
## An age past the fall (a settled corpse).
const SETTLED: int = 1 << 20
const PATH: String = "res://features/characters/art/view/plan/dead_contractor.png"
## The quest's fighter ids live apart from the rigs' actor ids in StreetDeadPlan's neighbour memory.
const ID_BASE: int = -1000000

static var _tex: Texture2D = null
static var _looked: bool = false


## Draws the dead guard `h` at `at_px` in a plan pose at the arena tick `now`; false = no strip or
## no card view (the caller draws the drawn frame or the sprite).
static func draw(canvas: CanvasItem, at_px: Vector2, h: Fighter, px_per_m: float, now: int) -> bool:
	if not ENABLED or not ViewMode.shared().cards or _strip() == null:
		return false
	var age: int = now - h.hurt_tick
	var tint: Color = StreetQuestCorpses.tint_of(age, StreetQuestCorpses.BASE)
	if tint.a <= 0.0:
		return true  # decayed away (StreetQuestCorpses)
	var t: Transform2D = transform_of(at_px, h, px_per_m, age)
	var w: float = _tex.get_width() / float(StreetDeadPlan.POSES)
	var hgt: float = float(_tex.get_height())
	var pose: int = StreetDeadPlan.pick(ID_BASE - h.id, &"", at_px)
	var c: Color = ground_tint(tint)
	var cell: Rect2 = Rect2(-w * 0.5, -hgt * 0.5, w, hgt)
	var src: Rect2 = Rect2(w * pose, 0.0, w, hgt)
	var off: Vector2 = StreetDeadHeading.shadow_off(px_per_m)
	if off != Vector2.ZERO:
		var under: Color = StreetDeadHeading.SHADOW
		under.a *= c.a
		canvas.draw_set_transform_matrix(t.translated(off))
		canvas.draw_texture_rect_region(_tex, cell, src, under)
	canvas.draw_set_transform_matrix(t)
	canvas.draw_texture_rect_region(_tex, cell, src, c)
	canvas.draw_set_transform(Vector2.ZERO)
	return true


## it22: where the dead guard `h` lies in metres at the arena tick `now` (its drawn pelvis), so what
## is laid on the body (CorpseStains' soaks) lies on it; h.pos when the plan pose does not draw.
## `px_per_m` is the draw's (CastView's Ink.PX_PER_M): the pick and the push are kept in its px.
static func lying_m(h: Fighter, now: int, px_per_m: float) -> Vector2:
	if not ENABLED or not ViewMode.shared().cards or _strip() == null:
		return h.pos
	var at: Vector2 = h.pos * px_per_m
	return transform_of(at, h, px_per_m, now - h.hurt_tick).origin / px_per_m


## CorpseStains' dead for quest 1 (CollectCallView): id -> where each dead hostile lies in sim px
## (spot_m at the arena tick). `on_rigs`: CastView.fighters_on_rigs.
static func dead_px(arena: CombatArena, on_rigs: bool, px_per_m: float) -> Dictionary[int, Vector2]:
	var out: Dictionary[int, Vector2] = {}
	for h: Fighter in arena.hostiles:
		if not h.alive():
			out[h.id] = spot_m(h, arena.tick, on_rigs, px_per_m) * SimConst.PX_PER_M
	return out


## it23: CombatBlood.pool_at for quest 1: where the killed hostile `id` comes to rest (metres, the
## settled plan pelvis), so the kill's pool lies under the drawn corpse, not beside it; `at` (his
## spot) when `id` is no hostile. The signature-kill veto still asks at his spot (CombatBlood).
static func pool_m(
	arena: CombatArena, id: int, at: Vector2, on_rigs: bool, px_per_m: float
) -> Vector2:
	for h: Fighter in arena.hostiles:
		if h.id == id:  # actor_killed fires before his hp drops: no alive() test here
			return _laid_m(h, h.hurt_tick + SETTLED, on_rigs, px_per_m)
	return at


## Where `h` is in metres at `now` for what is laid on or under him: his own spot alive, else
## _laid_m.
static func spot_m(h: Fighter, now: int, on_rigs: bool, px_per_m: float) -> Vector2:
	return h.pos if h.alive() else _laid_m(h, now, on_rigs, px_per_m)


## A dead `h`'s spot: his own for a boss or when the rigs draw the dead (on_rigs without
## QuestGuardCast); else the plan pelvis (lying_m).
static func _laid_m(h: Fighter, now: int, on_rigs: bool, px_per_m: float) -> Vector2:
	var cast: bool = not on_rigs or QuestGuardCast.ON
	if not cast or h.kind == Fighter.Kind.BOSS:
		return h.pos
	return lying_m(h, now, px_per_m)


## The corpse's colour from StreetQuestCorpses' decay tint: OPAQUE lifts the cast view's alpha to 1.
static func ground_tint(tint: Color) -> Color:
	var c: Color = tint
	if OPAQUE:
		c.a = minf(1.0, tint.a / StreetQuestCorpses.BASE.a)
	return c


## The corpse's ground transform `age` ticks after the blow: the cell centre (the pelvis) along the
## blow, the head along it, the fall's slide, turn and landing still to go (fall_left).
static func transform_of(
	at_px: Vector2, h: Fighter, px_per_m: float, age: int = SETTLED
) -> Transform2D:
	var blow: Vector2 = blow_of(at_px, h.facing)
	var pose: int = StreetDeadPlan.pick(ID_BASE - h.id, &"", at_px)
	var hv: int = StreetDeadPlan._hash(ID_BASE - h.id)
	var head: Vector2 = StreetDeadHeading.head_of(blow, pose, (hv & 1) == 1)
	var flip: bool = StreetDeadHeading.flipped(head, pose, (hv & 1) == 1)
	var s: float = StreetQuestCards.body_m() * px_per_m / StreetWalkerFall.STILL_PX
	var left: float = fall_left(age)
	var pelvis: float = StreetDeadPlan.PELVIS_K * StreetWalkerFall.STILL_PX * s
	var centre: Vector2 = at_px + head * pelvis
	var at: Vector2 = centre - blow * SLIDE_M * px_per_m * left
	at += StreetQuestDeadPush.push_of(ID_BASE - h.id, centre, px_per_m) * (1.0 - left)
	var turn: float = TWIST_RAD * left * (-1.0 if flip else 1.0)
	var k: float = s * lerpf(1.0, StreetDeadPlan.LAND_SCALE, left)
	var angle: float = StreetDeadHeading.angle_of(head, pose, flip)
	angle += StreetDeadHeading.jitter(hv) + turn
	return Transform2D(angle, Vector2(-k if flip else k, k), 0.0, at)


## Forgets every push (tests; a new scene starts from no dead).
static func reset() -> void:
	StreetQuestDeadPush.reset()


## The share of the fall still to go `age` ticks after the blow (1 at the blow, 0 settled).
static func fall_left(age: int) -> float:
	if FALL_TICKS <= 0:
		return 0.0
	var t: float = clampf(float(age) / float(FALL_TICKS), 0.0, 1.0)
	return (1.0 - t) * (1.0 - t)


## The blow's direction on the ground: away from the facing, turned by the spot's spread pick.
static func blow_of(at_px: Vector2, facing: Vector2) -> Vector2:
	var f: Vector2 = facing.normalized() if facing.length() > 0.0 else Vector2.RIGHT
	return (-f).rotated(StreetQuestCards.spread_of(at_px))


static func _strip() -> Texture2D:
	if not _looked:
		_looked = true
		_tex = load(PATH) as Texture2D if ResourceLoader.exists(PATH) else null
	return _tex
