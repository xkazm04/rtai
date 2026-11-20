class_name DentTether
extends RefCounted
## Both spectral looks share the roof, heat pulse, release clock and last held hand offsets.

var strap: DentStrap = DentStrap.new(HaulerLook.TEAL, VehicleView.CAR_H_M)
var strings: DentStrings
var _canvas: DentStrapCanvas
var _group: StringName
var _body: DentBody
var _form: GhostFormDef
var _offsets: PackedVector2Array = [Vector2.ZERO, Vector2.ZERO]


func _init(view: DentView) -> void:
	_canvas = DentStrapCanvas.new(view)
	_group = DentBody.group_for(view.dent)
	_form = view.stage.pilot.ghosts.forms.table.form(DentStage.GHOST)
	if strap.look.resolved() == "strings":
		strings = DentStrings.new(strap)


func paint(view: DentView) -> void:
	var vm: ViewMode = ViewMode.shared()
	var rivet: Fighter = view.stage.arena.rivet
	var at: Vector2 = rivet.pos * view.ppm
	if strap.held:
		if not is_instance_valid(_body):
			_body = view.get_tree().get_first_node_in_group(_group) as DentBody
		_offsets[1] = _offset(view, 1, at, vm)
		if strings != null:
			_offsets[0] = _offset(view, 0, at, vm)
	strap.place(at + _offsets[1], view.ppm, view.reduced_motion, vm)
	var heat: float = view.dent.heat
	var arm: float = view.dent.num(&"arm_k")
	var warmth: float = smoothstep(0.0, arm, heat)
	var pulse: float = 0.5
	if not view.reduced_motion:
		pulse += 0.5 * sin(view.stage.tick * (0.52 if heat >= arm else 0.18))
	var fill: Color = strap.fill_at(heat).lerp(DentStrap.AMBER, warmth * (0.4 + 0.3 * pulse))
	if strings != null:
		var turn: float = _body.steer.turn if is_instance_valid(_body) and _body.steer else 0.0
		strings.place(at + _offsets[0], turn, view.dent.strikes, vm)
		strings.paint(_canvas, fill)
	else:
		var stripe: Color = DentStrap.AQUA.lerp(
			DentStrap.AMBER.lerp(DentView.HOT, pulse * 0.6), warmth
		)
		strap.paint(_canvas, fill, stripe)


func _offset(view: DentView, index: int, at: Vector2, vm: ViewMode) -> Vector2:
	if _body != null:
		var hand: Vector2 = _body.grip_world() if strings == null else _body.string_grip(index)
		if hand.is_finite():
			return view.to_local(hand) - at
	var anchor: Vector2 = _form.anchor(&"hand_r" if index else &"hand_l")
	return (
		(
			anchor.rotated(view.stage.arena.rivet.facing.angle())
			+ vm.lift_px(strap.look.hand_height_m) / SimConst.PX_PER_M
		)
		* view.ppm
	)
