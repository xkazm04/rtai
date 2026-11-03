extends Node2D
## enemy-ai evidence: the pit fight (PitLayout + PitDummy) drawn top-down at 32 px/m, one sim
## tick per rendered frame, every frame saved to --out as PNG (ffmpeg makes the clip). A debug
## draw, not the cutout rig: blue discs are cops, steel discs robots, the vermilion line is the
## gun tell (thin while the aim tracks, thick once it locks), the vermilion arc a melee windup.
## Usage: godot --rendering-driver d3d12 --path project res://dev/enemy_ai/enemy_pit_view.tscn
##   -- --out=<dir> --squad=<id,id,...> [--mode=stand|dodge|fight] [--seconds=<s>] [--seed=<n>]
##   [--curve=gentle|standard|steep (waves instead of --squad)] [--human=1] [--every=<ticks>]

const PPM: float = 32.0
const ORIGIN: Vector2 = Vector2(640.0, 448.0)
const COP: Color = Color(0.22, 0.42, 0.85)
const ROBOT: Color = Color(0.62, 0.66, 0.7)
const DANGER: Color = Color(0.93, 0.33, 0.16)
const TRACER: Color = Color(1.0, 0.93, 0.7)
const NAIL: Color = Color(0.8, 0.85, 0.9)

var _pit: EnemyPit = null
var _dummy: PitDummy = null
var _out: String = ""
var _ticks: int = 900
var _waves: WaveRun = null
var _every: int = 1


func _ready() -> void:
	var args: Dictionary[String, String] = {}
	for a: String in OS.get_cmdline_user_args():
		args[a.get_slice("=", 0).trim_prefix("--")] = a.get_slice("=", 1)
	_out = _arg(args, "out", "user://enemy_pit")
	_ticks = CombatTuning.ticks(float(_arg(args, "seconds", "15")))
	_pit = PitLayout.build(int(_arg(args, "seed", "7")))
	var ids: Array[StringName] = []
	for id: String in _arg(args, "squad", "patrol_cop,swat,riot_cop").split(","):
		ids.append(StringName(id))
	var curve: String = _arg(args, "curve", "")
	if curve == "":
		PitLayout.squad(_pit, ids)
	else:
		_waves = WaveRun.new(PitWaves.shipped(), StringName(curve))
	_every = int(_arg(args, "every", "1"))
	var mode: PitDummy.Mode = PitDummy.Mode.FIGHT
	match _arg(args, "mode", "fight"):
		"stand":
			mode = PitDummy.Mode.STAND
		"dodge":
			mode = PitDummy.Mode.DODGE
	_dummy = PitDummy.new(mode, _pit.rivet_pos)
	_dummy.fire_m = float(_arg(args, "fire_m", "10"))
	_pit.rivet_hp = float(_arg(args, "hp", "100"))
	if _arg(args, "human", "0") == "1":
		_dummy.react_ticks = 15
		_dummy.read_frac = 0.7
		_dummy.aim_err_deg = 4.0
		_dummy.watch_rounds = false
	var made: Error = DirAccess.make_dir_recursive_absolute(_out)
	assert(made == OK or DirAccess.dir_exists_absolute(_out))
	_run.call_deferred()


func _run() -> void:
	while _pit.tick < _ticks:
		if _waves != null:
			_waves.step(_pit)
		_dummy.step(_pit)
		_pit.step()
		if _pit.tick % _every != 0:
			continue
		queue_redraw()
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var saved: Error = img.save_png("%s/f%05d.png" % [_out, _pit.tick])
		assert(saved == OK)
	var report: String = JSON.stringify(
		_pit.stats if _waves == null else {"waves": _waves.report()}
	)
	var f: FileAccess = FileAccess.open(_out + "/stats.json", FileAccess.WRITE)
	var wrote: bool = f.store_string(report)
	f.close()
	assert(wrote)
	get_tree().quit(0)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 896)), Color(0.11, 0.12, 0.13))
	draw_rect(_r(_pit.bounds), Color(0.16, 0.17, 0.18))
	for b: Rect2 in _pit.cover:
		draw_rect(_r(b), Color(0.36, 0.33, 0.28))
	for s: Shot in _pit.shots:
		var tail: Vector2 = s.pos - s.vel.normalized() * 0.9
		draw_line(_p(tail), _p(s.pos), NAIL if s.from_rivet else TRACER, 3.0)
	for e: EnemyAgent in _pit.agents:
		_draw_enemy(e)
	var rp: Vector2 = _p(_pit.rivet_pos)
	draw_circle(rp, _pit.rivet_radius * PPM, Color(0.3, 0.31, 0.33))
	draw_arc(rp, _pit.rivet_radius * PPM * 0.8, 0.0, TAU, 24, DANGER, 3.0)
	var hp: String = "Rivet hp %d   t %.1f s" % [_pit.rivet_hp, _pit.tick * SimClock.TICK_DT]
	if _waves != null:
		hp += "   wave %d" % (_waves.index + 1)
	draw_string(ThemeDB.fallback_font, Vector2(16, 28), hp, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)


func _draw_enemy(e: EnemyAgent) -> void:
	var c: Color = ROBOT if e.arch.body == &"robot" else COP
	var p: Vector2 = _p(e.pos)
	var r: float = e.radius() * PPM
	if not e.alive():
		draw_circle(p, r, c.darkened(0.6))
		return
	if e.state == EnemyAgent.State.WINDUP:
		_draw_tell(e, p)
	if e.state == EnemyAgent.State.DOWN or e.state == EnemyAgent.State.PANIC:
		c = c.lightened(0.35)
	draw_circle(p, r, c)
	draw_line(p, p + e.facing * r * 1.4, Color.WHITE, 2.0)
	if e.pose(_pit.tick) == &"hit":
		draw_arc(p, r + 3.0, 0.0, TAU, 20, Color.WHITE, 2.0)
	var st: String = str(EnemyAgent.State.keys()[e.state]).to_lower()
	var tag: String = "%s %s/%s" % [e.arch.id, e.pose(_pit.tick), st]
	draw_string(ThemeDB.fallback_font, p + Vector2(-r, -r - 6), tag, 0, -1, 12)


func _draw_tell(e: EnemyAgent, p: Vector2) -> void:
	var locked: bool = e.aim_locked(_pit.roster.aim_lock_ticks)
	if e.melee():
		var a: float = e.aim.angle()
		draw_arc(p, e.arch.weapon.reach_m * PPM, a - 1.0, a + 1.0, 16, DANGER, 4.0)
		return
	var w: float = 3.0 if locked else 1.0
	draw_line(p, p + e.aim * e.arch.attack_m * PPM, DANGER, w)


func _arg(args: Dictionary[String, String], key: String, fallback: String) -> String:
	return args[key] if args.has(key) else fallback


func _p(m: Vector2) -> Vector2:
	return ORIGIN + m * PPM


func _r(m: Rect2) -> Rect2:
	return Rect2(_p(m.position), m.size * PPM)
