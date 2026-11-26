extends GutTest
## --foe-fire presets: B (share 0.75, pistol/rifle 1.5) ships (owner, n31); "calm" is the old A.


func _roster() -> EnemyRoster:
	return EnemyRoster.shipped(EnemyRoster.TABLE, true)


func test_default_production_roster_is_the_shipped_setting() -> void:
	var r: EnemyRoster = _roster()
	assert_eq(r.max_shooters_share, 0.75)
	assert_eq(r.own_damage[&"pistol"], 1.5)
	assert_eq(r.own_damage[&"rifle"], 1.5)
	assert_eq(r.own_damage[&"cannon"], 8.0)


func test_calm_preset_restores_the_old_setting_a() -> void:
	var r: EnemyRoster = _roster()
	assert_true(r.apply_fire_preset("calm"))
	assert_eq(r.max_shooters_share, 0.5)
	assert_eq(r.own_damage[&"pistol"], 3.0)
	assert_eq(r.own_damage[&"rifle"], 2.0)


func test_hot_preset_overrides_share_and_damage() -> void:
	var r: EnemyRoster = _roster()
	assert_true(r.apply_fire_preset("hot"))
	assert_eq(r.max_shooters_share, 0.75)
	assert_eq(r.own_damage[&"pistol"], 1.5)
	assert_eq(r.own_damage[&"rifle"], 1.5)
	assert_eq(r.own_damage[&"cannon"], 8.0)
	assert_true(r.own_weapons)


func test_unknown_preset_changes_nothing() -> void:
	var r: EnemyRoster = _roster()
	assert_false(r.apply_fire_preset("nope"))
	assert_eq(r.max_shooters_share, 0.75)
	assert_eq(r.own_damage[&"pistol"], 1.5)
