class_name WeaponHold
extends RefCounted
## What Rivet holds on the fixed tick and how it changes hands (ArsenalTable): equip() stows the
## held weapon (its grip's stow_ticks), then draws the next (draw_ticks); &"" is the bare claw
## (stow only). A reload runs the weapon's reload_s split into the magazine out, in and the cock.
## Nothing fires until READY. Views read state, progress() and reload_phase() to pose the arm.

enum State { READY, STOWING, DRAWING, RELOADING }
enum Reload { NONE, MAG_OUT, MAG_IN, COCK }

var table: ArsenalTable
var state: State = State.READY
## The weapon in the claw (&"" = bare claw); while stowing, the one going away.
var held: StringName = &""
## The weapon coming next while stowing.
var pending: StringName = &""
var switches: int = 0
var _tick_in: int = 0
var _length: int = 0


func _init(p_table: ArsenalTable = ArsenalTable.shipped()) -> void:
	table = p_table


## Starts a switch to `weapon_id` (&"" puts the weapon away). False if it is already in hand.
func equip(weapon_id: StringName) -> bool:
	if weapon_id == held and state == State.READY:
		return false
	if weapon_id == held and state == State.DRAWING:
		return false
	pending = weapon_id
	switches += 1
	if state == State.STOWING:
		return true  # the stow already running ends in the new pick
	if held == &"" or state == State.DRAWING:
		_begin_draw()
	else:
		_begin(State.STOWING, _grip_ticks(held, false))
	return true


## Starts a reload of `reload_s` seconds; false unless a weapon is READY.
func reload(reload_s: float) -> bool:
	if state != State.READY or held == &"":
		return false
	_begin(State.RELOADING, maxi(roundi(reload_s / SimClock.TICK_DT), 1))
	return true


func step() -> void:
	if state == State.READY:
		return
	_tick_in += 1
	if _tick_in < _length:
		return
	if state == State.STOWING:
		_begin_draw()
	else:
		state = State.READY


func can_fire() -> bool:
	return state == State.READY and held != &""


## 0..1 through the running stow, draw or reload; 1 when READY.
func progress() -> float:
	return float(_tick_in) / float(_length) if state != State.READY and _length > 0 else 1.0


func reload_phase() -> Reload:
	if state != State.RELOADING:
		return Reload.NONE
	var u: float = progress()
	if u < table.out_k:
		return Reload.MAG_OUT
	return Reload.MAG_IN if u < table.out_k + table.in_k else Reload.COCK


## Ticks a switch from `from_id` to `to_id` takes (stow + draw).
func switch_ticks(from_id: StringName, to_id: StringName) -> int:
	return _grip_ticks(from_id, false) + _grip_ticks(to_id, true)


## Walk scale while the held weapon is out.
func move_mult() -> float:
	var g: ArsenalTable.Grip = table.grip_of(held)
	return g.move_mult if g != null else 1.0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(state)
	out.put_utf8_string(String(held))
	out.put_utf8_string(String(pending))
	out.put_32(_tick_in)
	out.put_32(_length)


func _begin_draw() -> void:
	held = pending
	pending = &""
	if held == &"":
		state = State.READY
		return
	_begin(State.DRAWING, _grip_ticks(held, true))


func _begin(s: State, ticks: int) -> void:
	state = s
	_tick_in = 0
	_length = ticks


func _grip_ticks(weapon_id: StringName, draw: bool) -> int:
	if weapon_id == &"":
		return 0
	var g: ArsenalTable.Grip = table.grip_of(weapon_id)
	if g == null:
		return 1
	return g.draw_ticks if draw else g.stow_ticks
