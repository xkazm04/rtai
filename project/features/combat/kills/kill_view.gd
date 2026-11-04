class_name KillView
extends Node2D
## The signature kills drawn (lane brutality), render only: under the bodies the scorch rings,
## the red spray fans and each flying part's ink shadow; above them the gib groups (GibCut copies
## of the victim's own rig parts) placed from GibSim every frame, lifted and grown with height,
## and the kill's ink flash (a cream starburst for flash_ticks, none under reduced motion).
## World px at `ppm` in the actor layer's space. Reads the sim, writes nothing back, no RNG.

const BLOOD: Color = KillMarkArt.BLOOD
const SOOT: Color = KillMarkArt.SOOT
const LIFT_SCALE: float = 0.22
const TRAIL_MAX: int = 40

var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
## Callable(victim_id: int) -> CutRig (null when the victim has no posed rig).
var rig_lookup: Callable = Callable()
var gib_layer: Node2D = Node2D.new()
## The leftovers: one KillGround per kill (spray, smears, scorch, ash heap), each reprinted only
## when its own kill changes (a full reprint of twelve kills was the kill-frame spike).
var ground: Node2D = Node2D.new()
## The smears of the kills whose parts still slide (redrawn every frame while any moves).
var fresh: Node2D = Node2D.new()
## The per-style overlays (char, X-ray, blade streak, dissolve, shard burst) and the cut dispatch.
var styles: KillStyles = KillStyles.new()
## CPU cost of this view (place, cut, draw; the char and shock overlays' own draws excluded):
## frames counted, microseconds in total and in the worst frame (telemetry, CONTENDED).
var frames: int = 0
var spent_us: int = 0
var worst_us: int = 0
## Microseconds of each kill's cut (_on_killed), in kill order: is only the first one slow?
var kill_us: PackedInt32Array = PackedInt32Array()
var _groups: Dictionary[int, Array] = {}
var _ang0: PackedFloat32Array = PackedFloat32Array()
## Each slot's drag smear (px), grown while its part slides on the street.
var _trail: Array[PackedVector2Array] = []
## Kill serials that bleed no smear (a row with no spray: the burn).
var _dry: Dictionary[int, bool] = {}
var _frame_us: int = 0
var _grounds: Dictionary[int, KillGround] = {}
var _moving: Dictionary[int, bool] = {}


func bind(p_kills: SignatureKills) -> void:
	kills = p_kills
	@warning_ignore("return_value_discarded")
	kills.killed.connect(_on_killed)
	@warning_ignore("return_value_discarded")
	_ang0.resize(GibSim.CAPACITY)
	for i: int in GibSim.CAPACITY:
		_trail.append(PackedVector2Array())
	ground.z_index = -1
	add_child(ground)
	fresh.z_index = -1
	@warning_ignore("return_value_discarded")
	fresh.draw.connect(_draw_fresh)
	add_child(fresh)
	gib_layer.z_index = 3
	add_child(gib_layer)
	styles.bind(kills, ppm, reduced_motion)
	add_child(styles)


func _process(_delta: float) -> void:
	if kills == null:
		return
	frames += 1
	spent_us += _frame_us
	worst_us = maxi(worst_us, _frame_us)
	var t0: int = Time.get_ticks_usec()
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		var node: Node2D = _node(i)
		if node == null:
			continue
		node.position = g.pos[i] * ppm
		node.rotation = g.ang[i] - _ang0[i]
		node.scale = Vector2.ONE * (1.0 + g.z[i] * LIFT_SCALE)
		_grow_trail(i, node.position, g.z[i] <= 0.0)
	styles.pose()
	_track_moving()
	for kg: KillGround in _grounds.values():
		if kg.needs_reprint(kills.tick):
			kg.queue_redraw()
	queue_redraw()
	_frame_us = Time.get_ticks_usec() - t0


## The smears of `serial`'s parts that came to rest (its KillGround prints them).
func settled_smears(serial: int) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	if _moving.has(serial):
		return out
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.kill_of[i] == serial and g.live(i) and _trail[i].size() > 1:
			out.append(_trail[i])
	return out


## A KillGround's print time joins this frame's cost.
func add_us(us: int) -> void:
	_frame_us += us


func _draw_fresh() -> void:
	var t0: int = Time.get_ticks_usec()
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.live(i) and _trail[i].size() > 1 and _moving.has(g.kill_of[i]):
			KillMarkArt.smear(fresh, _trail[i], ppm)
	_frame_us += Time.get_ticks_usec() - t0


## The kills with a part still moving; one coming to rest hands its smears to the ground.
func _track_moving() -> void:
	var moving: Dictionary[int, bool] = {}
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.live(i) and not g.at_rest(i):
			moving[g.kill_of[i]] = true
	for serial: int in _moving.keys():  # came to rest: its smears move onto its own print
		if not moving.has(serial) and _grounds.has(serial):
			_grounds[serial].queue_redraw()
	if not moving.is_empty() or not _moving.is_empty():
		fresh.queue_redraw()
	_moving = moving


## Every frame: the flying parts' shadows and the kill flash only.
func _draw() -> void:
	if kills == null:
		return
	var t0: int = Time.get_ticks_usec()
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.live(i):
			var r: float = 0.22 * ppm / (1.0 + g.z[i] * 0.6)
			draw_circle(g.pos[i] * ppm, r, SOOT)
	for m: KillMarks.Mark in kills.marks.marks:
		var age: int = kills.tick - m.tick
		var soot: int = 2 if m.flash_scale >= 1.0 else 0
		if not reduced_motion and age >= 0 and age < m.flash_ticks + soot:
			KillMarkArt.flash(self, m, age, ppm, m.flash_ticks)
	_frame_us += Time.get_ticks_usec() - t0


func _node(i: int) -> Node2D:
	var g: GibSim = kills.gibs
	if not g.live(i):
		return null
	var arr: Array = _groups.get(g.kill_of[i], [])
	var p: int = g.piece[i]
	if p >= arr.size():
		return null
	var n: Node2D = arr[p]
	return n


func _on_killed(victim_id: int, serial: int, row: SignatureKill, at: Vector2, dir: Vector2) -> void:
	var t0: int = Time.get_ticks_usec()
	var groups: Array[Node2D] = _parts(victim_id, serial, row, at, dir)
	for i: int in groups.size():
		var gr: Node2D = groups[i]
		if gr == null or not row.pieces.has(i):  # a group the row does not throw (burn: no cap)
			if gr != null:
				gr.queue_free()
			groups[i] = null
			continue
		if not row.whole_body() and row.style != &"split":
			var stump: GibBlob = GibBlob.new()  # the ragged red cap under each torn-off part
			stump.radius = 0.1 * ppm
			stump.z_index = -1
			gr.add_child(stump)
		gib_layer.add_child(gr)
	_groups[serial] = groups
	if row.spray == 0:
		_dry[serial] = true
	styles.take(serial, groups[SignatureKill.BODY], row, at, dir)
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.kill_of[i] == serial:
			_ang0[i] = g.ang[i]
			_trail[i] = PackedVector2Array()
	_drop_unused()
	_print_ground(serial)
	_frame_us += Time.get_ticks_usec() - t0
	@warning_ignore("return_value_discarded")
	kill_us.append(Time.get_ticks_usec() - t0)


## A sliding part paints the street behind it (a point every few px, at most TRAIL_MAX).
func _grow_trail(i: int, at: Vector2, grounded: bool) -> void:
	var t: PackedVector2Array = _trail[i]
	if not grounded or t.size() >= TRAIL_MAX or _dry.has(kills.gibs.kill_of[i]):
		return
	if t.is_empty() or t[t.size() - 1].distance_to(at) > ppm * 0.08:
		@warning_ignore("return_value_discarded")
		t.append(at)
		_trail[i] = t


## The new kill's print (its mark is the newest); prints whose mark was recycled are freed.
func _print_ground(serial: int) -> void:
	var kg: KillGround = KillGround.new()
	kg.view = self
	kg.mark = kills.marks.marks.back()
	kg.serial = serial
	ground.add_child(kg)
	_grounds[serial] = kg
	for s: int in _grounds.keys():
		if not kills.marks.marks.has(_grounds[s].mark):
			_grounds[s].queue_free()
			@warning_ignore("return_value_discarded")
			_grounds.erase(s)


## Frees the parts of kills whose pool slots were all reused (the leftover budget).
func _drop_unused() -> void:
	var used: Dictionary[int, bool] = {}
	for s: int in kills.gibs.kill_of:
		used[s] = true
	for serial: int in _groups.keys():
		if not used.has(serial):
			for gr: Variant in _groups[serial]:
				var dead: Node2D = gr
				if dead != null:
					dead.queue_free()
			@warning_ignore("return_value_discarded")
			_groups.erase(serial)
			@warning_ignore("return_value_discarded")
			_dry.erase(serial)
			styles.forget(serial)


## The victim's parts, cut by the row's style (KillStyles.parts).
func _parts(
	victim_id: int, serial: int, row: SignatureKill, at: Vector2, dir: Vector2
) -> Array[Node2D]:
	var rig: CutRig = rig_lookup.call(victim_id) if rig_lookup.is_valid() else null
	return styles.parts(rig, serial, row, at, dir)
