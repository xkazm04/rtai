class_name GhostFormView
extends Node2D
## ghost-forms: the bound player's ghost form on the live actor layer (the arena's print path, the
## city block, quest 1 on rigs). Reads StagePilot.ghosts (GhostForms) each frame, render-only:
## Tonnage's body (TonnageRig) stands in for Rivet's rig while the form is big (Rivet's CutRig is
## hidden, the held gun with it), unfolding from the in-between pose over the transformation's
## second stage; GhostMorphFx draws the teal burst, seams, steam and sparks over every
## transformation (base <-> form, and the form-to-form teal flash). Dent (DentBody) and Kerf
## (KerfRig) and Ohm (OhmRig) stand in the same way.

## The camera beat at the in-between pose: camera.json shakes (their budget and reduced-motion
## scale), the heavy one when the big body comes or goes.
const BEAT_BIG: StringName = &"crash"
const BEAT_LIGHT: StringName = &"hit"
## The HUD card's canvas layer (above the print and the dev HUD's world layers).
const HUD_LAYER: int = 5
## Above every rig part (rigs stack their parts' own z offsets; the held gun uses the same 60), so
## no human's head or arm draws over a ghost body; still inside the actors band (vehicles at +100).
const Z_OVER_RIGS: int = 60

var pilot: StagePilot = null
var arena: CombatArena = null
var rigs: CharacterRigs = null
var reduced_motion: bool = false
## The view's camera (the print stage's or the city view's CameraRig; null = no beat).
var camera: CameraRig = null
var hud: GhostFormHud = GhostFormHud.new()
## The voice moments: a ghost's teal apparition beside Rivet (cued by `events`' whispers).
var appear: GhostApparition = GhostApparition.new()
var events: EventBus = null
var beats: int = 0
## false (dev `--no-lurch`): Dent as iteration 2 built him (Rivet's plain cycle, linear filter, no
## soul glow): the A/B before.
var lurch_on: bool = true
var _tonnage: TonnageRig = TonnageRig.new()
var _kerf: KerfRig = KerfRig.new()
var _ohm: OhmRig = OhmRig.new()
## The hover/cane rigs' last spot (px), for their ground speed.
var _light_last: Dictionary[StringName, Vector2] = {}
var _fx: GhostMorphFx = GhostMorphFx.new()
var _dent: DentBody = DentBody.new()
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
	v.events = stage.events()
	if OS.get_cmdline_user_args().has("--apparition"):  # dev: a ghost speaks every 4 s
		v.appear.dev_every = 240
	v.lurch_on = not OS.get_cmdline_user_args().has("--no-lurch")  # dev A/B (not a LaunchArgs flag)
	GhostRim.enabled = not OS.get_cmdline_user_args().has("--no-rim")  # dev A/B
	v.z_index = (p_rigs.z_index if p_rigs != null else RenderLayers.z(&"actors")) + Z_OVER_RIGS
	layer.add_child(v)
	return v


func _ready() -> void:
	process_priority = 20  # after CharacterRigs poses and RivetHeldView feeds the rig
	_tonnage.visible = false
	add_child(_tonnage)
	for light: Node2D in [_kerf, _ohm]:
		light.visible = false
		add_child(light)
	_fx.reduced_motion = reduced_motion
	add_child(_fx)
	_dent.lurch_on = lurch_on
	_dent.reduced_motion = reduced_motion
	add_child(_dent)
	appear.reduced_motion = reduced_motion
	add_child(appear)
	appear.bind(pilot.ghosts.forms if pilot else null, events)
	_dent.setup(pilot.ghosts.forms.table.form(DentStage.GHOST) if pilot else null)
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
	_dent.step(is_dent, at, r.facing.angle(), steps, arena.tick)
	var is_kerf: bool = _step_light(_kerf, KerfStage.GHOST, at, r.facing.angle(), steps)
	var is_ohm: bool = _step_light(_ohm, OhmStage.GHOST, at, r.facing.angle(), steps)
	appear.step(at, r.facing.angle(), steps, arena.tick)
	_hide_rivet(is_big or is_dent or is_kerf or is_ohm, r.id)


## Kerf's hover rig or Ohm's cane rig at Rivet's pose (snaps with Kerf's blink: no tween),
## unfolding with the morph; `rig` has unfold, speed_mps and advance(dt). True while it shows.
func _step_light(rig: Node2D, id: StringName, at: Vector2, facing: float, steps: int) -> bool:
	var show: bool = big(pilot.ghosts.forms, id)
	rig.visible = show
	var last: Vector2 = _light_last.get(id, at)
	_light_last[id] = at
	if not show:
		return false
	rig.position = at
	rig.rotation = facing
	rig.set(&"unfold", unfold_k(pilot.ghosts.forms, id))
	var dt: float = maxf(1.0, float(steps)) * SimClock.TICK_DT
	rig.set(&"speed_mps", minf(20.0, at.distance_to(last) / SimConst.PX_PER_M / dt))
	rig.call(&"advance", steps * SimClock.TICK_DT)
	return true


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
