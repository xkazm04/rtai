class_name CheckpointSlot
extends RefCounted
## Reads a checkpoint back out of a save slot's body (the dictionary `Checkpoint.to_dict()` put
## there). Goes through `Checkpoint.from_json`, so every field is validated by the one reader.


## The Checkpoint in `body`, or null (reason logged) when it is not a valid one.
static func read(body: Dictionary) -> Checkpoint:
	return Checkpoint.from_json(JSON.stringify(body))
