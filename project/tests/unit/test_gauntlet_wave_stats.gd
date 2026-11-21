extends GutTest


class Buttons:
	extends GauntletPilot
	var mask: int = 0

	func sample(_tick: int) -> TickInput:
		return TickInput.new(mask, 0, 0)


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
