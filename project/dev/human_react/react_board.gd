class_name ReactBoard
extends D5ShowcaseRun
## human-reactions evidence: a line of real cast rigs (patrol cop, riot cop, pedestrians) in the
## D5 look takes the same family of hit at once, each from another side (front, behind, north,
## south), through DeathPipe/HumanReact: the wound families, then the standard deaths with red
## blood (CombatBlood) and corpses that hold their pose. A tracer shows where each round came
## from. Every `every`-th tick is saved as a JPG; timeline.json names the segments for captions.

const SPACING_M: float = 3.0
const LOOKS: PackedByteArray = [5, 6, 5, 6, 0, 3]
const DIRS: Array[Vector2] = [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN, Vector2.UP]
const HIT_AT: int = 24
const TRACER_TICKS: int = 5
const TRACER_M: float = 2.5
const CREAM: Color = Color(0.95, 0.92, 0.8)
## [label, hit class, lethal, in cover, ticks]
const SEGMENTS: Array[Array] = [
	["flinch (light round)", &"light", false, false, 96],
	["stagger (heavy round)", &"heavy", false, false, 110],
	["knockdown (blast)", &"blast", false, false, 170],
	["melee: spin from the side, fold from the front", &"melee", false, false, 96],
	["electro stun", &"shock", false, false, 110],
	["burning", &"burn", false, false, 180],
	["hit in cover", &"light", false, true, 90],
	["death: round (back from the front, crumple from behind)", &"light", true, false, 150],
	["death: melee (fold, topple)", &"melee", true, false, 150],
	["death: blast (thrown, tumbling)", &"blast", true, false, 150],
	["death: burn (flail, charred)", &"burn", true, false, 170],
	["death: electro (convulse, stiff fall)", &"shock", true, false, 150],
]

var every: int = 2
var zoom: float = 1.0
var only: int = -1
var _pipe: DeathPipe = DeathPipe.make(ReactTable.shipped())
var _blood: CombatBlood = null
var _tracers: Array[Line2D] = []
var _tick: int = 0
var _frame_no: int = 0
var _timeline: Array[Dictionary] = []


func _ready() -> void:
	super._ready()
	for i: int in LOOKS.size() * 2:
		var ln: Line2D = Line2D.new()
		ln.width = 5.0 if i % 2 == 0 else 2.2
		ln.default_color = D5HeroKerbs.INK if i % 2 == 0 else CREAM
		ln.visible = false
		_actors.add_child(ln)
		_tracers.append(ln)
	RigDetail.enabled = true


func _ground() -> void:
	var field: Polygon2D = Polygon2D.new()
	var e: Vector2 = Vector2(30.0, 18.0) * PX
	field.polygon = PackedVector2Array(
		[Vector2(-e.x, -e.y), Vector2(e.x, -e.y), Vector2(e.x, e.y), Vector2(-e.x, e.y)]
	)
	field.color = D5HeroKerbs.ASPHALT
	_world.add_child(field)


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for i: int in LOOKS.size():
		var at: Vector2 = Vector2((i - (LOOKS.size() - 1) * 0.5) * SPACING_M, 0.0) * PX
		var kind: BodyPlan.Kind = BodyPlan.Kind.COP if LOOKS[i] >= 5 else BodyPlan.Kind.PED
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kind, at, Vector2.ZERO)
		f.looks[i] = LOOKS[i]


## Plays every segment (or only `only`), saving frames; returns the exit code.
func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	_frame_at(zoom)
	overlay.set_shader_parameter("amount", amount_at(zoom))
	for s: int in SEGMENTS.size():
		if only >= 0 and s != only:
			continue
		var seg: Array = SEGMENTS[s]
		_timeline.append({"label": seg[0], "start_s": _frame_no * every * SimClock.TICK_DT})
		var ticks: int = seg[4]
		for t: int in ticks:
			_step(seg, t)
			if _tick % every != 0:
				continue
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_frame() and ok
	var fa: FileAccess = FileAccess.open(out_dir.path_join("timeline.json"), FileAccess.WRITE)
	ok = fa != null and ok
	if fa != null:
		@warning_ignore("return_value_discarded")
		fa.store_string(JSON.stringify(_timeline, "  ", false) + "\n")
		fa.close()
	return 0 if ok else 1


func _step(seg: Array, t: int) -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	for i: int in f.count:
		f.clip[i] = RigClips.Clip.NONE
		f.face[i] = 0.0
		f.aim[i] = f.pos[i] + Vector2(6.0 * PX, 0.0)
		f.flags[i] = (RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING) if LOOKS[i] >= 5 else 0
	if t == 0:
		_reset()
		_new_blood()
	if t == HIT_AT:
		_hit_all(seg)
	_rigs.step_ticks(1)
	_tick += 1
	for ln: Line2D in _tracers:
		ln.visible = ln.visible and t < HIT_AT + TRACER_TICKS
	var view: Vector2 = get_viewport().get_visible_rect().size
	_blood.step(_tick, (cam * zoom).round() - view * 0.5)


## Each segment starts on clean asphalt.
func _new_blood() -> void:
	if _blood != null:
		_blood.queue_free()
	_blood = CombatBlood.new()
	_actors.add_child(_blood)
	_actors.move_child(_blood, 0)


func _reset() -> void:
	_rigs.step_ticks(1)
	for i: int in _rigs.feed.count:
		var rig: CutRig = _rigs.rig_for(i + 1)
		if rig != null:
			rig.reset_state(0.0)


func _hit_all(seg: Array) -> void:
	var f: RigFeed = _rigs.feed
	var hit_class: StringName = seg[1]
	var lethal: bool = seg[2]
	var cover: bool = seg[3]
	for i: int in f.count:
		var rig: CutRig = _rigs.rig_for(i + 1)
		if rig == null:
			continue
		var dir: Vector2 = DIRS[i % DIRS.size()]
		var shielded: bool = LOOKS[i] == 6 and hit_class in [&"light", &"heavy", &"melee"]
		_tracer(i, f.pos[i], dir)
		if lethal:
			var kind: StringName = _pipe.kill(rig, hit_class, dir, &"")
			if hit_class != &"burn" and hit_class != &"shock":
				var slide: float = _pipe.table.travel(kind) * PX
				_blood.kill_human(f.pos[i], dir, slide)
		else:
			var fam: StringName = _pipe.wound(rig, hit_class, dir, shielded, cover)
			if fam != &"shield" and hit_class != &"burn" and hit_class != &"shock":
				_blood.blood.splash(f.pos[i], dir, "player_hit")


func _tracer(i: int, at: Vector2, dir: Vector2) -> void:
	var from: Vector2 = at - dir * TRACER_M * PX
	for k: int in 2:
		var ln: Line2D = _tracers[i * 2 + k]
		ln.points = PackedVector2Array([from, at - dir * 0.3 * PX])
		ln.visible = true


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	_frame_no += 1
	return img.save_jpg(out_dir.path_join("f_%05d.jpg" % _frame_no), 0.92) == OK
