class_name StreetBoard
extends ReactBoard
## human-reactions evidence: a street's reaction to a kill, through the real CrowdReact (the path
## the city and the arena city run) on the cast rigs in the D5 look. A patrol cop's round kills
## one walker of a 4 x 3 knot: the living within STARTLE_M cower away from the body, then
## scatter (the city sim's flight, scripted here), and a fleeing runner trips over the body.
## Four takes (a round from the west, the south, the east, the north). Frames + timeline.json
## as the board.

const COLS: int = 4
const ROWS: int = 3
const GAP_M: float = 1.2
const RUN_MPS: float = 3.0
const SHOOTER_M: float = 5.0
const DIE_AT: int = 36
const SCATTER_AT: int = 66
const TAKE_TICKS: int = 240
const PED_LOOKS: PackedByteArray = [0, 1, 2, 3, 4, 7]
const PATROL: int = 5
## [body grid index, round travel, runner start (metres from the body)]
const TAKES: Array[Array] = [
	[5, Vector2.RIGHT, Vector2(-5.0, -5.5)],
	[6, Vector2.UP, Vector2(6.0, -4.5)],
	[6, Vector2.LEFT, Vector2(-5.0, 5.0)],
	[5, Vector2.DOWN, Vector2(5.5, 5.0)],
]

var _crowd: CrowdReact = null
var _pos: PackedVector2Array = PackedVector2Array()
var _vel: PackedVector2Array = PackedVector2Array()
var _dead: int = -1


func _runner() -> int:
	return COLS * ROWS


func _cop() -> int:
	return COLS * ROWS + 1


func _grid(i: int) -> Vector2:
	var c: Vector2 = Vector2(i % COLS - (COLS - 1) * 0.5, floorf(float(i) / COLS) - 1.0)
	return c * GAP_M * PX


func _cast() -> void:
	_rigs.feed.count = 0
	for i: int in COLS * ROWS + 2:
		var kind: BodyPlan.Kind = BodyPlan.Kind.COP if i == _cop() else BodyPlan.Kind.PED
		@warning_ignore("return_value_discarded")
		_rigs.feed.put(i, i + 1, kind, _grid(i % (COLS * ROWS)), Vector2.ZERO)


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	_frame_at(zoom)
	overlay.set_shader_parameter("amount", amount_at(zoom))
	for take: Array in TAKES:
		_begin(take)
		for t: int in TAKE_TICKS:
			_caption(t)
			_street_step(take, t)
			if _tick % every != 0:
				continue
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_frame() and ok
		var n: Array[int] = [_crowd.startles, _crowd.trips, _crowd.deaths]
		Log.info("street_board", "take: %d startles, %d trips, %d deaths" % n)
	var fa: FileAccess = FileAccess.open(out_dir.path_join("timeline.json"), FileAccess.WRITE)
	ok = fa != null and ok
	if fa != null:
		@warning_ignore("return_value_discarded")
		fa.store_string(JSON.stringify(_timeline, "  ", false) + "\n")
		fa.close()
	return 0 if ok else 1


func _caption(t: int) -> void:
	var label: String = ""
	if t == 0:
		label = "a street: a cop takes aim at a walker"
	elif t == DIE_AT:
		label = (
			"the round kills; the living within %.1f m cower away from the body"
			% [CrowdReact.STARTLE_M]
		)
	elif t == SCATTER_AT:
		label = "they scatter (the city's flight); a fleeing runner trips over the body"
	if label != "":
		_timeline.append({"label": label, "start_s": _frame_no * every * SimClock.TICK_DT})


## A fresh street: the knot back in place, clean asphalt, a fresh crowd memory.
func _begin(take: Array) -> void:
	var index: int = take[0]
	var body: Vector2 = _grid(index)
	var travel: Vector2 = take[1]
	var start: Vector2 = take[2]
	@warning_ignore_start("return_value_discarded")
	_pos.resize(COLS * ROWS + 2)
	_vel.resize(COLS * ROWS + 2)
	@warning_ignore_restore("return_value_discarded")
	for i: int in COLS * ROWS:
		_pos[i] = _grid(i)
		_vel[i] = Vector2.ZERO
	_pos[_runner()] = body + start * PX
	_vel[_runner()] = -start.normalized() * RUN_MPS * PX
	_pos[_cop()] = body - travel * SHOOTER_M * PX
	_vel[_cop()] = Vector2.ZERO
	_dead = -1
	_crowd = CrowdReact.make(_pipe.table)
	_reset()
	_new_blood()


func _street_step(take: Array, t: int) -> void:
	var body: int = take[0]
	var travel: Vector2 = take[1]
	if t >= SCATTER_AT:
		_scatter(body, travel, t - SCATTER_AT)
	if t == DIE_AT:
		_dead = body
	for i: int in _pos.size():
		if i != _dead:
			_pos[i] += _vel[i] * SimClock.TICK_DT
		_put_row(i, body, travel if (i == body and t == DIE_AT) else Vector2.ZERO)
	if t == DIE_AT:
		_tracer(0, _pos[body], travel)
		_blood.kill_human(_pos[body], travel, ReactBoard.POOL_LEAD_MAX_PX)
	_crowd.observe(_rigs)
	_rigs.focus = Vector2.ZERO
	_rigs.step_ticks(1)
	_tick += 1
	for ln: Line2D in _tracers:
		ln.visible = ln.visible and t < DIE_AT + TRACER_TICKS
	var view: Vector2 = get_viewport().get_visible_rect().size
	_blood.step(_tick, (cam * zoom).round() - view * 0.5)


## Feed row `i` this tick; the dying walker carries the round's travel (CrowdReact reads it).
func _put_row(i: int, body: int, round_travel: Vector2) -> void:
	var f: RigFeed = _rigs.feed
	var kind: BodyPlan.Kind = BodyPlan.Kind.COP if i == _cop() else BodyPlan.Kind.PED
	var v: Vector2 = round_travel * 60.0 if round_travel != Vector2.ZERO else _vel[i]
	@warning_ignore("return_value_discarded")
	f.put(i, i + 1, kind, _pos[i], v)
	f.looks[i] = PATROL if i == _cop() else PED_LOOKS[i % PED_LOOKS.size()]
	if i == _cop():
		f.aim[i] = _pos[body]
		f.face[i] = (_pos[body] - _pos[i]).angle()
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
	elif i == _dead:
		f.flags[i] = RigFeed.Flag.DEAD
	elif _vel[i] != Vector2.ZERO:
		f.flags[i] = RigFeed.Flag.FLEE
	else:
		f.face[i] = 0.9 * i  # a knot of walkers standing about, facing every way


## The living walkers run away from the body and the shooter (the sim's flight after the bang),
## each on its own beat and pace (no RNG: by index), so the knot breaks up, not a ring. A walker
## on the line of fire (the two pulls cancel) breaks sideways off it, never toward the gun.
func _scatter(body: int, travel: Vector2, since: int) -> void:
	for i: int in COLS * ROWS:
		if i == body or since != (i * 7) % 5 * 5:
			continue
		var from_body: Vector2 = (_pos[i] - _pos[body]).normalized()
		var from_cop: Vector2 = (_pos[i] - _pos[_cop()]).normalized()
		var pace: float = RUN_MPS * (0.8 + 0.1 * ((i * 5) % 4))
		var d: Vector2 = from_body + from_cop * 0.8
		if d.length() < 0.6:
			d = travel.orthogonal() * (1.0 if i % 2 == 0 else -1.0)
		_vel[i] = d.normalized() * pace * PX
