extends Node2D
## Lane gunplay dodge clip: three blue gunners about 12 m out take turns at Rivet. Each tell
## draws a vermilion aim line (thin while it tracks, thick once the aim locks), then a muzzle
## flash and a 3-round volley. Rivet sidesteps 250 ms after a tell starts (a human read) and
## keeps returning pistol fire; his reticle opens with the bloom, his aim line ends at range_m.
## Drawn at --ppm px/m (default 32), the 60 Hz tick per frame (--fixed-fps 60);
## --enemy-speed=<scale> overrides weapons.json enemy_fire.speed_scale (the A/B for the ASK).

const PAPER: Color = Color(0.91, 0.89, 0.85)
const INK: Color = Color(0.08, 0.08, 0.09)
const COP: Color = Color(0.2, 0.36, 0.72)
const DANGER: Color = Color(0.89, 0.26, 0.12)
const FLASH: Color = Color(0.98, 0.72, 0.1)
const GUNNERS: Array[Vector2] = [Vector2(-8, -9), Vector2(0, -12), Vector2(8, -9)]
const REST_OFFSETS: Array[int] = [20, 60, 100]
const REACT_DELAY: int = 15
const STEP_TICKS: int = 24
const SPEED: float = 4.5

var _table: WeaponTable
var _sim: ProjectileSim
var _gunners: Array[EnemyGunner] = []
var _rivet: RangeTarget
var _trig: Trigger
var _tick: int = 0
var _ppm: float = 32.0
var _step_left: int = 0
var _step_dir: Vector2 = Vector2.ZERO
var _side: float = 1.0
var _hits_taken: int = 0
var _enemy_rounds: int = 0
var _aim_at: int = 1


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ppm="):
			_ppm = float(arg.trim_prefix("--ppm="))
	_table = WeaponTable.shipped()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--enemy-speed="):
			_table.enemy_speed_scale = float(arg.trim_prefix("--enemy-speed="))
	_sim = ProjectileSim.new(RngRegistry.new(42).stream(&"gunplay_dodge"), _table)
	_rivet = RangeTarget.make(1, Vector2.ZERO, 1.0e6, 0.42)
	_rivet.team = Projectile.TEAM_PLAYER
	_sim.targets.append(_rivet)
	for i: int in GUNNERS.size():
		var g: EnemyGunner = EnemyGunner.make(10 + i, GUNNERS[i], &"pistol", _table)
		g.rest_left = REST_OFFSETS[i]
		_gunners.append(g)
		_sim.targets.append(RangeTarget.make(10 + i, GUNNERS[i], 1.0e6, 0.35))
	_trig = Trigger.new(_table.weapon(&"pistol"))
	if _sim.hit.connect(_on_hit) != OK:
		Log.error("gunplay", "dodge view: hit not connected")


func _on_hit(t: RangeTarget, _amount: float, _c: StringName, _d: Vector2) -> void:
	if t.id == 1:
		_hits_taken += 1


func _process(_delta: float) -> void:
	for g: EnemyGunner in _gunners:
		var was: bool = g.telling()
		var before: int = _sim.shots_fired
		g.step(_sim, _rivet.pos)
		_enemy_rounds += _sim.shots_fired - before
		if g.telling() and not was:
			_start_step(g)
	_rivet.walk = _step_dir * SPEED if _step_left > 0 and _step_left <= STEP_TICKS else Vector2.ZERO
	_step_left = maxi(_step_left - 1, 0)
	_aim_at = (_tick / 150) % GUNNERS.size()
	_trig.step()
	if _trig.pull(_tick % 2 == 0):
		_sim.fire(_trig, _rivet.pos + _aim_dir() * 0.5, GUNNERS[_aim_at], Projectile.TEAM_PLAYER, 1)
	_sim.step(_tick)
	_tick += 1
	queue_redraw()


## Sidestep across the gunner's line, alternating sides, staying within 3 m of the mark.
func _start_step(g: EnemyGunner) -> void:
	var line: Vector2 = (_rivet.pos - g.pos).normalized()
	var across: Vector2 = Vector2(-line.y, line.x)
	_side = -_side
	var reach: float = SPEED * float(STEP_TICKS) * SimClock.TICK_DT
	if (_rivet.pos + across * _side * reach).length() > 3.0:
		_side = -_side
	_step_dir = across * _side
	_step_left = STEP_TICKS + REACT_DELAY


func _aim_dir() -> Vector2:
	return (GUNNERS[_aim_at] - _rivet.pos).normalized()


func _to_px(m: Vector2) -> Vector2:
	var size: Vector2 = get_viewport_rect().size
	return Vector2(size.x * 0.5, size.y * 0.5 + 5.5 * _ppm) + m * _ppm


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), PAPER)
	for g: EnemyGunner in _gunners:
		_draw_gunner(g)
	for p: Projectile in _sim.projectiles:
		var head: Vector2 = _to_px(p.pos)
		var tail: Vector2 = head - p.vel.normalized() * maxf(p.spec.tracer_len_m, 0.3) * _ppm
		var enemy: bool = p.team == Projectile.TEAM_ENEMY
		draw_line(tail, head, DANGER if enemy else INK, 3.0 if enemy else 2.0)
		if enemy:
			draw_circle(head, 5.0, INK)
			draw_circle(head, 3.5, DANGER)
	_draw_rivet()
	var hud: String = (
		"hits taken %d / enemy rounds %d   (enemy speed %.2fx)"
		% [_hits_taken, _enemy_rounds, _table.enemy_speed_scale]
	)
	draw_string(ThemeDB.fallback_font, Vector2(24, 40), hud, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)


func _draw_gunner(g: EnemyGunner) -> void:
	var at: Vector2 = _to_px(g.pos)
	if g.telling():
		var dir: Vector2 = (g.aim_point - g.pos).normalized()
		var width: float = 3.0 if g.locked() else 1.5
		draw_dashed_line(at, at + dir * 14.0 * _ppm, Color(DANGER, 0.8), width, 10.0)
	draw_circle(at, 0.35 * _ppm, COP)
	if g.flash_left > 0:
		var dir2: Vector2 = (g.aim_point - g.pos).normalized()
		draw_circle(at + dir2 * 0.6 * _ppm, 0.45 * _ppm, FLASH)


func _draw_rivet() -> void:
	var at: Vector2 = _to_px(_rivet.pos)
	var dir: Vector2 = _aim_dir()
	var reach: float = minf(_trig.spec.range_m, 13.0) * _ppm
	draw_line(at, at + dir * reach, Color(INK, 0.22), 1.0)
	var aim_px: Vector2 = _to_px(GUNNERS[_aim_at])
	var dist_m: float = _rivet.pos.distance_to(GUNNERS[_aim_at])
	var ring: float = maxf(tan(_trig.cone_rad()) * dist_m * _ppm, 6.0)
	draw_arc(aim_px, ring, 0.0, TAU, 32, INK, 1.5)
	draw_circle(at, 0.42 * _ppm, INK)
	draw_arc(at, 0.42 * _ppm, dir.angle() + 2.4, dir.angle() + 3.9, 8, DANGER, 3.0)
