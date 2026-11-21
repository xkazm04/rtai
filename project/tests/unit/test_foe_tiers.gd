extends GutTest

const TIERS: Dictionary[StringName, int] = {
	&"patrol_cop": 1,
	&"riot_cop": 2,
	&"swat": 2,
	&"contractor": 2,
	&"robot_thug": 3,
	&"robot_gunner": 3,
	&"rocket_trooper": 2,
	&"sentry_turret": 3,
	&"shield_robot": 4,
	&"war_machine": 5
}
const NEW_WEAPONS: Array[StringName] = [&"rocket", &"turret_gun", &"shove", &"war_cannon", &"stomp"]


func test_shipped_enemy_tiers_rounds_and_tells() -> void:
	var table: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	assert_true(roster.ok(), str(roster.errors()))
	_check_tiers(table, roster)
	_check_rounds(table)
	_check_tells(roster)
	assert_true(table.ok(), str(table.errors()))


func _check_tiers(table: DataTable, roster: EnemyRoster) -> void:
	var seen: Dictionary[StringName, bool] = {}
	for row: Dictionary in table.array(table.raw, "archetypes"):
		var id: StringName = StringName(table.text(row, "id"))
		var tier: float = table.num(row, "tier")
		# Godot reads JSON numbers as floats, including integer literals.
		assert_eq(tier, floorf(tier), String(id))
		assert_between(tier, 1.0, 5.0, String(id))
		var loaded: EnemyRoster.Archetype = roster.archetype(id)
		assert_not_null(loaded, String(id))
		if loaded != null:
			assert_eq(loaded.tier, int(tier), String(id))
			if TIERS.has(id):
				assert_eq(loaded.tier, TIERS[id], String(id))
		assert_false(seen.has(id), String(id))
		seen[id] = true
	for id: StringName in TIERS:
		assert_has(seen, id)


func _check_rounds(table: DataTable) -> void:
	var weapons: Dictionary = table.object(table.raw, "weapons")
	for id: StringName in NEW_WEAPONS:
		assert_has(weapons, id)
	for id: String in weapons:
		var row: Dictionary = table.object(weapons, id)
		if StringName(id) in NEW_WEAPONS:
			assert_has(row, "round", id)
		var declared: StringName = (
			StringName(table.text(row, "round")) if row.has("round") else Shot.SMALL
		)
		assert_has([Shot.SMALL, Shot.LARGE], declared, id)
		assert_eq(EnemyRounds.size_of(StringName(id)), declared, id)


func _check_tells(roster: EnemyRoster) -> void:
	for id: StringName in [&"rocket_trooper", &"sentry_turret", &"shield_robot", &"war_machine"]:
		var arch: EnemyRoster.Archetype = roster.archetype(id)
		assert_not_null(arch, String(id))
		if arch == null:
			continue
		assert_gte(arch.telegraph_ticks, 20, String(arch.weapon.id))
		if id == &"war_machine":
			assert_not_null(arch.alt_weapon, "stomp")
		if arch.alt_weapon != null:
			assert_gte(arch.alt_telegraph_ticks, 20, String(arch.alt_weapon.id))
