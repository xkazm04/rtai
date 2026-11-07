class_name CityFxFeed
extends RefCounted
## The riot's FX straight from the sim, render side (fx_triggers.json `sim` cues): each observed
## snapshot is diffed against the last one. A projectile slot that appears is a `shot` (fired one
## observe later, once its heading is known, at its first position), one that disappears is a
## `projectile_end` at its last position (thrown back along the heading), a person whose mode
## turns dead is a `death` under the body. A slot that jumped more than REBIRTH_M between two
## observes was re-fired. Reads the snapshot the rigs already take; writes no sim state, so
## parity and replay are untouched and no positional event is needed.

const REBIRTH_M: float = 4.0
const PENDING: int = 1
const FLYING: int = 2

## The last snapshot observed (CityOcclusion's crowd reads it instead of taking a second one).
var last_snap: PackedFloat64Array = PackedFloat64Array()
var triggers: FxTriggers
## The car lights (night), fed the same snapshot; null = none.
var headlights: CityHeadlights = null
var _q: PackedVector2Array = PackedVector2Array()
var _heading: PackedFloat32Array = PackedFloat32Array()
var _state: PackedByteArray = PackedByteArray()
var _seen: PackedByteArray = PackedByteArray()
var _dead: PackedByteArray = PackedByteArray()
## Slots whose _state is not 0 (the end pass walks these, not all PCAP slots).
var _active: PackedInt32Array = PackedInt32Array()
var _primed: bool = false


func _init(t: FxTriggers) -> void:
	triggers = t
	@warning_ignore("return_value_discarded")
	_q.resize(SimConst.PCAP)
	@warning_ignore("return_value_discarded")
	_heading.resize(SimConst.PCAP)
	@warning_ignore("return_value_discarded")
	_state.resize(SimConst.PCAP)
	@warning_ignore("return_value_discarded")
	_seen.resize(SimConst.PCAP)
	@warning_ignore("return_value_discarded")
	_dead.resize(SimConst.CAP)


## Diffs `snap` (CitySimBackend.snapshot(): actor records, then projectile records) at `tick`.
## The first observe only primes: nothing already flying or dead fires.
func observe(snap: PackedFloat64Array, tick: int) -> void:
	last_snap = snap
	_seen.fill(0)
	var n: int = snap.size()
	var r: int = 0
	while r + SimConst.SNAP_STRIDE <= n and snap[r] < SimConst.SNAP_PROJ_BASE:
		var i: int = int(snap[r])
		var kind: int = int(snap[r + 1])
		if i >= 0 and i < SimConst.CAP and (kind == SimConst.K_PED or kind == SimConst.K_COP):
			if (int(snap[r + 2]) == SimConst.M_DEAD) != (_dead[i] != 0):
				_person(snap, r, i, tick)  # only on a change: the call is the cost per person
		r += SimConst.SNAP_STRIDE
	while r + SimConst.SNAP_PROJ_STRIDE <= n:
		var k: int = int(snap[r]) - SimConst.SNAP_PROJ_BASE
		if k >= 0 and k < SimConst.PCAP:
			_shot(k, Vector2(snap[r + 1], snap[r + 2]), tick)
		r += SimConst.SNAP_PROJ_STRIDE
	_end_unseen(tick)
	_primed = true
	if headlights != null:
		headlights.observe(snap, triggers.focus_px / SimConst.PX_PER_M, tick)


## Person `i` (record at `r`) turned dead or back: a death fires once, after the first observe.
func _person(snap: PackedFloat64Array, r: int, i: int, tick: int) -> void:
	var dead: bool = int(snap[r + 2]) == SimConst.M_DEAD
	if dead and _primed:
		var at: Vector2 = Vector2(snap[r + 4], snap[r + 5]) * SimConst.PX_PER_M
		triggers.fire(&"death", at, atan2(snap[r + 7], snap[r + 6]), tick)
	_dead[i] = 1 if dead else 0


## Ends every live slot this snapshot did not carry, in slot order (as the full sweep did).
func _end_unseen(tick: int) -> void:
	_active.sort()
	var keep: int = 0
	for k: int in _active:
		if _seen[k] == 0:
			_end(k, tick)
		if _state[k] != 0:
			_active[keep] = k
			keep += 1
	@warning_ignore("return_value_discarded")
	_active.resize(keep)


func _shot(k: int, p: Vector2, tick: int) -> void:
	_seen[k] = 1
	if _state[k] == 0:
		@warning_ignore("return_value_discarded")
		_active.append(k)
		_q[k] = p
		_state[k] = PENDING if _primed else FLYING
		return
	var d: Vector2 = p - _q[k]
	if d.length_squared() > REBIRTH_M * REBIRTH_M:
		_end(k, tick)
		_q[k] = p
		_state[k] = PENDING
		return
	if d.length_squared() > 0.0:
		_heading[k] = d.angle()
	if _state[k] == PENDING:
		triggers.fire(&"shot", _q[k] * SimConst.PX_PER_M, _heading[k], tick)
		_state[k] = FLYING
	_q[k] = p


func _end(k: int, tick: int) -> void:
	if _state[k] == FLYING:
		triggers.fire(&"projectile_end", _q[k] * SimConst.PX_PER_M, _heading[k] + PI, tick)
	_state[k] = 0
