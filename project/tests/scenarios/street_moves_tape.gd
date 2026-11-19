class_name StreetMovesTape
extends InputSource
## Continuous stick input from the quest spawn. Alternate a sprint at the nearest occupied
## cell of a low prop with a run along/across traffic. Playback only reads the original words.

const SEED: int = 1911
const TICKS: int = 6000
const CARS: PackedStringArray = ["sedan", "sedan_b", "sedan_c", "car_wreck"]

var words: PackedInt64Array = []
var _stage: CollectCallStage
var _rng: RandomNumberGenerator = RngRegistry.new(SEED).stream(&"street_moves")
var _cars: Array[Vector2i] = []
var _furniture: Array[Vector2i] = []
var _next_burst: int = 0
var _direction: Vector2
var _cover: int
var _roll: int
var _sprint: bool


func bind(s: Quest1Session) -> void:
	_stage = s.stage
	s.city.spawner.targets.cars = 100
	var probe: VaultProbe = s.pilot.motion.vault.probe
	s.pilot.motion.vault.bind_solids(_stage)
	if words.is_empty():
		_index(probe, Rect2i(Vector2i(_stage.layout.origin) - Vector2i(32, 24), Vector2i(150, 48)))
	s.world.loop().set_input(self)


func _index(probe: VaultProbe, patch: Rect2i) -> void:
	for y: int in range(patch.position.y, patch.end.y):
		for x: int in range(patch.position.x, patch.end.x):
			if _stage.cells.code_at(x, y) != SimConst.C_PROP:
				continue
			var cell: Vector2i = Vector2i(x, y)
			var prop: VaultCity.Prop = probe.city.owner(cell)
			if prop == null or probe.heights.get(prop.kind, INF) > probe.max_height:
				continue
			if CARS.has(prop.kind):
				_cars.append(cell)
			else:
				_furniture.append(cell)


func sample(tick: int) -> TickInput:
	if tick < words.size():
		return TickInput.unpack(words[tick])
	if tick >= _next_burst:
		_burst(tick)
	var dir: Vector2 = _direction
	var v: PlayerVault = _stage.pilot.motion.vault
	if v.frame >= 0:
		dir = dir.orthogonal() if v.frame < v.ticks / 2 else -dir
	var a: PlayerActions = _stage.pilot.actions
	var bits: int = PlayerCommand.pack_aim(dir, a)
	if _sprint:
		bits |= 1 << a.bit(&"sprint")
	if tick == _roll:
		bits |= 1 << a.bit(&"roll")
	if tick == _cover:
		bits |= 1 << a.bit(&"cover")
	var axes: Vector2 = dir * TickInput.AXIS_MAX
	var input: TickInput = TickInput.new(bits, roundi(axes.x), roundi(axes.y))
	@warning_ignore("return_value_discarded")
	words.append(input.pack())
	return input


func _burst(tick: int) -> void:
	_next_burst = tick + _rng.randi_range(18, 48)
	_cover = _rng.randi_range(tick, _next_burst - 1)
	_roll = _rng.randi_range(tick, _next_burst - 1)
	_sprint = _rng.randf() < 0.9
	var p: Vector2 = _stage.arena.rivet.pos
	if tick % 360 < 260:
		var offset: Vector2 = _nearest(p, _cars if tick % 720 < 360 else _furniture)
		_direction = offset.normalized().rotated(_rng.randf_range(-0.10, 0.10))
	else:
		var goal: Vector2 = _stage.layout.origin + Vector2(55 if tick % 1800 < 900 else 0, 0)
		_direction = p.direction_to(goal).rotated(_rng.randf_range(-0.6, 0.6))


func _nearest(p: Vector2, cells: Array[Vector2i]) -> Vector2:
	var offset: Vector2 = Vector2.INF
	for cell: Vector2i in cells:
		var corner: Vector2 = Vector2(cell)
		var d: Vector2 = p.clamp(corner, corner + Vector2.ONE) - p
		if d.length_squared() < offset.length_squared():
			offset = d
	return offset if offset.is_finite() else Vector2.RIGHT
