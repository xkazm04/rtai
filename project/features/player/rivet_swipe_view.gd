class_name RivetSwipeView
extends Node2D
## n11 (the owner's "melee attack follows always only one direction"): the arc of a strike whose
## drawn cell cannot show it (RivetSwipe.needs_arc): one tapered ink-edged crescent trailing the
## swing's lead angle about the aim (RivetHeldView's MeleeSwing), at gun height, thin at both ends
## like the arcs the strike cells draw. A child of RivetHeldView (its z, its process order); away
## from the camera it draws under his figure, otherwise over it. Render only.

const ARM_MIN_M: float = 1.1
const REACH_MAX_M: float = 1.35
## Angles kept in the trail, the frames the finished arc lingers fading, the polygon's steps.
const KEEP: int = 4
const LINGER: int = 6
const STEPS: int = 16
## The crescent's width at its middle (a share of the reach) and its ink edge (px).
const THICK: float = 0.1
const EDGE_PX: float = 2.0
const CREAM: Color = Color(0.98, 0.95, 0.84, 1.0)
const MIN_SPAN: float = 0.1

var _rigs: CharacterRigs = null
var _pilot: StagePilot = null
var _rivet_id: int = 0
var _angles: PackedFloat32Array = PackedFloat32Array()
var _after: int = 0
var _root: Vector2 = Vector2.ZERO
var _r: float = 0.0


static func make(rigs: CharacterRigs, pilot: StagePilot, rivet_id: int) -> RivetSwipeView:
	var v: RivetSwipeView = RivetSwipeView.new()
	v._rigs = rigs
	v._pilot = pilot
	v._rivet_id = rivet_id
	return v


func _ready() -> void:
	process_priority = 12  # after the held view fed this frame


func _process(_frame: float) -> void:
	var rig: CutRig = _rigs.rig_for(_rivet_id) if _rigs != null and _pilot != null else null
	if rig == null or rig.head_card == null:
		return
	var o: int = RivetFrames.oct_of(rig)
	var on: bool = RivetSwipe.needs_arc(rig, o)
	on = on and MeleeSwing.cutting(rig.clips.strike_t, rig.clips.strike_ph)
	z_index = rig.plan.head_z - 1 - _z_over_rigs() if o >= 5 else 0
	_root = to_local(rig.global_position + ShotLift.up_m() * SimConst.PX_PER_M)
	_r = clampf(_reach_m(), ARM_MIN_M, REACH_MAX_M) * SimConst.PX_PER_M
	if on:
		_after = 0
		var a: float = rig.face_to + _sweep(rig) - global_rotation
		if not _angles.is_empty():  # one sweep, not the long way round when the aim crosses +-PI
			a = _angles[_angles.size() - 1] + wrapf(a - _angles[_angles.size() - 1], -PI, PI)
		@warning_ignore("return_value_discarded")
		_angles.append(a)
		if _angles.size() > KEEP:
			_angles.remove_at(0)
	elif not _angles.is_empty():
		_after += 1
		if _after > LINGER:
			_angles.clear()
	queue_redraw()


func _draw() -> void:
	if _angles.size() < 2:
		return
	var a0: float = _angles[0]
	var a1: float = _angles[_angles.size() - 1]
	if absf(a1 - a0) < MIN_SPAN:
		return
	var fade: float = clampf(1.6 - float(_after) / float(LINGER + 1) * 1.6, 0.0, 1.0)
	var outer: PackedVector2Array = PackedVector2Array()
	var inner: PackedVector2Array = PackedVector2Array()
	for s: int in STEPS + 1:
		var t: float = float(s) / STEPS
		var a: float = lerpf(a0, a1, t)
		var taper: float = sin(PI * t)
		@warning_ignore("return_value_discarded")
		outer.append(_root + Vector2.from_angle(a) * _r * (1.0 + 0.04 * taper))
		@warning_ignore("return_value_discarded")
		inner.append(_root + Vector2.from_angle(a) * _r * (1.0 - THICK * taper))
	var band: PackedVector2Array = outer.duplicate()
	inner.reverse()
	band.append_array(inner)
	if not Geometry2D.triangulate_polygon(band).is_empty():
		draw_colored_polygon(band, Color(CREAM, CREAM.a * fade))
	draw_polyline(outer, Color(Ink.INK, fade), EDGE_PX, true)


func _sweep(rig: CutRig) -> float:
	var c: MeleeCombo = _pilot.melee.combo
	var side: float = 1.0 if c.last_index % 2 == 1 else -1.0
	var h: MeleeHit = _hit()
	var arc: float = (
		maxf(RivetHeldView.SWEEP_MIN, acos(clampf(h.cone_dot, -1.0, 1.0))) if h else 1.0
	)
	return MeleeSwing.angle(rig.clips.strike_t, rig.clips.strike_ph, side, arc)


func _reach_m() -> float:
	var h: MeleeHit = _hit()
	return h.reach_m if h != null else ARM_MIN_M


## The current hit, or the one that just ended (its follow-through still draws).
func _hit() -> MeleeHit:
	var c: MeleeCombo = _pilot.melee.combo
	if c.current() != null:
		return c.current()
	var i: int = c.last_index
	return c.table.hits[i - 1] if i > 0 and i <= c.table.hits.size() else null


func _z_over_rigs() -> int:
	return (get_parent() as Node2D).z_index - _rigs.z_index
