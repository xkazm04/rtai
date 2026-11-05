class_name GhostAttacks
extends RefCounted
## Reader for data/tables/ghost_attacks.json (gtai.ghost_attacks/1): each ghost form's attack
## tuning beyond its powers.json row (lane ghost-powers). One block per ghost; a missing block is
## a load error (ok() false) and reads as zeros.

const PATH: String = "res://data/tables/ghost_attacks.json"
const SCHEMA: String = "gtai.ghost_attacks/1"
const GHOSTS: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]

var blocks: Dictionary[StringName, Dictionary] = {}
var _errors: Array[String] = []


static func shipped() -> GhostAttacks:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> GhostAttacks:
	var g: GhostAttacks = GhostAttacks.new()
	for id: StringName in GHOSTS:
		g.blocks[id] = t.object(t.raw, String(id))
	g._errors = t.errors()
	return g


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors.duplicate()


## The ghost's tuning block (empty when missing).
func block(ghost: StringName) -> Dictionary:
	return blocks.get(ghost, {})


## One number of a ghost's block (0 when missing).
func num(ghost: StringName, key: StringName) -> float:
	return SoulTuning.num(block(ghost), key)
