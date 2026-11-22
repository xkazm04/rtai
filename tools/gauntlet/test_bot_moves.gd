extends GutTest

var stage: ArenaStage
var squad: ArenaSquad
var profile: BotProfile
var actions: PlayerActions


func before_each() -> void:
	stage = ArenaStage.new(ArenaPlan.new(), ArenaStations.new(), ArenaArgs.new())
	var rng: RandomNumberGenerator = RngRegistry.new(23).stream(&"combat")
	stage.arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	stage.arena.walls = stage.walls
	stage.arena.rivet.facing = Vector2.RIGHT
	stage.arena.guard_map = GuardRouteMap.new(Rect2(-15, -15, 30, 30), [], null, 0.45)
	squad = ArenaSquad.new(stage.arena.guard_map)
	stage.arena.squad_ai = squad
	actions = PlayerActions.shipped(true)
	stage.pilot = StagePilot.new(actions)
	profile = BotProfile.shipped(&"expert")
	profile.form_use = 0.0
	profile.reaction_ticks = 0


func _target(id: StringName) -> Fighter:
	var h: Fighter = squad.spawn_member(stage.arena, Vector2(4, 0), id)
	h.pos = Vector2(4, 0)
	h.facing = Vector2.LEFT
	@warning_ignore("return_value_discarded")
	squad.mind_for(h)
	stage.pit.standing.append(h)
	return h


func _intent(form: StringName) -> TickInput:
	stage.pilot.ghosts.forms.selected = form
	var view: BotView = BotViewArena.new(stage, actions)
	var brain: GauntletBot = GauntletBot.new(view, actions, profile, 22)
	return brain.sample(0)


func test_ohm_intent_requires_enabled_vulnerable_machine_in_clear_cone() -> void:
	var h: Fighter = _target(&"sentry_turret")
	squad.moves.kerf_blink_behind.enabled = false
	var bit: int = actions.bit(&"power_hauler")
	assert_true(_intent(&"ohm").is_pressed(bit))
	stage.pilot.ghosts.forms.from_id = &"ohm"
	assert_true(_intent(&"ohm").is_pressed(actions.bit(&"melee")))
	stage.pilot.ghosts.forms.from_id = GhostForms.BASE
	squad.minds[h.id].immune_until = stage.arena.tick + 1
	assert_false(_intent(&"ohm").is_pressed(bit))
	squad.minds[h.id].immune_until = stage.arena.tick
	stage.arena.rivet.facing = Vector2.LEFT
	assert_false(_intent(&"ohm").is_pressed(bit))
	stage.arena.rivet.facing = Vector2.RIGHT
	squad.moves.ohm_short_circuit.enabled = false
	assert_false(_intent(&"ohm").is_pressed(bit))


func test_tonnage_intent_requires_enabled_unspent_stomp() -> void:
	var h: Fighter = _target(&"war_machine")
	squad.moves.ohm_short_circuit.enabled = false
	squad.moves.kerf_blink_behind.enabled = false
	h.pos = Vector2(2, 0)
	var mind: SquadMind = squad.minds[h.id]
	mind.agent.state = EnemyAgent.State.RECOVER
	mind.walker.attack = mind.agent.arch.alt_weapon
	mind.agent.shot_tick = stage.arena.tick
	var bit: int = actions.bit(&"power_hauler")
	assert_true(_intent(&"tonnage").is_pressed(bit))
	stage.pilot.ghosts.forms.from_id = &"tonnage"
	assert_true(_intent(&"tonnage").is_pressed(actions.bit(&"melee")))
	stage.pilot.ghosts.forms.from_id = GhostForms.BASE
	mind.walker.cracked_at = mind.agent.shot_tick
	stage.arena.rivet.weapon = &"pistol"
	assert_true(_intent(&"tonnage").is_pressed(actions.bit(&"fire")))
	assert_false(_intent(&"tonnage").is_pressed(bit))
	mind.walker.cracked_at = -1
	squad.moves.tonnage_armour_crack.enabled = false
	assert_false(_intent(&"tonnage").is_pressed(bit))


func test_kerf_intent_requires_enabled_plate_and_free_landing() -> void:
	var h: Fighter = _target(&"shield_robot")
	squad.moves.ohm_short_circuit.enabled = false
	var bit: int = actions.bit(&"power_hauler")
	assert_true(_intent(&"kerf").is_pressed(bit))
	stage.pilot.ghosts.forms.from_id = &"kerf"
	assert_true(_intent(&"kerf").is_pressed(actions.bit(&"melee")))
	stage.pilot.ghosts.forms.from_id = GhostForms.BASE
	var behind: Vector2 = h.pos - h.facing * (stage.pilot.kerf.num(&"behind_m") + h.radius_m)
	stage.walls.boxes.append(Rect2(behind - Vector2.ONE * 0.1, Vector2.ONE * 0.2))
	assert_false(_intent(&"kerf").is_pressed(bit))
	stage.walls.boxes.clear()
	squad.moves.kerf_blink_behind.enabled = false
	assert_false(_intent(&"kerf").is_pressed(bit))


func test_carry_offer_requires_enabled_cluster_and_weapon_then_accepts_rank_two() -> void:
	var preference: BotCarryPick = BotCarryPick.new()
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), stage.pilot.hold.table, RngRegistry.new(1).stream(&"carry")
	)
	stage.pilot.carry = carry
	assert_gte(carry.add(&"hand_cannon"), 0)
	@warning_ignore("return_value_discarded")
	_target(&"patrol_cop")
	var other: Fighter = _target(&"patrol_cop")
	other.pos.x += 1.0
	preference.observe(stage.arena, 3)
	var ids: Array[StringName] = [&"stat", &"effect", &"second"]
	var offers: Dictionary = {
		&"stat": {"kind": "stat", "ref": "hp_max"},
		&"effect": {"kind": "effect", "ref": "overkill_carry", "min_wave": 3},
		&"second": {"kind": "effect", "ref": "overkill_carry_2", "min_wave": 6}
	}
	var picker: BotPick = BotPick.new(&"greedy", profile, RngRegistry.new(1), offers)
	assert_eq(picker.pick(ids, 2, preference.desired(stage, 2)), &"stat")
	assert_eq(picker.pick(ids, 3, preference.desired(stage, 3)), &"effect")
	assert_true(MoveCarry.grant(stage, 1))
	assert_eq(picker.pick(ids, 6, preference.desired(stage, 6)), &"second")
	squad.moves.overkill_carry.enabled = false
	assert_eq(picker.pick(ids, 6, preference.desired(stage, 6)), &"stat")


func test_rocket_withholds_fire_near_rivet_and_fires_at_ten_metres() -> void:
	var view: BotView = BotView.new()
	var controls: PlayerActions = PlayerActions.shipped(true)
	var skill: BotProfile = BotProfile.shipped(&"expert")
	skill.aim_error_deg = 0.0
	skill.reaction_ticks = 0
	var brain: GauntletBot = GauntletBot.new(view, controls, skill, 8)
	var rocket: WeaponSpec = WeaponTable.shipped().weapon(&"rocket_launcher")
	var slot: BotView.Slot = BotView.Slot.new()
	slot.index = 1
	slot.splash_m = rocket.splash_radius_m
	slot.reach = rocket.range_m
	view.held_slots().append(slot)
	view.player().current_slot = slot.index
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = 1
	view.hostiles().append(foe)
	for distance: float in [1.0, 2.5, slot.splash_m + view.player().radius + skill.blast_margin_m]:
		foe.pos = Vector2.RIGHT * distance
		assert_false(brain.sample(0).is_pressed(controls.bit(&"fire")), str(distance))
	foe.pos = Vector2.RIGHT * 10.0
	assert_true(brain.sample(1).is_pressed(controls.bit(&"fire")))
	# A wall before the distant target stops the shot.
	view.solid_props().append(Rect2(1.5, -0.2, 0.5, 0.4))
	assert_false(brain.sample(2).is_pressed(controls.bit(&"fire")))
	var intent: GauntletBot.Intent = GauntletBot.Intent.new()
	intent.reach = 10.0
	intent.aim = Vector2.RIGHT
	assert_false(BotArsenal.clear_shot(view, intent, controls, skill.blast_margin_m))
	view.solid_props()[0] = Rect2(6.0, -0.2, 0.5, 0.4)
	assert_true(BotArsenal.clear_shot(view, intent, controls, skill.blast_margin_m))
