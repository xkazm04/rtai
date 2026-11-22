class_name MoveTtkPilot
extends RefCounted
## Both arms read the same tells and cooldowns. The pilot never reads a move switch or tally.

var stage: ArenaStage
var move: StringName
var flank: bool = false


func _init(host: ArenaStage, id: StringName) -> void:
	stage = host
	move = id


func sample(target: Fighter) -> TickInput:
	var pilot: StagePilot = stage.pilot
	var aim: Vector2 = stage.arena.rivet.pos.direction_to(target.pos)
	var walk: Vector2 = Vector2.ZERO
	var fire: bool = false
	var melee: bool = false
	match move:
		MoveTable.SHORT_CIRCUIT:
			melee = pilot.ghosts.settled_in(OhmStage.GHOST) and pilot.ohm.gap_left() <= 1
			fire = not melee and pilot.ohm.cast.due_tick < 0
			if flank:
				var mind: SquadMind = stage.arena.squad_ai.mind_for(target)
				if _turret_safe(mind, target, -aim):
					walk = _strafe(target, -aim)
				else:
					fire = false
		MoveTable.ARMOUR_CRACK:
			var mind: SquadMind = stage.arena.squad_ai.mind_for(target)
			walk = _walker_move(target, mind)
			melee = TonnageCrack.post_stomp(mind) and pilot.hauler.form.stomp_ready()
			fire = pilot.hauler.stomp_hits > 0
		MoveTable.BLINK_BEHIND:
			if stage.arena.rivet.pos.distance_to(target.pos) > pilot.kerf.num(&"range_m"):
				walk = aim
			else:
				melee = _blink_ready(pilot.kerf)
		MoveTable.OVERKILL:
			fire = true
	var actions: PlayerActions = pilot.actions
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	if melee:
		buttons |= 1 << actions.bit(&"melee")
	return TickInput.new(
		buttons, roundi(walk.x * TickInput.AXIS_MAX), roundi(walk.y * TickInput.AXIS_MAX)
	)


func _blink_ready(kerf: KerfStage) -> bool:
	var blinks: PackedInt32Array = kerf.trail_tick
	var gap: int = PowerDef.ticks(kerf.num(&"gap_s"))
	return kerf.charges > 0 and (blinks.is_empty() or stage.tick + 1 >= blinks[-1] + gap)


func _walker_move(target: Fighter, mind: SquadMind) -> Vector2:
	# A short backward input lets Tonnage's momentum carry him past the ring.
	# Release the stick early enough to stop within reach of the press head.
	if target.swing_left > mind.agent.arch.alt_telegraph_ticks - 12:
		return target.pos.direction_to(stage.arena.rivet.pos)
	return Vector2.ZERO


func _turret_safe(mind: SquadMind, target: Fighter, radial: Vector2) -> bool:
	if mind.agent.shot_tick == stage.tick:
		return false
	# The turret traverses in the positive angular direction through its committed sweep.
	var ahead: float = target.facing.angle_to(radial)
	return (
		mind.turret.phase != FoeTurret.Phase.SWEEP
		or ahead < 0.0
		or ahead > 2.0 * FoeTurret.HALF_ARC
	)


func _strafe(target: Fighter, radial: Vector2) -> Vector2:
	if radial.dot(target.facing) <= FoeArmor.REAR_COS:
		return Vector2.ZERO
	var range_error: float = (
		target.pos.distance_to(stage.arena.rivet.pos) - FoeTtkTrial.GUN_DISTANCE_M
	)
	return (radial.rotated(PI / 2.0) - radial * range_error).limit_length(1.0)
