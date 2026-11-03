class_name ArenaTickHook
extends ArenaHook
## The smallest ArenaHook, as the template a lane copies: it counts the ticks it was stepped and
## the hits Rivet landed while it ran, and folds both into the replay hash and the telemetry.
## A lane names its own hook in its station row: "script": "res://features/<lane>/<hook>.gd".

var ticks: int = 0
var set_up: bool = false
var view_seen: bool = false
var _hits_at_setup: int = 0
var _hits: int = 0


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	set_up = true
	_hits_at_setup = stage.telemetry.hits


func step(stage: ArenaStage, _tick: int) -> void:
	ticks += 1
	_hits = stage.telemetry.hits - _hits_at_setup


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(ticks)


func telemetry() -> Dictionary:
	return {"ticks": ticks, "hits": _hits}


func attach_view(_view: Node) -> void:
	view_seen = true
