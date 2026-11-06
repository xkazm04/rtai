class_name FeelCam
extends RefCounted
## The camera side of the shared hit feel in a playable view (lane n7-ranged): the arena's pit and
## city block and quest 1 (CollectCallView). Every round Rivet lands (CombatArena.struck) asks
## HitFeel.camera_row for its class + weapon feel and gets, inside the FeelBudget caps: a shake
## (camera.json id), a directional kick along the hit that eases back, and a hit-stop the clock
## holds (SimClock.hold: wall time only, every tick unchanged, replays and parity identical).
## Other attacks (melee, ghost powers, a boss slam) call hit() with their own weapon id and class.
## View only: made by the view, never in a headless replay; nothing here is read by the sim.

## A trigger rested this long lights up again with the weapon's ignite_kick_px (the flamer).
const IGNITE_IDLE_TICKS: int = 20

var feel: HitFeel
var budget: FeelBudget
var clock: SimClock = null
var reduced_motion: bool = false
## Evidence since boot: hits seen, kicks started, hit-stop ticks held.
var hits: int = 0
var kicks: int = 0
var held_ticks: int = 0
var _arena: CombatArena = null
var _table: WeaponTable = null
var _rig: CameraRig = CameraRig.new()
## n7-ranged: the drift toward a blast weapon's round (BlastLead), outside the kick cap.
var _lead: BlastLead = BlastLead.new()
## Live kicks: (x px, y px, start tick, length ticks).
var _kicks: Array[Vector4] = []
## Rivet's rounds already seen in flight (the fire kick fires once per new round).
var _seen: Dictionary[Shot, bool] = {}
## The tick each weapon last fired (the ignition kick waits for a rest of IGNITE_IDLE_TICKS).
var _last_fire: Dictionary[StringName, int] = {}
## A stop waiting for its tick: (ticks, tick it starts); x 0 = none.
var _pending: Vector2i = Vector2i.ZERO


static func attach(arena: CombatArena, p_clock: SimClock, p_feel: HitFeel = null) -> FeelCam:
	var c: FeelCam = FeelCam.new()
	c.feel = p_feel if p_feel != null else HitFeel.shipped()
	c.budget = FeelBudget.from_cap(c.feel.cap)
	c.clock = p_clock
	c._table = WeaponTable.shipped()
	c._arena = arena
	if arena != null:
		@warning_ignore("return_value_discarded")
		arena.struck.connect(c._on_struck)
	return c


## One landed hit of `weapon` (class `hit_class`) along `dir` at sim tick `tick`. The length of
## `dir` is the hit's strength (a unit vector = 1; a splash's falloff or a combo finisher scales
## it): it scales the kick. Returns the hit-stop ticks held (0 under the cap, off, reduced motion).
func hit(weapon: StringName, hit_class: StringName, dir: Vector2, lethal: bool, tick: int) -> int:
	hits += 1
	if not feel.enabled or reduced_motion:
		return 0
	var row: Dictionary = feel.camera_row(weapon, hit_class, lethal)
	var px: float = row["kick_px"]
	px *= minf(dir.length(), 2.0)
	if px > 0.0 and budget.take_kick(tick):
		var v: Vector2 = dir.normalized() * px
		var len_ticks: int = row["kick_ticks"]
		_kicks.append(Vector4(v.x, v.y, tick, maxi(len_ticks, 1)))
		kicks += 1
	var shake: StringName = row["shake"]
	if shake != &"" and budget.take_shake(tick):
		_rig.kick(shake, tick)
	var stop: StringName = row["hitstop"]
	var kill_stop: StringName = row["kill_hitstop"]
	if _rig.hitstop_ticks(kill_stop) > _rig.hitstop_ticks(stop):
		stop = kill_stop
	if stop == &"":
		return 0
	var ticks: int = budget.take_stop(tick, _rig.hitstop(stop, tick))
	if ticks > 0:  # a class's hold_delay_ticks lets the wound show before the frame freezes
		var delay: int = row["hold_delay"]
		var at: int = tick + delay
		_pending = Vector2i(maxi(_pending.x, ticks), mini(at, _pending.y) if _pending.x > 0 else at)
		_release_hold(tick)
	return ticks


func _release_hold(tick: int) -> void:
	if _pending.x <= 0 or tick < _pending.y:
		return
	if clock != null:
		clock.hold(_pending.x * SimClock.TICK_DT)
		held_ticks += _pending.x
	_pending = Vector2i.ZERO


## The camera offset now in world px for a camera at `zoom` (screen px per world px): the shake
## plus the live kicks, capped at the table's kick_px_max screen px, so it reads the same at 32,
## 48 or 64 px/m. Zero when nothing runs (bit-identical framing).
func offset_px(tick: int, zoom: float) -> Vector2:
	_watch_fire(tick)
	_release_hold(tick)
	_rig.step(tick, Vector2.ZERO)
	var sum: Vector2 = Vector2.ZERO
	for i: int in range(_kicks.size() - 1, -1, -1):
		var k: Vector4 = _kicks[i]
		var t: float = (tick - k.z) / k.w
		if t >= 1.0:
			_kicks.remove_at(i)
			continue
		sum += Vector2(k.x, k.y) * (1.0 - clampf(t, 0.0, 1.0)) * (1.0 - clampf(t, 0.0, 1.0))
	sum += spin_tremor(tick)
	var cap_px: float = feel.cap.get("kick_px_max", 8.0)
	var screen: Vector2 = sum.limit_length(cap_px) + _rig.offset_px(SimConst.PX_PER_M)
	var lead: Vector2 = _lead.step(_arena, feel, tick) * SimConst.PX_PER_M
	lead = lead.limit_length(_lead.max_px / maxf(zoom, 0.01))  # screen px, whatever the zoom
	if not feel.enabled or reduced_motion:
		lead = Vector2.ZERO
	return screen / maxf(zoom, 0.01) + lead


## The spin-up's anticipation (hit_feel.json `weapons` spin_rumble_px): while Rivet's barrels turn
## below full speed (spinning up, or winding down after the trigger lets go), a tremor that grows
## with the spin. Screen px; a fixed function of the tick (view only, no RNG); zero when off.
func spin_tremor(tick: int) -> Vector2:
	if not feel.enabled or reduced_motion or _arena == null or _arena.gun == null:
		return Vector2.ZERO
	var trig: Trigger = _arena.gun.trigger
	var full: int = trig.spec.spin_ticks
	var px: float = feel.spin_row(trig.spec.id)
	if px <= 0.0 or full <= 0 or trig.spin <= 0 or trig.spin >= full:
		return Vector2.ZERO
	var amp: float = px * float(trig.spin) / float(full)
	return Vector2(sin(tick * 1.1), cos(tick * 1.6)) * amp  # about 10 and 15 Hz: a rumble, not a blur


func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if victim == _arena.rivet:  # Rivet hit: the player_hit cue owns that (fx_triggers.json)
		return
	var spec: WeaponSpec = _table.weapons.get(weapon, null)
	var hit_class: StringName = spec.hit_class if spec != null else &"light"
	if weapon == &"burn":
		hit_class = &"burn"
	if _arena.struck_charged:  # a full charge lands as a blast (HitLink.CHARGED_CLASS)
		hit_class = HitLink.CHARGED_CLASS
	@warning_ignore("return_value_discarded")
	hit(weapon, hit_class, dir.normalized(), lethal, _arena.tick)


## One round of `weapon` fired along `aim` at `tick`: the weapon's fire kick (recoil) against the
## aim, inside the same per-tick kick cap as the hits. Returns true when it kicked.
func fire(weapon: StringName, aim: Vector2, tick: int) -> bool:
	if not feel.enabled or reduced_motion:
		return false
	var row: Vector2 = feel.fire_row(weapon)
	var last: int = _last_fire.get(weapon, -IGNITE_IDLE_TICKS - 1)
	_last_fire[weapon] = tick
	if tick - last > IGNITE_IDLE_TICKS:
		row.x = maxf(row.x, feel.ignite_px(weapon))
	if row.x <= 0.0 or aim == Vector2.ZERO or not budget.take_kick(tick):
		return false
	var v: Vector2 = -aim.normalized() * row.x
	_kicks.append(Vector4(v.x, v.y, tick, maxf(row.y, 1.0)))
	kicks += 1
	return true


func _watch_fire(tick: int) -> void:
	if _arena == null:
		return
	var live: Dictionary[Shot, bool] = {}
	for s: Shot in _arena.shots:
		live[s] = true
		if s.from_rivet and not _seen.has(s):
			@warning_ignore("return_value_discarded")
			fire(s.weapon, s.vel, tick)
	_seen = live
