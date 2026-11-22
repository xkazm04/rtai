class_name VaultTrial
extends RefCounted
## Shared arena and street setup for replay, fuzz and guarded landings.


static func stage_for(
	city: bool, ctx: WorldContext = null, use_wheel: bool = ControlsMode.wheel()
) -> ArenaStage:
	var stations: ArenaStations = ArenaStations.new()
	if not city:
		stations.add_file(ArenaStations.DIR + "/arena.json")
		# Actual station collision, with the combatants off the movement course.
		for station: ArenaStation in stations.stations:
			station.spawns.clear()
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.cells = StageCells.shipped() if city else null
	stage.setup(ctx if ctx != null else World.build_context(Events, Data, 1918))
	stage.pilot = StagePilot.new(PlayerActions.shipped(use_wheel))
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


static func approach_crate(stage: ArenaStage) -> void:
	stage.arena.rivet.pos = Vector2(4.0, 11.75)
	stage.pilot.motion.mover.velocity = Vector2.DOWN * 8.0


## The visual comparison uses the same guard position and approach speed.
static func place_landing_guard(stage: ArenaStage) -> Fighter:
	approach_crate(stage)
	var at: Vector2 = Vector2(4.0, 14.2)
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 190, at, 1.0)
	guard.brain_owned = true
	stage.arena.hostiles.append(guard)
	return guard


static func guarded_landing(offset: Vector2) -> String:
	var stage: ArenaStage = stage_for(false)
	var guard: Fighter = place_landing_guard(stage)
	guard.pos += offset
	var at: Vector2 = guard.pos
	var start: Vector2 = stage.arena.rivet.pos
	var vault: PlayerVault = stage.pilot.motion.vault
	for i: int in vault.ticks:
		stage.step(i, sample(stage, Vector2.DOWN, i == 0))
		if i == 0 and (vault.hit == null or vault.hit.reason != &"landing_blocked"):
			return "occupied landing at %s did not refuse the press" % at
		if i == 0 and stage.arena.rivet.pos != start:
			return "Rivet moved on the refused press"
		if vault.frame >= 0 or guard.pos != at:
			return (
				"occupied landing at %s: vault frame %d, guard at %s" % [at, vault.frame, guard.pos]
			)
		var contact: String = forbidden_contact(stage)
		if contact != "":
			return contact
	return ""
