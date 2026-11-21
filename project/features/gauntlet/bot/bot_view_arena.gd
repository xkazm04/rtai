class_name BotViewArena
extends BotView
## The pit supplies only its wave members. The street uses the session's hostile roster.

var street_layout: GauntletStreet
var _stage: ArenaStage
var _actions: PlayerActions
var _street: bool
var _path: BotStreetPath = BotStreetPath.new()
var _guns: WeaponTable = WeaponTable.shipped()
var _next_waypoint: int = 0
var _deaths: int = 0
var _round_ids: Dictionary[Shot, int] = {}
var _next_round: int = 0


func _init(stage: ArenaStage, actions: PlayerActions, street: bool = false) -> void:
	_stage = stage
	_actions = actions
	_street = street
	_solids = stage.walls.boxes


func refresh() -> void:
	var rivet: Fighter = _stage.arena.rivet
	_player.pos = rivet.pos
	_player.facing = rivet.facing
	_player.radius = rivet.radius_m
	_player.hp = rivet.hp
	_player.can_roll = _stage.pilot != null and _stage.pilot.motion.can_roll()
	_player.can_guard = _actions.bit(&"guard") >= 0
	_player.shots_fired = _stage.shots_fired
	_player.rolls_started = _stage.pilot.motion.rolls if _stage.pilot != null else 0
	if _deaths != _stage.deaths:
		_next_waypoint = 0
		_deaths = _stage.deaths
	_read_forms()
	_read_slots()
	_read_hostiles()
	_read_rounds()


func forward() -> Vector2:
	if _street:
		var x: float = (
			street_layout.current().end_x() + 1.0 if street_layout != null else _player.pos.x + 8.0
		)
		return _toward(Vector2(x, 0.0))
	var last: int = ArenaPitBot.ENTRY.size() - 1
	var to: Vector2 = _stage.plan.base + ArenaPitBot.ENTRY[_next_waypoint] - _player.pos
	if to.length() <= ArenaPitBot.REACH_M and _next_waypoint < last:
		_next_waypoint += 1
		to = _stage.plan.base + ArenaPitBot.ENTRY[_next_waypoint] - _player.pos
	return to.limit_length(1.0)


func chase(foe: Hostile) -> Vector2:
	return _toward(foe.pos) if _street else super.chase(foe)


func _toward(goal: Vector2) -> Vector2:
	_path.clearance(
		_stage.arena.guard_map, _solids, _player.radius, _stage.arena.tuning.human["radius_m"]
	)
	return _path.toward(_stage.arena.guard_map, _player.pos, goal, _stage.arena.tick)


func _read_hostiles() -> void:
	_hostiles.clear()
	var roster: Array[Fighter] = _stage.arena.hostiles if _street else _stage.pit.standing
	for fighter: Fighter in roster:
		if not fighter.alive():
			continue
		var foe: Hostile = Hostile.new()
		foe.id = fighter.id
		foe.pos = fighter.pos
		foe.facing = fighter.facing
		foe.archetype = fighter.archetype if fighter.archetype != &"" else &"contractor"
		foe.alive = fighter.alive()
		foe.hp = fighter.hp
		foe.robot = fighter.machine
		foe.shooter = fighter.weapon != &""
		_read_tell(fighter, foe)
		_hostiles.append(foe)


func _read_tell(fighter: Fighter, foe: Hostile) -> void:
	var winding: bool = fighter.tell_left > 0 or fighter.swing_left > 0
	var squad: ArenaSquad = _stage.arena.squad_ai
	if squad != null and squad.minds.has(fighter.id):
		var agent: EnemyAgent = squad.minds[fighter.id].agent
		winding = winding or agent.state == EnemyAgent.State.WINDUP
		if &"tier" in agent.arch:
			foe.tier = agent.arch.get(&"tier")
	if winding:
		if foe.archetype in [&"rocket_trooper", &"war_machine", &"robot_gunner"]:
			foe.tell = &"large"
		else:
			foe.tell = &"small" if foe.shooter else &"melee"


func _read_rounds() -> void:
	_rounds.clear()
	var live: Dictionary[Shot, int] = {}
	for shot: Shot in _stage.arena.shots:
		if shot.from_rivet:
			continue
		var round_in: Round = Round.new()
		if not _round_ids.has(shot):
			_next_round += 1
			_round_ids[shot] = _next_round
		round_in.id = _round_ids[shot]
		live[shot] = round_in.id
		round_in.pos = shot.pos
		round_in.vel = shot.vel
		round_in.remaining_m = shot.left_m
		round_in.size = shot.size
		_rounds.append(round_in)
	_round_ids = live


func _read_forms() -> void:
	var ghosts: GhostPilot = _stage.pilot.ghosts if _stage.pilot != null else null
	_player.forms.clear()
	_player.car_pos = Vector2.INF
	_player.seized_car_pos = Vector2.INF
	if ghosts == null:
		_player.form = &"base"
		_player.settled = true
		_player.selected = &""
		return
	var forms: GhostForms = ghosts.forms
	_player.form = forms.current()
	_player.settled = forms.settled()
	_player.selected = forms.selected
	for id: StringName in forms.table.order:
		var power: StringName = forms.table.form(id).power
		var cost: float = ghosts.powers.table.row(power).madness_cost
		if forms.locks.allows(forms.table, id) and ghosts.powers.cooldown_left(power) == 0:
			if ghosts.powers.madness + cost <= ghosts.powers.table.madness_max:
				_player.forms.append(id)
	if ghosts.dent.car != null:
		_player.seized_car_pos = ghosts.dent.car.pos
	for car: VehicleBody in _stage.cars():
		if car.state != VehicleBody.State.WRECK and not car.soul_hijacked:
			if _player.pos.distance_to(car.pos) < _player.pos.distance_to(_player.car_pos):
				_player.car_pos = car.pos


func _read_slots() -> void:
	_slots.clear()
	var carry: RivetCarry = _stage.pilot.carry if _stage.pilot != null else null
	_player.current_slot = carry.current if carry != null else -1
	if carry != null:
		for i: int in carry.slots.size():
			if carry.slots[i] != &"":
				_add_slot(i, carry.slots[i], carry.melee_ids.has(carry.slots[i]))
	if _player.current_slot < 0 and _stage.arena.rivet.weapon != &"":
		_add_slot(-1, _stage.arena.rivet.weapon, false)


func _add_slot(index: int, id: StringName, melee: bool) -> void:
	var slot: Slot = Slot.new()
	slot.index = index
	slot.action = RivetCarry.SLOT_ACTIONS[index] if index >= 0 else &""
	slot.melee = melee
	if melee:
		slot.reach = GauntletBot.MELEE_M
	elif _stage.arena.tuning.weapons.has(id):
		slot.reach = _stage.arena.tuning.weapon(id).range_m
	elif _guns.weapons.has(id):
		slot.reach = _guns.weapon(id).range_m
	else:
		return
	_slots.append(slot)
