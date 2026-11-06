class_name WeaponFxTrail
extends RefCounted
## n7-ranged it24 (audit: the pistol's round is a pale cream needle for 1-2 frames at 32 px/m,
## while a cop's vermilion round reads for 6): when Rivet's round stops in a body, its path stays
## for a few ticks as an ink line with a cream core from the held gun to the wound, the tail
## drawing in toward the wound as it fades, so the eye joins the shot to the hit. Per weapon:
## hit_feel.json `weapons` trail_ticks (absent or 0 = none: the Gatling and the flamer stay
## clean). View only: GunFx records it from the rounds it already tracks, nothing reaches the sim.
## `--shot-trail=off` or `--feel=off` = the before.

## The drawn round leaves the held gun this far out and this far left of the aim line
## (WeaponFxArt.CLEAR_M, GUN_SIDE_M), so the trail starts where the tracer started.
const CLEAR_M: float = 1.1
const GUN_SIDE_M: float = 0.35
## Ink casing and cream core widths at birth (world px at Ink.PX_PER_M); both thin as it fades.
const INK_PX: float = 6.0
const CORE_PX: float = 2.5
## The tail closes this share of the way to the wound over the trail's life.
const DRAW_IN: float = 0.6
## At most this many trails at once (a machine pistol burst into a crowd).
const MAX_TRAILS: int = 8


## One trail: the path's ends (m), its birth tick and life (ticks).
class Trail:
	var from: Vector2
	var to: Vector2
	var born: int
	var life: int


static var enabled: bool = not OS.get_cmdline_user_args().has("--shot-trail=off")
static var _feel: HitFeel = null


## Rivet's round from `origin` stopped in a body at `at` on `tick`: a trail on `trails` (GunFx's)
## if `weapon` has trail_ticks.
static func add(
	trails: Array[Trail], origin: Vector2, at: Vector2, weapon: StringName, tick: int
) -> void:
	var life: int = ticks_of(weapon)
	if life <= 0 or origin.distance_to(at) <= CLEAR_M:
		return
	var dir: Vector2 = (at - origin).normalized()
	var from: Vector2 = origin + dir * CLEAR_M + dir.orthogonal() * GUN_SIDE_M
	if trails.size() >= MAX_TRAILS:
		trails.remove_at(0)
	var t: Trail = Trail.new()
	t.from = from
	t.to = at
	t.born = tick
	t.life = life
	trails.append(t)


## The trail life of `weapon` in ticks (0 = none, and 0 under --shot-trail=off or --feel=off).
static func ticks_of(weapon: StringName) -> int:
	if not enabled:
		return 0
	if _feel == null:
		_feel = HitFeel.shipped()
	if not _feel.enabled:
		return 0
	return roundi(_feel.weapon_num(weapon, "trail_ticks", 0.0))


## Drop the trails whose life is over at `tick`.
static func expire(trails: Array[Trail], tick: int) -> void:
	while not trails.is_empty() and tick - trails[0].born >= trails[0].life:
		trails.remove_at(0)


## Draw every live trail at `tick`: the ink casing, then the cream core over it.
static func draw(ci: CanvasItem, trails: Array[Trail], tick: int) -> void:
	for t: Trail in trails:
		var k: float = fade_k(tick - t.born, t.life)
		if k <= 0.0:
			continue
		var to: Vector2 = t.to
		var from: Vector2 = t.from.lerp(to, DRAW_IN * (1.0 - k))
		ci.draw_line(Ink.px(from), Ink.px(to), Color(Ink.INK, 0.85 * k), INK_PX * (0.4 + 0.6 * k))
		ci.draw_line(Ink.px(from), Ink.px(to), Color(Ink.CREAM, k), CORE_PX * (0.5 + 0.5 * k))


## 1 on the hit tick, falling to 0 at the end of `life` (0 before birth or after).
static func fade_k(age: int, life: int) -> float:
	if age < 0 or age >= life or life <= 0:
		return 0.0
	return 1.0 - float(age) / float(life)


## A test: `feel` replaces the shipped table (null = load it on next use).
static func reset(feel: HitFeel = null) -> void:
	_feel = feel
