class_name MoveTtkTrial
extends RefCounted
## An empty arena keeps the bound pilot, live squad, real projectiles and form clocks.
## Timing starts with weapon drawn and form settled, immediately before the first combat input.

var stage: ArenaStage
var ctx: WorldContext
var controller: MoveTtkPilot
var bus: EventBus = EventBus.new()
var data: DataStore = DataStore.new()
var stomp_dodges: int = 0
var turret_rounds: int = 0
var rounds_during_stun: int = 0
var partial_carries: int = 0
var front_gun_k: Array[float] = []
var flank: bool = false
var rear_gun_hits: int = 0


func _init(turret_flank: bool = false) -> void:
	flank = turret_flank


func measure(
	move: StringName, enemy: StringName, weapon: StringName, seed_id: int, rank: int
) -> Dictionary:
	_open(move, weapon, seed_id)
	var row: Dictionary = {}
	if _configure(move, rank) and _ready_pilot(move):
		_spawn(move, enemy)
		row = _fight(move)
	data.free()
	bus.free()
	return row


func _open(move: StringName, weapon: StringName, seed_id: int) -> void:
	var plan: ArenaPlan = ArenaPlan.new()
	var floor_area: ArenaPlan.Area = ArenaPlan.Area.new()
	floor_area.rect = Rect2(-60, -60, 120, 120)
	plan.areas.append(floor_area)
	var args: ArenaArgs = ArenaArgs.new()
	args.values["--enemy-brain"] = "squad"
	stage = ArenaStage.new(plan, _stations(), args)
	ctx = World.build_context(bus, data, seed_id)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.arena.rivet.weapon = weapon
	stage.guns = StageGuns.make(ctx.rng.stream(&"gunplay"))
	controller = MoveTtkPilot.new(stage, move)
	controller.flank = flank
	@warning_ignore("return_value_discarded")
	stage.arena.struck.connect(_observe_impact)
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_observe_wound)


func _stations() -> ArenaStations:
	return ArenaStations.new()


func _configure(move: StringName, rank: int) -> bool:
	var table: MoveTable = stage.arena.squad_ai.moves
	if not table.errors.is_empty():
		return false
	var row: MoveTable.Row = table.get(move)
	row.enabled = rank > 0
	if move == MoveTable.OVERKILL:
		for grant: int in range(1, rank + 1):
			if not MoveCarry.grant(stage, grant):
				return false
	return true


func _ready_pilot(move: StringName) -> bool:
	var forms: GhostForms = stage.pilot.ghosts.forms
	match move:
		MoveTable.SHORT_CIRCUIT:
			forms.selected = OhmStage.GHOST
		MoveTable.ARMOUR_CRACK:
			forms.selected = HaulerStage.GHOST
		MoveTable.BLINK_BEHIND:
			forms.selected = KerfStage.GHOST
	if move != MoveTable.OVERKILL and forms.press_transform() != SoulPowers.OK:
		return false
	for warmup: int in 2 * SimClock.TICK_RATE:
		stage.step(warmup + 1, TickInput.new())
		if forms.settled() and (stage.arena.rivet.weapon == &"" or stage.pilot.hold.can_fire()):
			return true
	return false


func _spawn(move: StringName, enemy: StringName) -> void:
	var distance: float = 3.1 if move == MoveTable.ARMOUR_CRACK else FoeTtkTrial.GUN_DISTANCE_M
	var offsets: Array[float] = [0.0]
	if move == MoveTable.OVERKILL:
		offsets.append_array([-1.0, 1.0])
	var squad: ArenaSquad = stage.arena.squad_ai
	for offset: float in offsets:
		var at: Vector2 = Vector2(distance, offset)
		var h: Fighter = squad.spawn_member(stage.arena, at, enemy)
		# Drop spawn jitter, retain seeded cooldown and gun spread.
		h.pos = at
		h.facing = h.pos.direction_to(stage.arena.rivet.pos)
		if squad.mounts.anchors.has(h):
			squad.mounts.anchors[h] = at
	stage.arena.move_tally.begin_wave()


func _fight(move: StringName) -> Dictionary:
	var arena: CombatArena = stage.arena
	var elapsed: Variant = null
	for tick: int in range(1, FoeTtkTrial.LIMIT + 1):
		var target: Fighter = _first_alive()
		if move == MoveTable.SHORT_CIRCUIT and not flank:
			arena.rivet.pos = target.pos + Vector2.LEFT * FoeTtkTrial.GUN_DISTANCE_M
		stage.step(stage.tick + 1, controller.sample(target))
		_observe_attack(target)
		if arena.hostiles_alive() == 0:
			elapsed = tick
			break
		if not arena.rivet.alive():
			break
	return _result(move, elapsed)


func _result(move: StringName, elapsed: Variant) -> Dictionary:
	var arena: CombatArena = stage.arena
	var wave: Dictionary = {}
	arena.move_tally.append_wave(wave)
	var moves: Dictionary = wave.get("moves", {})
	var result: Dictionary = {
		"kill_tick": elapsed,
		"damage_to_rivet": stage.telemetry.damage_taken,
		"move_uses": moves.get(move, 0),
		"gun_shots": stage.shots_fired,
	}
	if move in [MoveTable.SHORT_CIRCUIT, MoveTable.ARMOUR_CRACK]:
		result.front_gun_multipliers = front_gun_k
	if arena.hostiles[0].archetype == &"sentry_turret":
		result.turret_rounds = turret_rounds
		result.rounds_during_short_circuit = rounds_during_stun
		result.rear_gun_hits = rear_gun_hits
	if move == MoveTable.BLINK_BEHIND:
		result.slices = stage.pilot.kerf.slices
	if move == MoveTable.ARMOUR_CRACK:
		result.stomps_dodged = stomp_dodges
		result.tonnage_hits = stage.pilot.hauler.stomp_hits
	if move == MoveTable.OVERKILL:
		result.nonlethal_carries = partial_carries
	return result


func _first_alive() -> Fighter:
	for h: Fighter in stage.arena.hostiles:
		if h.alive():
			return h
	return null


func _observe_attack(h: Fighter) -> void:
	var mind: SquadMind = stage.arena.squad_ai.minds.get(h.id)
	if mind == null or mind.agent.shot_tick != stage.tick:
		return
	if mind.turret != null:
		turret_rounds += 1
		rounds_during_stun += int(OhmShortCircuit.held(stage.arena.squad_ai, h))
	if mind.walker != null and mind.walker.attack.melee:
		if h.pos.distance_to(stage.arena.rivet.pos) > mind.walker.attack.splash_radius_m:
			stomp_dodges += 1


func _observe_impact(h: Fighter, ray: Vector2, _lethal: bool, weapon: StringName) -> void:
	var arena: CombatArena = stage.arena
	if weapon != arena.rivet.weapon or h == arena.rivet:
		return
	var arch: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(h.archetype)
	var bearing: float = h.facing.dot(-ray.normalized())
	rear_gun_hits += int(bearing <= FoeArmor.REAR_COS)
	if not arch.explicit_spawn or bearing < arch.shield_cos:
		return
	var multiplier: float = FoeArmor.k(h, ray, &"shot", arena.squad_ai, arena.tick)
	if not front_gun_k.has(multiplier):
		front_gun_k.append(multiplier)


func _observe_wound(_h: Fighter, weapon: StringName) -> void:
	if weapon == MoveTable.OVERKILL:
		partial_carries += 1
