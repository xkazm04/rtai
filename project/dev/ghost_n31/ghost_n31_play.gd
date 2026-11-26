class_name GhostN31Play
extends RefCounted
## n31 measure (dev only), play mode: one headless gauntlet seed with the shipped test player.
## Tonnage is granted at the start the way its gauntlet ghost card does (its unlock id joins
## GhostLocks.done) and kept the only free ghost, so the shipped GhostDeployBot drops it
## whenever it is ready and its spot search finds 3+ bodies. Every 60 ticks the bot would deploy,
## the densest 4/8/12 foes are kept as a lab shape.

const BOT_PATH: String = "res://features/gauntlet/bot/gauntlet_bot.gd"
const SAMPLE_EVERY: int = 60
const NEAR_M: float = 14.0

## The ghost form granted and deployed (HaulerStage.GHOST = Tonnage); other forms keep no shapes.
var form: StringName = HaulerStage.GHOST
var shapes: Dictionary = {4: [], 8: [], 12: []}
## "relaxed" swaps the bot's spot scorer for GhostN31BotSpot (Ohm at 3+ bodies, Kerf any target).
var fit: StringName = &"shipped"


func run_seed(
	seed_id: int, profile: StringName, waves_cap: int, geometry: GhostN31Geometry, charge: int
) -> Dictionary:
	var run: GauntletRun = GauntletRun.new()
	run.seed = seed_id
	run.profile = profile
	var pilot: GauntletPilot = (load(BOT_PATH) as GDScript).new()
	var session: GauntletSession = GauntletSession.open_street(Events, Data, run, pilot)
	if session == null:
		return {"seed": seed_id, "opened": false}
	pilot.configure(profile, &"random", seed_id)
	pilot.bind(run, session)
	if fit == &"relaxed" and not GhostN31BotSpot.install(pilot):
		return {"seed": seed_id, "opened": false}
	var waves: GauntletWaves = GauntletWaves.attach(session, run, pilot, waves_cap)
	var ghost: GhostDeploy = session.stage.pilot.ghosts.deploy
	var strike: GhostN31Strike = GhostN31Strike.new(ghost.strike.attacks, ghost.strike.press)
	strike.geometry = geometry
	strike.form = form
	strike.charge_ticks = charge
	strike.watch(session.stage.arena)
	ghost.strike = strike
	var cap: int = waves_cap * 7200
	var stamped: int = 0
	while not waves.done and session.tick() < cap:
		_grant(session.stage.pilot.ghosts.forms)
		var before: GhostDeploy.Phase = ghost.phase
		session.step()
		# Key down: AIMING on main's hold flow, ACTIVE at once on a drop-mode press.
		if before == GhostDeploy.Phase.IDLE and ghost.phase != GhostDeploy.Phase.IDLE:
			strike.press_tick = session.stage.tick
			strike.press_rivet = session.stage.arena.rivet.pos
		strike.resolve_due(session.stage)
		if strike.deploys.size() > stamped:
			stamped = strike.deploys.size()
			strike.deploys[stamped - 1].wave = run.wave
		if form == HaulerStage.GHOST and session.tick() % SAMPLE_EVERY == 0:
			_sample(session.stage, seed_id)
		if (session.stage.arena as GauntletCombat).report_bot_freeze():
			break
	var row: Dictionary = {
		"seed": seed_id,
		"opened": true,
		"ticks": session.tick(),
		"wave": run.wave,
		"done": waves.done,
		"deploys": strike.deploys,
	}
	session.close()
	return row


func _grant(forms: GhostForms) -> void:
	if forms.locks.done.size() != 1 or forms.locks.done[0] != form:
		forms.locks.done.clear()
		forms.locks.done.append(form)
	forms.selected = form


## Keep the densest 4/8/12 live foes near Rivet when the bot's own spot search would deploy.
func _sample(stage: ArenaStage, seed_id: int) -> void:
	var rivet: Fighter = stage.arena.rivet
	var seen: Array[BotView.Hostile] = []
	var points: Array[Vector2] = []
	for foe: Fighter in stage.arena.hostiles:
		if foe.alive() and foe.pos.distance_to(rivet.pos) <= NEAR_M:
			seen.append(BotArenaFoe.read(foe, stage.arena))
			points.append(foe.pos)
	if points.size() < GhostN31Shapes.SIZES[0] or not rivet.alive():
		return
	var spots: GhostDeployBotSpot = GhostDeployBotSpot.new(stage, stage.pilot.actions)
	var gun: Vector2 = GhostN31Shapes.centroid(points) - rivet.pos
	if spots.best(HaulerStage.GHOST, gun, seen, true) == Vector2.ZERO:
		return
	for size: int in GhostN31Shapes.SIZES:
		var picked: Array[int] = GhostN31Shapes.densest(points, size)
		if picked.is_empty():
			continue
		var row: Dictionary = GhostN31Shapes.shape(points, picked, rivet.pos)
		row.seed = seed_id
		row.tick = stage.tick
		var list: Array = shapes[size]
		list.append(row)
