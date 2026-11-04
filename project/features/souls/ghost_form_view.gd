class_name GhostFormView
extends Node2D
## ghost-forms: the bound player's ghost form on the live actor layer (the arena's print path, the
## city block, quest 1 on rigs). Reads StagePilot.ghosts (GhostForms) each frame, render-only:
## Tonnage's body (TonnageRig) stands in for Rivet's rig while the form is big (Rivet's CutRig is
## hidden, the held gun with it), unfolding from the in-between pose over the transformation's
## second stage; GhostMorphFx draws the teal burst, seams, steam and sparks over every
## transformation (base <-> form, and the form-to-form teal flash). Kerf, Dent and Ohm show base
## Rivet under the effects until their rigs land.

## The camera beat's share of the print zoom (GhostMorphFx.beat() is 1 + up to BEAT_ZOOM).
const BEAT_ON: bool = true

var pilot: StagePilot = null
var arena: CombatArena = null
var rigs: CharacterRigs = null
var reduced_motion: bool = false
## Set when the host lets the beat move its zoom (1.0 = no beat this frame).
var beat_zoom: float = 1.0
var _tonnage: TonnageRig = TonnageRig.new()
var _fx: GhostMorphFx = GhostMorphFx.new()
var _hidden_rig: CutRig = null
var _last_tick: int = -1


## Adds the view to `layer` for `stage`'s pilot (no pilot = the bot: nothing to show).
static func attach(
	layer: CanvasLayer, stage: CollectCallStage, p_rigs: CharacterRigs
) -> GhostFormView:
	if stage.pilot == null or stage.pilot.ghosts == null:
		return null
	var v: GhostFormView = GhostFormView.new()
	v.pilot = stage.pilot
	v.arena = stage.arena
	v.rigs = p_rigs
	v.reduced_motion = LaunchArgs.has("--reduced-motion")
	v.z_index = p_rigs.z_index + 1 if p_rigs != null else RenderLayers.z(&"actors")
	layer.add_child(v)
	return v


func _ready() -> void:
	process_priority = 20  # after CharacterRigs poses and RivetHeldView feeds the rig
	_tonnage.visible = false
	add_child(_tonnage)
	_fx.reduced_motion = reduced_motion
	add_child(_fx)


## True while the big body (Tonnage) stands in for Rivet.
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
	beat_zoom = _fx.beat() if BEAT_ON and not reduced_motion else 1.0
	_hide_rivet(is_big, r.id)


## Rivet's own rig (and the weapon views riding on it) is hidden while the big body stands in.
func _hide_rivet(hide: bool, rivet_id: int) -> void:
	var rig: CutRig = rigs.rig_for(rivet_id) if rigs != null else null
	if rig != _hidden_rig and _hidden_rig != null:
		_hidden_rig.visible = true
	_hidden_rig = rig
	if rig != null:
		rig.visible = not hide
