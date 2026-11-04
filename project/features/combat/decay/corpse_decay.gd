class_name CorpseDecay
extends RefCounted
## The live fight's leftovers leave the floor (the owner, 2026-11-04: "bring hoards of opponents
## without damaging visibility in longer fights"): corpse_decay.json read into two DecayLedgers,
## `bodies` (standard corpses and the signature kills' body leftovers) and `stains` (the kill
## prints and the blood under them: longer, slower). Both keyed by fighter id and stepped on the
## 60 Hz sim tick (CorpseDecayHook), no RNG. The views read ink_of() and sink_of() (the D5 part
## print discards a part under alpha 0.45 and stipples it above, so a body inks out and sinks
## instead of fading its alpha); nothing here touches a node.

const PATH: String = "res://data/tables/corpse_decay.json"
const SCHEMA: String = "gtai.corpse-decay/1"

var bodies: DecayLedger = DecayLedger.new()
var stains: DecayLedger = DecayLedger.new()
## How far a body shrinks into its stain by the end of its fade (0.95 = to 5 %).
var sink: float = 0.95
## The share of the fade by which the body has turned to ink (0.5 = half way).
var ink_k: float = 0.5
var problems: Array[String] = []


static func shipped() -> CorpseDecay:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> CorpseDecay:
	var d: CorpseDecay = CorpseDecay.new()
	if t.ok():
		var b: Dictionary = t.object(t.raw, "bodies")
		d.bodies = _ledger(t, b)
		d.sink = clampf(t.num(b, "sink"), 0.0, 1.0)
		d.ink_k = clampf(t.num(b, "ink_k"), 0.05, 1.0)
		d.stains = _ledger(t, t.object(t.raw, "stains"))
	d.problems = t.errors()
	return d


static func _ledger(t: DataTable, row: Dictionary) -> DecayLedger:
	return DecayLedger.make(
		t.num(row, "linger_s"), t.num(row, "fade_s"), t.integer(row, "cap"), t.integer(row, "room")
	)


## A fighter died at `tick`: its body and its stain start their clocks.
func add(id: int, tick: int) -> void:
	bodies.add(id, tick)
	stains.add(id, tick)


## A dummy stood up again: its body and stain are whole, nothing to fade.
func forget(id: int) -> void:
	bodies.forget(id)
	stains.forget(id)


func step(tick: int) -> void:
	bodies.step(tick)
	stains.step(tick)


## The body's scale over its plan's: 1 while it lies, down to 1 - sink at the end of its fade
## (it starts shrinking a fifth of the way in, once the ink is showing).
func sink_of(id: int) -> float:
	return 1.0 - sink * smoothstep(0.2, 1.0, bodies.fade_k(id))


## 0 while the body lies, 1 once it is all ink (ink_k of the way into its fade).
func ink_of(id: int) -> float:
	return smoothstep(0.0, ink_k, bodies.fade_k(id))


func write_state(out: StreamPeerBuffer) -> void:
	bodies.write_state(out)
	stains.write_state(out)
