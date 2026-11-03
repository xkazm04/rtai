class_name HaulerKick
extends RefCounted
## The Hauler stomp's impact in a playable view (quest 1, the arena that extends it): once per
## stomp landing, a camera shake (powers.json stomp_shake) and a hit-stop (stomp_hitstop), both
## camera.json ids. The hit-stop holds the sim clock (SimClock.hold: wall time only, every tick
## unchanged, replays identical). With the host's own CameraRig the kick goes there; without one
## (quest 1's CityView today) a private rig does the shake maths only (no zoom, no look-ahead) and
## step() returns the shake as a world-px camera offset (CityView.kick_px keeps the print locked).
## A ram hit lands the same way with ram_shake / ram_hitstop (the rig's cooldown: one stop a burst).

var reduced_motion: bool = false
## Evidence: the stomp tick last kicked for and the ticks its hit-stop held.
var kicked_tick: int = -1
var held_ticks: int = 0
var kicks: int = 0
## Ram hits kicked for (ram_shake / ram_hitstop) and the ticks held by them.
var ram_kicks: int = 0
var ram_held_ticks: int = 0
var _rig: CameraRig = null
var _rams_seen: int = 0


## One view frame at stage tick `tick` (the stomp's timebase). Returns the shake offset (world
## px) to add to the camera, zero when `host_rig` is set (it shakes itself, on the clock's tick)
## or when no shake is running.
func step(h: HaulerStage, tick: int, clock: SimClock, host_rig: CameraRig) -> Vector2:
	if _rig == null and host_rig == null:
		_rig = CameraRig.new()
	var r: CameraRig = host_rig if host_rig != null else _rig
	if host_rig == null:
		_rig.reduced_motion = reduced_motion
	if h != null and h.stomp_tick >= 0 and h.stomp_tick != kicked_tick:
		kicked_tick = h.stomp_tick
		kicks += 1
		var at: int = h.stomp_tick
		if host_rig != null and clock != null:
			at += clock.tick() - tick
		r.kick(h.form.id_of(&"stomp_shake"), at)
		held_ticks = r.hitstop(h.form.id_of(&"stomp_hitstop"), at)
		if clock != null and held_ticks > 0:
			clock.hold(held_ticks * SimClock.TICK_DT)
	if h != null and h.ram_hits > _rams_seen:
		_rams_seen = h.ram_hits
		ram_kicks += 1
		var now: int = clock.tick() if host_rig != null and clock != null else tick
		r.kick(h.form.id_of(&"ram_shake"), now)
		var held: int = r.hitstop(h.form.id_of(&"ram_hitstop"), now)
		ram_held_ticks += held
		if clock != null and held > 0:
			clock.hold(held * SimClock.TICK_DT)
	if host_rig != null:
		return Vector2.ZERO
	_rig.step(tick, Vector2.ZERO)
	return _rig.offset_px(SimConst.PX_PER_M)
