extends RefCounted

const LIMIT: int = 180 * SimClock.TICK_RATE

var run: GauntletRun = GauntletRun.new()
var bot: GauntletTestPlayer = GauntletTestPlayer.new()
var session: GauntletSession
var waves: GauntletWaves
var gauge: Gauge
var boss: Fighter
var electric_finishes: int = 0


## Constrain the existing quantized spot search to the boss while it lives.
class BossSpot:
	extends GhostDeployBotSpot

	func best(form: StringName, gun: Vector2, seen: Array[BotView.Hostile], fit: bool) -> Vector2:
		for foe: BotView.Hostile in seen:
			if foe.alive and foe.archetype == GauntletComposer.BOSS:
				var one: Array[BotView.Hostile] = [foe]
				return super.best(form, gun, one, fit)
		return super.best(form, gun, seen, fit)


class Gauge:
	extends GhostDeployStrike

	var releases: Array[Dictionary] = []

	func land(stage: CollectCallStage, ghost: GhostDeploy) -> void:
		releases.append({"tick": stage.tick, "target": "", "hp_lost": 0.0})
		super.land(stage, ghost)

	func _hit(
		arena: CombatArena, foe: Fighter, dir: Vector2, amount: float, weapon: StringName
	) -> void:
		var hp: float = foe.hp
		super._hit(arena, foe, dir, amount, weapon)
		releases[-1].target = foe.archetype
		releases[-1].hp_lost = hp - foe.hp


func measure(wave: int, seed_id: int, arm: String, weapon: String) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	run.seed = seed_id
	run.wave = wave - 1
	run.profile = &"expert"
	run.controls = &"wheel"
	bot.configure(run.profile, &"greedy", seed_id)
	bot._skill.form_use = 1.0
	session = GauntletSession.open_street(bus, data, run, bot)
	var row: Dictionary = {}
	if session != null and _setup(arm, weapon):
		row = _fight()
		row.merge(
			{
				"wave": wave,
				"seed": seed_id,
				"arm": arm,
				"weapon": weapon,
				"segment": session.street.current().id
			}
		)
		Log.info(
			"boss-wave", "%s wave %d seed %d: %s at %d" % [arm, wave, seed_id, row.end, row.ticks]
		)
	if session != null:
		session.close()
	data.free()
	bus.free()
	return row


func _setup(arm: String, weapon: String) -> bool:
	if not session.bonuses.apply({"kind": "weapon", "ref": weapon}):
		return false
	if arm != "no_kerf" and not session.bonuses.apply({"kind": "ghost", "ref": &"kerf"}):
		return false
	session.pilot.ghosts.transform_unlocked = false
	var deploy: GhostDeploy = session.pilot.ghosts.deploy
	gauge = Gauge.new(deploy.strike.attacks, deploy.strike.press)
	deploy.strike = gauge
	if arm == "kerf_uncapped":
		gauge.attacks.deploy[&"kerf"].boss_damage_cap = 1.0
	bot.bind(run, session)
	bot._brain._deploy._spots = BossSpot.new(session.stage, session.actions)
	for block: int in run.wave + 1:
		session.stage.arena.rivet.pos = Vector2(session.street.current().end_x() + 0.01, 0)
		session.street.step(session.stage, 0)
	waves = GauntletWaves.attach(session, run, bot, run.wave + 1)
	for id: StringName in [&"stat_hp_max_10", &"stat_hp_max_25"]:
		if not session.bonuses.apply(waves.draw.rows[id]):
			return false
	@warning_ignore("return_value_discarded")
	session.stage.arena.kill_landed.connect(_on_kill)
	session.step()
	return not waves._live.is_empty() and not waves._live[0].members.is_empty()


func _fight() -> Dictionary:
	var live: GauntletLiveWave = waves._live[0]
	boss = live.members[0]
	var row: Dictionary = {
		"end": "timeout",
		"wave_s": null,
		"boss_ttk_s": null,
		"boss_max_hp": boss.max_hp,
		"start_tick": live.start_tick,
		"boss_damage_cap": gauge.attacks.deploy[&"kerf"].boss_damage_cap,
		"roster": live.row.enemies,
		"deploys": gauge.releases,
	}
	for tick: int in LIMIT:
		session.step()
		var seconds: float = live.seconds(session.stage.tick)
		if not boss.alive() and row.boss_ttk_s == null:
			row.boss_ttk_s = seconds
		if live.cleared():
			row.wave_s = seconds
			row.end = "clear"
			break
		if not run.alive or session.stage.deaths > 0:
			row.end = "death"
			break
	row.ticks = session.stage.tick - live.start_tick
	row.rivet_hp_lost = session.stage.telemetry.damage_taken
	row.rivet_max_hp = session.stage.arena.rivet.max_hp
	row.electric_robot_finishes = electric_finishes
	return row


func _on_kill(
	foe: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	if (
		weapon in [&"electro_gun", &"claw_shock"]
		and foe.get_meta(KillEvent.SHUTDOWN, false) == true
	):
		electric_finishes += 1
