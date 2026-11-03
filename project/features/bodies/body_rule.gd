class_name BodyRule
extends RefCounted
## One row of the tackle matrix (bodies.json `rules`): what happens when `attacker` walks (walk)
## or runs (run: closing speed above the attacker's run_mps) into `defender`.

var attacker: StringName = &""
var defender: StringName = &""
## shove | stagger | knockdown | blocked
var walk: StringName = &"blocked"
var run: StringName = &"blocked"
var knockback_m: float = 0.0
var down_s: float = 0.0
var can_hurt: bool = false


static func from_row(t: DataTable, r: Dictionary) -> BodyRule:
	var b: BodyRule = BodyRule.new()
	b.attacker = StringName(t.text(r, "attacker"))
	b.defender = StringName(t.text(r, "defender"))
	b.walk = StringName(t.text(r, "walk"))
	b.run = StringName(t.text(r, "run"))
	b.knockback_m = t.num(r, "knockback_m")
	b.down_s = t.num(r, "down_s")
	b.can_hurt = r.get("can_hurt", false) == true
	return b


## The result for a contact at `closing_mps` (the attacker's speed into the defender).
func result(closing_mps: float, run_mps: float) -> StringName:
	return run if closing_mps > run_mps else walk
