extends "res://dev/ghost-powers/quest_hauler_rec.gd"
## A ghost's attack set in quest 1's real view (boot/quest1.tscn, the shipped sprite cast unless
## `--rigs`), through bound input only: Start, a spread group of dock guards east of Rivet, then
## G taps (power_gearbox) to pick the ghost (order tonnage, dent, kerf, ohm), Q (power_hauler)
## to take it, the right stick on the nearest standing guard and a melee press every CADENCE
## ticks (Kerf's blink-slice, Ohm's bolt; Dent's press is fire, the seize: in quest 1 the street's
## ghost car on the aim, else a reach that misses; Ohm, once no guard stands, aims at the nearest
## live street car: the car bolt). One tick per frame, a PNG every tick. Dev-only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/quest_ghost_rec.tscn
##     -- --out=<abs dir> --ghost=<dent|kerf|ohm> [--ppm=<32|48|64>] [--rigs]

const ORDER: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]
const GROUP: Array[Vector2] = [
	Vector2(4.5, -1.2), Vector2(6.0, 1.4), Vector2(7.5, -0.4), Vector2(6.5, 3.0), Vector2(8.5, 1.0)
]
const TICKS: int = 300
## Ohm runs longer: the last guards fall, then he turns his bolt on the street car.
const OHM_TICKS: int = 450
const TAKE_AT: int = 30
const FIRST_PRESS: int = 70
const CADENCE: int = 20
## Dent: the melee press (the overload command) blows the seized car here.
const DENT_BLOW_AT: int = 200

## Ohm turns to the nearest live car once no guard stands this close (his bolt's range_m 11).
const CAR_AIM_M: float = 11.0

var _ghost: StringName = &"kerf"


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ghost="):
			_ghost = StringName(arg.substr(8))
	var ghost: StringName = _ghost
	var s: Quest1Session = _game.session
	for i: int in WARM:
		s.step()
	var stage: CollectCallStage = s.stage
	var at: Vector2 = stage.arena.rivet.pos
	for off: Vector2 in GROUP:
		var g: Fighter = stage.arena.spawn_guard(at + off)
		g.pos = at + off
	var picks: int = ORDER.find(ghost)
	for t: int in OHM_TICKS if ghost == &"ohm" else TICKS:
		_tap(&"power_gearbox", t >= 10 and t < 10 + 4 * picks and (t - 10) % 4 == 0)
		_tap(&"power_hauler", t == TAKE_AT)
		var beat: bool = t >= FIRST_PRESS and (t - FIRST_PRESS) % CADENCE == 0
		_tap(&"fire" if ghost == &"dent" else &"melee", beat)
		if ghost == &"dent":
			_tap(&"melee", t == DENT_BLOW_AT)
		_aim_at(stage)
		Input.flush_buffered_events()
		s.step()
		await _save()
		await _hold(s.world.context().clock)
	_report(ghost, stage)


func _report(ghost: StringName, stage: CollectCallStage) -> void:
	var p: StagePilot = stage.pilot
	var line: String = "%s: transforms %d kills %d kerf blinks %d slices %d"
	line += " ohm bolts %d struck %d cars_hit %d dent misses %d seizes %d strikes %d blasts %d"
	(
		Log
		. info(
			"quest_ghost",
			(
				line
				% [
					ghost,
					p.ghosts.transforms,
					stage.arena.kills,
					p.kerf.blinks,
					p.kerf.slices,
					p.ohm.bolts,
					p.ohm.struck,
					p.ohm.cars_hit,
					p.dent.misses,
					p.dent.seizes,
					p.dent.strikes,
					p.dent.blasts,
				]
			)
		)
	)


## The right stick on the nearest standing guard (the pad aim; the viewport is off, so no mouse).
func _aim_at(stage: CollectCallStage) -> void:
	var rivet: Vector2 = stage.arena.rivet.pos
	var best: Vector2 = Vector2.RIGHT
	var near: float = INF
	for h: Fighter in stage.arena.hostiles:
		if h.alive() and rivet.distance_to(h.pos) < near:
			near = rivet.distance_to(h.pos)
			best = (h.pos - rivet).normalized()
	if near > CAR_AIM_M and _ghost == &"ohm":  # no guard in the bolt's reach: the car bolt
		for b: VehicleBody in stage.cars():
			if b.state != VehicleBody.State.WRECK and rivet.distance_to(b.pos) < near:
				near = rivet.distance_to(b.pos)
				best = (b.pos - rivet).normalized()
	for axis: JoyAxis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y]:
		var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = best.x if axis == JOY_AXIS_RIGHT_X else best.y
		Input.parse_input_event(ev)
