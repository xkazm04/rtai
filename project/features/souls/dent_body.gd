class_name DentBody
extends Node2D
## ghost-forms: Dent's stand-in body for GhostFormView. A standalone CutRig on DentPlan
## (CharacterRigs holds one plan per actor kind) fed Rivet's pose on whole sim ticks, riding a root
## that rolls and yaws per stride (DentLurch), over the breathing teal soul pool (GhostAura).
## Render-only.

## false (dev `--no-lurch`): Dent as iteration 2 built him (Rivet's plain cycle, linear filter, no
## soul glow): the A/B before.
var lurch_on: bool = true
var reduced_motion: bool = false
var _rig: CutRig = CutRig.new()
var _lurch: DentLurch = DentLurch.new()
var _aura: GhostAura = GhostAura.new()
var _last_pos: Vector2 = Vector2.ZERO


## Builds the rig for Dent's form row (null = the plan's defaults).
func setup(row: GhostFormDef) -> void:
	visible = false
	if lurch_on:
		_rig.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # raw art at 32 px/m
	_aura.reduced_motion = reduced_motion
	_aura.visible = lurch_on
	add_child(_aura)  # under the body
	add_child(_rig)
	_rig.setup(DentPlan.build(row.size_k if row else 1.05), RigVariant.rivet())
	_aura.radius_px = (row.radius_m if row else 0.45) * SimConst.PX_PER_M
	_rig.reset_state(0.0)


## One frame: shown or not, at Rivet's spot `at` (px) facing `facing`, `steps` sim ticks since
## the last frame (the gait from Rivet's own travel), `tick` for the glow's breath.
func step(show: bool, at: Vector2, facing: float, steps: int, tick: int) -> void:
	if show and not visible:
		_lurch.reset()
		_place(at, facing)  # before the reset: the rig plants its feet where it stands
		_rig.reset_state(facing)
		_last_pos = at
	visible = show  # the soul glow goes with the body
	if not show:
		return
	_rig.face_to = facing
	_rig.vel_in = (at - _last_pos) / (maxf(1.0, float(steps)) * SimClock.TICK_DT)
	_last_pos = at
	for i: int in steps if lurch_on else 0:
		_lurch.step(_rig.vel_in.length() / SimConst.PX_PER_M, SimClock.TICK_DT)
	_place(at, facing)
	for i: int in steps:
		_rig.drive(SimClock.TICK_DT)
	_aura.sync(tick, clampf(_rig.vel_in.length() / SimConst.PX_PER_M / 7.0, 0.0, 1.0))


## The root at Rivet's spot, rolled sideways and yawed by the lurch (the rig sits at its origin).
func _place(at: Vector2, facing: float) -> void:
	var side: Vector2 = Vector2.from_angle(facing).orthogonal()
	position = at + side * _lurch.sway_m() * SimConst.PX_PER_M
	rotation = _lurch.yaw()
	_rig.position = Vector2.ZERO
