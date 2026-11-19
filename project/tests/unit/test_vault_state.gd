extends GutTest
## Vault start, protection-window bounds and target identity as observed by replay.


func test_last_protected_frame_must_exist_in_the_vault() -> void:
	var t: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var settings: Dictionary = t.object(t.raw, "vault")
	var ticks: int = t.integer(settings, "ticks")
	var vault: PlayerVault = PlayerVault.new()
	settings["iframe_to"] = ticks - 1
	assert_true(vault.configure(t).is_empty())
	settings["iframe_to"] = ticks
	assert_false(vault.configure(t).is_empty())


func _take_off(hidden_in: String = "") -> ArenaStage:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	VaultTrial.approach_crate(stage)
	stage.hidden_in = hidden_in
	stage.step(0, VaultTrial.sample(stage, Vector2.DOWN, true))
	return stage


func test_taking_off_from_hiding_exposes_the_first_drawn_step() -> void:
	var stage: ArenaStage = _take_off("test_hide")
	var vault: PlayerVault = stage.pilot.motion.vault
	assert_eq(vault.frame, 0)
	assert_eq(stage.hidden_in, "")
	assert_gt(vault.lift(), 0.0)


func test_station_and_city_targets_have_distinct_replay_bytes() -> void:
	var stage: ArenaStage = _take_off()
	var vault: PlayerVault = stage.pilot.motion.vault
	var station: StreamPeerBuffer = StreamPeerBuffer.new()
	vault.write_state(station, stage.pilot.motion.phase)
	vault.hit.city_prop = VaultCity.Prop.new()
	var street: StreamPeerBuffer = StreamPeerBuffer.new()
	vault.write_state(street, stage.pilot.motion.phase)
	assert_eq(station.data_array.decode_u8(0), 0)
	assert_eq(street.data_array.decode_u8(0), 1)
	assert_eq(station.data_array.slice(1), street.data_array.slice(1))
