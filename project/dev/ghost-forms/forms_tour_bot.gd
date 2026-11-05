class_name FormsTourBot
extends InputSource
## `--bot=forms [--form=<id>|all]` (ghost-forms proof clips): Rivet walks a square in base, picks
## the form with G, transforms with Q while walking, walks the square in the form, and Q takes him
## back to base; `--form=all` goes base -> Tonnage, then G switches through Dent, Kerf and Ohm
## (the teal flash) before Q back; `--form=voices` only walks (base: for `--apparition`). Input
## only (the live GhostPilot does the rest).

const START_AT: int = 40
## Ticks per side of the walked square.
const SIDE: int = 75
const HOLD: int = 330
const HOLD_ALL: int = 170
const SIDES: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var stage: ArenaStage
var actions: PlayerActions
var form: StringName = &"dent"
## (tick, action) presses, in order.
var plan: Array[Array] = []


func _init(p_stage: ArenaStage, p_actions: PlayerActions, p_form: StringName) -> void:
	stage = p_stage
	actions = p_actions
	form = p_form
	_plan()


static func of(p_stage: ArenaStage, p_actions: PlayerActions, args: ArenaArgs) -> FormsTourBot:
	return FormsTourBot.new(p_stage, p_actions, StringName(args.text("--form", "dent")))


func _plan() -> void:
	var t: int = START_AT + 60
	var order: Array[StringName] = stage.pilot.ghosts.forms.table.order if stage.pilot else []
	if form == &"voices":
		return
	if form == &"all":
		plan.append([t, &"power_hauler"])  # the first in the order (Tonnage)
		for i: int in order.size() - 1:
			t += HOLD_ALL
			plan.append([t, &"power_gearbox"])
		plan.append([t + HOLD_ALL, &"power_hauler"])
		return
	for i: int in maxi(0, order.find(form)):
		plan.append([t, &"power_gearbox"])
		t += 2
	plan.append([t, &"power_hauler"])
	plan.append([t + HOLD, &"power_hauler"])


func sample(tick: int) -> TickInput:
	if tick < START_AT:
		return _input(Vector2.ZERO, Vector2.RIGHT, &"")
	var dir: Vector2 = SIDES[((tick - START_AT) / SIDE) % SIDES.size()]
	var act: StringName = &""
	for p: Array in plan:
		if p[0] == tick:
			act = p[1]
	return _input(dir * 0.75, dir, act)


func _input(move: Vector2, aim: Vector2, act: StringName) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if act != &"":
		buttons |= 1 << actions.bit(act)
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
