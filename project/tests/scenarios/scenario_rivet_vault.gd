extends Scenario
## Replay every serialized motion tick and world position, then exercise real stage collision
## against the shipped arena stations and street furniture on the first generated city block.

const ATTEMPTS: int = 180
const SEED: int = 1918


class Trace:
	extends RefCounted
	var positions: PackedVector2Array = []
	var digest: String
	var landed: bool


var refused: Dictionary[StringName, int] = {}
var started: int = 0
var landed: int = 0
var attempts: int = 0
var airborne_ticks: int = 0
var city_starts: Dictionary[String, int] = {}


func run(_tree: SceneTree) -> String:
	var first: Trace = _replay()
	var second: Trace = _replay()
	if first.digest.is_empty() or not first.landed:
		return "scripted vault did not complete"
	if first.digest != second.digest or first.positions != second.positions:
		return "scripted vault missed its landing or diverged across fresh stages"
	var rng: RandomNumberGenerator = RngRegistry.new(SEED).stream(&"vault_approaches")
	for city: bool in [false, true]:
		var error: String = _fuzz(city, rng)
		if error != "":
			return error
	Log.info(
		"vault",
		(
			"attempts %d started %d refused %s landed %d airborne ticks %d; city %s"
			% [attempts, started, refused, landed, airborne_ticks, city_starts]
		)
	)
	if airborne_ticks == 0 or started == 0 or started != landed or not city_starts.has("sedan"):
		return "expected every started vault to land and a parked sedan crossing"
	for kind: String in ["bollard", "bench", "planter", "fire_hydrant", "trash_can"]:
		if city_starts.has(kind):
			return ""
	return "expected a street prop crossing as well as a parked sedan"


func _stage(city: bool) -> ArenaStage:
	var stations: ArenaStations = ArenaStations.new()
	if not city:
		stations.add_file(ArenaStations.DIR + "/arena.json")
		# Actual station collision, with the combatants off the movement course.
		for station: ArenaStation in stations.stations:
			station.spawns.clear()
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.cells = StageCells.shipped() if city else null
	stage.setup(World.build_context(Events, Data, SEED))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.motion.vault.enabled = true
	stage.pilot.motion.vault.prepare(stage)
	return stage


func _input_for(stage: ArenaStage, direction: Vector2, press: bool) -> TickInput:
	var a: PlayerActions = stage.pilot.actions
	var bits: int = (1 << a.bit(&"roll")) if press else 0
	var axes: Vector2 = direction * TickInput.AXIS_MAX
	return TickInput.new(bits, roundi(axes.x), roundi(axes.y))


func _replay() -> Trace:
	var stage: ArenaStage = _stage(false)
	var trace: Trace = Trace.new()
	var motion: PlayerMotion = stage.pilot.motion
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	var body: Fighter = stage.arena.rivet
	body.pos = Vector2(4.0, 9.0)
	var pressed: bool = false
	for i: int in 60:
		var edge: bool = not pressed and body.pos.y >= 11.6
		pressed = pressed or edge
		stage.step(i, _input_for(stage, Vector2.DOWN, edge))
		motion.write_state(stream)
		@warning_ignore("return_value_discarded")
		trace.positions.append(body.pos)
		if motion.vault.frame == motion.vault.ticks - 1:
			trace.landed = body.pos == motion.vault.hit.landing and body.pos.y > 14.0
	var digest: HashingContext = HashingContext.new()
	if digest.start(HashingContext.HASH_SHA256) == OK and digest.update(stream.data_array) == OK:
		trace.digest = digest.finish().hex_encode()
	return trace


func _fuzz(city: bool, rng: RandomNumberGenerator) -> String:
	var stage: ArenaStage = _stage(city)
	var probe: VaultProbe = stage.pilot.motion.vault.probe
	var targets: Dictionary[Rect2, String] = probe.boxes.duplicate()
	if city:
		probe.city.collect(Rect2(2, 2, 60, 60), targets)
	var boxes: Array[Rect2] = []
	for box: Rect2 in targets:
		if targets[box] != "":
			boxes.append(box)
	if boxes.is_empty():
		return "no approach targets"
	var count: int = 0
	for trial: int in ATTEMPTS * 10:
		var box: Rect2 = boxes[rng.randi_range(0, boxes.size() - 1)]
		var path: Vector4 = _approach(box, stage.arena.rivet.radius_m, rng)
		var at: Vector2 = Vector2(path.x, path.y)
		if not probe.clear_at(at, stage.arena.rivet.radius_m):
			continue
		stage.arena.rivet.pos = at
		var dir: Vector2 = Vector2(path.z, path.w)
		stage.pilot.motion.mover.velocity = dir * rng.randf_range(1.0, 9.3)
		var kick: int = rng.randi_range(1, 6)
		var error: String = _attempt(stage, dir, kick)
		if error != "":
			return (
				"city=%s trial=%d start=%s dir=%s press=%d %s" % [city, trial, at, dir, kick, error]
			)
		count += 1
		if count == ATTEMPTS:
			return ""
	return "only %d clear starting positions" % count


func _approach(box: Rect2, radius: float, rng: RandomNumberGenerator) -> Vector4:
	var normal: Vector2 = Vector2.DOWN if rng.randi_range(0, 1) == 0 else Vector2.RIGHT
	if rng.randi_range(0, 1) == 0:
		normal = -normal
	var dir: Vector2 = normal.rotated(deg_to_rad(rng.randf_range(-56.0, 56.0)))
	var across: Vector2 = normal.orthogonal()
	var face: Vector2 = box.get_center() - normal * box.size.dot(normal.abs()) * 0.5
	face += across * box.size.dot(across.abs()) * rng.randf_range(-0.52, 0.52)
	var at: Vector2 = face - dir * (radius + rng.randf_range(0.05, 1.15)) / dir.dot(normal)
	return Vector4(at.x, at.y, dir.x, dir.y)


func _attempt(stage: ArenaStage, dir: Vector2, press: int) -> String:
	var motion: PlayerMotion = stage.pilot.motion
	var vault: PlayerVault = motion.vault
	var body: Fighter = stage.arena.rivet
	attempts += 1
	for i: int in 52:
		stage.step(
			attempts * 52 + i, _input_for(stage, dir if i <= press else Vector2.ZERO, i == press)
		)
		if vault.airborne():
			var mask: int = vault.probe.contacts(body.pos, body.radius_m, vault.hit)
			if mask != VaultProbe.Contact.TARGET or vault.hit.height > vault.probe.max_height:
				return "airborne contact with a foreign or high solid at %s" % body.pos
			airborne_ticks += 1
		elif not vault.probe.clear_at(body.pos, body.radius_m):
			return "overlap tick %d pos %s phase %d" % [i, body.pos, motion.phase]
		if i == press:
			if vault.hit == null:
				return "press did not reach the probe"
			if vault.frame == 0:
				started += 1
				if stage.cells != null:
					var kind: String = vault.hit.kind
					city_starts[kind] = city_starts.get(kind, 0) + 1
			else:
				refused[vault.hit.reason] = refused.get(vault.hit.reason, 0) + 1
		if vault.frame == vault.ticks - 1:
			if body.pos != vault.hit.landing or motion.phase != PlayerMotion.Phase.RECOVER:
				return "vault missed its committed endpoint"
			landed += 1
	return ""
