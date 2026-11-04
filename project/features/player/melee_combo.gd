class_name MeleeCombo
extends RefCounted
## The claw combo on the fixed tick: press() starts hit 1, or buffers the next hit while one
## plays; a buffered hit starts `cancel_ticks` into the current hit's recovery. After the last
## hit's recovery, a press within the combo window continues the chain; later, it restarts at
## hit 1, and the finisher (the last row) always ends the chain. lands() is true on exactly one
## tick per hit (the first active tick): the host runs its hit test there. A grinding hit (the
## chainsaw, grind_ticks > 0) holds its last active tick for grind_min_ticks and on while the host
## sets `holding`, landing again every grind_ticks; a release lets it run into its recovery.

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
## Set by the host each tick: the attack is held down (a grinding hit keeps grinding).
var holding: bool = false
## Ticks the current hit has held its grind (0 = not grinding yet).
var ground: int = 0


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
	var h: MeleeHit = current()
	if grinding():
		ground += 1
		buffered = false  # a held trigger is the grind, not a queued next hit
		return
	tick_in += 1
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
		ground = 0


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


## True while a grinding hit holds its last active tick: the attack is held down, or the bite has
## not yet held its grind_min_ticks.
func grinding() -> bool:
	var h: MeleeHit = current()
	if h == null or h.grind_ticks <= 0 or tick_in != h.windup + h.active - 1:
		return false
	return holding or ground < h.grind_min_ticks


## True on the first active tick of the current hit, and every grind_ticks of a held grind: run
## the hit test now.
func lands() -> bool:
	var h: MeleeHit = current()
	if h == null:
		return false
	if ground > 0:
		return ground % h.grind_ticks == 0 and tick_in == h.windup + h.active - 1
	return tick_in == h.windup


## 0..1 progress through the current hit (for the rig's reach envelope); 0 when idle.
func progress() -> float:
	var h: MeleeHit = current()
	return float(tick_in) / float(h.length()) if h != null else 0.0


## Metres Rivet travels along his facing on this tick: a hit's lunge_m spread evenly over its
## windup and active ticks (the katana's thrust); 0 in recovery, idle, or for a hit without one.
func lunge_step_m() -> float:
	var h: MeleeHit = current()
	if h == null or h.lunge_m <= 0.0 or tick_in >= h.windup + h.active or ground > 0:
		return 0.0
	return h.lunge_m / float(h.windup + h.active)


## Top-speed scale for the mover: the weapon's move_mult while a hit plays, else 1.
func move_scale() -> float:
	return table.move_mult if hit_index > 0 else 1.0


func _start(index: int) -> void:
	hit_index = index
	starts += 1
	tick_in = 0
	buffered = false
	ground = 0
