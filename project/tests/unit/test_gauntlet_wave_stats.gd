extends GutTest


class Buttons:
	extends GauntletPilot
	var mask: int = 0

	func sample(_tick: int) -> TickInput:
		return TickInput.new(mask, 0, 0)


class Counters:
	extends GauntletPilot
	var deflects: int = 3
	var resets: int = 0

	func wave_counters() -> Dictionary:
		return {"guard_deflects": deflects, "rolls": 88, "form_seconds": {"fake": 99}, "hits": 777}

	func reset_wave_counters() -> void:
		deflects = 0
		resets += 1


var run: GauntletRun
var input: Buttons
var session: GauntletSession
var waves: GauntletWaves


func before_each() -> void:
	run = GauntletRun.new()
	run.profile = &"average"
	input = Buttons.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run, input)
	waves = GauntletWaves.attach(session, run, input, 1)
	session.stage.arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()


func after_each() -> void:
	session.close()


func _clear() -> Dictionary:
	var arena: CombatArena = session.stage.arena
	for foe: Fighter in arena.hostiles:
		arena.damage(foe, foe.max_hp * 10, arena.rivet.id, &"claw")
	session.step()
	return run.waves[0]


func test_a_roll_and_a_real_transformation_partition_wave_ticks() -> void:
	var forms: GhostForms = session.pilot.ghosts.forms
	assert_true(session.bonuses.apply(waves.draw.rows[&"ghost_ohm"]))
	input.mask = 1 << session.actions.bit(&"roll")
	for tick: int in 30:
		session.step()
	input.mask = 0
	assert_eq(forms.press_transform(), SoulPowers.OK)
	var enter: int = forms.table.form(&"ohm").enter_ticks
	for tick: int in enter + 15:
		session.step()
	assert_eq(forms.form_id(), &"ohm")
	var row: Dictionary = _clear()
	var rolls: int = row["rolls"]
	assert_eq(rolls, 1)
	var durations: Dictionary[String, float] = row["form_seconds"]
	assert_eq(durations.size(), 2)
	assert_almost_eq(durations["ohm"], 17.0 / 60.0, 0.006)
	assert_almost_eq(durations["rivet"], (29.0 + enter) / 60.0, 0.006)
	assert_false(row.has("guard_deflects"))


func test_pistol_pick_records_pulls_hits_and_incoming_damage() -> void:
	var arena: CombatArena = session.stage.arena
	assert_true(session.bonuses.apply(waves.draw.rows[&"weapon_pistol"]))
	var target: Fighter = arena.hostiles[0]
	target.pos = arena.rivet.pos + Vector2.RIGHT * 1.5
	input.mask = PlayerCommand.pack_aim(Vector2.RIGHT, session.actions, 2.0)
	input.mask |= 1 << session.actions.bit(&"fire")
	var inbound: Shot = Shot.new()
	inbound.from_rivet = false
	inbound.pos = arena.rivet.pos
	inbound.damage = 3.0
	inbound.vel = Vector2.RIGHT
	arena.shots.append(inbound)
	for tick: int in 40:
		session.step()
	var gun_shots: int = arena.gun.shots_fired
	assert_gt(gun_shots, 0)
	assert_lt(target.hp, target.max_hp)
	var row: Dictionary = _clear()
	var shots: int = row["shots"]
	var hits: int = row["hits"]
	var lost: float = row["damage_taken"]
	assert_eq(shots, gun_shots)
	assert_gt(hits, 0)
	assert_gte(lost, 3.0)


func test_one_round_and_one_claw_contact_are_counted_separately() -> void:
	var arena: CombatArena = session.stage.arena
	assert_true(session.bonuses.apply(waves.draw.rows[&"weapon_pistol"]))
	var target: Fighter = arena.hostiles[0]
	target.pos = arena.rivet.pos + Vector2.RIGHT * 1.3
	target.hp = 50.0
	assert_true(arena.rivet_fire(target.pos))
	for tick: int in 4:
		arena._step_shots()
	assert_lt(target.hp, 50.0)
	var claw: PlayerMelee = PlayerMelee.new()
	for tick: int in 18:
		arena.rivet.pos += claw.step(arena, tick == 0, Vector2.RIGHT)
	assert_eq(claw.landed, 1)
	assert_false(target.alive(), "the rake kills the guard hit by the pistol")
	# Other damage still belongs in the original all-source hits total.
	for foe: Fighter in arena.hostiles:
		arena.damage(foe, 1000.0, target.id, &"enemy_rifle")
	session.step()
	var row: Dictionary = run.waves[0]
	var rounds: int = row["hits_gun"]
	var melee: int = row["hits_melee"]
	var total: int = row["hits"]
	assert_eq(rounds, 1)
	assert_eq(melee, 1)
	assert_eq(total, 2 + arena.hostiles.size() - 1, "only the surviving foes take rifle hits")


func test_only_rivets_hits_on_live_exposed_foes_emit_contact(
	exclusion: String = use_parameters(
		["hostile attacker", "self hit", "dead foe", "unexposed foe"]
	)
) -> void:
	var arena: GauntletCombat = session.stage.arena as GauntletCombat
	var attacker: Fighter = arena.rivet
	var victim: Fighter = arena.hostiles[0]
	match exclusion:
		"hostile attacker":
			attacker = arena.hostiles[1]
		"self hit":
			victim = arena.rivet
		"dead foe":
			victim.hp = 0.0
		"unexposed foe":
			victim.exposed = false
	watch_signals(arena)
	arena.damage(victim, 1.0, attacker.id, &"claw")
	assert_signal_not_emitted(arena.rivet_contact)


func test_splash_and_a_returned_enemy_round_do_not_score_another_gun_hit() -> void:
	var arena: CombatArena = session.stage.arena
	assert_true(session.bonuses.apply(waves.draw.rows[&"weapon_rocket_launcher"]))
	var direct: Fighter = arena.hostiles[0]
	var nearby: Fighter = arena.hostiles[1]
	direct.pos = arena.rivet.pos + Vector2(2.0, 0.0)
	nearby.pos = direct.pos + Vector2(0.0, 1.5)
	direct.hp = 50.0
	nearby.hp = 50.0
	assert_true(arena.rivet_fire(direct.pos))
	for tick: int in 12:
		arena._step_shots()
	assert_lt(direct.hp, 50.0)
	assert_lt(nearby.hp, 50.0)
	DeflectRule.of(arena).pass_ratio_k = 0.0
	var rebound: Shot = Shot.fire(direct, Vector2.LEFT, arena.tuning.weapon(&"assault-rifle"))
	rebound.pos = arena.rivet.pos + Vector2.RIGHT
	arena.shots.append(rebound)
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 2.0), 1)
	var hp: float = direct.hp
	for tick: int in 12:
		arena._step_shots()
	assert_lt(direct.hp, hp)
	for foe: Fighter in arena.hostiles:
		arena.damage(foe, 1000.0, nearby.id, &"enemy_rifle")
	session.step()
	var gun_hits: int = run.waves[0]["hits_gun"]
	assert_eq(gun_hits, 1)


func test_pilot_cannot_supply_guard_deflects_under_legacy_controls() -> void:
	var pilot: Counters = Counters.new()
	waves._picker = pilot
	var row: Dictionary = _clear()
	var rolls: int = row["rolls"]
	var seconds: Dictionary = row["form_seconds"]
	var hits: int = row["hits"]
	assert_false(row.has("guard_deflects"))
	assert_eq(rolls, 0)
	assert_true(seconds.has("rivet"))
	assert_false(seconds.has("fake"))
	assert_ne(hits, 777)
	assert_eq(pilot.resets, 1)
	assert_eq(pilot.deflects, 0)
