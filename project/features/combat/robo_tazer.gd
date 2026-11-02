class_name RoboTazer
extends RefCounted
## Quartermaster Mertz's Robo-tazer (mechanic robo-tazer): an enemy-only anti-bot rifle. It waits
## first_delay_s, then each shot is a charge_s telegraph (the rising whine, sparking prongs, the
## capacitor tubes filling), the shot itself, and a vent_s window in which Mertz stands still
## (the window for Gloria). It shorts out when its carrier dies and is never dropped.

enum State { READY, CHARGING, VENTING, SHORTED }

var state: State = State.READY
var ticks: int = 0
var shots: int = 0
var charge_ticks: int = 90
var vent_ticks: int = 120
var _first_delay_ticks: int = 72


func _init(tuning: CombatTuning) -> void:
	charge_ticks = CombatTuning.ticks(tuning.tazer["charge_s"])
	vent_ticks = CombatTuning.ticks(tuning.tazer["vent_s"])
	_first_delay_ticks = CombatTuning.ticks(tuning.tazer["first_delay_s"])


## One tick; true on the tick the shot leaves the prongs.
func step() -> bool:
	if state == State.SHORTED:
		return false
	ticks += 1
	match state:
		State.READY:
			if ticks >= _first_delay_ticks:
				_go(State.CHARGING)
		State.CHARGING:
			if ticks >= charge_ticks:
				shots += 1
				_go(State.VENTING)
				return true
		State.VENTING:
			if ticks >= vent_ticks:
				_go(State.CHARGING)
	return false


## 0..1 through the telegraph (the whine's pitch, the tubes' fill); 0 outside it.
func charge_frac() -> float:
	return float(ticks) / charge_ticks if state == State.CHARGING else 0.0


## Charging began on this tick (the robo-tazer-charge cue).
func charge_began() -> bool:
	return state == State.CHARGING and ticks == 0


## The carrier stands still and is open to a nail.
func vulnerable() -> bool:
	return state == State.VENTING


## The carrier died: it shorts out in the puddle and can never fire or be picked up.
func short_out() -> void:
	_go(State.SHORTED)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_8(state)
	out.put_32(ticks)
	out.put_32(shots)


func _go(next: State) -> void:
	state = next
	ticks = 0
