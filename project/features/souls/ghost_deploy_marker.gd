class_name GhostDeployMarker
extends Node2D
## A world-space stencil. All geometry is in metres until the stroke is drawn on the actor layer.

const TEAL: Color = GhostFormHud.TEAL
const INK: Color = GhostFormHud.INK
const PPM: float = SimConst.PX_PER_M
const DASHES: int = 64

var stage: CollectCallStage
var _tick: int = -1


func _process(_delta: float) -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var aiming: bool = ghost.phase == GhostDeploy.Phase.AIMING or ghost._held
	if visible != aiming:
		visible = aiming
	if aiming and _tick != stage.tick:
		_tick = stage.tick
		queue_redraw()


func _draw() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var attacks: GhostAttacks = ghost.strike.attacks
	var forms: GhostForms = stage.pilot.ghosts.forms
	var row: GhostAttacks.DeployRow = attacks.deploy.get(forms.selected)
	if row == null or not ghost._held:
		return
	var ready: bool = ghost.phase == GhostDeploy.Phase.AIMING and row.enabled
	ready = ready and forms.locks.allows(forms.table, forms.selected) and forms.settled()
	ready = ready and not ghost.cooldowns.has(forms.selected) and forms.current() == GhostForms.BASE
	var at: Vector2 = stage.arena.rivet.pos
	var alpha: float = 0.88 if ready else 0.32
	for i: int in DASHES:
		var start: float = TAU * i / DASHES
		_arc(at, row.range_m, start, start + 0.55 * TAU / DASHES, alpha)
	if not ready:
		return
	match ghost.form:
		KerfStage.GHOST:
			_kerf(ghost, attacks)
		OhmStage.GHOST:
			_arc(ghost.spot, row.radius_m, 0.0, TAU)
		HaulerStage.GHOST:
			_stomp(ghost, attacks.num(ghost.form, &"press_ahead_m"))
		DentStage.GHOST:
			_ram(ghost, row.ram_half_m)


func _kerf(ghost: GhostDeploy, attacks: GhostAttacks) -> void:
	var foe: Fighter = GhostDeploySpot.kerf_target(stage, ghost.spot, ghost.facing, attacks)
	var tip: Vector2 = ghost.spot
	var facing: Vector2 = ghost.facing
	if foe != null:
		tip = KerfBehind.rear_spot(
			stage, foe, attacks.num(ghost.form, &"behind_m"), stage.arena.walls, true
		)
		facing = tip.direction_to(foe.pos)
	var heel: Vector2 = tip - facing * 0.48
	var side: Vector2 = facing.orthogonal() * 0.34
	_line(heel - side, tip)
	_line(tip, heel + side)


func _stomp(ghost: GhostDeploy, ahead: float) -> void:
	var radius: float = ghost.strike.press.num(&"stomp_radius_m")
	var centre: Vector2 = ghost.spot + ghost.facing * ahead
	var half: float = acos(clampf(-ahead / radius, -1.0, 1.0))
	var yaw: float = ghost.facing.angle()
	_arc(centre, radius, yaw - half, yaw + half)
	_line(
		centre + Vector2.from_angle(yaw - half) * radius,
		centre + Vector2.from_angle(yaw + half) * radius
	)


func _ram(ghost: GhostDeploy, half: float) -> void:
	var rivet: Fighter = stage.arena.rivet
	var origin: Vector2 = GhostDeploySpot.clip(
		stage, rivet.pos, rivet.pos + ghost.facing.orthogonal() * rivet.radius_m
	)
	var end: Vector2 = GhostDeploySpot.clip(stage, origin, ghost.spot)
	var dir: Vector2 = origin.direction_to(end)
	var side: Vector2 = dir.orthogonal() * half
	_line(origin + side, end + side)
	_line(origin - side, end - side)
	_arc(end, half, dir.angle() - PI / 2.0, dir.angle() + PI / 2.0)
	_arc(origin, half, dir.angle() + PI / 2.0, dir.angle() + 1.5 * PI)


func _arc(at: Vector2, radius: float, start: float, end: float, alpha: float = 1.0) -> void:
	var points: int = maxi(3, ceili(absf(end - start) * radius * 3.0))
	draw_arc(at * PPM, radius * PPM, start, end, points, Color(INK, alpha), 4.0, true)
	draw_arc(at * PPM, radius * PPM, start, end, points, Color(TEAL, alpha), 1.8, true)


func _line(a: Vector2, b: Vector2) -> void:
	draw_line(a * PPM, b * PPM, INK, 4.0, true)
	draw_line(a * PPM, b * PPM, TEAL, 1.8, true)
