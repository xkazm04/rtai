class_name GunFxFollow
extends RefCounted
## n15 combat (DEFECTS c-2 #3, "the body-hit burst lands about 0.5 m in front of the thrown-back
## card"). Two causes: a round counts as on a body when its last step passes within radius + 0.3 m
## of his centre, and its burst was drawn at that step's closest point, up to 0.75 m short of him
## (on_body puts it on his front, FRONT_M from his centre along the round); and the knock-back
## (HitLink moves the sim Fighter.pos) and a death's slide (the view's rig carry) move him on while
## the burst stays (per body-hit impact this keeps [the victim, where his body was drawn then] and
## draws the burst at that offset from him now). Render only: no sim state is read back.
## `--impact-follow=off` = the before (the closest point, the world point).
## n15 s8: a living hit also pushes the drawn street card off his point (StreetWalkerHit.shove,
## body_push); the burst is recorded on his body WITHOUT that push and drawn with the push of the
## moment, so a later round of a burst lands on the pushed card and returns to the body when the
## push ends (at his death). `--burst-push=off` = the before (no push: the dot beside the card).

## A body hit's burst this far in front of the body's centre, toward the shooter (metres).
const FRONT_M: float = 0.15

static var _off: int = -1
static var _push_off: int = -1

## The view's slide of a fighter's drawn body off its sim point (metres), Callable(id: int) ->
## Vector2: a death's rig carry (RigCarry.hook, wired by ArenaRigs). Unset = none.
var body_off: Callable = Callable()
## The living hit card's push off his point (metres), Callable(id: int) -> Vector2 (RigCarry.wire).
var body_push: Callable = Callable()
var _on: Dictionary[Vector4, Array] = {}


## Where a round whose last step came closest to `f` at `c` marks him: on his front along `hop`.
static func on_body(c: Vector2, f: Fighter, hop: Vector2) -> Vector2:
	if is_off() or hop == Vector2.ZERO:
		return c
	return f.pos - hop.normalized() * FRONT_M


## True with `--impact-follow=off` (the before).
static func is_off() -> bool:
	if _off < 0:
		_off = 1 if ArenaArgs.parse().text("--impact-follow") == "off" else 0
	return _off == 1


## Impact `im` stopped on `f`; impacts past a burst's life are forgotten.
func record(im: Vector4, f: Fighter) -> void:
	for k: Vector4 in _on.keys():
		if im.w - k.w > GunFx.IMPACT_TICKS:
			@warning_ignore("return_value_discarded")
			_on.erase(k)
	_on[im] = [f, body_at(f)]


func has(im: Vector4) -> bool:
	return _on.has(im)


## Where `f`'s body is drawn (metres): his sim point plus the view's slide of it.
func body_at(f: Fighter) -> Vector2:
	if body_off.is_valid():
		var off: Vector2 = body_off.call(f.id)
		return f.pos + off
	return f.pos


## Where impact `im` is drawn: on its victim's body as he moves (a body hit), else where it stopped.
func drawn_at(im: Vector4) -> Vector2:
	var at: Vector2 = Vector2(im.x, im.y)
	var on: Array = _on.get(im, [])
	if on.size() < 2 or is_off():
		return at
	var f: Fighter = on[0]
	var then: Vector2 = on[1]
	return at + body_at(f) + push_of(f) - then


## The living hit card's push of `f` now (metres); zero unset or with `--burst-push=off`.
func push_of(f: Fighter) -> Vector2:
	if not body_push.is_valid():
		return Vector2.ZERO
	if _push_off < 0:
		_push_off = 1 if ArenaArgs.parse().text("--burst-push") == "off" else 0
	if _push_off == 1:
		return Vector2.ZERO
	var push: Vector2 = body_push.call(f.id)
	return push
