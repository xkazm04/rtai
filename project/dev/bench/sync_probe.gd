class_name SyncProbe
extends Node
## n12 B1: the victim-sync table's instrument (dev arena `--sync=<json>`, needs the cast rigs).
## Every landed hit (CombatArena.struck) opens a row: weapon, victim, lethal, the hit tick. Each
## frame after the rigs posed, the victim's rig is read until its body shows a reaction: the
## reaction layer's drawn offset or turn passes MOVE_PX / TURN_RAD, it starts dying, or a kill cut
## takes the rig (hidden, gone, back to the pool). The row closes with that tick, what showed it
## and how well the drawn offset follows the hit (cos). Writes the rows when the run ends.

## Screen px of drawn offset (the reaction's offsets turned through the rig's global transform).
const MOVE_PX: float = 1.0
const TURN_RAD: float = 0.06
## A row still open this many ticks after its hit is written as "none".
const GIVE_UP: int = 90

var out_path: String = ""
var arena: CombatArena = null
var host: RigHost = null
var world: World = null
var _open: Array[Dictionary] = []
var _rows: Array[Dictionary] = []
var _written: bool = false


static func attach(
	parent: Node, args: ArenaArgs, p_arena: CombatArena, p_host: RigHost, w: World
) -> void:
	if not args.has("--sync") or p_host == null:
		return
	var probe: SyncProbe = SyncProbe.new()
	probe.out_path = args.text("--sync")
	probe.arena = p_arena
	probe.host = p_host
	probe.world = w
	@warning_ignore_start("return_value_discarded")
	p_arena.struck.connect(probe._on_struck)
	p_arena.kill_landed.connect(probe._on_kill)  # melee kills land here, not on struck
	p_arena.wounded.connect(probe._on_wound)
	@warning_ignore_restore("return_value_discarded")
	parent.add_child(probe)


func _ready() -> void:
	process_priority = 4000  # after the rigs posed this frame


func _on_kill(
	victim: Fighter, weapon: StringName, dir: Vector2, _at: Vector2, _k: StringName
) -> void:
	_on_struck(victim, dir, true, weapon)


func _on_wound(victim: Fighter, weapon: StringName) -> void:
	_on_struck(victim, Vector2.ZERO, false, weapon)


## One row per victim per tick (a gun kill fires kill_landed and struck on the same landing).
func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	for o: Dictionary in _open:
		if o["victim"] == victim.id and o["hit_tick"] == _tick():
			o["lethal"] = o["lethal"] or lethal
			return
	var row: Dictionary = {
		"weapon": String(weapon),
		"victim": victim.id,
		"lethal": lethal,
		"hit_tick": _tick(),
		"dir": [dir.x, dir.y],
	}
	_open.append(row)


func _process(_delta: float) -> void:
	var tick: int = _tick()
	var still: Array[Dictionary] = []
	for row: Dictionary in _open:
		var seen: String = _seen(row)
		var hit: int = row["hit_tick"]
		if seen != "":
			row["react_tick"] = tick
			row["gap"] = tick - hit
			row["by"] = seen
			_rows.append(row)
		elif tick - hit > GIVE_UP:
			row["by"] = "none"
			row["gap"] = -1
			_rows.append(row)
		else:
			still.append(row)
	_open = still


## What shows a reaction on the victim's rig now ("" = nothing yet).
func _seen(row: Dictionary) -> String:
	var id: int = row["victim"]
	if host.hidden.has(id) or host.gone.has(id):
		return "taken"
	var rig: CutRig = host.rigs.rig_for(id)
	if rig == null or not rig.visible:
		return "taken"
	var r: HumanReact = rig.react
	if r == null or r.kind == &"":
		return ""
	var moved: float = _px(rig, r)
	_peak(row, r, moved)
	if r.dying:
		row["cos"] = _cos(row, r)
		return "dying:%s" % r.kind
	if moved > MOVE_PX or absf(r.rot) + absf(r.head_rot) > TURN_RAD:
		row["cos"] = _cos(row, r)
		return "react:%s" % r.kind
	return ""


## The reaction's drawn offset (body, head, carry) in screen px: through the rig's transform.
static func _px(rig: CutRig, r: HumanReact) -> float:
	var b: Transform2D = rig.get_global_transform()
	var body: float = b.basis_xform(r.off + r.slide).length()
	return maxf(body, b.basis_xform(r.off + r.head_off).length())


## The largest drawn offset (world px) and the families seen while the row was open.
func _peak(row: Dictionary, r: HumanReact, px: float) -> void:
	var was: float = row.get("peak_px", 0.0)
	row["peak_px"] = snappedf(maxf(was, px), 0.01)
	var trace: Array = row.get("trace", [])
	if trace.size() < 16:
		trace.append([_tick(), String(r.kind), snappedf(px, 0.01), snappedf(r.t, 0.01)])
		row["trace"] = trace
	var kinds: String = row.get("kinds", "")
	if not kinds.contains(String(r.kind)):
		row["kinds"] = kinds + String(r.kind) + " "


## How the drawn throw follows the hit: cos between the body's offset and the hit, both in rig
## space (HumanReact.dir is the blow turned into the rig's frame at play()).
func _cos(_row: Dictionary, r: HumanReact) -> float:
	var drawn: Vector2 = r.off + r.slide
	if drawn.length() < 0.001:
		return 0.0
	return snappedf(r.dir.dot(drawn.normalized()), 0.01)


func _tick() -> int:
	return world.context().clock.tick() if world != null else 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		write()


func write() -> void:
	if _written or out_path == "":
		return
	_written = true
	for row: Dictionary in _open:
		row["by"] = "open"
		_rows.append(row)
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		Log.warn("bench", "sync probe: cannot write %s" % out_path)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify({"schema": "gtai.sync-probe/1", "rows": _rows}))
	f.close()
	Log.info("bench", "sync probe -> %s (%d hits)" % [out_path, _rows.size()])
