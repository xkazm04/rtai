class_name StreetQuestCorpses
extends RefCounted
## Lane n8 street (it13): quest 1's drawn dead contractors leave the floor as the live fight's do.
## Under a card view StreetQuestCards.draw_down lays each downed guard as a standing-height lying
## figure; quest 1 runs no CorpseDecayHook (the sim keeps every guard_down), so at Dock 9 some 30
## lay stacked over the kerb and the bench card (view's it15 NOTE, 32 px/m tick 15000). Render
## only: a corpse lies at the top path's DOWN_FADE alpha for the decay table's bodies.linger_s from
## its killing blow (Fighter.hurt_tick, the arena's tick), then over fade_s inks out (to ink by
## ink_k of the fade, as CorpseFade) and fades away. Stateless: the age is the tick difference, so
## a replay or a seek draws the same floor. DECAY false = every corpse stays (it8-it12).

const DECAY: bool = true
## CastView's DOWN_FADE: the top path's sprite corpses lie at this alpha.
const BASE: Color = Color(1.0, 1.0, 1.0, 0.8)

static var _decay: CorpseDecay = null


## CastView's card corpse: the dead guard `h` at `at_px`, drawn by StreetQuestCards.draw_down
## at its decay tint for the arena tick `now`; false = no card art (CastView draws the sprite).
static func draw(canvas: CanvasItem, at_px: Vector2, px_per_m: float, h: Fighter, now: int) -> bool:
	if StreetQuestDeadPlan.draw(canvas, at_px, h, px_per_m, now):  # n9 world: the plan dead
		return true
	var tint: Color = tint_of(now - h.hurt_tick, BASE)
	return StreetQuestCards.draw_down(canvas, at_px, h.facing, px_per_m, tint)


## The tint of a corpse `age` ticks after its killing blow, over `base` (CastView's DOWN_FADE);
## alpha 0 = gone (the caller may skip the draw).
static func tint_of(age: int, base: Color) -> Color:
	if not DECAY:
		return base
	var d: CorpseDecay = _table()
	var k: float = clampf(
		float(age - d.bodies.linger_ticks) / float(maxi(1, d.bodies.fade_ticks)), 0.0, 1.0
	)
	var ink: float = smoothstep(0.0, d.ink_k, k)
	var c: Color = base.lerp(Color(ArtIds.INK, base.a), ink)
	c.a = base.a * (1.0 - smoothstep(d.ink_k, 1.0, k))
	return c


## The decay table, read once (corpse_decay.json; the live fight's law).
static func _table() -> CorpseDecay:
	if _decay == null:
		_decay = CorpseDecay.shipped()
	return _decay
