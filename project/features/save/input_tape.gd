class_name InputTape
extends InputSource
## Every tick's input as a list of changes (tick, packed TickInput), recorded from a live source
## and, after a checkpoint load, played back first: until `play_until` the tape feeds its own
## history (re-simulating the run bit-identically, SIM-05), from then on it records the live
## source. A checkpoint is the seed plus this tape, so loading one is exact by construction.

var live: InputSource
## Ticks below this replay the recorded history; at and after it the live source is sampled.
var play_until: int = 0
var change_ticks: Array[int] = []
var change_inputs: Array[int] = []


func _init(p_live: InputSource) -> void:
	live = p_live


## Loads a history to play back (the lists from a checkpoint) up to `until` (exclusive).
func preload_history(ticks: Array[int], inputs: Array[int], until: int) -> void:
	change_ticks = ticks.duplicate()
	change_inputs = inputs.duplicate()
	play_until = until


func sample(tick: int) -> TickInput:
	if tick < play_until:
		return TickInput.unpack(_packed_at(tick))
	var input: TickInput = live.sample(tick)
	var packed: int = input.pack()
	if change_inputs.is_empty() or change_inputs[-1] != packed:
		change_ticks.append(tick)
		change_inputs.append(packed)
	return input


## The history before `tick` (what a checkpoint taken between ticks keeps).
func history_before(tick: int) -> Array[Array]:
	var ticks: Array[int] = []
	var inputs: Array[int] = []
	for i: int in change_ticks.size():
		if change_ticks[i] < tick:
			ticks.append(change_ticks[i])
			inputs.append(change_inputs[i])
	return [ticks, inputs]


func _packed_at(tick: int) -> int:
	var i: int = change_ticks.bsearch(tick, false) - 1
	return change_inputs[i] if i >= 0 else TickInput.new().pack()
