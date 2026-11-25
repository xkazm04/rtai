class_name GhostN31Lab
extends RefCounted
## n31 measure (dev only), lab mode: one fresh open-floor stage per shape, patrol cops at a
## sampled gauntlet cluster shape, Rivet at the sampled stand-off, Tonnage pressed and released
## through the real input word at the best cursor (GhostDeployBot's search: every heading and
## reach the word encodes, ties nearest the bearing to the cluster, then shortest). The real
## GhostDeployStrike.land resolves it (GhostN31Strike only swaps the footprint for a what-if).

const FOE: StringName = &"patrol_cop"


func trial(shape: Dictionary, geometry: GhostN31Geometry, shipped: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var stage: ArenaStage = _stage(World.build_context(bus, data, 1))
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var strike: GhostN31Strike = GhostN31Strike.new(ghost.strike.attacks, ghost.strike.press)
	strike.geometry = null if shipped else geometry
	ghost.strike = strike
	var row: Dictionary = {}
	for tick: int in range(1, 121):
		stage.step(tick, TickInput.new())
		if stage.pilot.hold.can_fire():
			row = _deploy(stage, strike, shape, geometry)
			break
	data.free()
	bus.free()
	return row


## Main's footprint, read from a live stage's strike (press_ahead_m, stomp_radius_m).
func shipped_geometry() -> GhostN31Geometry:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var stage: ArenaStage = _stage(World.build_context(bus, data, 1))
	var strike: GhostDeployStrike = stage.pilot.ghosts.deploy.strike
	var out: GhostN31Geometry = GhostN31Geometry.shipped(
		strike.attacks.num(HaulerStage.GHOST, &"press_ahead_m"), strike.press.num(&"stomp_radius_m")
	)
	data.free()
	bus.free()
	return out


func _stage(ctx: WorldContext) -> ArenaStage:
	var plan: ArenaPlan = ArenaPlan.new()
	var floor_area: ArenaPlan.Area = ArenaPlan.Area.new()
	floor_area.rect = Rect2(-24, -24, 48, 48)
	plan.areas.append(floor_area)
	var args: ArenaArgs = ArenaArgs.new()
	args.values["--enemy-brain"] = "squad"
	var stage: ArenaStage = ArenaStage.new(plan, ArenaStations.new(), args)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.arena.rivet.weapon = &"pistol"
	stage.guns = StageGuns.make(ctx.rng.stream(&"gunplay"))
	stage.pilot.ghosts.transform_unlocked = false
	stage.pilot.ghosts.forms.selected = HaulerStage.GHOST
	return stage


func _deploy(
	stage: ArenaStage, strike: GhostN31Strike, shape: Dictionary, geometry: GhostN31Geometry
) -> Dictionary:
	var rivet: Fighter = stage.arena.rivet
	var squad: ArenaSquad = stage.arena.squad_ai
	var back: Vector2 = shape.rivet
	var foes: Array = shape.foes
	var mid: Vector2 = rivet.pos - back
	for offset: Vector2 in foes:
		var foe: Fighter = squad.spawn_member(stage.arena, mid + offset, FOE)
		foe.pos = mid + offset
		foe.facing = foe.pos.direction_to(rivet.pos)
	var actions: PlayerActions = stage.pilot.actions
	var row: GhostAttacks.DeployRow = strike.attacks.deploy[HaulerStage.GHOST]
	var cursor: Vector2 = best(stage, geometry, mid - rivet.pos, row.range_m)
	if cursor == Vector2.ZERO:
		cursor = (mid - rivet.pos).limit_length(row.range_m)
	var aim: int = PlayerCommand.pack_aim(cursor.normalized(), actions, cursor.length())
	strike.press_tick = stage.tick + 1
	strike.press_rivet = rivet.pos
	stage.step(stage.tick + 1, TickInput.new(aim | 1 << actions.bit(&"ghost_deploy")))
	strike.press_rivet = rivet.pos
	stage.step(stage.tick + 1, TickInput.new(aim))
	var size: int = foes.size()
	if strike.deploys.is_empty():
		return {"size": size, "hits": 0, "kills": 0, "landed": false}
	var out: Dictionary = strike.deploys[0].duplicate()
	out.size = size
	out.landed = true
	out.seed = shape.get("seed", 0)
	out.standoff_m = snappedf(back.length(), 0.01)
	return out


## The cursor (metres from Rivet) whose footprint covers the most live foes, over the input
## word's headings and reaches; Vector2.ZERO when none covers anyone.
static func best(
	stage: ArenaStage, geometry: GhostN31Geometry, gun: Vector2, range_m: float
) -> Vector2:
	var actions: PlayerActions = stage.pilot.actions
	var from: Vector2 = stage.arena.rivet.pos
	var first: int = roundi(gun.angle() * actions.aim_steps / TAU)
	var reaches: int = mini(PlayerCommand.REACH_MAX, ceili(range_m / actions.aim_reach_step_m))
	var cursor: Vector2 = Vector2.ZERO
	var high: int = 0
	for i: int in actions.aim_steps:
		var offset: int = ceili(i * 0.5) * (1 if i % 2 == 1 else -1)
		var face: Vector2 = Vector2.from_angle((first + offset) * TAU / actions.aim_steps)
		for step: int in range(1, reaches + 1):
			var dist: float = minf(range_m, step * actions.aim_reach_step_m)
			var spot: Vector2 = from + face * dist
			var at: Vector2 = geometry.centre(spot, from)
			var score: int = 0
			for foe: Fighter in stage.arena.hostiles:
				score += int(foe.alive() and geometry.hits(at, face, foe.pos, foe.radius_m))
			if score > high and GhostDeploySpot.clear(stage, from, spot):
				high = score
				cursor = face * dist
	return cursor
