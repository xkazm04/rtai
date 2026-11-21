class_name PlayerGuardView
extends Node2D
## The live guard's articulated forearms, charge at his feet and flash on the break tick.

const STEEL: Color = Color("#b8c1c9")
const AMBER: Color = Color("#ffc15b")
const INK: Color = Color("#171920")
const FLASH_TICKS: int = 12
const METER: Rect2 = Rect2(-12, 15, 24, 4)

var _guard: PlayerGuard
var _arena: CombatArena
var _rigs: CharacterRigs
var _breaks: int
var _flash_tick: int = -FLASH_TICKS


static func attach(layer: CanvasLayer, stage: CollectCallStage, rigs: CharacterRigs) -> void:
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
	if rig != null:
		pose(rig, _guard.up())
	position = _arena.rivet.pos * SimConst.PX_PER_M
	if _guard.breaks != _breaks:
		_breaks = _guard.breaks
		_flash_tick = _arena.tick
	visible = _arena.rivet.alive() and (_guard.up() or _guard.meter() < 1.0)
	if visible:
		queue_redraw()


static func pose(rig: CutRig, raised: bool) -> void:
	if RivetFrames.drawn(rig):
		_pitched(rig, raised)
		return
	if not raised:
		return
	var previous: float = rig.c_hands_up
	rig.c_hands_up = 1.0
	RigPose.solve_arms(rig)
	rig.c_hands_up = previous


static func _pitched(rig: CutRig, raised: bool) -> void:
	var card: Sprite2D = rig.head_card
	var art: String = ViewMode.shared().art
	var guard_pose: PlayerGuardPose = PlayerGuardPose.for_card(card, art, raised)
	if guard_pose == null:
		return
	var path: String = RivetStrips.DIR + art + "/" + RivetStrips.BASE
	if guard_pose.art_id != art:
		guard_pose.strip(
			art, StreetStrips.get_tex(path), RivetFrames.BASE_CELLS, RivetStrips.foot_px(path)
		)
	var octant: int = RivetFrames.oct_of(rig)
	var height: float = RivetFrames.HEIGHT_BY_ART.get(art, RivetFrames.HEIGHT_M)
	var scale_px: float = height * RivetFrames.height_k * PlayerScale.k() * CharacterRigs.PX_PER_M
	scale_px /= RivetFrames.FIG_PX * RivetRes.of(path)
	var stride: float = sin(TAU * rig.phase) * clampf(rig.speed_now / CutRig.WALK_SPEED, 0.0, 1.0)
	guard_pose.face(
		RigHeadCard.OCT_FRAME[octant],
		RigHeadCard.OCT_FLIP[octant] == 1,
		scale_px,
		stride,
		card.global_position
	)


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
