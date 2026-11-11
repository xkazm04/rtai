extends GutTest
## Lane kills-new (n16): the molotov's own death. The sim names every fire death `burn`;
## KillFireSource names the fire that set him alight (CombatArena.struck), so the molotov takes
## molotov_torch and the flamethrower keeps burn_char. View side only.


func _fighter(id: int) -> Fighter:
	var f: Fighter = Fighter.new()
	f.id = id
	return f


func _kills(gore: String = "full") -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args(gore)
	return SignatureKills.new(table, RngRegistry.new(5).stream(&"brutality"))


func _burn_kill(src: KillFireSource, victim: int) -> KillEvent:
	var e: KillEvent = KillEvent.make(
		victim, Vector2.ONE, Vector2.RIGHT, src.weapon_of(victim, &"burn")
	)
	e.damage_type = &"burned"
	return e


func test_a_burn_death_names_the_fire_that_last_hit_him() -> void:
	var src: KillFireSource = KillFireSource.new()
	src.on_struck(_fighter(1), Vector2.RIGHT, false, &"flamethrower")
	src.on_struck(_fighter(2), Vector2.RIGHT, false, &"molotov")
	src.on_struck(_fighter(2), Vector2.RIGHT, false, &"pistol")
	assert_eq(src.weapon_of(1, &"burn"), &"flamethrower")
	assert_eq(src.weapon_of(2, &"burn"), &"molotov", "a pistol hit is not a fire")
	assert_eq(src.weapon_of(3, &"burn"), KillFireSource.PATCH, "walked into a ground fire")
	assert_eq(src.weapon_of(1, &"pistol"), &"pistol", "any other kill unchanged")


func test_the_molotov_burns_as_a_torch_and_the_flamethrower_still_chars() -> void:
	var src: KillFireSource = KillFireSource.new()
	src.on_struck(_fighter(1), Vector2.RIGHT, false, &"flamethrower")
	src.on_struck(_fighter(2), Vector2.RIGHT, false, &"molotov")
	var k: SignatureKills = _kills()
	assert_true(k.on_kill(_burn_kill(src, 1)))
	assert_true(k.on_kill(_burn_kill(src, 2)))
	var burn: int = k.by_style.get(&"burn", 0)
	var torch: int = k.by_style.get(&"torch", 0)
	assert_eq(burn, 1, "the flamethrower: burn_char")
	assert_eq(torch, 1, "the molotov: molotov_torch")


func test_reduced_gore_drops_the_burning_man_whole() -> void:
	var src: KillFireSource = KillFireSource.new()
	var k: SignatureKills = _kills("reduced")
	assert_false(k.on_kill(_burn_kill(src, 4)), "--gore=reduced = the standard death")
	assert_true(k.consumed.is_empty())
