class_name AudioDice
extends RefCounted
## The audio's dice: variation picks and pitch jitter. Seeded from the RNG registry's master seed
## and the name "audio" (RngRegistry.seed_for), so a run's audio is a pure function of its seed
## and the order of its cues. It is NOT a registry stream on purpose: a stream created mid-run
## enters the replay state hash (RngRegistry.write_state), and a windowed recording (audio on) would
## diverge from its headless replay (audio off). Render-side only, never read by the sim.

const MASK: int = 0xFFFFFFFF
const MUL: int = 1664525
const ADD: int = 1013904223

var _state: int = 0
var _last_take: Dictionary[StringName, int] = {}


func _init(master_seed: int) -> void:
	var full: int = RngRegistry.seed_for(master_seed, &"audio")
	_state = (full ^ (full >> 32)) & MASK


## A float in [0, 1).
func unit() -> float:
	_state = (_state * MUL + ADD) & MASK
	return float((_state >> 8) & 0xFFFF) / 65536.0


## 1 + a draw in [-spread, +spread].
func jitter(spread: float) -> float:
	return 1.0 + (unit() * 2.0 - 1.0) * spread


## A take in 0..takes-1 that is never the cue's previous one (when it has a choice).
func take(cue_id: StringName, takes: int) -> int:
	if takes <= 1:
		return 0
	var pick: int = int(unit() * takes) % takes
	if _last_take.get(cue_id, -1) == pick:
		pick = (pick + 1 + int(unit() * (takes - 1))) % takes
	_last_take[cue_id] = pick
	return pick
