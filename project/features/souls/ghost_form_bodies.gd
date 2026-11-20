class_name GhostFormBodies
extends RefCounted
## Presentation of the four bodies owned by GhostFormView. Attack and morph inputs are shared by
## both looks. Only the host transform and the locomotion inputs differ for spectral bodies.

var tonnage: TonnageRig = TonnageRig.new()
var dent: DentBody = DentBody.new()
var kerf: KerfRig = KerfRig.new()
var ohm: OhmRig = OhmRig.new()
var _light_last: Dictionary[StringName, Vector2] = {}
var _carried_rig: CutRig


func attach(host: GhostFormView, fx: GhostMorphFx) -> void:
	PlayerScale.fit([tonnage, kerf, ohm])
	_attach_body(host, tonnage, tonnage.drawn, HaulerStage.GHOST)
	_attach_body(host, kerf, kerf.drawn, KerfStage.GHOST)
	_attach_body(host, ohm, ohm.drawn, OhmStage.GHOST)
	fx.reduced_motion = host.reduced_motion
	host.add_child(fx)
	dent.lurch_on = host.lurch_on
	dent.reduced_motion = host.reduced_motion
	ohm.reduced_motion = host.reduced_motion
	_attach_body(host, dent, dent.drawn, DentStage.GHOST)


func setup_dent(row: GhostFormDef) -> void:
	dent.setup(row)
	if dent.drawn.hover:
		for child: Node in dent.get_children():
			if child is CutRig:
				_carried_rig = child as CutRig
				break


func wash() -> void:
	var m: ShaderMaterial = GhostApparition.ghost_material(false, 0.0)
	for body: Node in [tonnage, kerf, ohm, dent]:
		GhostApparition.wash(body, m, GhostApparition.ghost_material(true, 0.0))


func step_tonnage(p: StagePilot, at: Vector2, facing: float, steps: int) -> bool:
	var forms: GhostForms = p.ghosts.forms
	var shown: bool = GhostFormView.big(forms, HaulerStage.GHOST)
	tonnage.visible = shown
	tonnage.position = _spot(tonnage.drawn, at, facing, steps, shown)
	tonnage.rotation = facing
	tonnage.unfold = GhostFormView.unfold_k(forms, HaulerStage.GHOST)
	tonnage.speed_mps = (
		p.hauler.form.vel.length() if forms.settled() and not tonnage.drawn.hover else 0.0
	)
	tonnage.hauler = p.hauler  # n20-tonnage: the spectral body reads the slam and ram state
	tonnage.advance(steps * SimClock.TICK_DT)
	return shown


func step_dent(p: StagePilot, at: Vector2, facing: float, steps: int, tick: int) -> bool:
	var shown: bool = GhostFormView.big(p.ghosts.forms, DentStage.GHOST)
	dent.riding = p.dent.riding()
	dent.strikes = p.dent.strikes
	dent.blasts = p.dent.blasts
	dent.step(shown, _dent_spot(at, facing, steps, shown), facing, steps, tick)
	return shown


## The standing IK stores both feet in world space. Carry those anchors with the flight mount
## so a moving body never asks its stationary gait to take a catch-up step.
func _dent_spot(at: Vector2, facing: float, steps: int, shown: bool) -> Vector2:
	if _carried_rig == null or steps <= 0 or not shown or not dent.visible:
		return _spot(dent.drawn, at, facing, steps, shown)
	var before: Transform2D = _carried_rig.global_transform
	var spot: Vector2 = _spot(dent.drawn, at, facing, steps, shown)
	# The flight already supplies yaw lag. Carry the feet through the rig's own turn as well.
	_carried_rig.snap_facing(facing)
	var travel: Transform2D = _carried_rig.global_transform * before.affine_inverse()
	for side: RigLimbs in _carried_rig.sides:
		side.foot_w = travel * side.foot_w
		side.foot_from = travel * side.foot_from
	return spot


func step_light(rig: Node2D, forms: GhostForms, at: Vector2, facing: float, steps: int) -> bool:
	var id: StringName = KerfStage.GHOST if rig == kerf else OhmStage.GHOST
	var drawn: GhostDrawn = kerf.drawn if rig == kerf else ohm.drawn
	var shown: bool = GhostFormView.big(forms, id)
	rig.visible = shown
	var last: Vector2 = _light_last.get(id, at)
	_light_last[id] = at
	var spot: Vector2 = _spot(drawn, at, facing, steps, shown)
	if not shown:
		return false
	rig.position = spot
	rig.rotation = facing
	rig.set(&"unfold", GhostFormView.unfold_k(forms, id))
	var dt: float = maxf(1.0, float(steps)) * SimClock.TICK_DT
	var speed: float = minf(20.0, at.distance_to(last) / SimConst.PX_PER_M / dt)
	rig.set(&"speed_mps", 0.0 if drawn.hover else speed)
	rig.call(&"advance", steps * SimClock.TICK_DT)
	return true


func feed(pilot: StagePilot, rivet: Fighter, tick: int) -> void:
	var drawn: Array[GhostDrawn] = [tonnage.drawn, dent.drawn, kerf.drawn, ohm.drawn]
	GhostActs.feed(drawn, pilot, rivet, tick)


func _spot(drawn: GhostDrawn, at: Vector2, facing: float, steps: int, shown: bool) -> Vector2:
	if drawn.flight == null:
		return at
	drawn.flight.visible = shown
	drawn.flight.step(at, facing, steps)
	return Vector2.ZERO


static func _attach_body(parent: Node2D, body: Node2D, drawn: GhostDrawn, id: StringName) -> void:
	body.visible = false
	if GhostLook.spectral(id):
		drawn.flight = GhostFlight.make(id)
		if drawn.flight != null:
			drawn.hover = true
			drawn.flight.visible = false
			parent.add_child(drawn.flight)
			drawn.flight.mount(body)
			return
		Log.warn("ghost_flight", "missing hover row for %s, keeping its ground rig" % id)
	parent.add_child(body)
