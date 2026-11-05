class_name GhostApparition
extends Node2D
## ghost-forms: a ghost speaking (the voice moments): the ghost's own body (its form rig) beside
## Rivet, at his left shoulder and turned in to him, every part washed teal through
## ghost_apparition.gdshader (its rims a pale-teal glow edge), with a thin teal tether to Rivet. It
## flickers in, hovers while the voice speaks, and fades out. Cued by the stage's whispers_spiked
## while Rivet is in base (the selected ghost speaks; in a form the ghost IS Rivet, so no
## apparition), or every `dev_every` ticks (dev `--apparition`). Render-only, stepped on sim ticks.

const SHADER: Shader = preload("res://features/souls/ghost_apparition.gdshader")
const TEAL_HI: Color = GhostMorphFx.TEAL_HI
const FADE_IN: int = 18
const HOLD: int = 150
const FADE_OUT: int = 36
const ALPHA: float = 0.8
## Beside Rivet: to his left (m), a little behind, turned in to face past him.
const SIDE_M: float = 1.45
const BACK_M: float = 0.35
const TURN_IN: float = deg_to_rad(20.0)
## Tonnage's apparition is a voice, not the 3x body: drawn at this scale, a little further out.
const BIG_K: float = 0.6
const BIG_SIDE_M: float = 2.1

var reduced_motion: bool = false
## > 0 (dev `--apparition`): a ghost speaks every this many ticks, the four in table order.
var dev_every: int = 0
var id: StringName = &""
var _age: int = -1
var _hold: int = HOLD
var _forms: GhostForms = null
var _rigs: Dictionary[StringName, Node2D] = {}
var _dent: DentBody = DentBody.new()
var _tether: Line2D = Line2D.new()
var _dev_slot: int = -1
var _mat: ShaderMaterial = ghost_material(false, 0.2)
var _rim_mat: ShaderMaterial = ghost_material(true, 0.2)


## Builds the four bodies; `events` (may be null) cues the voices.
func bind(forms: GhostForms, events: EventBus) -> void:
	_forms = forms
	visible = false
	_tether.width = 2.0
	_tether.default_color = TEAL_HI
	add_child(_tether)
	_rigs[HaulerStage.GHOST] = TonnageRig.new()
	_rigs[KerfStage.GHOST] = KerfRig.new()
	_rigs[OhmStage.GHOST] = OhmRig.new()
	for rig: Node2D in _rigs.values():
		rig.visible = false
		add_child(rig)
	_dent.reduced_motion = reduced_motion
	add_child(_dent)
	_dent.setup(forms.table.form(DentStage.GHOST) if forms != null else null)
	_rigs[DentStage.GHOST] = _dent
	if events != null:
		@warning_ignore("return_value_discarded")
		events.whispers_spiked.connect(_on_whispers)


## Ghost `p_id` speaks for `hold` ticks (restarts a voice already showing).
func say(p_id: StringName, hold: int = HOLD) -> void:
	if not _rigs.has(p_id):
		return
	id = p_id
	_hold = hold
	_age = 0
	Log.info("souls", "ghost voice: %s beside Rivet" % p_id)
	wash(self, _mat, _rim_mat)


## Every part under `n` draws through `mat` (the ghost material), its sticker rims through
## `rim_mat` (the glow-edge variant). Parts a rig adds later are not covered: re-run (each voice).
static func wash(n: Node, mat: ShaderMaterial, rim_mat: ShaderMaterial) -> void:
	for c: Node in n.get_children():
		if c is CanvasItem:
			(c as CanvasItem).material = rim_mat if c.name == RigBuild.HALO else mat
		wash(c, mat, rim_mat)


## The ghost material (`rim` = the glow-edge variant for the sticker rims), `bands` scan-band depth.
static func ghost_material(rim: bool, bands: float) -> ShaderMaterial:
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter(&"silhouette", 1.0 if rim else 0.0)
	m.set_shader_parameter(&"band_k", bands)
	return m


func speaking() -> bool:
	return _age >= 0


## Alpha 0..1 at `age` ticks into a voice held `hold` ticks (in, hold, out; 0 when done).
static func envelope(age: int, hold: int) -> float:
	if age < 0:
		return 0.0
	if age < FADE_IN:
		return float(age) / FADE_IN
	if age < FADE_IN + hold:
		return 1.0
	return clampf(1.0 - float(age - FADE_IN - hold) / FADE_OUT, 0.0, 1.0)


## One frame: Rivet at `at` (px) facing `facing`, `steps` sim ticks since the last frame.
func step(at: Vector2, facing: float, steps: int, tick: int) -> void:
	_dev_cue(tick)
	if _age >= 0:
		_age += steps
		if _age >= FADE_IN + _hold + FADE_OUT:
			_age = -1
	visible = _age >= 0
	for key: StringName in _rigs:
		if key != id or not visible:
			_rigs[key].visible = false
	if not visible:
		return
	_pose(at, facing, steps, tick)


func _pose(at: Vector2, facing: float, steps: int, tick: int) -> void:
	var big: bool = id == HaulerStage.GHOST
	var fwd: Vector2 = Vector2.from_angle(facing)
	var side_m: float = BIG_SIDE_M if big else SIDE_M
	var drift: float = 0.0 if reduced_motion else sin(_age * 0.045) * 0.08
	var spot: Vector2 = (
		at + (fwd.orthogonal() * (side_m + drift) - fwd * BACK_M) * SimConst.PX_PER_M
	)
	var pop: float = 1.0 if reduced_motion else lerpf(0.88, 1.0, minf(1.0, _age / float(FADE_IN)))
	var rig: Node2D = _rigs[id]
	if rig == _dent:
		_dent.step(true, spot, facing + TURN_IN, steps, tick)
	else:
		rig.visible = true
		rig.position = spot
		rig.rotation = facing + TURN_IN
		rig.set(&"unfold", 1.0)
		rig.set(&"speed_mps", 0.0)
		rig.call(&"advance", steps * SimClock.TICK_DT)
	rig.scale = Vector2.ONE * (BIG_K if big else 1.0) * pop
	var mid: Vector2 = (at + spot) * 0.5 + fwd * (0.0 if reduced_motion else sin(tick * 0.11) * 6.0)
	_tether.points = PackedVector2Array([at, mid, spot])
	var flick: float = 0.35 if not reduced_motion and _age >= 4 and _age < 8 else 1.0
	modulate = Color(1.0, 1.0, 1.0, ALPHA * envelope(_age, _hold) * flick)
	var band: float = 0.0 if reduced_motion else tick * 0.02
	_mat.set_shader_parameter(&"band_phase", band)
	_rim_mat.set_shader_parameter(&"band_phase", band)


func _dev_cue(tick: int) -> void:
	if dev_every <= 0 or _forms == null or _forms.table.order.is_empty():
		return
	@warning_ignore("integer_division")
	var slot: int = tick / dev_every
	if slot != _dev_slot and _forms.from_id == GhostForms.BASE and _forms.settled():
		_dev_slot = slot
		say(_forms.table.order[slot % _forms.table.order.size()])


func _on_whispers() -> void:
	if _forms != null and _forms.from_id == GhostForms.BASE and _forms.settled():
		say(_forms.selected)
