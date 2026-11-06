class_name StrikeDepth
extends RefCounted
## n7-melee: how far a timed strike cocks back before it lands (the audit: the claw's jab
## wind-up is a ~10 px pull at 48 px/m and barely reads at 32). RigClips scales its windup reach
## (the torso twist back and the lean, then the arm out on the hit tick) by depth(rig.hold); the
## hit tick and the strike's timing are untouched (realtime-combat-semantics: anticipation never
## moves the active frame). Rows: melee_marks.json `swing.pullback`, keyed by the rig's hold class
## (blade, chainsaw: the held melee weapons swing); a hold without a row (none, or a gun's: the
## strike is then the claw's jab) takes the "claw" row. No rows (a bad table, --pullback=off or
## --feel=off) = BEFORE, the night's curve. Render only: never read by the sim.

const TABLE: String = "res://data/tables/melee_marks.json"
const SCHEMA: String = "gtai.melee_marks/1"
const BEFORE: float = 0.35
const BARE: StringName = &"claw"

static var _rows: Dictionary[StringName, float] = {}
static var _arm: Dictionary[StringName, float] = {}
static var _loaded: bool = false


## The windup reach's depth (> 0) for a rig holding `hold` (no row: the claw's jab).
static func depth(hold: StringName) -> float:
	if not _loaded:
		load_table(TABLE)
	if _rows.has(hold):
		return _rows[hold]
	return _rows[BARE] if _rows.has(BARE) else BEFORE


## How far the striking arm draws back with the torso (0 = it stays, the night's; RigArm), per
## hold as depth(); no rows = 0.
static func arm_back(hold: StringName) -> float:
	if not _loaded:
		load_table(TABLE)
	if _arm.has(hold):
		return _arm[hold]
	return _arm[BARE] if _arm.has(BARE) else 0.0


## RigArm: how far the striking arm is drawn back now, 0..1: only past the night's cock (the
## jab always leaves from there, so a held hit frame never shows the arm back).
static func cock(rig: CutRig) -> float:
	var extra: float = maxf(depth(rig.hold) - BEFORE, 0.01)
	return clampf((-rig.c_reach - BEFORE) / extra * arm_back(rig.hold), 0.0, 1.0)


## Reads the rows (or none, the before, under --feel=off or on a table error).
static func load_table(path: String) -> void:
	_loaded = true
	_rows = {}
	_arm = {}
	var t: DataTable = DataTable.open(path, SCHEMA)
	var swing: Dictionary = t.object(t.raw, "swing")
	var row: Dictionary = t.object(swing, "pullback")
	var arm: Dictionary = t.object(swing, "arm_back")
	if not t.ok():
		Log.error("melee_marks", str(t.errors()))
		return
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if HitFeel.feel_flag() == "off" or args.has("--pullback=off"):
		return
	for k: String in row:
		_rows[StringName(k)] = t.num(row, k)
	for k: String in arm:
		_arm[StringName(k)] = t.num(arm, k)


## Tests: use these rows instead of the table ({} = the before for every hold).
static func use(
	rows: Dictionary[StringName, float], arm: Dictionary[StringName, float] = {}
) -> void:
	_loaded = true
	_rows = rows
	_arm = arm


## Tests: forget the rows (the next depth() reads the table again).
static func reset() -> void:
	_loaded = false
	_rows = {}
	_arm = {}
