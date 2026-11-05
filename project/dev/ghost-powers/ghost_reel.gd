class_name GhostReel
extends ArenaHook
## The ghost attacks' scripted beat (`--bot=ghosts` in the arena, also `--arena=city`), lane
## ghost-powers. Sim side as a hook (the setup runs on the 60 Hz tick, so a run records and
## replays); sample() only reads the sim. Tonnage: Rivet on the director's open mark, a
## cluster of patrol cops, a riot cop and a police cruiser ahead, a second pair farther on.
## He takes the soul (Q), walks in under small-arms fire (the plates take armor_k), slams the
## press onto the cluster and the car, then rams through the far pair and slams again.

const MARK: Vector2 = Vector2(-34.0, 2.0)
const LOOK_TICKS: int = 40
## The press slam goes off once the nearest standing victim is inside this (metres).
const SLAM_M: float = 2.2
## The walk-in's stick before the first slam (under the ram line: the slam takes the cluster).
const STALK: float = 0.45
## The far pair is rammed: the tank charges through them before the second slam.
const CLUSTER: Array[Vector2] = [Vector2(5.2, -1.0), Vector2(5.6, 0.9), Vector2(6.4, -0.1)]
const RIOT: Vector2 = Vector2(4.9, 0.1)
const CAR: Vector2 = Vector2(6.0, 2.6)
const FAR: Array[Vector2] = [Vector2(10.5, -0.6), Vector2(11.0, 0.7)]

var actions: PlayerActions
var started_tick: int = -1
var victims: Array[Fighter] = []
var car: VehicleBody = null
var car_two: VehicleBody = null
var wave: int = 1
## The ghost whose beat runs (--ghost=<tonnage|dent|kerf|ohm>, default tonnage).
var ghost: StringName = &"tonnage"
var dent_beat: DentBeat = null
var kerf_beat: KerfBeat = null
var ohm_beat: OhmBeat = null
## False plants the scenario's fault: every button off (aim and walk only).
var trigger: bool = true
var _anchor: Vector2 = Vector2.ZERO
var _stage: ArenaStage = null


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions
	ghost = StringName(ArenaArgs.parse().text("--ghost", "tonnage"))


func step(stage: ArenaStage, tick: int) -> void:
	if started_tick < 0:
		_begin(stage, tick)
	elif ohm_beat != null:
		ohm_beat.hold()
	elif ghost == &"tonnage" and wave == 1 and _nearest(stage.arena.rivet.pos) == null:
		_wave_two(stage, tick)


## The second wave behind him: he turns the press round (the turn limit) and slams again.
func _wave_two(stage: ArenaStage, tick: int) -> void:
	wave = 2
	var at: Vector2 = stage.arena.rivet.pos
	for off: Vector2 in CLUSTER:
		victims.append(spawn(stage, at - off - Vector2(1.0, 0.0), false))
	victims.append(spawn(stage, at - RIOT - Vector2(1.0, 0.0), true))
	if stage.vehicles != null:
		car_two = stage.vehicles.spawn_parked(&"sedan", at - CAR - Vector2(1.0, 0.0), Vector2.UP)
	Log.info("ghosts", "ghost reel: tonnage wave 2 at tick %d" % tick)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(victims.size())
	out.put_32(1 if car != null and car.state == VehicleBody.State.WRECK else 0)
	out.put_32(wave)


func telemetry() -> Dictionary:
	var dead: int = victims.filter(func(f: Fighter) -> bool: return not f.alive()).size()
	var out: Dictionary = {"ghost_victims": victims.size(), "ghost_dead": dead}
	var h: HaulerStage = _stage.pilot.hauler if _stage != null and _stage.pilot != null else null
	if h != null:
		out["tonnage"] = {
			"activations": h.activations,
			"slams": h.form.stomps,
			"slam_hits": h.stomp_hits,
			"ram_hits": h.ram_hits,
			"cars_crushed": h.cars_crushed,
			"ticks_on": h.ticks_on,
			"rivet_hp": _stage.arena.rivet.hp,
		}
	var d: DentStage = _stage.pilot.dent if _stage != null and _stage.pilot != null else null
	if d != null:
		out["dent"] = {
			"seizes": d.seizes, "strikes": d.strikes, "blasts": d.blasts, "rides": d.rides
		}
	var k: KerfStage = _stage.pilot.kerf if _stage != null and _stage.pilot != null else null
	if k != null:
		var forms: int = _stage.pilot.ghosts.transforms
		out["kerf"] = {"transforms": forms, "blinks": k.blinks, "slices": k.slices}
	var o: OhmStage = _stage.pilot.ohm if _stage != null and _stage.pilot != null else null
	if o != null:
		out["ohm"] = {"bolts": o.bolts, "struck": o.struck, "cars_hit": o.cars_hit}
	return out


## The tick's input: look, take the soul, close in and slam, then charge the far pair.
func sample(stage: ArenaStage, tick: int) -> TickInput:
	var rivet: Fighter = stage.arena.rivet
	var local: int = tick - started_tick
	if started_tick < 0 or local < LOOK_TICKS:
		return _input(Vector2.ZERO, Vector2.RIGHT, 0)
	if dent_beat != null or kerf_beat != null or ohm_beat != null:
		var w: Array = _beat_want(stage, local)
		var move: Vector2 = w[0]
		var look: Vector2 = w[1]
		var act: StringName = w[2]
		return _input(move, look, _bit(act, act != &""))
	if local == LOOK_TICKS:
		return _input(Vector2.ZERO, Vector2.RIGHT, _bit(&"power_hauler", true))
	var foe: Fighter = _nearest(rivet.pos)
	if foe == null:
		return _input(Vector2.ZERO, rivet.facing, 0)
	var gap: Vector2 = foe.pos - rivet.pos
	var aim: Vector2 = gap.normalized()
	var hauler: HaulerStage = stage.pilot.hauler if stage.pilot != null else null
	var ready: bool = hauler != null and hauler.form.stomp_ready()
	if gap.length() <= SLAM_M and ready:
		return _input(Vector2.ZERO, aim, _bit(&"melee", true))
	var slammed: bool = hauler != null and hauler.form.stomps > 0
	return _input(aim * (1.0 if slammed else STALK), aim, 0)  # stalk under ram speed, then charge


## The scripted ghost beat's (move, aim, action) for this tick.
func _beat_want(stage: ArenaStage, local: int) -> Array:
	if dent_beat != null:
		return dent_beat.want(stage, local)
	return kerf_beat.want(stage, local) if kerf_beat != null else ohm_beat.want(stage, local)


func _begin(stage: ArenaStage, tick: int) -> void:
	started_tick = tick
	_stage = stage
	_anchor = stage.plan.base + MARK
	var arena: CombatArena = stage.arena
	arena.rivet.pos = _anchor
	arena.rivet.facing = Vector2.RIGHT
	if stage.follow != null:  # the city block: the city's body holds Rivet where it last saw him
		stage.follow.focus = _anchor
		stage.follow.target = _anchor
	if ghost == &"dent":
		dent_beat = DentBeat.new()
		dent_beat.begin(self, stage, _anchor)
		Log.info("ghosts", "ghost reel: dent beat at tick %d" % tick)
		return
	if ghost == &"kerf":
		kerf_beat = KerfBeat.new()
		kerf_beat.begin(self, stage, _anchor)
		Log.info("ghosts", "ghost reel: kerf beat at tick %d" % tick)
		return
	if ghost == &"ohm":
		ohm_beat = OhmBeat.new()
		ohm_beat.begin(self, stage, _anchor)
		Log.info("ghosts", "ghost reel: ohm beat at tick %d" % tick)
		return
	for off: Vector2 in CLUSTER:
		victims.append(spawn(stage, _anchor + off, false))
	victims.append(spawn(stage, _anchor + RIOT, true))
	for off: Vector2 in FAR:
		victims.append(spawn(stage, _anchor + off, false))
	if stage.vehicles != null:
		car = stage.vehicles.spawn_parked(&"police_cruiser", _anchor + CAR, Vector2.UP)
	Log.info("ghosts", "ghost reel: tonnage beat at tick %d" % tick)


func spawn(stage: ArenaStage, at: Vector2, riot: bool) -> Fighter:
	var g: Fighter = stage.arena.spawn_guard(at)
	g.pos = at
	g.facing = Vector2.LEFT
	if riot and stage.pit != null:  # the riot cop: armored hp, ArenaRigs dresses the shield
		if stage.pit.riot_hp <= 0.0:
			stage.pit.riot_hp = ArenaPit.armored_hp()
		g.max_hp *= stage.pit.riot_hp
		g.hp = g.max_hp
		stage.pit.riot[g.id] = true
	return g


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in victims:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best


func _bit(action: StringName, on: bool) -> int:
	return 1 << actions.bit(action) if on else 0


func _input(move: Vector2, aim: Vector2, extra: int) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions) | (extra if trigger else 0)
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
