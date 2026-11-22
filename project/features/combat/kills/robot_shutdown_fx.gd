class_name RobotShutdownFx
extends Node2D
## A copy of the struck chassis stays on its feet during the short, then folds around its feet.
## The clock is the signature kill's simulation tick, including when several render frames repeat.

const AMBER: Color = Color("#edab42")
const DARK: Color = Color("#23272e")
const SMOKE: Color = Color("#777778")


class Mount:
	extends Node2D
	var frame: Fighter
	var turret: bool

	func _draw() -> void:
		if turret:
			FoeTurretView.draw_mount(self, frame, 0.0, true)
		else:
			FoeShieldView.draw_plate(self, frame, null, 0)


var clock: SignatureKills
var born: int
var ppm: float
var side: float
var still: bool
var shake_ticks: int
var fold_ticks: int
var joint_m: float
var fall_deg: float
var pivot: Node2D = Node2D.new()
var chassis: Node2D = Node2D.new()


static func wrap(
	body: Node2D, row: SignatureKill, kills: SignatureKills, pixels: float, dir: Vector2
) -> Node2D:
	var v: RobotShutdownFx = RobotShutdownFx.new()
	var details: KillTrackRows.Extra = KillTrackRows.of(row.id)
	v.clock = kills
	v.born = kills.tick
	v.ppm = pixels
	v.side = -1.0 if dir.x < 0.0 else 1.0
	v.still = LaunchArgs.has("--reduced-motion")
	v.shake_ticks = maxi(1, row.stand_ticks)
	v.fold_ticks = maxi(1, row.crumble_ticks)
	v.fall_deg = details.num("fold_deg", 65.0)
	v.joint_m = details.num("joint_m", 0.65)
	v.add_child(v.pivot)
	v.pivot.add_child(v.chassis)
	v._copy(body, row.victim, dir)
	return v


func _copy(body: Node2D, victim: StringName, dir: Vector2) -> void:
	var turret: bool = victim == &"sentry_turret"
	if body is GibBlob or turret:
		body.free()
		if not turret:
			var shell: Sprite2D = Sprite2D.new()
			shell.texture = FoeShieldView.TORSO
			shell.scale = Vector2.ONE * ppm / shell.texture.get_width()
			shell.position.y = -joint_m * ppm
			chassis.add_child(shell)
	else:
		chassis.add_child(body)
	if turret or victim == &"shield_robot":
		var mount: Mount = Mount.new()
		mount.frame = Fighter.make(Fighter.Kind.GUARD, 0, Vector2.ZERO, 1)
		mount.frame.facing = -dir
		mount.turret = turret
		mount.scale = Vector2.ONE * ppm / Ink.PX_PER_M
		mount.z_index = 32
		chassis.add_child(mount)
	var lights: Node2D = Node2D.new()
	lights.z_index = 40
	pivot.add_child(lights)
	@warning_ignore("return_value_discarded")
	lights.draw.connect(_lights.bind(lights))


func _process(_delta: float) -> void:
	var age: int = clock.tick - born
	var fall: float = smoothstep(0.0, float(fold_ticks), float(age - shake_ticks))
	var jerk: float = 0.0
	if age < shake_ticks and not still:
		jerk = sin(float(age / 2) * 19.0) * 0.045
	pivot.rotation = jerk + side * deg_to_rad(fall_deg) * fall
	pivot.position = Vector2(jerk * ppm, -fall * 0.08 * ppm)
	pivot.scale.y = lerpf(1.0, 0.56, fall)
	chassis.modulate = Color.WHITE.lerp(Color("#4c5055"), fall)
	(pivot.get_child(1) as Node2D).queue_redraw()
	queue_redraw()


func _lights(ci: Node2D) -> void:
	var age: int = clock.tick - born
	var at: Vector2 = Vector2.UP * joint_m * ppm
	var power: float = clampf(float(age) / float(shake_ticks), 0.0, 1.0)
	if age < shake_ticks:
		crackle(ci, at, ppm, age, power)
	var eye: Vector2 = at + Vector2(side * 0.06, -0.30) * ppm
	ci.draw_circle(eye, 0.105 * ppm, DARK)
	if age < shake_ticks:
		ci.draw_circle(eye, (0.035 + 0.035 * power) * ppm, AMBER)


static func crackle(ci: CanvasItem, at: Vector2, pixels: float, tick: int, power: float) -> void:
	for sign_x: float in [-1.0, 1.0]:
		var joint: Vector2 = at + Vector2(sign_x * 0.27, -0.04) * pixels
		ci.draw_circle(joint, (0.11 + 0.06 * power) * pixels, Color(AMBER, 0.23 + power * 0.25))
		ci.draw_circle(joint, 0.07 * pixels, AMBER)
	ShockJolt.arcs(ci, at, pixels, tick, Vector2i(3, 2))


func _draw() -> void:
	var age: int = clock.tick - born - shake_ticks
	if age < 0 or age >= fold_ticks * 2:
		return
	var u: float = float(age) / float(fold_ticks * 2)
	for i: int in 4:
		var at: Vector2 = Vector2(side * (0.18 + i * 0.1), -0.30 - u * (0.65 + i * 0.17))
		draw_circle(at * ppm, (0.06 + u * 0.18) * ppm, Color(SMOKE, (1.0 - u) * 0.7))
	if age < fold_ticks / 3:
		for i: int in 3:
			draw_polyline(ShockJolt.spit(Vector2.ZERO, ppm, age / 2, i), AMBER, 2.0)


static func overload(view: CanvasItem, pos: Vector2, tick: int) -> void:
	crackle(view, Ink.px(pos + Vector2.UP * 0.55), Ink.PX_PER_M, tick, 0.75)


static func rig_for(host: RigHost, victim_id: int) -> CutRig:
	if host == null:
		return null
	if host is ArenaRigs and (host as ArenaRigs).robots != null:
		var robot_rig: CutRig = (host as ArenaRigs).robots.rig_for(victim_id)
		if robot_rig != null:
			return robot_rig
	return host.rigs.rig_for(victim_id)
