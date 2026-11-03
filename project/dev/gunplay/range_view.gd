extends Node2D
## Lane gunplay dev range (until the arena station is on this branch): the six core weapons
## side by side, each lane firing at a strafing human dummy 20 m down range, drawn at --ppm
## px/m (default 32). Steps the sim on the 60 Hz tick per rendered frame (--fixed-fps 60).

const LANE_GAP_M: float = 3.5
const DIST_M: float = 20.0
const ORIGIN: Vector2 = Vector2(190, 90)
const PAPER: Color = Color(0.91, 0.89, 0.85)
const INK: Color = Color(0.08, 0.08, 0.09)
const FIRE: Color = Color(0.95, 0.55, 0.15)
const ARC: Color = Color(0.85, 0.9, 1.0)

var _table: WeaponTable
var _sims: Array[ProjectileSim] = []
var _trigs: Array[Trigger] = []
var _tick: int = 0
var _ppm: float = 32.0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ppm="):
			_ppm = float(arg.trim_prefix("--ppm="))
	_table = WeaponTable.shipped()
	var ids: Array[StringName] = _table.playable()
	ids.erase(&"gloria")
	var reg: RngRegistry = RngRegistry.new(42)
	for i: int in ids.size():
		var sim: ProjectileSim = ProjectileSim.new(reg.stream(StringName("gunplay_%d" % i)), _table)
		_sims.append(sim)
		_trigs.append(Trigger.new(_table.weapon(ids[i])))
		_respawn(sim)


func _process(_delta: float) -> void:
	for i: int in _sims.size():
		var sim: ProjectileSim = _sims[i]
		var target: RangeTarget = sim.targets[0]
		if not target.alive() and _tick - target.hurt_tick > 30:
			_respawn(sim)
		if _tick % 90 == 0:
			target.walk = -target.walk
		_trigs[i].step()
		var held: bool = _trigs[i].spec.auto or _tick % 2 == 0
		if target.alive() and _trigs[i].pull(held):
			sim.fire(_trigs[i], Vector2(0.5, 0), target.pos, Projectile.TEAM_PLAYER, 0)
		sim.step(_tick)
	_tick += 1
	queue_redraw()


func _respawn(sim: ProjectileSim) -> void:
	sim.targets.clear()
	var t: RangeTarget = RangeTarget.make(1, Vector2(DIST_M, 0), 100.0, 0.35)
	t.walk = Vector2(0, 3.2)
	sim.targets.append(t)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), PAPER)
	for i: int in _sims.size():
		var base: Vector2 = ORIGIN + Vector2(0, i * minf(LANE_GAP_M * _ppm, 120.0))
		draw_string(
			ThemeDB.fallback_font,
			base + Vector2(-110, -14),
			String(_trigs[i].spec.id),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			INK
		)
		draw_line(base + Vector2(0, -1.6 * _ppm), base + Vector2(0, 1.6 * _ppm), INK, 1.0)
		_draw_lane(_sims[i], _trigs[i], base)


func _draw_lane(sim: ProjectileSim, trig: Trigger, base: Vector2) -> void:
	for k: int in sim.patches.size():
		var p: Vector4 = sim.patches[k]
		draw_circle(base + Vector2(p.x, p.y) * _ppm, p.z * _ppm, Color(FIRE, 0.35))
	draw_circle(base, 0.42 * _ppm, INK)
	for t: RangeTarget in sim.targets:
		var col: Color = INK if t.alive() else Color(INK, 0.25)
		draw_circle(base + t.pos * _ppm, t.radius_m * _ppm, col)
		if t.panicking():
			draw_arc(base + t.pos * _ppm, t.radius_m * _ppm + 4, 0, TAU, 16, FIRE, 2.0)
	for p: Projectile in sim.projectiles:
		var head: Vector2 = base + p.pos * _ppm
		var tail_m: float = maxf(p.spec.tracer_len_m, 0.3)
		var tail: Vector2 = head - p.vel.normalized() * tail_m * _ppm
		var kind: WeaponSpec.Kind = p.spec.kind
		var col: Color = FIRE if kind == WeaponSpec.Kind.CONE else INK
		var width: float = 5.0 if kind == WeaponSpec.Kind.ROCKET else 2.0
		draw_line(tail, head, col, width)
		if kind == WeaponSpec.Kind.THROWN or kind == WeaponSpec.Kind.ROCKET:
			draw_circle(head, 4.0, col)
	for arc: PackedVector2Array in sim.chain_arcs:
		draw_line(base + arc[0] * _ppm, base + arc[1] * _ppm, ARC, 3.0)
	var cone: float = trig.cone_rad()
	var far: float = 6.0 * _ppm
	draw_line(base, base + Vector2.RIGHT.rotated(cone) * far, Color(INK, 0.3), 1.0)
	draw_line(base, base + Vector2.RIGHT.rotated(-cone) * far, Color(INK, 0.3), 1.0)
