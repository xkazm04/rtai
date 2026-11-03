class_name ArenaHook
extends RefCounted
## A lane's code in the arena, named by its station row's `script` (a res://features/ script that
## extends ArenaHook). The arena stage calls every hook in station-file order, so a lane wires its
## weapon, enemies or power into the arena from its own folder and never edits the arena's files:
## setup() once after the stage is built, step() every 60 Hz tick after the stage's own step,
## write_state() into the replay hash, telemetry() into the session's JSON, attach_view() once the
## dev view exists (absent headless). Every method is optional: the defaults do nothing.

## The station this hook came from (set by the loader before setup).
var station: ArenaStation = null


func setup(_stage: ArenaStage, _ctx: WorldContext) -> void:
	pass


func step(_stage: ArenaStage, _tick: int) -> void:
	pass


func write_state(_out: StreamPeerBuffer) -> void:
	pass


func telemetry() -> Dictionary:
	return {}


func attach_view(_view: Node) -> void:
	pass


## The hook a station names, or null (logged) when the path is missing, outside res://features/,
## or the script does not extend ArenaHook. A broken hook never stops the arena.
static func make(s: ArenaStation) -> ArenaHook:
	if s.script_path.is_empty():
		return null
	var path: String = s.script_path
	if not path.begins_with("res://features/") or path.get_extension() != "gd":
		Log.warn("arena", "station %s: hook %s is not under res://features/" % [s.id, path])
		return null
	if not ResourceLoader.exists(s.script_path):
		Log.warn("arena", "station %s: hook %s not found" % [s.id, s.script_path])
		return null
	var scr: GDScript = load(s.script_path) as GDScript
	var obj: Variant = scr.new() if scr != null and scr.can_instantiate() else null
	if not obj is ArenaHook:
		Log.warn("arena", "station %s: %s does not extend ArenaHook" % [s.id, s.script_path])
		return null
	var hook: ArenaHook = obj
	hook.station = s
	return hook
