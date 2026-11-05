extends "res://dev/ghost-powers/quest_hauler_rec.gd"
## A ghost's attack set in quest 1's real view (boot/quest1.tscn, the shipped sprite cast unless
## `--rigs`), through bound input only: Start, a spread group of dock guards east of Rivet, then
## G taps (power_gearbox) to pick the ghost (order tonnage, dent, kerf, ohm), Q (power_hauler)
## to take it, the right stick on the nearest standing guard and a melee press every CADENCE
## ticks (Kerf's blink-slice, Ohm's bolt; Dent's press is fire, the seize: in quest 1 a reach
## that finds no car). One tick per frame, a PNG every tick. Dev-only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/quest_ghost_rec.tscn
##     -- --out=<abs dir> --ghost=<dent|kerf|ohm> [--ppm=<32|48|64>] [--rigs]

const ORDER: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]
const GROUP: Array[Vector2] = [
	Vector2(4.5, -1.2), Vector2(6.0, 1.4), Vector2(7.5, -0.4), Vector2(6.5, 3.0), Vector2(8.5, 1.0)
]
const TICKS: int = 300
const TAKE_AT: int = 30
const FIRST_PRESS: int = 70
const CADENCE: int = 20


func _run() -> void:
	var ghost: StringName = &"kerf"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ghost="):
			ghost = StringName(arg.substr(8))
	var s: Quest1Session = _game.session
	for i: int in WARM:
		s.step()
	var stage: CollectCallStage = s.stage
	var at: Vector2 = stage.arena.rivet.pos
	for off: Vector2 in GROUP:
		var g: Fighter = stage.arena.spawn_guard(at + off)
		g.pos = at + off
	var picks: int = ORDER.find(ghost)
	for t: int in TICKS:
		_tap(&"power_gearbox", t >= 10 and t < 10 + 4 * picks and (t - 10) % 4 == 0)
		_tap(&"power_hauler", t == TAKE_AT)
		var beat: bool = t >= FIRST_PRESS and (t - FIRST_PRESS) % CADENCE == 0
		_tap(&"fire" if ghost == &"dent" else &"melee", beat)
		_aim_at(stage)
		Input.flush_buffered_events()
		s.step()
		await _save()
		await _hold(s.world.context().clock)
	_report(ghost, stage)


func _report(ghost: StringName, stage: CollectCallStage) -> void:
	var p: StagePilot = stage.pilot
	var line: String = "%s: transforms %d kills %d kerf blinks %d slices %d"
	line += " ohm bolts %d struck %d dent misses %d"
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
					p.dent.misses,
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
	for axis: JoyAxis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y]:
		var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = best.x if axis == JOY_AXIS_RIGHT_X else best.y
		Input.parse_input_event(ev)
