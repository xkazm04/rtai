class_name MeleeSweep
extends RefCounted
## n31 melee 02 (the owner's "melee weapons are visible smashing through enemies and nothing
## happened"): with `--melee-sweep` a hit tests on every tick its blade is DRAWN cutting
## (MeleeSwing's cut window: CUT_TICKS before the windup ends to 12 % into the recovery), not on
## the first active tick alone, and it tests the sector the drawn blade crossed since the last
## tick (MeleeSwing.angle about the aim, as RivetHeldView draws it) out to the hit's reach plus
## the body's radius, widened by the body's own angular half-width. Each fighter is struck at most
## once per hit (`struck`, cleared when a new hit starts or the combo goes idle). Pure and RNG-free:
## the sim derives the drawn angles from the same static functions the view uses. Off = the before.

## The flag lives on MeleeHit (a leaf class: MeleeTable reads it while it loads, inside the
## MeleeTable -> MeleeSweep -> MeleeCombo cycle where this script's statics are not up yet).
static var on: bool:
	get:
		return MeleeHit.sweep
	set(value):
		MeleeHit.sweep = value

## Fighter ids struck by the current hit.
var struck: Dictionary[int, bool] = {}
## The combo's `starts` count of the hit the set belongs to (-1 = idle).
var swing: int = -1
## The current hit struck something / ran a sweep tick / closed its sweep (whiff counted).
var hit_any: bool = false
var tested: bool = false
var closed: bool = false


## The first and last tick_in (inclusive) on which hit `h`'s blade is drawn cutting.
static func window(h: MeleeHit) -> Vector2i:
	var w: float = float(h.windup)
	var first: int = ceili(w - minf(MeleeSwing.CUT_TICKS, w * 0.5))
	var end: float = w + float(h.active) + float(h.recovery) * 0.12
	return Vector2i(first, ceili(end) - 1)


## True when tick_in `tick` of hit `h` is a sweep tick.
static func cuts(h: MeleeHit, tick: int) -> bool:
	var win: Vector2i = window(h)
	return tick >= win.x and tick <= win.y


## True while a grinding hit holds its bite (ground > 0 on its last active tick): the grind's own
## re-test runs there (MeleeCombo.lands), not the sweep.
static func held(combo: MeleeCombo) -> bool:
	var h: MeleeHit = combo.current()
	return h != null and combo.ground > 0 and combo.tick_in == h.windup + h.active - 1


## The swing's side (+1 / -1): the combo's hits alternate it.
static func side(combo: MeleeCombo) -> float:
	return 1.0 if combo.last_index % 2 == 1 else -1.0


## The drawn blade's angle off the aim (rad) at tick_in `tick` of the combo's current hit `h`.
static func drawn(combo: MeleeCombo, h: MeleeHit, tick: int) -> float:
	var dt: float = SimClock.TICK_DT
	var ph: Vector3 = Vector3(float(h.windup), float(h.active), float(h.recovery)) * dt
	var arc: float = maxf(RivetHeldView.SWEEP_MIN, acos(clampf(h.cone_dot, -1.0, 1.0)))
	return MeleeSwing.angle(float(tick) * dt, ph, side(combo), arc)


## The drawn angles from the last tick to this one (the sector the blade crossed), clamped in
## the side frame to the hit's drawn angle range (02p3: the pixels' sector, `sweep_arc_deg`).
static func span(combo: MeleeCombo, h: MeleeHit) -> Vector2:
	var s: float = side(combo)
	var a: Vector2 = Vector2(drawn(combo, h, combo.tick_in - 1), drawn(combo, h, combo.tick_in)) * s
	var lo: float = h.sweep_arc.x
	var hi: float = h.sweep_arc.y
	return Vector2(clampf(a.x, lo, hi), clampf(a.y, lo, hi)) * s


## True when the blade sweeping from angle `arc.x` to `arc.y` off `facing` (about `at`, out to
## `reach_m` plus the body's radius) crosses fighter `f`.
static func crosses(f: Fighter, at: Vector2, facing: Vector2, arc: Vector2, reach_m: float) -> bool:
	var to: Vector2 = f.pos - at
	var d: float = to.length()
	if d > reach_m + f.radius_m:
		return false
	if d <= f.radius_m:
		return true
	var pad: float = asin(clampf(f.radius_m / d, 0.0, 1.0))
	var mid: float = (arc.x + arc.y) * 0.5
	var half: float = absf(arc.y - arc.x) * 0.5 + pad
	return half >= PI or absf(wrapf(facing.angle_to(to) - mid, -PI, PI)) <= half


## True once a grinding hit (the chainsaw) has bitten: its sweep ends at the first bite and the
## grind re-test (MeleeCombo.lands) takes what it caught (02p3, the saw does not keep sweeping).
func bitten(h: MeleeHit) -> bool:
	return h.grind_ticks > 0 and hit_any


## Follows the combo: a new hit (or idle) clears the struck set. Returns true when the hit it
## leaves ran sweep ticks, struck nothing and had not yet counted its whiff (cut short).
func track(combo: MeleeCombo) -> bool:
	var key: int = combo.starts if combo.hit_index > 0 else -1
	if key == swing:
		return false
	var whiffed: bool = tested and not closed and not hit_any
	swing = key
	struck.clear()
	hit_any = false
	tested = false
	closed = false
	return whiffed


## Closes sweep tick `tick` of hit `h`: 1 = the hit's first land, -1 = its whiff (the last
## cutting tick and nothing struck), else 0.
func close(h: MeleeHit, tick: int, hit_now: bool) -> int:
	var last: bool = tick == window(h).y
	var out: int = 0
	if hit_now and not hit_any:
		out = 1
	elif not hit_now and last and not hit_any and not closed:
		out = -1
	tested = true
	hit_any = hit_any or hit_now
	closed = closed or last
	return out


func write(out: StreamPeerBuffer) -> void:
	out.put_32(swing)
	out.put_8((1 if hit_any else 0) | (2 if tested else 0) | (4 if closed else 0))
	var ids: Array = struck.keys()
	ids.sort()
	out.put_32(ids.size())
	for id: int in ids:
		out.put_32(id)
