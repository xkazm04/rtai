class_name GhostFormView
extends Node2D
## ghost-forms: the bound player's ghost form on the live actor layer (the arena's print path, the
## city block, quest 1 on rigs). Reads StagePilot.ghosts (GhostForms) each frame, render-only:
## Tonnage's body (TonnageRig) stands in for Rivet's rig while the form is big (Rivet's CutRig is
## hidden, the held gun with it), unfolding from the in-between pose over the transformation's
## second stage; GhostMorphFx draws the teal burst, seams, steam and sparks over every
## transformation (base <-> form, and the form-to-form teal flash). Kerf, Dent and Ohm show base
## Rivet under the effects until their rigs land.

## The camera beat at the in-between pose: camera.json shakes (their budget and reduced-motion
## scale), the heavy one when the big body comes or goes.
const BEAT_BIG: StringName = &"crash"
const BEAT_LIGHT: StringName = &"hit"
## The HUD card's canvas layer (above the print and the dev HUD's world layers).
const HUD_LAYER: int = 5

var pilot: StagePilot = null
var arena: CombatArena = null
var rigs: CharacterRigs = null
var reduced_motion: bool = false
## The view's camera (the print stage's or the city view's CameraRig; null = no beat).
var camera: CameraRig = null
var hud: GhostFormHud = GhostFormHud.new()
var beats: int = 0
## false (dev `--no-lurch`): Dent as iteration 2 built him (Rivet's plain cycle, linear filter, no
## soul glow): the A/B before.
var lurch_on: bool = true
var _tonnage: TonnageRig = TonnageRig.new()
var _fx: GhostMorphFx = GhostMorphFx.new()
## Dent's body: a standalone CutRig on DentPlan, fed Rivet's pose (CharacterRigs holds one plan
## per actor kind).
var _dent: CutRig = CutRig.new()
## Dent's stagger: the rig rides a root that rolls and yaws per stride (DentLurch).
var _dent_root: Node2D = Node2D.new()
var _lurch: DentLurch = DentLurch.new()
var _aura: GhostAura = GhostAura.new()
var _last_pos: Vector2 = Vector2.ZERO
var _hidden_rig: CutRig = null
var _last_tick: int = -1
var _last_stage: int = 0


## Adds the view to `layer` for `stage`'s pilot (no pilot = the bot: nothing to show).
static func attach(
	layer: CanvasLayer, stage: CollectCallStage, p_rigs: CharacterRigs, p_camera: CameraRig
) -> GhostFormView:
	if stage.pilot == null or stage.pilot.ghosts == null:
		return null
	var v: GhostFormView = GhostFormView.new()
	v.pilot = stage.pilot
	v.arena = stage.arena
	v.rigs = p_rigs
	v.camera = p_camera
	v.reduced_motion = LaunchArgs.has("--reduced-motion")
	v.lurch_on = not OS.get_cmdline_user_args().has("--no-lurch")  # dev A/B (not a LaunchArgs flag)
	v.z_index = p_rigs.z_index + 1 if p_rigs != null else RenderLayers.z(&"actors")
	layer.add_child(v)
	return v


func _ready() -> void:
	process_priority = 20  # after CharacterRigs poses and RivetHeldView feeds the rig
	_tonnage.visible = false
	add_child(_tonnage)
	_fx.reduced_motion = reduced_motion
	add_child(_fx)
	_dent.visible = false
	if lurch_on:
		_dent.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # raw art at 32 px/m
	add_child(_dent_root)
	_aura.reduced_motion = reduced_motion
	_aura.visible = lurch_on
	_dent_root.add_child(_aura)  # under the body
	_dent_root.add_child(_dent)
	var dent_row: GhostFormDef = pilot.ghosts.forms.table.form(DentStage.GHOST) if pilot else null
	_dent.setup(DentPlan.build(dent_row.size_k if dent_row else 1.05), RigVariant.rivet())
	_aura.radius_px = (dent_row.radius_m if dent_row else 0.45) * SimConst.PX_PER_M
	_dent.reset_state(0.0)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = HUD_LAYER
	add_child(layer)
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	var table: GhostFormTable = pilot.ghosts.forms.table if pilot != null else null
	for id: StringName in table.order if table != null else []:
		var key: String = table.form(id).name_key
		var word: String = tr(key)
		hud.names[id] = word if word != key else String(id).capitalize()


## True while form `big_id`'s body stands in for Rivet (settled, or past the in-between pose).
static func big(forms: GhostForms, big_id: StringName) -> bool:
	if forms.settled():
		return forms.current() == big_id
	var entering: bool = forms.to_id == big_id and forms.stage() == 1
	var leaving: bool = forms.from_id == big_id and forms.stage() == 0
	return entering or leaving


## Tonnage's unfold 0..1 this frame (0 = the in-between pose).
static func unfold_k(forms: GhostForms, big_id: StringName) -> float:
	if forms.settled():
		return 1.0
	var k: float = forms.k()
	if forms.to_id == big_id:
		return clampf((k - 0.5) * 2.0, 0.0, 1.0)
	return clampf(1.0 - k * 2.0, 0.0, 1.0)


func _process(_delta: float) -> void:
	if pilot == null or arena == null:
		return
	var steps: int = clampi(arena.tick - _last_tick, 0, 4) if _last_tick >= 0 else 0
	_last_tick = arena.tick
	var forms: GhostForms = pilot.ghosts.forms
	var r: Fighter = arena.rivet
	var at: Vector2 = r.pos * SimConst.PX_PER_M
	var is_big: bool = big(forms, HaulerStage.GHOST)
	_tonnage.visible = is_big
	_tonnage.position = at
	_tonnage.rotation = r.facing.angle()
	_tonnage.unfold = unfold_k(forms, HaulerStage.GHOST)
	_tonnage.speed_mps = pilot.hauler.form.vel.length() if forms.settled() else 0.0
	_tonnage.advance(steps * SimClock.TICK_DT)  # the gait on sim ticks, not the frame delta
	_fx.position = at
	var with_big: bool = forms.to_id == HaulerStage.GHOST or forms.from_id == HaulerStage.GHOST
	_fx.reach_m = 2.4 if with_big else 1.4
	var busy: bool = not forms.settled()
	_fx.show_progress(busy, forms.k(), forms.stage(), forms.phase == GhostForms.SWITCHING)
	_beat(forms.stage() if busy else 0, with_big)
	hud.sync(forms)
	var is_dent: bool = big(forms, DentStage.GHOST)
	_step_dent(is_dent, at, r.facing.angle(), steps)
	_hide_rivet(is_big or is_dent, r.id)


## Dent's rig at Rivet's pose, posed on whole sim ticks (its gait from Rivet's own travel).
func _step_dent(show: bool, at: Vector2, facing: float, steps: int) -> void:
	if show and not _dent.visible:
		_lurch.reset()
		_place_dent(at, facing)  # before the reset: the rig plants its feet where it stands
		_dent.reset_state(facing)
		_last_pos = at
	_dent.visible = show
	_dent_root.visible = show  # the soul glow goes with the body
	if not show:
		return
	_dent.face_to = facing
	_dent.vel_in = (at - _last_pos) / (maxf(1.0, float(steps)) * SimClock.TICK_DT)
	_last_pos = at
	for i: int in steps if lurch_on else 0:
		_lurch.step(_dent.vel_in.length() / SimConst.PX_PER_M, SimClock.TICK_DT)
	_place_dent(at, facing)
	for i: int in steps:
		_dent.drive(SimClock.TICK_DT)
	_aura.sync(arena.tick, clampf(_dent.vel_in.length() / SimConst.PX_PER_M / 7.0, 0.0, 1.0))


## Dent's root at Rivet's spot, rolled sideways and yawed by the lurch (the rig sits at its origin).
func _place_dent(at: Vector2, facing: float) -> void:
	var side: Vector2 = Vector2.from_angle(facing).orthogonal()
	_dent_root.position = at + side * _lurch.sway_m() * SimConst.PX_PER_M
	_dent_root.rotation = _lurch.yaw()
	_dent.position = Vector2.ZERO


## One camera shake as the transformation passes its in-between pose.
func _beat(stage: int, with_big: bool) -> void:
	if stage == 1 and _last_stage == 0 and camera != null:
		camera.kick(BEAT_BIG if with_big else BEAT_LIGHT, arena.tick)
		beats += 1
	_last_stage = stage


## Rivet's own rig (and the weapon views riding on it) is hidden while the big body stands in.
func _hide_rivet(hide: bool, rivet_id: int) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	if rig != _hidden_rig and _hidden_rig != null:
		_hidden_rig.visible = true
	_hidden_rig = rig
	if rig != null:
		rig.visible = not hide
	for n: Node in get_parent().get_children():  # the claw's weapon and magazine views
		if n is RivetHeldView or n is WeaponMagView:
			(n as CanvasItem).visible = not hide
