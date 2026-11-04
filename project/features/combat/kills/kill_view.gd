class_name KillView
extends Node2D
## The signature kills drawn (lane brutality), render only: under the bodies the scorch rings,
## the red spray fans and each flying part's ink shadow; above them the gib groups (GibCut copies
## of the victim's own rig parts) placed from GibSim every frame, lifted and grown with height,
## and the kill's ink flash (a cream starburst for flash_ticks, none under reduced motion).
## World px at `ppm` in the actor layer's space. Reads the sim, writes nothing back, no RNG.

const BLOOD: Color = Color("#A30509")
const BLOOD_DARK: Color = Color("#540005")
const SOOT: Color = Color(0.09, 0.075, 0.105, 0.55)
const LIFT_SCALE: float = 0.22
const FLASH_HOLD: int = 4

var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
## Callable(victim_id: int) -> CutRig (null when the victim has no posed rig).
var rig_lookup: Callable = Callable()
var gib_layer: Node2D = Node2D.new()
var _groups: Dictionary[int, Array] = {}
var _ang0: PackedFloat32Array = PackedFloat32Array()


func bind(p_kills: SignatureKills) -> void:
	kills = p_kills
	@warning_ignore("return_value_discarded")
	kills.killed.connect(_on_killed)
	@warning_ignore("return_value_discarded")
	_ang0.resize(GibSim.CAPACITY)
	gib_layer.z_index = 3
	add_child(gib_layer)


func _process(_delta: float) -> void:
	if kills == null:
		return
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		var node: Node2D = _node(i)
		if node == null:
			continue
		node.position = g.pos[i] * ppm
		node.rotation = g.ang[i] - _ang0[i]
		node.scale = Vector2.ONE * (1.0 + g.z[i] * LIFT_SCALE)
	queue_redraw()


func _draw() -> void:
	if kills == null:
		return
	for m: KillMarks.Mark in kills.marks.marks:
		_draw_scorch(m)
		_draw_spray(m)
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.live(i):
			var r: float = 0.22 * ppm / (1.0 + g.z[i] * 0.6)
			draw_circle(g.pos[i] * ppm, r, SOOT)
	for m: KillMarks.Mark in kills.marks.marks:
		var age: int = kills.tick - m.tick
		if not reduced_motion and age >= 0 and age < FLASH_HOLD + 2:
			_draw_flash(m, age)


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


func _on_killed(
	victim_id: int, serial: int, _row: SignatureKill, _at: Vector2, _dir: Vector2
) -> void:
	var rig: CutRig = rig_lookup.call(victim_id) if rig_lookup.is_valid() else null
	var groups: Array[Node2D] = GibCut.cut(rig) if rig != null else _blobs()
	for gr: Node2D in groups:
		gib_layer.add_child(gr)
	_groups[serial] = groups
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.kill_of[i] == serial:
			_ang0[i] = g.ang[i]
	_drop_unused()


## Frees the parts of kills whose pool slots were all reused (the leftover budget).
func _drop_unused() -> void:
	var used: Dictionary[int, bool] = {}
	for s: int in kills.gibs.kill_of:
		used[s] = true
	for serial: int in _groups.keys():
		if not used.has(serial):
			for gr: Variant in _groups[serial]:
				var dead: Node2D = gr
				dead.queue_free()
			@warning_ignore("return_value_discarded")
			_groups.erase(serial)


## No rig to cut (a headless or sprite-cast run): inked blobs stand in for the parts.
func _blobs() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for i: int in SignatureKill.PIECE_IDS.size():
		var b: GibBlob = GibBlob.new()
		b.radius = (0.16 if i < 2 else 0.1) * ppm
		@warning_ignore("return_value_discarded")
		out.append(b)
	return out


func _draw_scorch(m: KillMarks.Mark) -> void:
	if m.scorch_m <= 0.0:
		return
	var c: Vector2 = m.at * ppm
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in 18:
		var a: float = TAU * float(k) / 18.0
		var r: float = m.scorch_m * ppm * (0.75 + 0.25 * sin(a * 5.0 + m.at.x))
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2.from_angle(a) * r)
	draw_colored_polygon(pts, SOOT)
	draw_circle(c, m.scorch_m * ppm * 0.45, Ink.INK)


func _draw_spray(m: KillMarks.Mark) -> void:
	var c: Vector2 = m.at * ppm
	for d: Vector3 in m.drops:
		var p: Vector2 = c + Vector2(d.x, d.y) * ppm
		draw_circle(p, d.z * ppm * 1.15, BLOOD_DARK)
		draw_circle(p, d.z * ppm, BLOOD)
	draw_circle(c + m.dir * 0.3 * ppm, 0.42 * ppm, BLOOD)


func _draw_flash(m: KillMarks.Mark, age: int) -> void:
	var c: Vector2 = m.at * ppm
	var grow: float = 1.0 + 0.25 * float(age)
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in 24:
		var r: float = (1.6 if k % 2 == 0 else 0.8) * ppm * grow
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2.from_angle(TAU * float(k) / 24.0 + 0.2) * r)
	draw_colored_polygon(pts, Ink.CREAM if age < FLASH_HOLD else SOOT)
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	draw_polyline(pts, Ink.INK, maxf(2.0, ppm * 0.08))
