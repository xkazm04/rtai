class_name VehicleFrameBench
extends Node
## n8 vehicles it17, brief item 5: the real drive's frame time WITH the traffic cards.
## vehicle_frame `--frames=<json> [--frames-ticks=<n>] [--spans=<json>]`: the game's own traffic
## (CitySystem's default targets, not the showcase's six cars), no shots, vsync off, the
## FightFrames log, and the cards drawn per frame (all / under the actors) -> <json>.cards.json.

## Set by vehicle_frame's arg parse when --frames / --frames-ticks is given.
static var on: bool = false

var view: VehicleView = null
var out_path: String = ""
var _cards: PackedInt32Array = PackedInt32Array()
var _under: PackedInt32Array = PackedInt32Array()
var _written: bool = false


## True for the flags this probe owns (vehicle_frame's parse accepts them through this).
static func flag(arg: String) -> bool:
	if not (arg.begins_with("--frames") or arg.begins_with("--spans")):
		return false
	on = true
	VehicleFrameSetup.game_traffic = true
	return true


## After the bake: FightFrames on `world` and the card counter on the VehicleView under `city`.
static func attach(parent: Node, world: World, city: CityView) -> void:
	if not on:
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var args: ArenaArgs = ArenaArgs.parse()
	FightFrames.attach(parent, args, world)
	var probe: VehicleFrameBench = VehicleFrameBench.new()
	probe.out_path = args.text("--frames").get_basename() + ".cards.json"
	for n: Node in city.actor_layer().get_children():
		if n is VehicleView:
			probe.view = n as VehicleView
	parent.add_child(probe)


func _ready() -> void:
	process_priority = 4095  # after VehicleView drew this frame's cards


func _process(_delta: float) -> void:
	var c: VehicleCards = view.cards if view != null else null
	@warning_ignore_start("return_value_discarded")
	_cards.append(c.count() if c != null and c.visible else 0)
	_under.append(c.count_under() if c != null and c.visible else 0)
	@warning_ignore_restore("return_value_discarded")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_write()


func _write() -> void:
	if _written or out_path == "" or _cards.is_empty():
		return
	_written = true
	var doc: Dictionary = {
		"schema": "gtai.vehicle-frame-cards/1",
		"view": String(ViewMode.shared().id) if ViewMode.shared() != null else "",
		"frames": _cards.size(),
		"cards": _stats(_cards),
		"under": _stats(_under),
	}
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		@warning_ignore("return_value_discarded")
		f.store_string(JSON.stringify(doc, "  ", true))


static func _stats(a: PackedInt32Array) -> Dictionary:
	var s: PackedInt32Array = a.duplicate()
	s.sort()
	var total: int = 0
	for v: int in s:
		total += v
	return {
		"avg": float(total) / maxi(1, s.size()),
		"p50": s[s.size() >> 1],
		"max": s[s.size() - 1],
	}
