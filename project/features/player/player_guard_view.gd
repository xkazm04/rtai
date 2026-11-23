class_name PlayerGuardView
extends Node2D
## The live guard pose, charge at Rivet's feet and flash on the break tick.

const STEEL: Color = Color("#b8c1c9")
const AMBER: Color = Color("#ffc15b")
const INK: Color = Color("#171920")
const FLASH_TICKS: int = 12
const PHASE_TICKS: int = roundi(0.05 * SimClock.TICK_RATE)
const FULL_LIFT: int = 2 * PHASE_TICKS + 1
const METER: Rect2 = Rect2(-12, 15, 24, 4)

var _guard: PlayerGuard
var _arena: CombatArena
var _rigs: CharacterRigs
var _last_tick: int = -1
var _lift: int = 0
var _breaks: int
var _flash_tick: int = -FLASH_TICKS


static func attach(layer: CanvasLayer, stage: CollectCallStage, rigs: CharacterRigs) -> void:
	if stage.pilot != null:
		DeflectPassView.attach(layer, stage.arena, rigs.z_index + 71)
	if stage.pilot == null or stage.pilot.guard == null:
		return
	var view: PlayerGuardView = PlayerGuardView.new()
	view._guard = stage.pilot.guard
	view._arena = stage.arena
	view._rigs = rigs
	view._breaks = view._guard.breaks
	view.z_index = rigs.z_index + 70
	view.process_priority = 11
	layer.add_child(view)


func _process(_delta: float) -> void:
	var rig: CutRig = _rigs.rig_for(_arena.rivet.id)
	var phase: PlayerGuardPose.Phase = phase_at(_guard, _arena.tick)
	if rig != null:
		pose(rig, phase)
	position = _arena.rivet.pos * SimConst.PX_PER_M
	if _guard.breaks != _breaks:
		_breaks = _guard.breaks
		_flash_tick = _arena.tick
	visible = _arena.rivet.alive() and (_guard.up() or _guard.meter() < 1.0)
	if visible:
		queue_redraw()


## Advance on arena ticks, including skipped render frames. Reversing partway retraces the lift.
func phase_at(guard: PlayerGuard, tick: int) -> PlayerGuardPose.Phase:
	var elapsed: int = maxi(tick - _last_tick, 0) if _last_tick >= 0 else 1
	_last_tick = tick
	if guard.broken():
		_lift = 0
		return PlayerGuardPose.Phase.STAGGER
	_lift = clampi(_lift + (elapsed if guard.up() else -elapsed), 0, FULL_LIFT)
	if _lift == FULL_LIFT:
		return PlayerGuardPose.Phase.HELD
	if _lift > PHASE_TICKS:
		return PlayerGuardPose.Phase.MID
	return PlayerGuardPose.Phase.LOW if _lift > 0 else PlayerGuardPose.Phase.REST


static func pose(rig: CutRig, phase: PlayerGuardPose.Phase) -> void:
	if rig.dead or rig.clips.rolling() or (rig.react != null and rig.react.dying):
		phase = PlayerGuardPose.Phase.REST
	if RivetFrames.drawn(rig):
		PlayerGuardPose.apply(rig.head_card, ViewMode.shared().art, phase, RivetFrames.oct_of(rig))
	elif phase != PlayerGuardPose.Phase.REST:
		_flat(rig, phase)


static func _flat(rig: CutRig, phase: PlayerGuardPose.Phase) -> void:
	var previous: Vector3 = Vector3(rig.c_tuck, rig.c_hands_up, rig.c_sprawl)
	if phase == PlayerGuardPose.Phase.STAGGER:
		rig.c_sprawl = maxf(rig.c_sprawl, 0.65)
	else:
		var lift: float = (phase + 1.0) / (PlayerGuardPose.Phase.HELD + 1.0)
		rig.c_hands_up = maxf(rig.c_hands_up, lift)
		rig.c_tuck = maxf(rig.c_tuck, 0.45 * lift)
	RigPose.step(rig)
	RigGait.solve_legs(rig)
	if rig.tilt_up != Vector2.ZERO:
		RigTilt.lift_upper(rig)
		RigHeadCard.step(rig)
	rig.c_tuck = previous.x
	rig.c_hands_up = previous.y
	rig.c_sprawl = previous.z


func _draw() -> void:
	var fill: Color = AMBER if _guard.broken() else STEEL
	draw_rect(METER.grow(1.0), INK)
	draw_rect(METER, fill if _guard.broken() else fill.darkened(0.60))
	draw_rect(METER.grow(-1.0), INK)
	var charge: float = roundf((METER.size.x - 2.0) * _guard.meter())
	if charge > 0.0:
		draw_rect(Rect2(METER.position + Vector2.ONE, Vector2(charge, 2.0)), fill)
	var age: int = _arena.tick - _flash_tick
	if age >= 0 and age < FLASH_TICKS:
		_flash(float(age) / FLASH_TICKS)


func _flash(t: float) -> void:
	var facing: float = _arena.rivet.facing.angle()
	var radius: float = lerpf(29.0, 44.0, t)
	var tint: Color = Color(AMBER, 1.0 - t)
	var center: Vector2 = Vector2.ZERO
	var view: ViewMode = ViewMode.shared()
	if not view.is_flat():
		var height: float = RivetFrames.HEIGHT_BY_ART.get(view.art, RivetFrames.HEIGHT_M)
		center.y = (
			-0.45
			* height
			* PlayerScale.k()
			* RivetFrames.height_k
			* CharacterRigs.PX_PER_M
			/ view.ground_k()
		)
	for side: float in [-1.0, 1.0]:
		var angle: float = facing + side * (0.70 + t * 0.40)
		var ray: Vector2 = Vector2.from_angle(angle)
		var at: Vector2 = center + ray * radius
		draw_arc(center, radius, angle - 0.30, angle + 0.30, 8, tint, 3.0, true)
		draw_line(at + ray * 3.0, at + ray * 9.0, tint, 2.0, true)
