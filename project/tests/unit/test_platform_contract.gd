extends GutTest
## One contract suite run against both NullBackend and FakeBackend (TST-06).

const MIRROR_PATH: String = "user://test_tmp/contract/achievements_mirror.json"


func after_each() -> void:
	if FileAccess.file_exists(MIRROR_PATH):
		assert_eq(DirAccess.remove_absolute(MIRROR_PATH), OK)


func test_null_backend_honours_the_contract() -> void:
	_check_contract(NullBackend.new(MIRROR_PATH))


func test_fake_backend_honours_the_contract() -> void:
	_check_contract(FakeBackend.new())


func test_failed_store_is_reported() -> void:
	var fake: FakeBackend = FakeBackend.new()
	fake.fail_flush = true
	watch_signals(fake)
	assert_false(fake.flush())
	assert_signal_emitted(fake, "store_failed")


func _check_contract(backend: PlatformBackend) -> void:
	watch_signals(backend)
	assert_true(backend.start(), "start")
	assert_false(backend.is_unlocked(AchIds.ACH_CLOCKED_OUT), "starts locked")
	assert_true(backend.unlock(AchIds.ACH_CLOCKED_OUT), "first unlock")
	assert_false(backend.unlock(AchIds.ACH_CLOCKED_OUT), "second unlock is a no-op")
	assert_signal_emit_count(backend, "achievement_confirmed", 1)
	assert_true(backend.set_stat(AchIds.STAT_CARS_BORROWED, 2), "set_stat")
	assert_eq(backend.inc_stat(AchIds.STAT_CARS_BORROWED, 5), 7, "inc_stat")
	assert_true(backend.flush(), "flush")
	assert_false(backend.cloud_enabled(), "no cloud offline")
	assert_true(backend.profile_dir().begins_with("user://"), "profile under user://")
	backend.shutdown()
