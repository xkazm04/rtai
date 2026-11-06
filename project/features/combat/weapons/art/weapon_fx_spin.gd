class_name WeaponFxSpin
extends RefCounted
## n7-ranged (audit row 3, the Gatling's anticipation): while Rivet's barrels spin up to speed (or
## wind down) no round leaves, and the gun showed nothing. A whirl turns at the muzzle instead:
## three ink-and-cream arcs about the barrel axis, longer, bolder and faster as the spin grows,
## gone on the tick the barrels reach speed, where the first round's flash takes over.
## hit_feel.json `weapons` spin_whirl_m (its width; 0, no row or --feel=off = none, the before).
## View only: the turn steps with the sim tick, so it freezes under hit-stop; no RNG.

## Turn per tick at full spin (rad): under 60 deg, so the three-fold whirl never strobes backwards.
const TURN_MAX: float = 0.8
const ARCS: int = 3
## Each arc's span (rad) at full spin; half of it as the spin starts.
const ARC_SPAN: float = 1.1
## The whirl seen from above: its depth along the aim as a share of its width.
const DEPTH_K: float = 0.4
const STEPS: int = 6
## The flash sits FLASH_AHEAD_M past the body edge; the barrel's tip is this share of that.
const TIP_BACK_K: float = 0.4

static var _feel: HitFeel = null
static var _phase: float = 0.0
static var _tick: int = -1


## The whirl's width (m) for `trig` now: 0 unless its barrels are turning below speed.
static func width_m(trig: Trigger) -> float:
	if _feel == null:
		_feel = HitFeel.shipped()
	var full: int = trig.spec.spin_ticks
	if full <= 0 or trig.spin <= 0 or trig.spin >= full:
		return 0.0
	return _feel.spin_whirl_m(trig.spec.id)


## The whirl's turn (rad) at `tick` for a spin share `s` (0..1): advances once per new tick.
static func phase(tick: int, s: float) -> float:
	if tick != _tick:
		_phase = fmod(_phase + TURN_MAX * s * float(clampi(tick - _tick, 0, 2)), TAU)
		_tick = tick
	return _phase


## Where the whirl rings the barrel: the drawn bore tip (HeldMuzzle) when the held view published
## it this frame, else WeaponFxArt's flash spot pulled back onto the barrel's tip.
static func tip(r: Fighter, gun: GunHand, ci: CanvasItem = null) -> Vector2:
	var aim: Vector2 = (gun.last_aim if gun.last_aim != Vector2.ZERO else r.facing).normalized()
	var art: WeaponArt = WeaponFxArt.art()
	var id: StringName = gun.trigger.spec.id
	var len_m: float = art.muzzle_m(id).x * 0.5 if art.has(id) else 0.0
	var reach: float = r.radius_m + WeaponFxArt.FLASH_AHEAD_M * TIP_BACK_K + len_m
	return HeldMuzzle.at_m(ci, r.pos + aim * reach + aim.orthogonal() * WeaponFxArt.GUN_SIDE_M)


## Draw the whirl of Rivet's `gun` (held by `r`) on `ci` at `tick`.
static func draw(ci: CanvasItem, r: Fighter, gun: GunHand, tick: int) -> void:
	var trig: Trigger = gun.trigger
	var w: float = width_m(trig)
	if w <= 0.0:
		return
	var aim: Vector2 = (gun.last_aim if gun.last_aim != Vector2.ZERO else r.facing).normalized()
	var at: Vector2 = tip(r, gun, ci)
	var s: float = float(trig.spin) / float(trig.spec.spin_ticks)
	var turn: float = phase(tick, s)
	var side: Vector2 = aim.orthogonal() * w * 0.5
	var depth: Vector2 = aim * w * 0.5 * DEPTH_K
	for i: int in ARCS:
		var a0: float = turn + TAU * float(i) / float(ARCS)
		var pts: PackedVector2Array = PackedVector2Array()
		for j: int in STEPS + 1:
			var a: float = a0 + ARC_SPAN * (0.5 + 0.5 * s) * float(j) / float(STEPS)
			@warning_ignore("return_value_discarded")
			pts.append(Ink.px(at + side * cos(a) + depth * sin(a)))
		ci.draw_polyline(pts, Ink.INK, 4.0 + 4.0 * s)
		ci.draw_polyline(pts, Ink.CREAM, 1.5 + 2.0 * s)


## Forget the turn (a test); `feel` replaces the shipped table (null = load it on next use).
static func reset(feel: HitFeel = null) -> void:
	_phase = 0.0
	_tick = -1
	_feel = feel
