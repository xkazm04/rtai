class_name GauntletComposer
extends RefCounted
## A wave has its own sequence within the gauntlet_waves stream, so previewing wave 10
## never changes the roster for wave 2. Tier costs and unlocks come from the shipped tables.

const BOSS: StringName = &"war_machine"

var tiers: Dictionary[StringName, int] = {}
var costs: Dictionary[StringName, int] = {}
var unlocks: Array[int] = []
var boss_every: int
var _base: int
var _per_wave: int
var _stream_seed: int


static func shipped(registry: RngRegistry) -> GauntletComposer:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var roster: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	return GauntletComposer.new(registry, rules, roster.array(roster.raw, "archetypes"))


func _init(registry: RngRegistry, rules: DataTable, rows: Array) -> void:
	_stream_seed = registry.stream(&"gauntlet_waves").seed
	var budget_row: Dictionary = rules.object(rules.raw, "budget")
	_base = rules.integer(budget_row, "base")
	_per_wave = rules.integer(budget_row, "per_wave")
	var unit: int = rules.integer(budget_row, "unit")
	var overrides: Dictionary = rules.raw.get("cost", {})
	boss_every = rules.integer(rules.raw, "boss_every")
	for first_wave: float in rules.array(rules.raw, "tier_unlock_wave"):
		unlocks.append(roundi(first_wave))
	var fallback: Dictionary = rules.object(rules.raw, "tier_map")
	for row: Dictionary in rows:
		var id: String = rules.text(row, "id")
		var tier: int = (
			rules.integer(row, "tier") if row.has("tier") else rules.integer(fallback, id)
		)
		if tier >= 1 and tier <= unlocks.size():
			tiers[StringName(id)] = tier
			costs[StringName(id)] = (
				rules.integer(overrides, id) if overrides.has(id) else tier * unit
			)


func budget(wave: int) -> int:
	return _base + _per_wave * wave


func compose(wave: int) -> Array[StringName]:
	var remaining: int = budget(wave)
	var cheapest: int = remaining
	var eligible: Array[StringName] = []
	var selected: Array[StringName] = []
	var boss: StringName = BOSS if tiers.has(BOSS) else &""
	for id: StringName in tiers:
		var tier: int = tiers[id]
		if id == BOSS or wave < unlocks[tier - 1] or costs[id] > remaining:
			continue
		cheapest = mini(cheapest, costs[id])
		eligible.append(id)
		if boss == &"" or (boss != BOSS and tier > tiers[boss]):
			boss = id
	if wave % boss_every == 0 and boss != &"":
		selected.append(boss)
		eligible.erase(boss)
		remaining = maxi(0, remaining - costs[boss])
	var wave_seed: int = RngRegistry.fnv1a32("%d:%d" % [_stream_seed, wave])
	var rng: RandomNumberGenerator = RngRegistry.new(wave_seed).stream(&"gauntlet_waves")
	@warning_ignore("integer_division")
	for _slot: int in remaining / cheapest:
		var affordable: Array[StringName] = []
		for id: StringName in eligible:
			if costs[id] <= remaining:
				affordable.append(id)
		if affordable.is_empty():
			break
		var id: StringName = affordable[rng.randi_range(0, affordable.size() - 1)]
		selected.append(id)
		remaining -= costs[id]
	return selected
