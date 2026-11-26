class_name GhostN31BeatsInput
extends InputSource
## n31 ghost 03 (dev only): selects Tonnage, then one drop press at PRESS_TICK on a ring of
## standing foes (brain owned: they hold still so every beat is filmed on the same spot).

const PRESS_TICK: int = 90
const AHEAD_M: float = 5.5
## Foes at these distances from the spot (m) on a spread of angles: inside and outside 6.5 m.
const RING: Array[Vector2] = [
	Vector2(2.5, 0.4), Vector2(4.5, 2.2), Vector2(6.0, 4.1), Vector2(7.6, 5.3), Vector2(5.2, 3.3)
]

var stage: ArenaStage
var spot: Vector2
var press_tick: int = -1
var kill: bool = false
var crush_cop: Fighter = null


func bind(source: ArenaStage) -> void:
	stage = source
	spot = stage.arena.rivet.pos + Vector2(AHEAD_M, 0.0)
	for at: Vector2 in RING:
		var foe: Fighter = stage.arena.squad_ai.spawn_member(
			stage.arena, spot + Vector2.from_angle(at.y) * at.x, &"patrol_cop"
		)
		foe.brain_owned = true
	if kill:
		var cop: Fighter = stage.arena.squad_ai.spawn_member(
			stage.arena, spot + Vector2(-1.0, 0.0), &"patrol_cop"
		)
		cop.brain_owned = true
		cop.max_hp = 1.0
		cop.hp = 1.0
		crush_cop = cop


func sample(tick: int) -> TickInput:
	var actions: PlayerActions = stage.pilot.actions
	var bits: int = 0
	if stage.pilot.ghosts.forms.selected != HaulerStage.GHOST and tick % 2 == 0:
		bits |= 1 << actions.bit(&"power_gearbox")
	if tick == PRESS_TICK:
		bits |= 1 << actions.bit(&"ghost_deploy")
		press_tick = tick
	var aim: Vector2 = spot - stage.arena.rivet.pos
	bits |= PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	return TickInput.new(bits, 0, 0)
