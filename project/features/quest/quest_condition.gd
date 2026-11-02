class_name QuestCondition
extends RefCounted
## One bark `when` tag of a gtai.quest/1 line. A state condition is `kind:value` (`soul:hauler`,
## `madness:choir`, `weapon:gloria`, `heat:>=3`); an event tag is a bare word from
## quest_rules.json `event_tags` (`kill`, `wave-start`) that holds while its fact is recent.
## parse() never fails silently: a malformed tag comes back with error set. A line's tags are ANDed.

enum Kind { SOUL, MADNESS, HEAT, WEAPON, EVENT }
enum Op { EQ, GE, LE, GT, LT }

const OPS: Dictionary[String, Op] = {
	"": Op.EQ, "=": Op.EQ, "==": Op.EQ, ">=": Op.GE, "<=": Op.LE, ">": Op.GT, "<": Op.LT
}

var kind: Kind = Kind.SOUL
## The name (soul, band, weapon) or, for an event tag, the fact it waits for.
var value: String = ""
var op: Op = Op.EQ
var n: int = 0
var error: String = ""


static func parse(tag: String, rules: QuestRules) -> QuestCondition:
	var c: QuestCondition = QuestCondition.new()
	if rules.event_tags.has(tag):
		c.kind = Kind.EVENT
		c.value = rules.event_tags[tag]
		return c
	var kv: PackedStringArray = tag.split(":", true, 1)
	if kv.size() != 2:
		var known: PackedStringArray = PackedStringArray(rules.event_tags.keys())
		c.error = "unknown event tag '%s' (known: %s)" % [tag, ", ".join(known)]
		return c
	match kv[0]:
		"soul":
			c.kind = Kind.SOUL
			c._expect_name(kv[1], rules.souls, "soul")
		"madness":
			c.kind = Kind.MADNESS
			c._expect_name(kv[1], rules.madness_bands, "madness band")
		"weapon":
			c.kind = Kind.WEAPON
			c._expect_name(kv[1], rules.weapons, "weapon")
		"heat":
			c.kind = Kind.HEAT
			c._parse_heat(kv[1], rules.heat_pattern)
		_:
			c.error = "unknown condition '%s' (known: soul, madness, weapon, heat)" % kv[0]
	return c


func holds(facts: QuestFacts) -> bool:
	match kind:
		Kind.SOUL:
			return facts.soul == value
		Kind.MADNESS:
			return facts.madness == value
		Kind.WEAPON:
			return facts.weapon == value
		Kind.EVENT:
			return facts.recent(value)
	return compare(facts.heat)


## The heat test against `level`.
func compare(level: int) -> bool:
	match op:
		Op.GE:
			return level >= n
		Op.LE:
			return level <= n
		Op.GT:
			return level > n
		Op.LT:
			return level < n
	return level == n


func _expect_name(name: String, known: Array[String], what: String) -> void:
	value = name
	if not known.has(name):
		error = "unknown %s '%s' (known: %s)" % [what, name, ", ".join(PackedStringArray(known))]


func _parse_heat(text: String, pattern: String) -> void:
	var m: RegExMatch = RegEx.create_from_string(pattern).search(text)
	if m == null:
		error = "bad heat test '%s' (use heat:>=N)" % text
		return
	op = OPS[m.get_string(1)]
	n = m.get_string(2).to_int()
