class_name GhostForms
extends RefCounted
## The ghost-form state machine (data/tables/ghost_forms.json; JOURNAL REQUEST 1 is the interface).
## base -> entering -> form -> exiting -> base, and form -> switching -> form' (a teal flash, no
## base pass). All on whole 60 Hz ticks. A form runs as its powers.json row (SoulPowers: Madness
## cost, duration, cooldown); when that power ends (expired, interrupted) the form exits by itself.
## Input: press_transform() (Q / LB) enters the selected form or exits to base; press_next()
## (G / RB) selects the next ghost in base, or switches straight to it in a form. A request
## during a transformation is refused (BUSY): every transformation plays whole.

signal form_entering(from: StringName, to: StringName, ticks: int)
signal form_entered(id: StringName)
signal form_exiting(id: StringName, ticks: int)
signal form_exited(id: StringName)

const BASE: StringName = &"base"
const SETTLED: StringName = &"settled"
const ENTERING: StringName = &"entering"
const EXITING: StringName = &"exiting"
const SWITCHING: StringName = &"switching"
const BUSY: StringName = &"busy"
const SAME: StringName = &"same"

var table: GhostFormTable = null
var powers: SoulPowers = null
## The settled form (BASE while in base); during a transformation the form it leaves.
var from_id: StringName = BASE
## The form a running transformation goes to (== from_id when settled).
var to_id: StringName = BASE
var phase: StringName = SETTLED
var selected: StringName = &""
## Fault injection for the tests (never set in game): accept a request mid-transformation.
var plant_mid_switch: bool = false
## Every transformation as [kind, from, to, start_tick, end_tick] (evidence and check()).
var history: Array[Array] = []
var _left: int = 0
var _total: int = 1
var _tick: int = 0
var _releasing: bool = false


func _init(p_table: GhostFormTable, p_powers: SoulPowers) -> void:
	table = p_table
	powers = p_powers
	selected = table.order[0] if not table.order.is_empty() else &""
	@warning_ignore("return_value_discarded")
	powers.ended.connect(_on_power_ended)


## The settled form id (BASE during a transformation: no attacks then).
func current() -> StringName:
	return from_id if phase == SETTLED else BASE


func settled() -> bool:
	return phase == SETTLED


## 0..1 through the running transformation (1 when settled).
func k() -> float:
	return 1.0 if phase == SETTLED else 1.0 - float(_left) / float(_total)


## The transformation's stage: 0 = the from pose, 1 = the in-between pose (past the midpoint).
func stage() -> int:
	return 1 if k() >= 0.5 and phase != SETTLED else 0


## The settled form's definition (null in base).
func def() -> GhostFormDef:
	return table.form(current())


## Q / LB: base -> the selected form, a form -> base. Returns SoulPowers' answer or BUSY.
func press_transform() -> StringName:
	if not _free():
		return BUSY
	if from_id == BASE:
		return _enter(selected)
	return _exit()


## G / RB: in base, select the next ghost; in a form, switch straight to the next one.
func press_next() -> StringName:
	if not _free():
		return BUSY
	if from_id == BASE:
		selected = table.next_after(selected)
		return SoulPowers.OK
	return switch_to(table.next_after(from_id))


## Form to form through the teal flash; refused in base, mid-transformation, or by SoulPowers.
func switch_to(id: StringName) -> StringName:
	if not _free() or from_id == BASE:
		return BUSY
	if id == from_id:
		return SAME
	var f: GhostFormDef = table.form(id)
	if f == null:
		return SoulPowers.UNKNOWN
	_releasing = true
	@warning_ignore("return_value_discarded")
	powers.release()
	_releasing = false
	var r: StringName = powers.try_activate(f.power)
	if r != SoulPowers.OK:
		_begin(EXITING, BASE, table.form(from_id).exit_ticks)
		return r
	selected = id
	_begin(SWITCHING, id, table.switch_ticks)
	return r


## One sim tick: the running transformation counts down and lands.
func tick() -> void:
	_tick += 1
	if phase == SETTLED:
		return
	_left -= 1
	if _left > 0:
		return
	var kind: StringName = phase
	var left_id: StringName = from_id
	phase = SETTLED
	from_id = to_id
	history[history.size() - 1][4] = _tick
	if kind == EXITING:
		form_exited.emit(left_id)
	else:
		form_entered.emit(from_id)


## The invariant over the history: no transformation began before the previous one landed.
## Returns one line per violation (empty = sound).
func check() -> Array[String]:
	var out: Array[String] = []
	for i: int in range(1, history.size()):
		var prev_end: int = history[i - 1][4]
		if prev_end < 0 or history[i][3] < prev_end:
			out.append(
				(
					"%s %s->%s at tick %d began before %s landed"
					% [
						history[i][0],
						history[i][1],
						history[i][2],
						history[i][3],
						history[i - 1][0]
					]
				)
			)
	return out


func _free() -> bool:
	return phase == SETTLED or plant_mid_switch


func _enter(id: StringName) -> StringName:
	var f: GhostFormDef = table.form(id)
	if f == null:
		return SoulPowers.UNKNOWN
	var r: StringName = powers.try_activate(f.power)
	if r == SoulPowers.OK:
		_begin(ENTERING, id, f.enter_ticks)
	return r


func _exit() -> StringName:
	_releasing = true
	@warning_ignore("return_value_discarded")
	powers.release()
	_releasing = false
	_begin(EXITING, BASE, table.form(from_id).exit_ticks)
	return SoulPowers.OK


func _begin(kind: StringName, to: StringName, ticks: int) -> void:
	if phase != SETTLED:
		from_id = to_id
	phase = kind
	to_id = to
	_total = maxi(1, ticks)
	_left = _total
	history.append([kind, from_id, to, _tick, -1])
	if kind == EXITING:
		form_exiting.emit(from_id, _total)
	else:
		form_entering.emit(from_id, to, _total)


func _on_power_ended(_id: StringName, _reason: StringName, _bark: StringName) -> void:
	if _releasing or from_id == BASE and phase == SETTLED:
		return
	if phase == SETTLED:
		_begin(EXITING, BASE, table.form(from_id).exit_ticks)
	elif to_id != BASE:
		_begin(EXITING, BASE, table.form(to_id).exit_ticks)
