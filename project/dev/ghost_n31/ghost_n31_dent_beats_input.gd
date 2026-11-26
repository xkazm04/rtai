class_name GhostN31DentBeatsInput
extends InputSource
## n31 ghost 17 (dev only): selects Dent, then one drop press at PRESS_TICK aimed AHEAD_M along
## +x, with standing foes in and beside the lane (brain owned: they hold still for every beat).

const PRESS_TICK: int = 90
const AHEAD_M: float = 6.0
## Foes at these offsets from Rivet (m): three in the lane, two beside it.
const FOES: Array[Vector2] = [
	Vector2(2.5, 0.3), Vector2(4.2, -0.6), Vector2(5.6, 0.5), Vector2(3.4, 2.6), Vector2(6.5, -2.8)
]

var stage: ArenaStage
var spot: Vector2
var press_tick: int = -1


func bind(source: ArenaStage) -> void:
	stage = source
	spot = stage.arena.rivet.pos + Vector2(AHEAD_M, 0.0)
	for at: Vector2 in FOES:
		var foe: Fighter = stage.arena.squad_ai.spawn_member(
			stage.arena, stage.arena.rivet.pos + at, &"patrol_cop"
		)
		foe.brain_owned = true


func sample(tick: int) -> TickInput:
	var actions: PlayerActions = stage.pilot.actions
	var bits: int = 0
	if stage.pilot.ghosts.forms.selected != DentStage.GHOST and tick % 2 == 0:
		bits |= 1 << actions.bit(&"power_gearbox")
	if tick == PRESS_TICK:
		bits |= 1 << actions.bit(&"ghost_deploy")
		press_tick = tick
	var aim: Vector2 = spot - stage.arena.rivet.pos
	bits |= PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	return TickInput.new(bits, 0, 0)
