class_name VaultTrial
extends RefCounted
## Shared arena and street setup for replay, fuzz and the measured guard impact.


static func stage_for(city: bool, ctx: WorldContext = null) -> ArenaStage:
	var stations: ArenaStations = ArenaStations.new()
	if not city:
		stations.add_file(ArenaStations.DIR + "/arena.json")
		# Actual station collision, with the combatants off the movement course.
		for station: ArenaStation in stations.stations:
			station.spawns.clear()
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.cells = StageCells.shipped() if city else null
	stage.setup(ctx if ctx != null else World.build_context(Events, Data, 1918))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.motion.vault.enabled = true
	stage.pilot.motion.vault.prepare(stage)
	return stage


static func sample(stage: ArenaStage, direction: Vector2, press: bool) -> TickInput:
	var a: PlayerActions = stage.pilot.actions
	var bits: int = (1 << a.bit(&"roll")) if press else 0
	var axes: Vector2 = direction * TickInput.AXIS_MAX
	return TickInput.new(bits, roundi(axes.x), roundi(axes.y))


## After the whole stage step, the only legal overlap is the low target of an airborne vault.
static func forbidden_contact(stage: CollectCallStage) -> String:
	var body: Fighter = stage.arena.rivet
	var vault: PlayerVault = stage.pilot.motion.vault
	if vault.airborne():
		var mask: int = vault.probe.contacts(body.pos, body.radius_m, vault.hit)
		if mask == VaultProbe.Contact.TARGET and vault.hit.height <= vault.probe.max_height:
			return ""
	elif vault.probe.clear_at(body.pos, body.radius_m):
		return ""
	var touched: PackedStringArray = []
	for box: Rect2 in vault.probe.boxes:
		if VaultProbe._overlaps(body.pos, body.radius_m, box):
			@warning_ignore("return_value_discarded")
			touched.append("station %s %s" % [vault.probe.boxes[box], box])
	if stage.cells != null:
		var r: float = body.radius_m
		for y: int in range(floori(body.pos.y - r), floori(body.pos.y + r) + 1):
			for x: int in range(floori(body.pos.x - r), floori(body.pos.x + r) + 1):
				if stage.cells.solid(x, y) and VaultProbe._overlaps(body.pos, r, Rect2(x, y, 1, 1)):
					var prop: VaultCity.Prop = vault.probe.city.owner(Vector2i(x, y))
					var kind: String = prop.kind if prop != null else str(stage.cells.code_at(x, y))
					@warning_ignore("return_value_discarded")
					touched.append("city (%d,%d) %s" % [x, y, kind])
	return "overlap at %s with %s" % [body.pos, touched]


## The measured pit landing. The visual comparison uses the same feet and approach speed.
static func place_tackle(stage: ArenaStage) -> Fighter:
	var body: Fighter = stage.arena.rivet
	body.pos = Vector2(4.0, 11.75)
	stage.pilot.motion.mover.velocity = Vector2.DOWN * 8.0
	var at: Vector2 = Vector2(4.0, 14.2)
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 190, at, 1.0)
	guard.brain_owned = true
	stage.arena.hostiles.append(guard)
	return guard


static func tackle() -> Vector3:
	var stage: ArenaStage = stage_for(false)
	var guard: Fighter = place_tackle(stage)
	var at: Vector2 = guard.pos
	var body: Fighter = stage.arena.rivet
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
