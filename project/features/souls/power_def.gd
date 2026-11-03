class_name PowerDef
extends RefCounted
## One row of data/tables/powers.json: a soul's power as the framework runs it (SoulPowers).
## Durations are converted to whole sim ticks once, here (SIM: the 60 Hz tick, never a delta).

var id: StringName = &""
var action: StringName = &""
var bark_on: StringName = &""
var bark_off: StringName = &""
var duration_ticks: int = 0
var cooldown_ticks: int = 0
var madness_cost: float = 0.0
var interrupt_on: Array[StringName] = []


static func from_row(t: DataTable, r: Dictionary) -> PowerDef:
	var p: PowerDef = PowerDef.new()
	p.id = StringName(t.text(r, "id"))
	p.action = StringName(t.text(r, "action"))
	p.bark_on = StringName(t.text(r, "bark_on"))
	p.bark_off = StringName(t.text(r, "bark_off"))
	p.duration_ticks = PowerDef.ticks(t.num(r, "duration_s"))
	p.cooldown_ticks = PowerDef.ticks(t.num(r, "cooldown_s"))
	p.madness_cost = t.num(r, "madness_cost")
	for reason: Variant in t.array(r, "interrupt_on"):
		p.interrupt_on.append(StringName(str(reason)))
	return p


static func ticks(seconds: float) -> int:
	return maxi(0, roundi(seconds / SimClock.TICK_DT))


func interrupted_by(reason: StringName) -> bool:
	return interrupt_on.has(reason)
