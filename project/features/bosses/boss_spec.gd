class_name BossSpec
extends RefCounted
## One boss from data/tables/bosses.json (schema gtai.bosses/1): hp, body, the named RNG stream,
## its phases (entered by hp fraction) and attacks, its arena, and the optional per-boss script
## (features/bosses/<id>/, a BossMoves). The interface the king and servo lanes share
## (n7-king JOURNAL REQUEST 1).

const TABLE: String = "res://data/tables/bosses.json"
const SCHEMA: String = "gtai.bosses/1"


class Phase:
	extends RefCounted
	var id: StringName = &""
	var hp_below: float = 1.0
	var attacks: Array[StringName] = []
	var gap: int = 60
	var transition: int = 0
	var adds_archetype: StringName = &""
	var adds_count: int = 0
	var adds_every: int = 0


class Arena:
	extends RefCounted
	var id: StringName = &""
	var area: StringName = &""
	var boss_at: Vector2 = Vector2.ZERO
	var rivet_at: Vector2 = Vector2.ZERO
	var add_spawns: Array[Vector2] = []


var id: StringName = &""
var hp: float = 1.0
var move_mps: float = 0.0
var radius_m: float = 1.0
var rng: StringName = &""
var script_path: String = ""
var phases: Array[Phase] = []
var attacks: Dictionary[StringName, BossAttack] = {}
var arena: Arena = Arena.new()


## The boss `boss_id` from the shipped table, or null (logged) when it is missing or broken.
static func shipped(boss_id: StringName) -> BossSpec:
	return from_table(DataTable.open(TABLE, SCHEMA), boss_id)


static func ids() -> Array[StringName]:
	var out: Array[StringName] = []
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	for k: Variant in t.object(t.raw, "bosses").keys():
		out.append(StringName(str(k)))
	out.sort()
	return out


static func from_table(t: DataTable, boss_id: StringName) -> BossSpec:
	var row: Dictionary = BossAttack.opt_object(t.object(t.raw, "bosses"), String(boss_id))
	if row.is_empty():
		Log.warn("bosses", "no boss %s in bosses.json" % boss_id)
		return null
	var s: BossSpec = BossSpec.new()
	s.id = boss_id
	s.hp = t.num(row, "hp")
	s.move_mps = t.num(row, "move_mps")
	s.radius_m = t.num(row, "radius_m")
	s.rng = StringName(t.text(row, "rng"))
	s.script_path = str(row.get("script", ""))
	var atk: Dictionary = t.object(row, "attacks")
	for k: Variant in atk.keys():
		s.attacks[StringName(str(k))] = BossAttack.from_row(t, str(k), t.object(atk, str(k)))
	for p: Variant in t.array(row, "phases"):
		var p_row: Dictionary = p if p is Dictionary else {}
		s.phases.append(_phase(t, p_row))
	var arena_id: String = t.text(row, "arena")
	s.arena = _arena(t, arena_id, t.object(t.object(t.raw, "arenas"), arena_id))
	if not t.ok() or s.phases.is_empty():
		Log.warn("bosses", "boss %s: %s" % [boss_id, ", ".join(t.errors())])
		return null
	return s


static func _phase(t: DataTable, row: Dictionary) -> Phase:
	var p: Phase = Phase.new()
	p.id = StringName(t.text(row, "id"))
	p.hp_below = t.num(row, "hp_below")
	for a: Variant in t.array(row, "attacks"):
		p.attacks.append(StringName(str(a)))
	p.gap = BossAttack.ticks(t.num(row, "gap_s"))
	p.transition = BossAttack.ticks(t.num(row, "transition_s"))
	var adds: Dictionary = BossAttack.opt_object(row, "adds")
	p.adds_archetype = StringName(str(adds.get("archetype", "")))
	p.adds_count = roundi(BossAttack.opt(adds, "count", 0.0))
	p.adds_every = BossAttack.ticks(BossAttack.opt(adds, "every_s", 0.0))
	return p


static func _arena(t: DataTable, p_id: String, row: Dictionary) -> Arena:
	var a: Arena = Arena.new()
	a.id = StringName(p_id)
	if row.is_empty():
		return a
	a.area = StringName(t.text(row, "area"))
	a.boss_at = t.vec(row, "boss_at")
	a.rivet_at = t.vec(row, "rivet_at")
	for v: Variant in t.array(row, "add_spawns"):
		a.add_spawns.append(t.vec({"v": v}, "v"))
	return a


## The phase index for an hp fraction: the last phase whose hp_below the fraction has reached.
func phase_for(frac: float) -> int:
	var at: int = 0
	for i: int in phases.size():
		if frac <= phases[i].hp_below:
			at = i
	return at
