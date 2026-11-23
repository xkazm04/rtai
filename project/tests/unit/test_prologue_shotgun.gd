extends GutTest


func test_player_can_draw_and_fire_the_explicit_shotgun() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	assert_true(table.ok())
	assert_false(table.playable().has(&"shotgun"))
	var gun: GunHand = GunHand.make(table, &"shotgun", RngRegistry.new(7).stream(&"gunplay"))
	var spec: WeaponSpec = gun.trigger.spec
	assert_eq(spec.pellets, 8)
	assert_almost_eq(rad_to_deg(spec.spread_rad), 13.0, 0.001)
	assert_eq(spec.magazine, 5)
	assert_eq(spec.interval_ticks, 48)
	assert_eq(spec.reload_ticks, 108)
	assert_eq(spec.shot_cue, &"shotgun")
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	assert_eq(arsenal.weapon_grip[spec.id], &"two_hand_long")
	assert_true(WeaponArt.new().has(arsenal.art_id(spec.id)))
	var held: WeaponHold = WeaponHold.new(arsenal)
	assert_true(held.equip(spec.id))
	for tick: int in arsenal.grip_of(spec.id).draw_ticks:
		held.step()
	assert_true(held.can_fire())
	var rounds: Array[Shot] = gun.pull(Fighter.new(), Vector2.RIGHT)
	assert_eq(rounds.size(), spec.pellets)
	for round: Shot in rounds:
		assert_eq(round.weapon, held.held)
		assert_eq(StageAudio.shot_cue(round), &"shotgun")
		assert_lte(absf(round.vel.angle()), spec.spread_rad)


func test_mulroney_alone_reads_the_enemy_pellet_profile() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	assert_true(roster.ok())
	var gun: EnemyWeapon = roster.weapons[&"shotgun"]
	assert_same(roster.archetype(&"sergeant_mulroney").weapon, gun)
	for foe: EnemyRoster.Archetype in roster.archetypes.values():
		if foe.id != &"sergeant_mulroney":
			assert_ne(foe.weapon, gun, String(foe.id))
	var rifle: EnemyWeapon = roster.weapons[&"rifle"]
	assert_eq(rifle.pellets, 1)
	assert_eq(rifle.spread_rad, 0.0)
	assert_eq(gun.pellets, 8)
	assert_eq(gun.reach_m, 9.0)
	assert_eq(gun.cooldown_ticks, 48)
	assert_almost_eq(rad_to_deg(gun.spread_rad), 13.0, 0.001)
	assert_gt(gun.damage * gun.pellets, rifle.damage * rifle.burst)
	var audio: AudioTables = AudioTables.shipped()
	assert_not_null(audio.cue(&"shotgun"))
	assert_not_null(audio.cue(&"shotgun_pump"))
