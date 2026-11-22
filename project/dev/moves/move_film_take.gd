class_name MoveFilmTake
extends MoveTtkTrial
## Stage directions gate the m4 pilot's buttons. All hits, AI and cue lifetimes use the real stage.

const WEAPONS: Dictionary[StringName, StringName] = {
	MoveTable.SHORT_CIRCUIT: &"pistol",
	MoveTable.ARMOUR_CRACK: &"pistol",
	MoveTable.BLINK_BEHIND: &"",
	MoveTable.OVERKILL: &"hand_cannon",
}

var move: StringName
var second: bool
var compare_slice: bool = false
var subject: Fighter
var mind: SquadMind
var elapsed: int = 0
var film_frame: int = 0
var last_hit: String = ""
var first_stomp: int = -1
var first_round: int = -1
var carry_hits: int = 0


func open(id: StringName, off: bool, second_take: bool) -> bool:
	move = id
	second = second_take
	_open(move, WEAPONS[move], 1)
	stage.plan.areas[0].stenciled = false
	if not _configure(move, 2 if second and move == MoveTable.OVERKILL else 1):
		return false
	stage.arena.squad_ai.moves.get(move).enabled = not off
	if not _ready_pilot(move):
		return false
	_spawn(move, _enemy())
	subject = stage.arena.hostiles[0]
	if move == MoveTable.SHORT_CIRCUIT and not second:
		_escort()
	if move == MoveTable.OVERKILL:
		_cluster()
	if move == MoveTable.BLINK_BEHIND and second:
		subject.pos = Vector2(1.7, 0)
		if compare_slice:
			stage.arena.rivet.pos = Vector2(0.7, 0)
	mind = stage.arena.squad_ai.mind_for(subject)
	@warning_ignore("return_value_discarded")
	stage.arena.struck.connect(_hit)
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wound)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_kill)
	return true


func _enemy() -> StringName:
	match move:
		MoveTable.SHORT_CIRCUIT:
			return &"sentry_turret" if second else &"shield_robot"
		MoveTable.ARMOUR_CRACK:
			return &"war_machine"
		MoveTable.OVERKILL:
			return &"patrol_cop"
	return &"shield_robot"


func _stations() -> ArenaStations:
	return MoveFilmSet.stations(move == MoveTable.BLINK_BEHIND and second)


func _escort() -> void:
	var squad: ArenaSquad = stage.arena.squad_ai
	for offset: Vector2 in [Vector2(2.2, -1.2), Vector2(2.8, 1.4)]:
		var h: Fighter = squad.spawn_member(stage.arena, subject.pos + offset, &"swat")
		h.pos = subject.pos + offset
		h.facing = h.pos.direction_to(stage.arena.rivet.pos)


func _cluster() -> void:
	for i: int in range(1, 3):
		var offset: Vector2 = Vector2(1.0, -2.0) if i == 1 else Vector2(3.3, -1.3)
		stage.arena.hostiles[i].pos = subject.pos + offset


func advance() -> void:
	elapsed += 1
	var command: TickInput = TickInput.new()
	if subject.alive() and not (compare_slice and stage.pilot.kerf.slices > 0):
		command = controller.sample(subject)
		_direct(command)
	elif move == MoveTable.BLINK_BEHIND:
		var aim: Vector2 = stage.arena.rivet.pos.direction_to(subject.pos)
		command.buttons = PlayerCommand.pack_aim(aim, stage.pilot.actions)
	stage.step(stage.tick + 1, command)
	stage.clock.complete_tick()
	if not stage.pilot.kerf.trail_tick.is_empty() and stage.pilot.kerf.trail_tick[-1] == stage.tick:
		var r: Fighter = stage.arena.rivet
		mark(
			(
				"landing %s facing %s; shield %s facing %s"
				% [r.pos, r.facing, subject.pos, subject.facing]
			)
		)
	if stage.pilot.hauler.stomp_hits > 0 and first_stomp < 0:
		first_stomp = elapsed
		mark("Tonnage hit")
	if stage.pilot.ohm.bolt_tick == stage.tick:
		mark("bolt released")
	if mind.walker != null and mind.agent.shot_tick == stage.tick:
		mark("walker stomp" if mind.walker.attack.melee else "walker shell")
	if mind.turret != null and mind.agent.shot_tick == stage.tick:
		if first_round < 0:
			first_round = elapsed
		mark("turret round")
	if mind.stun_until > 0 and mind.stun_until == stage.tick:
		mark("short circuit expired")
	if mind.walker != null and mind.walker.cracked_at >= 0:
		var open_ticks: int = stage.arena.squad_ai.moves.tonnage_armour_crack.open_ticks
		if mind.walker.cracked_at + open_ticks == stage.tick:
			mark("split closed")


func _direct(cmd: TickInput) -> void:
	var pilot: StagePilot = stage.pilot
	var fire: int = 1 << pilot.actions.bit(&"fire")
	var melee: int = 1 << pilot.actions.bit(&"melee")
	match move:
		MoveTable.SHORT_CIRCUIT:
			var ready: bool = (
				elapsed >= 55 if not second else first_round >= 0 and elapsed >= first_round + 10
			)
			if not ready or pilot.ohm.bolts > 0:
				cmd.buttons &= ~melee
			var age: int = stage.tick - pilot.ohm.bolt_tick
			if pilot.ohm.bolts > 0 and age >= 30 and stage.shots_fired < (2 if second else 9):
				cmd.buttons |= fire
			else:
				cmd.buttons &= ~fire
		MoveTable.ARMOUR_CRACK:
			_tonnage(cmd, fire, melee)
		MoveTable.BLINK_BEHIND:
			var press: bool = elapsed == 94
			if second:
				# Sidestep the planted shield tell, then cut across its armoured front.
				var wind: int = mind.agent.arch.telegraph_ticks - subject.swing_left
				press = subject.swing_left > 0 and wind >= (20 if compare_slice else 33)
				if subject.swing_left > 0 and not press:
					cmd.move_y = -TickInput.AXIS_MAX
			if not press:
				cmd.buttons &= ~melee
		MoveTable.OVERKILL:
			if elapsed < 30 or stage.shots_fired > 0:
				cmd.buttons &= ~fire


func _tonnage(cmd: TickInput, fire: int, melee: int) -> void:
	if first_stomp >= 0 and elapsed - first_stomp > 305:
		# After the closed-plate control shot, close for the pilot's next counter.
		var approach: Vector2 = stage.arena.rivet.pos.direction_to(subject.pos)
		if subject.pos.distance_to(stage.arena.rivet.pos) > 3.1 and subject.swing_left == 0:
			cmd.move_x = roundi(approach.x * TickInput.AXIS_MAX)
			cmd.move_y = roundi(approach.y * TickInput.AXIS_MAX)
		return
	if first_stomp >= 0:
		cmd.buttons &= ~melee
	if first_stomp < 0 or elapsed - first_stomp not in [48, 300]:
		cmd.buttons &= ~fire


func _hit(h: Fighter, ray: Vector2, _lethal: bool, weapon: StringName) -> void:
	if h == subject and weapon == &"pistol":
		var k: float = FoeArmor.k(h, ray, &"shot", stage.arena.squad_ai, stage.arena.tick)
		var front: bool = h.facing.dot(-ray.normalized()) >= mind.agent.arch.shield_cos
		last_hit = tr("Front pistol  ×%.2f") % k if front else tr("Pistol  ×%.2f") % k
		mark(last_hit + " hp=%.2f" % h.hp)


func _wound(h: Fighter, weapon: StringName) -> void:
	if weapon == MoveTable.OVERKILL:
		carry_hits += 1
	mark("%s wounds %s, hp before %.2f" % [weapon, h.archetype, h.hp])


func _kill(h: Fighter, weapon: StringName, ray: Vector2, _at: Vector2, _kind: StringName) -> void:
	if weapon == MoveTable.OVERKILL:
		carry_hits += 1
	if weapon == &"kerf_slice":
		var bearing: float = h.facing.dot(-ray.normalized())
		last_hit = tr("Rear slice") if bearing <= FoeArmor.REAR_COS else tr("Shield-side slice")
		mark("slice bearing %.3f" % bearing)
	mark("%s kills %s" % [weapon, h.archetype])


func mark(event: String) -> void:
	Log.info("move-film", "frame=%d sim=%d %s" % [film_frame, stage.tick, event])


func close() -> void:
	data.free()
	bus.free()
