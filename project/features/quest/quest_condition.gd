class_name QuestCondition
extends RefCounted
## One bark `when` tag of a gtai.quest/1 line: `soul:hauler`, `madness:choir`, `heat:>=3`.
## parse() never fails silently: a malformed tag comes back with error set. A line's tags are ANDed.

enum Kind { SOUL, MADNESS, HEAT }
enum Op { EQ, GE, LE, GT, LT }

const OPS: Dictionary[String, Op] = {
	"": Op.EQ, "=": Op.EQ, "==": Op.EQ, ">=": Op.GE, "<=": Op.LE, ">": Op.GT, "<": Op.LT
}
const HEAT_PATTERN: String = "^(>=|<=|>|<|==|=)?(\\d+)$"

var kind: Kind = Kind.SOUL
var value: String = ""
var op: Op = Op.EQ
var n: int = 0
var error: String = ""


static func parse(tag: String, rules: QuestRules) -> QuestCondition:
	var c: QuestCondition = QuestCondition.new()
	var kv: PackedStringArray = tag.split(":", true, 1)
	if kv.size() != 2:
		c.error = "no ':' in '%s'" % tag
		return c
	match kv[0]:
		"soul":
			c.kind = Kind.SOUL
			c._expect_name(kv[1], rules.souls, "soul")
		"madness":
			c.kind = Kind.MADNESS
			c._expect_name(kv[1], rules.madness_bands, "madness band")
		"heat":
			c.kind = Kind.HEAT
			c._parse_heat(kv[1])
		_:
			c.error = "unknown condition '%s' (known: soul, madness, heat)" % kv[0]
	return c


## soul is the name of the soul in control, madness the band name, heat the wanted level.
func holds(soul: String, madness: String, heat: int) -> bool:
	match kind:
		Kind.SOUL:
			return soul == value
		Kind.MADNESS:
			return madness == value
	return compare(heat)


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


func _parse_heat(text: String) -> void:
	var m: RegExMatch = RegEx.create_from_string(HEAT_PATTERN).search(text)
	if m == null:
		error = "bad heat test '%s' (use heat:>=N)" % text
		return
	op = OPS[m.get_string(1)]
	n = m.get_string(2).to_int()
