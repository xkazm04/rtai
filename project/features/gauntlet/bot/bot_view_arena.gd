class_name BotViewArena
extends BotView
## The pit supplies only its wave members. The street uses the session's hostile roster.

var street_layout: GauntletStreet
var _stage: ArenaStage
var _actions: PlayerActions
var _street: bool
var _path: BotStreetPath = BotStreetPath.new()
var _arsenal: BotArsenal = BotArsenal.new()
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
	var street_combat: GauntletCombat = _stage.arena as GauntletCombat
	_player.repair_available = street_combat == null or street_combat.can_repair()
	_player.street_max_hp = rivet.max_hp if _street else 0.0
	_player.walk_mps = _stage.arena.tuning.rivet["walk_mps"]
	if _stage.pilot != null:
		var motion: PlayerMotion = _stage.pilot.motion
		_player.roll_m = motion.roll_m
		_player.roll_ticks = motion.roll_ticks
		_player.iframe_from = motion.iframe_from
		_player.iframe_to = motion.iframe_to
	_player.can_roll = _stage.pilot != null and _stage.pilot.motion.can_roll()
	_player.can_guard = _actions.bit(&"guard") >= 0
	if _street:
		var pilot: StagePilot = _stage.pilot
		_player.can_guard = (
			pilot != null
			and pilot.guard != null
			and not pilot.guard.broken()
			and PlayerGuardInput.available(pilot, _stage.arena)
		)
	_player.shots_fired = _stage.shots_fired
	_player.rolls_started = _stage.pilot.motion.rolls if _stage.pilot != null else 0
	if _deaths != _stage.deaths:
		_next_waypoint = 0
		_deaths = _stage.deaths
	_read_forms()
	_arsenal.observe(self, _stage, _street)
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


func blink_clear(aim: Vector2) -> bool:
	if street_layout == null:
		return true
	var kerf: KerfStage = _stage.pilot.kerf
	var at: Vector2 = _player.pos
	var hit: Fighter = kerf.pick(_stage, aim)
	var landing: Vector2 = at + aim * kerf.num(&"dash_m")
	if hit != null:
		landing = hit.pos + at.direction_to(hit.pos) * (kerf.num(&"behind_m") + hit.radius_m)
	return (
		_stage.arena.squad_ai.pit.bounds.has_point(landing)
		and _stage.arena.guard_map.clear_line(at, landing)
	)


func retreat() -> Vector2:
	if street_layout == null:
		return super.retreat()
	var goal: Vector2 = Vector2(street_layout.window[0].start_x + 2.0, 0.0)
	return _toward(goal) if _player.pos.distance_to(goal) > 0.3 else Vector2.ZERO


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
		var foe: Hostile = BotArenaFoe.read(fighter, _stage.arena)
		BotArenaMoves.observe(_stage, fighter, foe, _player)
		_hostiles.append(foe)


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
	_player.stomp_reach = ghosts.hauler.form.num(&"stomp_radius_m")
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
