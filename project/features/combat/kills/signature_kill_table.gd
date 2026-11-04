class_name SignatureKillTable
extends RefCounted
## signature_kills.json read as data (lane brutality): the signature kill of each advanced weapon,
## looked up by the weapon id a lethal hit carries. `gore_full` false (`--gore=reduced`) makes
## every lookup miss, so the victim takes the standard death and nothing is dismembered.

const PATH: String = "res://data/tables/signature_kills.json"
const SCHEMA: String = "gtai.signature_kills/1"

var leftover_budget: int = 12
var gore_full: bool = true
var problems: Array[String] = []
var _by_weapon: Dictionary[StringName, SignatureKill] = {}


static func load_table(path: String = PATH) -> SignatureKillTable:
	return from_table(DataTable.open(path, SCHEMA))


static func from_table(t: DataTable) -> SignatureKillTable:
	var out: SignatureKillTable = SignatureKillTable.new()
	if t.ok():
		out.leftover_budget = maxi(1, t.integer(t.raw, "leftover_budget"))
		for v: Variant in t.array(t.raw, "kills"):
			if v is Dictionary:
				var d: Dictionary = v
				var row: SignatureKill = SignatureKill.from_dict(t, d)
				out._by_weapon[row.weapon] = row
				for also: Variant in d.get("also_weapons", []):  # e.g. Rivet's charged claw shock
					out._by_weapon[StringName(str(also))] = row
	out.problems = t.errors()
	return out


## `--gore=full|reduced` (default full) from the launch args.
static func gore_from_args(value: String) -> bool:
	return value != "reduced"


## The weapon's signature kill, or null (no row, or reduced gore).
func for_weapon(weapon: StringName) -> SignatureKill:
	if not gore_full:
		return null
	return _by_weapon.get(weapon, null)


func weapons() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_by_weapon.keys())
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out
