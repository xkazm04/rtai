class_name ServoRack
extends RefCounted
## The launch rack across Servo's back: `cells` docking cells in `rows` rows across the body. A cell
## is FULL (a drone docked, drawn in it), OUT (its drone is flying), REFILL (its drone died; a new
## one is loaded from inside the hub after refill_ticks) or BROKEN (phase 3: the wing blew off).
## The rig's rack layer draws straight from `state`.

enum Cell { FULL, OUT, REFILL, BROKEN }

var state: Array[int] = []
## Servo's body on the ground and the way he faces (radians, 0 = +x); set by the boss each tick.
var origin: Vector2 = Vector2.ZERO
var facing: float = 0.0
var _refill_left: Array[int] = []
var _tuning: ServoTuning = null


func setup(tuning: ServoTuning) -> void:
	_tuning = tuning
	state.clear()
	_refill_left.clear()
	for i: int in tuning.cells:
		state.append(Cell.FULL)
		_refill_left.append(0)


## Where cell `i` sits on the ground: columns run across the back (perpendicular to facing),
## the rows behind the body, row_dy_m apart.
func cell_pos(i: int) -> Vector2:
	var per_row: int = cols()
	var col: int = i % per_row
	var row: int = floori(float(i) / per_row)
	var across: float = (col - (per_row - 1) * 0.5) * _tuning.cell_dx_m
	var back: float = -0.4 - row * _tuning.row_dy_m
	var fwd: Vector2 = Vector2.from_angle(facing)
	var side: Vector2 = Vector2(-fwd.y, fwd.x)
	return origin + side * across + fwd * back


## The next full cell, outermost columns first (the wings empty from the tips in), or -1.
func take() -> int:
	var per_row: int = cols()
	var best: int = -1
	var best_out: float = -1.0
	for i: int in state.size():
		if state[i] != Cell.FULL:
			continue
		var out: float = absf((i % per_row) - (per_row - 1) * 0.5) + (0.01 * i)
		if out > best_out:
			best_out = out
			best = i
	if best >= 0:
		state[best] = Cell.OUT
	return best


func dock(i: int) -> void:
	if i >= 0 and i < state.size() and state[i] == Cell.OUT:
		state[i] = Cell.FULL


func lost(i: int) -> void:
	if i >= 0 and i < state.size() and state[i] == Cell.OUT:
		state[i] = Cell.REFILL
		_refill_left[i] = _tuning.refill_ticks


## Phase 3: one wing (the first half of every row) blows off; its cells never refill.
func break_wing() -> void:
	var per_row: int = cols()
	for i: int in state.size():
		if (i % per_row) < per_row * 0.5 and state[i] != Cell.OUT:
			state[i] = Cell.BROKEN


func step() -> void:
	for i: int in state.size():
		if state[i] == Cell.REFILL:
			_refill_left[i] -= 1
			if _refill_left[i] <= 0:
				state[i] = Cell.FULL


## Rows of cells (servo.json rack.rows; 2 before the target pass) and cells per row.
func rows() -> int:
	return maxi(_tuning.rows, 1) if _tuning != null else 2


func cols() -> int:
	return maxi(ceili(state.size() / float(rows())), 1)


func count(kind: int) -> int:
	var n: int = 0
	for s: int in state:
		if s == kind:
			n += 1
	return n
