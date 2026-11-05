class_name FeelCam
extends RefCounted
## The camera side of the shared hit feel in a playable view (lane n7-ranged): the arena's pit and
## city block and quest 1 (CollectCallView). Every round Rivet lands (CombatArena.struck) asks
## HitFeel.camera_row for its class + weapon feel and gets, inside the FeelBudget caps: a shake
## (camera.json id), a directional kick along the hit that eases back, and a hit-stop the clock
## holds (SimClock.hold: wall time only, every tick unchanged, replays and parity identical).
## Other attacks (melee, ghost powers, a boss slam) call hit() with their own weapon id and class.
## View only: made by the view, never in a headless replay; nothing here is read by the sim.

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
## Live kicks: (x px, y px, start tick, length ticks).
var _kicks: Array[Vector4] = []


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
	if ticks > 0 and clock != null:
		clock.hold(ticks * SimClock.TICK_DT)
		held_ticks += ticks
	return ticks


## The camera offset now in world px for a camera at `zoom` (screen px per world px): the shake
## plus the live kicks, capped at the table's kick_px_max screen px, so it reads the same at 32,
## 48 or 64 px/m. Zero when nothing runs (bit-identical framing).
func offset_px(tick: int, zoom: float) -> Vector2:
	_rig.step(tick, Vector2.ZERO)
	var sum: Vector2 = Vector2.ZERO
	for i: int in range(_kicks.size() - 1, -1, -1):
		var k: Vector4 = _kicks[i]
		var t: float = (tick - k.z) / k.w
		if t >= 1.0:
			_kicks.remove_at(i)
			continue
		sum += Vector2(k.x, k.y) * (1.0 - clampf(t, 0.0, 1.0)) * (1.0 - clampf(t, 0.0, 1.0))
	var cap_px: float = feel.cap.get("kick_px_max", 8.0)
	var screen: Vector2 = sum.limit_length(cap_px) + _rig.offset_px(SimConst.PX_PER_M)
	return screen / maxf(zoom, 0.01)


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
