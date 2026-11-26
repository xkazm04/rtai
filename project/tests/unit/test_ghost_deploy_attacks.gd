extends GutTest

var stage: CollectCallStage
var arena: CombatArena
var squad: ArenaSquad
var pilot: StagePilot
var ghost: GhostDeploy
var last_weapon: StringName


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	arena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	for id: StringName in [&"ohm", &"dent"]:  # n31: shipped drops; these drive the hold flow
		ghost.strike.attacks.deploy[id].press_mode = &"hold"
	ghost.strike.attacks.deploy[&"ohm"].radius_m = 3.5  # Ohm's pre-n31 radius
	watch_signals(bus)
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(_killed)


func _killed(
	_foe: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	last_weapon = weapon


func _spawn(at: Vector2, id: StringName = &"contractor", hp: float = 100.0) -> Fighter:
	var foe: Fighter = squad.spawn_member(arena, at, id)
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = hp
	foe.hp = hp
	return foe


func _release(form: StringName, reach: float = 6.0) -> void:
	pilot.ghosts.forms.selected = form
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, reach)
	stage.tick += 1
	pilot.drive(stage, TickInput.new(aim | (1 << pilot.actions.bit(&"ghost_deploy"))))
	stage.tick += 1
	pilot.drive(stage, TickInput.new(aim))


func test_kerf_prefers_cursor_target_and_slices_once_from_its_back() -> void:
	var by_line: Fighter = _spawn(Vector2(2, 0))
	var primary: Fighter = _spawn(Vector2(6, 1), &"contractor", 1.0)
	var runner_up: Fighter = _spawn(Vector2(6, -1.5))
	var near_player: Fighter = _spawn(Vector2(0.2, 0))
	_release(&"kerf")
	var behind: float = pilot.kerf.num(&"behind_m") + primary.radius_m
	assert_eq(ghost.spot, primary.pos - primary.facing * behind)
	assert_eq(arena.hit_dir, primary.facing)
	assert_eq(arena.hit_at, primary.pos - primary.facing * primary.radius_m)
	assert_eq(last_weapon, &"deploy_kerf")
	assert_signal_emitted_with_parameters(
		stage.events(), "actor_killed", [arena.rivet.id, primary.id, KerfStage.KILL_KIND]
	)
	assert_eq(by_line.hp, by_line.max_hp)
	assert_eq(runner_up.hp, runner_up.max_hp)
	assert_eq(near_player.hp, near_player.max_hp)
	assert_eq(arena.rivet.pos, Vector2.ZERO)


func test_kerf_falls_back_to_clear_aim_line_within_range_and_uses_robot_damage() -> void:
	var beyond: Fighter = _spawn(Vector2(10, 0))
	var hidden: Fighter = _spawn(Vector2(4, 0))
	var robot: Fighter = _spawn(Vector2(6, 2), &"robot_thug")
	arena.walls = ArenaWalls.new()
	arena.walls.boxes.append(Rect2(3, -0.2, 0.2, 0.4))
	_release(&"kerf", 1.2)
	assert_eq(robot.max_hp - robot.hp, pilot.kerf.num(&"robot_damage"))
	assert_eq(beyond.hp, beyond.max_hp)
	assert_eq(hidden.hp, hidden.max_hp)


func test_kerf_still_cuts_when_a_wall_shortens_the_rear_landing() -> void:
	var target: Fighter = _spawn(Vector2(6, 0), &"contractor", 1.0)
	arena.walls = ArenaWalls.new()
	arena.walls.boxes.append(Rect2(5, 1, 2, 0.3))
	_release(&"kerf")
	assert_eq(last_weapon, &"deploy_kerf")
	assert_false(target.alive())
	assert_gt(ghost.spot.y, target.pos.y)
	assert_lt(ghost.spot.y, 1.0)
	assert_false(arena.walls.blocks(target.pos, ghost.spot))


func test_centring_the_stick_at_release_rechecks_reach_from_moving_rivet() -> void:
	ghost.strike.attacks.deploy[&"tonnage"].press_mode = &"hold"  # n31: pin the hold flow
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	pilot.drive(stage, TickInput.new(aim | (1 << pilot.actions.bit(&"ghost_deploy"))))
	arena.rivet.pos = Vector2(-0.1, 0)
	pilot.drive(stage, TickInput.new())
	assert_almost_eq(ghost.spot.x, 5.9, 0.00001)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)


func test_ohm_damages_every_hostile_in_radius_and_only_shorts_flagged_machines() -> void:
	var human: Fighter = _spawn(Vector2(5, 0), &"contractor", 1.0)
	var turret: Fighter = _spawn(Vector2(6, 3.5), &"sentry_turret")
	var walker: Fighter = _spawn(Vector2(7, 0), &"war_machine")
	turret.facing = Vector2.RIGHT
	var far: Fighter = _spawn(Vector2(6, 3.51), &"sentry_turret")
	var immune: Fighter = _spawn(Vector2(6, -2), &"sentry_turret")
	squad.mind_for(immune).immune_until = 40
	_release(&"ohm")
	assert_false(human.alive())
	assert_eq(last_weapon, &"deploy_ohm")
	assert_eq(turret.max_hp - turret.hp, pilot.ohm.num(&"bolt_damage"))
	assert_lt(walker.hp, walker.max_hp)
	assert_eq(far.hp, far.max_hp)
	assert_eq(squad.mind_for(human).stun_until, 0)
	assert_eq(squad.mind_for(far).stun_until, 0)
	assert_eq(squad.mind_for(immune).stun_until, 0)
	var row: MoveTable.ShortCircuit = squad.moves.ohm_short_circuit
	assert_eq(squad.mind_for(turret).stun_until, stage.tick + row.stun_ticks)
	assert_eq(squad.mind_for(walker).stun_until, stage.tick + row.boss_stun_ticks)
	assert_eq(squad.mind_for(walker).immune_until, stage.tick + row.immune_ticks)


func test_tonnage_stomps_only_in_front_and_opens_a_walker_outside_recovery() -> void:
	var front: Fighter = _spawn(Vector2(7, 0), &"contractor", 1.0)
	var back: Fighter = _spawn(Vector2(5.9, 0))
	var far: Fighter = _spawn(Vector2(11, 0))
	var walker: Fighter = _spawn(Vector2(8, 0), &"war_machine")
	walker.facing = Vector2.LEFT
	assert_false(TonnageCrack.post_stomp(squad.mind_for(walker)))
	ghost.strike.attacks.deploy[&"tonnage"].press_mode = &"hold"  # n31: pin the hold flow
	_release(&"tonnage")
	assert_false(front.alive())
	assert_eq(last_weapon, &"deploy_tonnage")
	assert_eq(back.hp, back.max_hp)
	assert_eq(far.hp, far.max_hp)
	assert_eq(walker.max_hp - walker.hp, pilot.hauler.form.num(&"stomp_damage"))
	assert_true(
		TonnageCrack.is_open(squad.mind_for(walker), squad.moves.tonnage_armour_crack, stage.tick)
	)


func test_dent_hits_the_swept_segment_and_knocks_along_it() -> void:
	var first: Fighter = _spawn(Vector2(2, 0), &"contractor", 1.0)
	var last: Fighter = _spawn(Vector2(5.9, 0))
	var wide: Fighter = _spawn(Vector2(3, 2))
	var beyond: Fighter = _spawn(Vector2(7.1, 0))
	var before: Vector2 = last.pos
	_release(&"dent")
	assert_eq(ghost.origin, Vector2.RIGHT.orthogonal() * arena.rivet.radius_m)
	assert_eq(ghost.spot, Vector2(6, 0))
	assert_false(first.alive())
	assert_eq(last_weapon, &"deploy_dent")
	assert_eq(last.max_hp - last.hp, pilot.ghosts.jab.num(&"jab_damage"))
	assert_almost_eq(last.pos.distance_to(before), pilot.ghosts.jab.num(&"jab_knock_m"), 0.001)
	assert_eq(wide.hp, wide.max_hp)
	assert_eq(beyond.hp, beyond.max_hp)
	assert_eq(arena.rivet.pos, Vector2.ZERO)


func test_kerf_includes_snap_and_range_edges_from_a_displaced_rivet() -> void:
	var r: Vector2 = Vector2(20, 7)
	arena.rivet.pos = r
	var line: Fighter = _spawn(r + Vector2.RIGHT)
	var edge: Fighter = _spawn(r + Vector2(9, 0))
	var picked: Fighter = GhostDeploySpot.kerf_target(
		stage, r + Vector2(9, 2), Vector2.RIGHT, ghost.strike.attacks
	)
	assert_same(picked, edge)
	_release(&"kerf", 9.0)
	assert_eq(edge.max_hp - edge.hp, pilot.kerf.num(&"human_damage"))
	assert_eq(line.hp, line.max_hp)


func test_kerf_ignores_a_hostile_outside_both_snap_and_cone() -> void:
	var side: Fighter = _spawn(Vector2(0, 4))
	_release(&"kerf")
	assert_eq(side.hp, side.max_hp)


func test_dent_includes_the_end_cap_at_its_half_width() -> void:
	ghost.strike.attacks.deploy[&"dent"].ram_half_m = 1.0
	var rim: Fighter = _spawn(Vector2(7, 0))
	_release(&"dent")
	assert_eq(rim.max_hp - rim.hp, pilot.ghosts.jab.num(&"jab_damage"))


func test_deploy_respects_city_solids_without_arena_wall_boxes() -> void:
	stage.arena.walls = null
	stage.cells = StageCells.shipped()
	var from: Vector2 = Vector2(-4, -2)
	var to: Vector2 = Vector2(-2, -2)
	assert_false(GhostDeploySpot.clear(stage, from, to))
	assert_eq(GhostDeploySpot.clip(stage, from, to), from)
