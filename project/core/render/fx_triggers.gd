class_name FxTriggers
extends RefCounted
## FX cues as data (data/tables/fx_triggers.json, gtai.fx-triggers/1): fire(id) spawns the row's
## fx.json kinds (FxSystem links their lights and routes emissive kinds above the lights) and
## kicks the camera rig's shake when the cue is within shake_near_m of the focus. `sim` cues come
## from a snapshot reader (CityFxFeed); `event` cues follow an Events signal (listen()). A row's
## `hitstop` holds the clock (SimClock.hold: wall time only, every tick unchanged). Render only:
## no RNG stream, no frame delta, nothing written back to the sim.

const TABLE: String = "res://data/tables/fx_triggers.json"

var rows: Dictionary[StringName, Dictionary] = {}
## Cues fired per id since boot (evidence and tests).
var fired: Dictionary[StringName, int] = {}
var fx: FxSystem = null
var rig: CameraRig = null
## The camera focus in world px (shake_near_m is measured from it).
var focus_px: Vector2 = Vector2.ZERO
## Rivet's runtime actor id: actor_killed with this killer fires `rivet_kill` (-1 = none).
var player_id: int = -1
## Hit-stops held since boot (evidence and tests).
var stops: int = 0
var _clock: SimClock = null
var _at: Callable = Callable()


func _init() -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	for row: Dictionary in d["triggers"]:
		var id: StringName = StringName(str(row["id"]))
		rows[id] = row
		fired[id] = 0


## Fires cue `id` at `pos_px` (world px) along `angle` on sim tick `tick`.
func fire(id: StringName, pos_px: Vector2, angle: float, tick: int) -> void:
	var row: Dictionary = rows.get(id, {})
	if row.is_empty():
		return
	fired[id] += 1
	if fx != null:
		for kind: String in row["fx"]:
			@warning_ignore("return_value_discarded")
			fx.spawn(StringName(kind), pos_px, angle, tick)
	_stop(row, tick)
	var shake: String = row["shake"]
	if rig == null or shake == "":
		return
	var near_m: float = row["shake_near_m"]
	if near_m > 0.0 and pos_px.distance_to(focus_px) > near_m * FxPool.PX_PER_M:
		return
	rig.kick(StringName(shake), tick)


## Follows the `event` cues on `bus` (the Events autoload) at the tick `clock` reads; `at`
## returns where the cue lands in world px (Rivet's position for player_hit).
func listen(bus: EventBus, clock: SimClock, at: Callable) -> void:
	_clock = clock
	_at = at
	if rows.has(&"player_hit"):
		@warning_ignore("return_value_discarded")
		bus.player_hit.connect(_on_player_hit)
	if rows.has(&"rivet_kill"):
		@warning_ignore("return_value_discarded")
		bus.actor_killed.connect(_on_killed)


func _on_player_hit(_weapon: StringName) -> void:
	var tick: int = _clock.tick() if _clock != null else 0
	var at: Vector2 = _at.call() if _at.is_valid() else focus_px
	fire(&"player_hit", at, 0.0, tick)


func _on_killed(killer_id: int, _victim_id: int, _kind: StringName) -> void:
	if killer_id != player_id or player_id < 0:
		return
	var tick: int = _clock.tick() if _clock != null else 0
	var at: Vector2 = _at.call() if _at.is_valid() else focus_px
	fire(&"rivet_kill", at, 0.0, tick)


## The row's hit-stop: the rig decides the length (reduced motion, cooldown), the clock holds it.
func _stop(row: Dictionary, tick: int) -> void:
	var id: String = row.get("hitstop", "")
	if id == "" or rig == null or _clock == null:
		return
	var ticks: int = rig.hitstop(StringName(id), tick)
	if ticks > 0:
		_clock.hold(ticks * SimClock.TICK_DT)
		stops += 1
