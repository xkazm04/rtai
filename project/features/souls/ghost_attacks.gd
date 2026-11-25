class_name GhostAttacks
extends RefCounted
## Reader for data/tables/ghost_attacks.json (gtai.ghost_attacks/1): each ghost form's attack
## tuning beyond its powers.json row (lane ghost-powers). One block per ghost; a missing block is
## a load error (ok() false) and reads as zeros.

const PATH: String = "res://data/tables/ghost_attacks.json"
const SCHEMA: String = "gtai.ghost_attacks/1"
const GHOSTS: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]


class DeployRow:
	var enabled: bool
	var range_m: float
	var cooldown_ticks: int
	var life_ticks: int
	var snap_m: float
	var boss_damage_cap: float
	var radius_m: float
	var ram_half_m: float
	## Tonnage only (n31): &"drop" deploys on the key's press edge, &"hold" is the aim-and-release.
	var press_mode: StringName = &"hold"
	## &"aim" = the aim point within range_m, &"rivet" = Rivet's own position.
	var drop_at: StringName = &"aim"
	## Ticks from the press to the dump (round(charge_s x TICK_RATE)).
	var charge_ticks: int = 0
	var dump_damage: float

	func drops() -> bool:
		return press_mode == &"drop"


var blocks: Dictionary[StringName, Dictionary] = {}
var deploy: Dictionary[StringName, DeployRow] = {}
var _errors: Array[String] = []


static func shipped() -> GhostAttacks:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> GhostAttacks:
	var g: GhostAttacks = GhostAttacks.new()
	var deploy_block: Dictionary = t.object(t.raw, "deploy")
	for id: StringName in GHOSTS:
		g.blocks[id] = t.object(t.raw, String(id))
		var row: Dictionary = t.object(deploy_block, String(id))
		var def: DeployRow = DeployRow.new()
		def.enabled = row.get("enabled") == true
		def.range_m = t.num(row, "range_m")
		def.cooldown_ticks = t.integer(row, "cooldown_ticks")
		def.life_ticks = t.integer(row, "life_ticks")
		if id == &"kerf":
			def.boss_damage_cap = t.num(row, "boss_damage_cap")
			def.snap_m = t.num(row, "snap_m")
		elif id == &"ohm":
			def.radius_m = t.num(row, "radius_m")
		elif id == &"dent":
			def.ram_half_m = t.num(row, "ram_half_m")
		elif id == &"tonnage":
			_tonnage(t, row, def)
		g.deploy[id] = def
	g._errors = t.errors()
	return g


static func _tonnage(t: DataTable, row: Dictionary, def: DeployRow) -> void:
	def.press_mode = StringName(t.text(row, "press_mode"))
	def.drop_at = StringName(t.text(row, "drop_at"))
	def.charge_ticks = roundi(t.num(row, "charge_s") * SimClock.TICK_RATE)
	def.radius_m = t.num(row, "radius_m")
	def.dump_damage = t.num(row, "dump_damage")


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
