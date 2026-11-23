class_name DeployWorthTrial
extends RefCounted
## Combat uses the normal pilot, gun, projectile, squad and deploy paths. Seeded
## spread and AI timers remain live. Only the initial placement is fixed.

const LIMIT: int = 30 * SimClock.TICK_RATE
const ENCOUNTERS: Dictionary = {
	&"kerf":
	[
		[&"shield_robot", Vector2(6.5, 0)],
		[&"patrol_cop", Vector2(5.1, -1.6)],
		[&"patrol_cop", Vector2(6.2, 1.6)],
		[&"patrol_cop", Vector2(7.7, -1)]
	],
	&"ohm":
	[
		[&"sentry_turret", Vector2(6.6, 0)],
		[&"shield_robot", Vector2(5, -1.5)],
		[&"swat", Vector2(7.8, 1.3)],
		[&"swat", Vector2(6.7, -2)]
	],
	&"tonnage": [[&"war_machine", Vector2(7, 0)]],
	&"dent":
	[
		[&"patrol_cop", Vector2(3.6, 0.15)],
		[&"patrol_cop", Vector2(4.7, -0.2)],
		[&"patrol_cop", Vector2(5.8, 0.28)],
		[&"patrol_cop", Vector2(6.9, -0.3)],
		[&"patrol_cop", Vector2(8, 0.15)]
	],
}

var stage: ArenaStage
var gauge: StrikeGauge
var tally: GhostDeployTally = GhostDeployTally.new()
var controller: DeployWorthAim


class StrikeGauge:
	extends GhostDeployStrike
	var damage: float = 0.0
	var contacts: int = 0
	var empty: int = 0
	var start_tick: int = 0
	var releases: Array[int] = []

	func land(host: CollectCallStage, ghost: GhostDeploy) -> void:
		contacts = 0
		super.land(host, ghost)
		empty += int(contacts == 0)
		releases.append(host.tick - start_tick)

	func _hit(
		arena: CombatArena, foe: Fighter, dir: Vector2, amount: float, weapon: StringName
	) -> void:
		var before: float = foe.hp
		super._hit(arena, foe, dir, amount, weapon)
		damage += before - maxf(0.0, foe.hp)
		contacts += 1


func measure(form: StringName, seed_id: int, enabled: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var ctx: WorldContext = World.build_context(bus, data, seed_id)
	var plan: ArenaPlan = ArenaPlan.new()
	var floor_area: ArenaPlan.Area = ArenaPlan.Area.new()
	floor_area.rect = Rect2(-24, -24, 48, 48)
	plan.areas.append(floor_area)
	var args: ArenaArgs = ArenaArgs.new()
	args.values["--enemy-brain"] = "squad"
	stage = ArenaStage.new(plan, ArenaStations.new(), args)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.arena.rivet.weapon = &"pistol"
	stage.guns = StageGuns.make(ctx.rng.stream(&"gunplay"))
	stage.pilot.ghosts.transform_unlocked = false
	stage.pilot.ghosts.forms.selected = form
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	gauge = StrikeGauge.new(ghost.strike.attacks, ghost.strike.press)
	ghost.strike = gauge
	controller = DeployWorthAim.new(stage, form)
	var result: Dictionary = {}
	for tick: int in range(1, 121):
		stage.step(tick, TickInput.new())
		if stage.pilot.hold.can_fire():
			_spawn(form)
			result = _fight(form, enabled)
			break
	data.free()
	bus.free()
	return result


func _spawn(form: StringName) -> void:
	var squad: ArenaSquad = stage.arena.squad_ai
	for spec: Array in ENCOUNTERS[form]:
		var at: Vector2 = spec[1]
		var archetype: StringName = spec[0]
		var foe: Fighter = squad.spawn_member(stage.arena, at, archetype)
		foe.pos = at
		foe.facing = at.direction_to(stage.arena.rivet.pos)
		if squad.mounts.anchors.has(foe):
			squad.mounts.anchors[foe] = at


func _fight(form: StringName, enabled: bool) -> Dictionary:
	gauge.start_tick = stage.tick
	tally.begin(stage.tick)
	var row: Dictionary = {"end": "timeout"}
	for tick: int in range(1, LIMIT + 1):
		stage.step(stage.tick + 1, controller.sample(enabled))
		tally.sample(stage)
		if stage.arena.hostiles_alive() == 0:
			row.clear_s = tick * SimClock.TICK_DT
			row.end = "clear"
			break
		if not stage.arena.rivet.alive() or stage.deaths > 0:
			row.end = "death"
			break
	row.hp_lost = stage.telemetry.damage_taken
	row.shots = stage.shots_fired
	row.ticks = stage.tick - gauge.start_tick
	row.hostiles_left = stage.arena.hostiles_alive()
	if enabled:
		var wave: Dictionary = {}
		tally.append_wave(wave)
		var counts: Dictionary = wave.get("deploys", {})
		var kills: Dictionary = wave.get("deploy_kills", {})
		var stuns: Dictionary = wave.get("deploy_stun_s", {})
		row.uses = counts.get(form, 0)
		row.kills = kills.get(form, 0)
		row.stun_s = stuns.get(form, 0.0)
		row.damage = gauge.damage
		row.empty = gauge.empty
		row.release_ticks = gauge.releases
		row.cooldown_ticks = controller.row.cooldown_ticks
	return row
