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

var triggers: FxTriggers
var _q: PackedVector2Array = PackedVector2Array()
var _heading: PackedFloat32Array = PackedFloat32Array()
var _state: PackedByteArray = PackedByteArray()
var _seen: PackedByteArray = PackedByteArray()
var _dead: PackedByteArray = PackedByteArray()
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
	_seen.fill(0)
	var n: int = snap.size()
	var r: int = 0
	while r + SimConst.SNAP_STRIDE <= n and snap[r] < SimConst.SNAP_PROJ_BASE:
		_person(snap, r, tick)
		r += SimConst.SNAP_STRIDE
	while r + SimConst.SNAP_PROJ_STRIDE <= n:
		var k: int = int(snap[r]) - SimConst.SNAP_PROJ_BASE
		if k >= 0 and k < SimConst.PCAP:
			_shot(k, Vector2(snap[r + 1], snap[r + 2]), tick)
		r += SimConst.SNAP_PROJ_STRIDE
	for k: int in SimConst.PCAP:
		if _state[k] != 0 and _seen[k] == 0:
			_end(k, tick)
	_primed = true


func _person(snap: PackedFloat64Array, r: int, tick: int) -> void:
	var i: int = int(snap[r])
	var kind: int = int(snap[r + 1])
	if i < 0 or i >= SimConst.CAP or (kind != SimConst.K_PED and kind != SimConst.K_COP):
		return
	var dead: bool = int(snap[r + 2]) == SimConst.M_DEAD
	if dead and _dead[i] == 0 and _primed:
		var at: Vector2 = Vector2(snap[r + 4], snap[r + 5]) * SimConst.PX_PER_M
		triggers.fire(&"death", at, atan2(snap[r + 7], snap[r + 6]), tick)
	_dead[i] = 1 if dead else 0


func _shot(k: int, p: Vector2, tick: int) -> void:
	_seen[k] = 1
	if _state[k] == 0:
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
