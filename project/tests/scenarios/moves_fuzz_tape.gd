class_name MovesFuzzTape
extends InputSource
## Generates bursts only on the first run. Playback consumes the recorded input words and
## respawn points, even if a diverging fighter would choose a different nearest solid.

enum Burst { WALK, ROLL, COVER, FIRE, ROLL_COVER, COVER_ROLL }

var words: PackedInt64Array = []
var spawns: Dictionary[int, Vector2] = {}
var playing: bool = false
var stage: ArenaStage
var _rng: RandomNumberGenerator
var _targets: Array[Rect2] = []
var _city_targets: Array[Rect2] = []
var _begin: int = 0
var _end: int = 0
var _first: int
var _second: int
var _burst: Burst
var _stick: Vector2
var _held: int


func _init(master_seed: int) -> void:
	_rng = RngRegistry.new(master_seed).stream(&"moves_fuzz")


func bind(s: ArenaStage) -> void:
	stage = s
	var probe: VaultProbe = stage.pilot.motion.vault.probe
	_targets = stage.walls.boxes.duplicate()
	if probe.city != null:
		var nearby: Dictionary[Rect2, String] = {}
		probe.city.collect(stage.plan.area("pit").rect.grow(8.0), nearby)
		_city_targets.assign(nearby.keys())


func sample(tick: int) -> TickInput:
	if playing:
		return TickInput.unpack(words[tick])
	if tick >= _end:
		_burst_at(tick)
	var a: PlayerActions = stage.pilot.actions
	var bits: int = _held
	if _burst == Burst.FIRE:
		bits |= 1 << a.bit(&"fire")
	if tick == _first and _burst in [Burst.ROLL, Burst.ROLL_COVER]:
		bits |= 1 << a.bit(&"roll")
	if tick == _first and _burst in [Burst.COVER, Burst.COVER_ROLL]:
		bits |= 1 << a.bit(&"cover")
	if tick == _second and _burst == Burst.ROLL_COVER:
		bits |= 1 << a.bit(&"cover")
	if tick == _second and _burst == Burst.COVER_ROLL:
		bits |= 1 << a.bit(&"roll")
	var axes: Vector2 = _stick * TickInput.AXIS_MAX
	var input: TickInput = TickInput.new(bits, roundi(axes.x), roundi(axes.y))
	@warning_ignore("return_value_discarded")
	words.append(input.pack())
	return input


func _burst_at(tick: int) -> void:
	_begin = tick
	_end = tick + _rng.randi_range(6, 40)
	_first = _rng.randi_range(_begin, _end - 1)
	_second = _first + _rng.randi_range(0, mini(8, _end - 1 - _first))
	_burst = _rng.randi_range(0, Burst.size() - 1) as Burst
	_stick = Vector2.from_angle(_rng.randf_range(-PI, PI))
	if _rng.randf() < 0.6:
		_stick = _nearest().rotated(_rng.randf_range(-0.28, 0.28))
	var aim: Vector2 = Vector2.from_angle(_rng.randf_range(-PI, PI))
	_held = PlayerCommand.pack_aim(aim, stage.pilot.actions)
	if _rng.randf() < 0.5:
		_held |= 1 << stage.pilot.actions.bit(&"sprint")


func _nearest() -> Vector2:
	var p: Vector2 = stage.arena.rivet.pos
	var offset: Vector2 = Vector2.INF
	for box: Rect2 in _targets:
		var d: Vector2 = p.clamp(box.position, box.end) - p
		if d.length_squared() < offset.length_squared():
			offset = d
	if stage.cells != null:
		# The stick can carry Rivet beyond the respawn patch. Check every occupied cell
		# close enough to beat the nearest station, including cells of irregular props.
		var reach: float = offset.length()
		for y: int in range(floori(p.y - reach), floori(p.y + reach) + 1):
			for x: int in range(floori(p.x - reach), floori(p.x + reach) + 1):
				if stage.cells.solid(x, y):
					var corner: Vector2 = Vector2(x, y)
					var d: Vector2 = p.clamp(corner, corner + Vector2.ONE) - p
					if d.length_squared() < offset.length_squared():
						offset = d
	return offset.normalized()


## Respawns are the only placements. Leave the stage's combatants and their AI untouched.
func respawn(tick: int) -> bool:
	var body: Fighter = stage.arena.rivet
	if not playing:
		for attempt: int in 512:
			var boxes: Array[Rect2] = _targets
			if not _city_targets.is_empty() and _rng.randf() < 0.5:
				boxes = _city_targets
			var box: Rect2 = boxes[_rng.randi_range(0, boxes.size() - 1)]
			var n: Vector2 = Vector2.RIGHT.rotated((_rng.randi() % 4) * PI / 2.0).round()
			var tangent: Vector2 = n.orthogonal()
			var face: Vector2 = box.get_center() + n * box.size * 0.5
			face += tangent * box.size.dot(tangent.abs()) * _rng.randf_range(-0.55, 0.55)
			var p: Vector2 = face + n * (body.radius_m + _rng.randf_range(0.02, 1.6))
			if stage.pilot.motion.vault.probe.clear_at(p, body.radius_m):
				spawns[tick] = p
				break
	if not spawns.has(tick):
		return false
	stage.pilot.stop()
	body.pos = spawns[tick]
	body.hp = body.max_hp
	return true


func history(tick: int) -> PackedStringArray:
	var last: PackedStringArray = []
	for i: int in range(maxi(0, tick - 19), mini(tick + 1, words.size())):
		var input: TickInput = TickInput.unpack(words[i])
		@warning_ignore("return_value_discarded")
		last.append("%d:%x/%d/%d" % [i, input.buttons, input.move_x, input.move_y])
	return last
