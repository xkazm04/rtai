extends GutTest
## n7-ranged (it15): the heavy guns and the homing shard voice a shot of their own. On main the
## rocket played the pistol shot, the mini-nuke Rivet's quiet joint whine, the hand cannon
## Gloria's nail-gun pop and the shard the generic pistol shot.

const LIGHT: Array[StringName] = [&"pistol", &"machine_pistol", &"gloria"]
const HEAVY: Array[StringName] = [&"hand_cannon", &"rocket_launcher", &"mini_nuke"]


func _light_cues(table: WeaponTable) -> Array[StringName]:
	var out: Array[StringName] = [&"shot", &"servo"]
	for id: StringName in LIGHT:
		out.append(table.weapon(id).shot_cue)
	return out


func test_heavy_guns_and_the_shard_do_not_borrow_a_light_shot() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var light: Array[StringName] = _light_cues(table)
	for id: StringName in HEAVY + [&"homing_shard"]:
		var cue: StringName = table.weapon(id).shot_cue
		assert_false(light.has(cue), "%s plays %s, a light gun's or a generic cue" % [id, cue])


func test_heavy_shots_sound_lower_and_the_shard_higher() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var tables: AudioTables = AudioTables.shipped()
	for id: StringName in HEAVY:
		var cue: AudioCue = tables.cue(table.weapon(id).shot_cue)
		assert_not_null(cue, "%s: its cue exists" % id)
		if cue != null:
			assert_lt(cue.pitch, 0.8, "%s: a heavy shot is pitched down" % id)
			assert_gt(cue.max_m, 60.0, "%s: heard further than a pistol" % id)
	var shard: AudioCue = tables.cue(table.weapon(&"homing_shard").shot_cue)
	assert_not_null(shard)
	if shard != null:
		assert_gt(shard.pitch, 1.3, "the shard's flick is pitched up")
		assert_lt(shard.gain_db, -3.0, "and quieter than a gun")


## it16: the Gatling shared the contractors' rifle shot with the machine pistol; its own cue sits
## under them (a heavier rumble) and over the tube's launch thump.
func test_gatling_has_its_own_heavier_shot() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var tables: AudioTables = AudioTables.shipped()
	var cue_id: StringName = table.weapon(&"gatling").shot_cue
	assert_ne(cue_id, table.weapon(&"machine_pistol").shot_cue, "not the machine pistol's shot")
	assert_ne(cue_id, &"shot_assault_rifle", "not the contractors' rifle")
	var cue: AudioCue = tables.cue(cue_id)
	assert_not_null(cue, "gatling: its cue exists")
	if cue != null:
		assert_lt(cue.pitch, tables.cue(&"shot_assault_rifle").pitch, "lower than the rifle")
		assert_gt(cue.pitch, tables.cue(&"shot_tube").pitch, "over the tube's thump")


## it16: the electro gun, plasma rifle and ray gun fired Rivet's own hurt cue
## (player_hit_robo_tazer: non-positional, a 10-tick cooldown that voiced every other ray round
## and muted a real tazer hit). Each has its own crackle now: plasma low, electro, ray high.
func test_no_gun_fires_a_hurt_cue_and_the_zaps_are_apart() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	for id: StringName in table.weapons:
		var cue: String = str(table.weapon(id).shot_cue)
		assert_false(cue.begins_with("player_hit"), "%s plays %s, a hurt cue" % [id, cue])
	var tables: AudioTables = AudioTables.shipped()
	var plasma: AudioCue = tables.cue(table.weapon(&"plasma_rifle").shot_cue)
	var electro: AudioCue = tables.cue(table.weapon(&"electro_gun").shot_cue)
	var ray: AudioCue = tables.cue(table.weapon(&"ray_gun").shot_cue)
	assert_true(plasma != null and electro != null and ray != null, "the three cues exist")
	if plasma != null and electro != null and ray != null:
		assert_lt(plasma.pitch, electro.pitch, "the plasma rifle is the heavier crack")
		assert_gt(ray.pitch, electro.pitch, "the ray gun the thinner zip")
		assert_lt(ray.cooldown_ticks, 6, "every ray round (one per 6 ticks) voices")


## it16: the molotov's landing had only projectile_end (a concrete tick); its fire burst now has
## a small ignition whoomp, lighter and quieter than the rocket's blast.
func test_molotov_bursts_with_a_whoomp_under_the_blast() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var tables: AudioTables = AudioTables.shipped()
	var cue: AudioCue = tables.cue(table.weapon(&"molotov").end_cue)
	var blast: AudioCue = tables.cue(table.weapon(&"rocket_launcher").end_cue)
	assert_not_null(cue, "the molotov has an end cue")
	if cue != null and blast != null:
		assert_gt(cue.pitch, blast.pitch, "lighter than the blast")
		assert_lt(cue.gain_db, blast.gain_db - 4.0, "well under the blast")
