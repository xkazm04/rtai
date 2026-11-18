extends Scenario
## Two fresh arena runs of one input tape, then independent approaches to the shipped stations.
## Every tick is checked after combat, body resolution and the stage's final collision pass.

const SEED: int = 1903
const ATTEMPTS: int = 800


class Trace:
	extends RefCounted
	var positions: PackedVector2Array = []
	var digest: String


var stage: ArenaStage
var cover: PlayerCover
var body: Fighter
var failure: String = ""
var snaps: int = 0
var peeks: int = 0
var leaves: int = 0
var refused: int = 0


func run(_tree: SceneTree) -> String:
	var first: Trace = _scripted()
	var second: Trace = _scripted()
	if failure != "":
		return failure
	if first.digest != second.digest or first.positions != second.positions:
		return "identical arena input diverged in state or position"
	_setup()
	var rng: RandomNumberGenerator = RngRegistry.new(SEED).stream(&"cover_approaches")
	for i: int in ATTEMPTS:
		if not _random_start(rng):
			return "no clear starting position for attempt %d" % i
		_trial(rng)
		if failure != "":
			return "attempt %d: %s" % [i, failure]
	var counts: Array[int] = [ATTEMPTS, snaps, peeks, leaves, refused]
	Log.info("cover", "attempts %d snaps %d full peeks %d leaves %d refused %d" % counts)
	Log.info("cover", "scripted stage SHA-256 %s" % first.digest)
	if snaps + refused != ATTEMPTS or snaps != leaves or peeks < 300 or refused == 0:
		return "expected refusals, 300 full peeks and a leave for every snap: %s" % [counts]
	return ""


func _setup() -> void:
	stage = VaultTrial.stage_for(false)
	stage.pilot.motion.vault.enabled = false
	cover = stage.pilot.motion.cover
	cover.enabled = true
	body = stage.arena.rivet


func _tick(move: Vector2, action: StringName = &"", aim: Vector2 = Vector2.ZERO) -> void:
	var actions: PlayerActions = stage.pilot.actions
	var bits: int = PlayerCommand.pack_aim(aim, actions)
	if action != &"":
		bits |= 1 << actions.bit(action)
	var axes: Vector2 = move * TickInput.AXIS_MAX
	stage.step(stage.tick + 1, TickInput.new(bits, roundi(axes.x), roundi(axes.y)))
	if failure == "" and not stage.pilot.motion.vault.probe.clear_at(body.pos, body.radius_m):
		failure = "solid overlap at tick %d, pos %s, phase %d" % [stage.tick, body.pos, cover.phase]


func _scripted() -> Trace:
	_setup()
	body.pos = Vector2(4, 10)
	var dummy: ArenaStation.Spawn = ArenaStation.Spawn.new()
	dummy.id = "corner_target"
	dummy.kind = "target"
	dummy.at = Vector2(6, 15)
	var target: ArenaTargets.Target = stage.targets.add(stage.arena, dummy, stage.plan.base, 903)
	var trace: Trace = Trace.new()
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	for i: int in 85:
		_script_tick(i)
		if i == 26 and cover.phase != PlayerCover.Phase.IN:
			failure = "the approach did not snap to the station"
		if i == 63 and (cover.phase != PlayerCover.Phase.PEEK or cover.blocks_fire()):
			failure = "slide and aim did not reach a full peek"
		@warning_ignore("return_value_discarded")
		trace.positions.append(body.pos)
		stage.write_state(out)
	if target.hits == 0 or stage.shots_fired == 0 or cover.phase != PlayerCover.Phase.OFF:
		failure = "script missed the dummy or did not leave cover"
	var hash: HashingContext = HashingContext.new()
	if hash.start(HashingContext.HASH_SHA256) != OK or hash.update(out.data_array) != OK:
		failure = "could not hash the scripted stage"
	else:
		trace.digest = hash.finish().hex_encode()
	return trace


func _script_tick(i: int) -> void:
	if i < 22:
		_tick(Vector2.DOWN)
	elif i == 22 or i == 80:
		_tick(Vector2.ZERO, &"cover")
	elif i >= 28 and i < 58:
		_tick(Vector2.RIGHT)
	elif i >= 58 and i < 64:
		_tick(Vector2.ZERO, &"", Vector2.RIGHT)
	elif i >= 64 and i < 80:
		_tick(Vector2.ZERO, &"fire", Vector2.DOWN)
	else:
		_tick(Vector2.ZERO)


func _random_start(rng: RandomNumberGenerator) -> bool:
	var boxes: Array[Rect2] = stage.walls.boxes
	var normals: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for retry: int in 80:
		var box: Rect2 = boxes[rng.randi_range(0, boxes.size() - 1)]
		var n: Vector2 = normals[rng.randi_range(0, 3)]
		var t: Vector2 = n.orthogonal()
		var face: Vector2 = box.get_center() + n * box.size * 0.5
		face += t * box.size.dot(t.abs()) * rng.randf_range(-0.55, 0.55)
		var p: Vector2 = face + n * (body.radius_m + rng.randf_range(0.02, 1.45))
		if (
			stage.collide_preview(p) == p
			and stage.pilot.motion.vault.probe.clear_at(p, body.radius_m)
		):
			stage.pilot.motion.stop()
			body.pos = p
			return true
	return false


func _trial(rng: RandomNumberGenerator) -> void:
	_tick(Vector2.ZERO, &"cover")
	for i: int in cover.snap_ticks - 1:
		_tick(Vector2.ZERO)
	if cover.phase == PlayerCover.Phase.OFF:
		refused += 1
		return
	if cover.phase != PlayerCover.Phase.IN:
		failure = "snap missed its deadline"
		return
	snaps += 1
	var dir: Vector2 = cover.spot.tangent if rng.randi_range(0, 1) == 0 else -cover.spot.tangent
	var outward: Vector2 = cover.spot.normal
	for i: int in rng.randi_range(12, 75):
		_tick(dir)
	var fire: bool = rng.randi_range(0, 1) == 0
	for i: int in cover.peek_ticks:
		_tick(Vector2.ZERO, &"fire" if fire else &"", -outward if fire else dir)
	if cover.phase == PlayerCover.Phase.PEEK and not cover.blocks_fire():
		peeks += 1
	if rng.randi_range(0, 1) == 0:
		_tick(Vector2.ZERO, &"cover")
	else:
		for i: int in cover.leave_ticks:
			_tick(outward)
	if cover.phase == PlayerCover.Phase.OFF:
		leaves += 1
	_tick(Vector2.ZERO)
