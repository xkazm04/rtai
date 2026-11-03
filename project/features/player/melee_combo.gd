class_name MeleeCombo
extends RefCounted
## The claw combo on the fixed tick: press() starts hit 1, or buffers the next hit while one
## plays; a buffered hit starts `cancel_ticks` into the current hit's recovery. After the last
## hit's recovery, a press within the combo window continues the chain; later, it restarts at
## hit 1, and the finisher (the last row) always ends the chain. lands() is true on exactly one
## tick per hit (the first active tick): the host runs its hit test there.

enum Phase { NONE, WINDUP, ACTIVE, RECOVERY }

var table: MeleeTable
## 0 = no hit playing; else the 1-based hit index.
var hit_index: int = 0
var tick_in: int = 0
var buffered: bool = false
## Ticks since the last hit ended (the combo window), and which hit that was.
var since_end: int = 1 << 20
var last_index: int = 0
## Counts hit starts: a host that poses the rig compares it with the count it last saw.
var starts: int = 0


func _init(p_table: MeleeTable) -> void:
	table = p_table


func press() -> void:
	if hit_index > 0:
		buffered = true
		return
	var next: int = 1
	if since_end <= table.combo_window_ticks and last_index < table.hits.size():
		next = last_index + 1
	_start(next)


## Advances one tick (call after press() for this tick's input).
func step() -> void:
	if hit_index == 0:
		since_end += 1
		return
	tick_in += 1
	var h: MeleeHit = current()
	var cancel_at: int = h.windup + h.active + table.cancel_ticks
	if buffered and tick_in >= cancel_at and hit_index < table.hits.size():
		_start(hit_index + 1)
		return
	if tick_in >= h.length():
		last_index = hit_index
		hit_index = 0
		tick_in = 0
		since_end = 0
		buffered = false


func current() -> MeleeHit:
	return table.hits[hit_index - 1] if hit_index > 0 else null


func phase() -> Phase:
	var h: MeleeHit = current()
	if h == null:
		return Phase.NONE
	if tick_in < h.windup:
		return Phase.WINDUP
	if tick_in < h.windup + h.active:
		return Phase.ACTIVE
	return Phase.RECOVERY


## True on the first active tick of the current hit: run the hit test now.
func lands() -> bool:
	var h: MeleeHit = current()
	return h != null and tick_in == h.windup


## 0..1 progress through the current hit (for the rig's reach envelope); 0 when idle.
func progress() -> float:
	var h: MeleeHit = current()
	return float(tick_in) / float(h.length()) if h != null else 0.0


func _start(index: int) -> void:
	hit_index = index
	starts += 1
	tick_in = 0
	buffered = false
