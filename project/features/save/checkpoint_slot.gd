class_name CheckpointSlot
extends RefCounted
## Reads a checkpoint back out of a save slot's body (the dictionary `Checkpoint.to_dict()` put
## there). Goes through `Checkpoint.from_json`, so every field is validated by the one reader,
## then bounds what loading would cost: a slot whose hash is right can still ask for a replay of
## a billion ticks (a bug in a future writer, a hand edit with the hash recomputed), and that
## must be refused, not run. The container's hash guards against damage, not against intent.

## Six hours of play at 60 Hz. A longer replay is refused (no quest approaches it).
const MAX_TICK: int = 6 * 3600 * 60


## The Checkpoint in `body`, or null (reason logged) when it is not a valid, affordable one.
static func read(body: Dictionary) -> Checkpoint:
	var cp: Checkpoint = Checkpoint.from_json(JSON.stringify(body))
	if cp == null:
		return null
	var why: String = _bounds_error(cp)
	if why != "":
		Log.warn("save", "checkpoint refused: %s" % why)
		return null
	return cp


static func _bounds_error(cp: Checkpoint) -> String:
	if cp.tick > MAX_TICK:
		return "tick %d is past the %d-tick replay cap" % [cp.tick, MAX_TICK]
	var previous: int = -1
	for t: int in cp.input_ticks:
		if t <= previous or t >= cp.tick:
			return "input tape out of order or past the checkpoint tick"
		previous = t
	return ""
