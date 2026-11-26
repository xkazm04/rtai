class_name GhostN31KerfBeatsInput
extends InputSource
## n31 ghost 21 (dev only): selects Kerf, then one drop press at PRESS_TICK aimed AHEAD_M along
## +x at a target that walks WALK_M a tick across the aim through the wind-up (the lock follows
## it), with two standing bystanders (brain owned: they hold still for every beat).

const PRESS_TICK: int = 90
const AHEAD_M: float = 6.0
const TARGET_AT: Vector2 = Vector2(6.0, 0.4)
const WALK_M: Vector2 = Vector2(0.0, 0.05)
const BYSTANDERS: Array[Vector2] = [Vector2(3.0, -1.8), Vector2(7.5, -2.6)]

var stage: ArenaStage
var spot: Vector2
var target: Fighter
var press_tick: int = -1


func bind(source: ArenaStage) -> void:
	stage = source
	spot = stage.arena.rivet.pos + Vector2(AHEAD_M, 0.0)
	target = _spawn(TARGET_AT)
	for at: Vector2 in BYSTANDERS:
		@warning_ignore("return_value_discarded")
		_spawn(at)


func _spawn(at: Vector2) -> Fighter:
	var foe: Fighter = stage.arena.squad_ai.spawn_member(
		stage.arena, stage.arena.rivet.pos + at, &"patrol_cop"
	)
	foe.brain_owned = true
	return foe


func sample(tick: int) -> TickInput:
	var actions: PlayerActions = stage.pilot.actions
	var bits: int = 0
	if stage.pilot.ghosts.forms.selected != KerfStage.GHOST and tick % 2 == 0:
		bits |= 1 << actions.bit(&"power_gearbox")
	if tick == PRESS_TICK:
		bits |= 1 << actions.bit(&"ghost_deploy")
		press_tick = tick
	elif press_tick >= 0 and target.alive():
		target.pos += WALK_M
	var aim: Vector2 = spot - stage.arena.rivet.pos
	bits |= PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	return TickInput.new(bits, 0, 0)
