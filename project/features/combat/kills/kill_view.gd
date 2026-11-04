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
## The burn char (smoke, embers, ash flakes) over the burnt bodies.
var char_fx: KillCharFx = KillCharFx.new()
## The electro kill (convulsion, X-ray strobe, stiff drop, collar smoke).
var shock_fx: KillShockFx = KillShockFx.new()
var _groups: Dictionary[int, Array] = {}
var _ang0: PackedFloat32Array = PackedFloat32Array()
## Each slot's drag smear (px), grown while its part slides on the street.
var _trail: Array[PackedVector2Array] = []
## Kill serials that bleed no smear (a row with no spray: the burn).
var _dry: Dictionary[int, bool] = {}


func bind(p_kills: SignatureKills) -> void:
	kills = p_kills
	@warning_ignore("return_value_discarded")
	kills.killed.connect(_on_killed)
	@warning_ignore("return_value_discarded")
	_ang0.resize(GibSim.CAPACITY)
	for i: int in GibSim.CAPACITY:
		_trail.append(PackedVector2Array())
	gib_layer.z_index = 3
	add_child(gib_layer)
	char_fx.kills = kills
	char_fx.ppm = ppm
	char_fx.reduced_motion = reduced_motion
	char_fx.z_index = 4
	add_child(char_fx)
	shock_fx.kills = kills
	shock_fx.ppm = ppm
	shock_fx.reduced_motion = reduced_motion
	shock_fx.z_index = 40  # the X-ray over the living rigs crowding the victim (parts reach +30)
	add_child(shock_fx)


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
		_grow_trail(i, node.position, g.z[i] <= 0.0)
	char_fx.pose()
	shock_fx.pose()
	queue_redraw()


func _draw() -> void:
	if kills == null:
		return
	for m: KillMarks.Mark in kills.marks.marks:
		KillMarkArt.spray(self, m, ppm)
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.live(i) and _trail[i].size() > 1:
			KillMarkArt.smear(self, _trail[i], ppm)
	for m: KillMarks.Mark in kills.marks.marks:
		KillMarkArt.scorch(self, m, ppm)
		KillCharFx.pile(self, m, kills.tick, ppm)
	for i: int in GibSim.CAPACITY:
		if g.live(i):
			var r: float = 0.22 * ppm / (1.0 + g.z[i] * 0.6)
			draw_circle(g.pos[i] * ppm, r, SOOT)
	for m: KillMarks.Mark in kills.marks.marks:
		var age: int = kills.tick - m.tick
		var soot: int = 2 if m.flash_scale >= 1.0 else 0
		if not reduced_motion and age >= 0 and age < m.flash_ticks + soot:
			KillMarkArt.flash(self, m, age, ppm, m.flash_ticks)


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
	victim_id: int, serial: int, row: SignatureKill, _at: Vector2, dir: Vector2
) -> void:
	var rig: CutRig = rig_lookup.call(victim_id) if rig_lookup.is_valid() else null
	var whole: bool = row.whole_body()
	var groups: Array[Node2D] = GibCut.cut(rig, whole) if rig != null else _blobs()
	for i: int in groups.size():
		var gr: Node2D = groups[i]
		if not row.pieces.has(i):  # a group the row does not throw (the burn keeps no cap)
			gr.queue_free()
			groups[i] = null
			continue
		if not row.whole_body():
			var stump: GibBlob = GibBlob.new()  # the ragged red cap under each torn-off part
			stump.radius = 0.1 * ppm
			stump.z_index = -1
			gr.add_child(stump)
		gib_layer.add_child(gr)
	_groups[serial] = groups
	if row.spray == 0:
		_dry[serial] = true
	if row.style == &"burn":
		char_fx.add(serial, groups[SignatureKill.BODY], row)
	elif row.style == &"shock":
		shock_fx.add(serial, groups[SignatureKill.BODY], row, dir)
	var g: GibSim = kills.gibs
	for i: int in GibSim.CAPACITY:
		if g.kill_of[i] == serial:
			_ang0[i] = g.ang[i]
			_trail[i] = PackedVector2Array()
	_drop_unused()


## A sliding part paints the street behind it (a point every few px, at most TRAIL_MAX).
func _grow_trail(i: int, at: Vector2, grounded: bool) -> void:
	var t: PackedVector2Array = _trail[i]
	if not grounded or t.size() >= TRAIL_MAX or _dry.has(kills.gibs.kill_of[i]):
		return
	if t.is_empty() or t[t.size() - 1].distance_to(at) > ppm * 0.08:
		@warning_ignore("return_value_discarded")
		t.append(at)
		_trail[i] = t


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
			char_fx.forget(serial)
			shock_fx.forget(serial)


## No rig to cut (a headless or sprite-cast run): inked blobs stand in for the parts.
func _blobs() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for i: int in SignatureKill.PIECE_IDS.size():
		var b: GibBlob = GibBlob.new()
		b.radius = (0.16 if i < 2 or i == SignatureKill.BODY else 0.1) * ppm
		@warning_ignore("return_value_discarded")
		out.append(b)
	return out
