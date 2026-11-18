class_name VaultTrial
extends RefCounted
## Shared arena and street setup for replay, fuzz and the measured guard impact.


static func stage_for(city: bool) -> ArenaStage:
	var stations: ArenaStations = ArenaStations.new()
	if not city:
		stations.add_file(ArenaStations.DIR + "/arena.json")
		# Actual station collision, with the combatants off the movement course.
		for station: ArenaStation in stations.stations:
			station.spawns.clear()
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.cells = StageCells.shipped() if city else null
	stage.setup(World.build_context(Events, Data, 1918))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.motion.vault.enabled = true
	stage.pilot.motion.vault.prepare(stage)
	return stage


static func sample(stage: ArenaStage, direction: Vector2, press: bool) -> TickInput:
	var a: PlayerActions = stage.pilot.actions
	var bits: int = (1 << a.bit(&"roll")) if press else 0
	var axes: Vector2 = direction * TickInput.AXIS_MAX
	return TickInput.new(bits, roundi(axes.x), roundi(axes.y))


static func tackle() -> Vector3:
	var stage: ArenaStage = stage_for(false)
	var body: Fighter = stage.arena.rivet
	body.pos = Vector2(4.0, 11.75)
	stage.pilot.motion.mover.velocity = Vector2.DOWN * 8.0
	var at: Vector2 = Vector2(4.0, 14.2)
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 190, at, 1.0)
	guard.brain_owned = true
	stage.arena.hostiles.append(guard)
	var result: Vector3 = Vector3.ZERO
	for i: int in stage.pilot.motion.vault.ticks:
		var before: Vector2 = body.pos
		var target: Vector2 = guard.pos
		stage.step(i, sample(stage, Vector2.DOWN, i == 0))
		var speed: float = before.distance_to(body.pos) / SimClock.TICK_DT
		result.x = maxf(result.x, speed)
		if guard.pos.distance_to(target) > 1.0:
			result.y = speed
	result.z = guard.pos.distance_to(at)
	return result
