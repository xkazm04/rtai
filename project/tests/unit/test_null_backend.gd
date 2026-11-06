extends GutTest
## NullBackend: unlock + stat survive a flush and a fresh backend (the local mirror round-trip).

var _mirror_path: String = TestTmp.dir("null_backend").path_join("achievements_mirror.json")


func before_each() -> void:
	_remove_mirror()


func after_each() -> void:
	_remove_mirror()


func test_unlock_and_stat_round_trip_through_the_mirror() -> void:
	var first: NullBackend = NullBackend.new(_mirror_path)
	assert_true(first.start())
	assert_true(first.unlock(AchIds.ACH_CLOCKED_OUT))
	assert_eq(first.inc_stat(AchIds.STAT_CARS_BORROWED, 3), 3)
	assert_true(first.flush())

	var second: NullBackend = NullBackend.new(_mirror_path)
	assert_true(second.start())
	assert_true(second.is_unlocked(AchIds.ACH_CLOCKED_OUT))
	assert_eq(second.get_stat(AchIds.STAT_CARS_BORROWED), 3)
	assert_eq(second.pending_unlocks(), [AchIds.ACH_CLOCKED_OUT] as Array[StringName])


func test_unlock_is_idempotent_and_queues_once() -> void:
	var backend: NullBackend = NullBackend.new(_mirror_path)
	assert_true(backend.start())
	assert_true(backend.unlock(AchIds.ACH_CLOCKED_OUT))
	assert_false(backend.unlock(AchIds.ACH_CLOCKED_OUT))
	assert_eq(backend.pending_unlocks().size(), 1)


func test_corrupt_mirror_starts_empty_and_is_not_overwritten_silently() -> void:
	assert_eq(DirAccess.make_dir_recursive_absolute(_mirror_path.get_base_dir()), OK)
	var file: FileAccess = FileAccess.open(_mirror_path, FileAccess.WRITE)
	assert_true(file.store_string("{not json"))
	file.close()
	var backend: NullBackend = NullBackend.new(_mirror_path)
	assert_true(backend.start())
	assert_false(backend.is_unlocked(AchIds.ACH_CLOCKED_OUT))
	assert_eq(FileAccess.get_file_as_string(_mirror_path), "{not json")


func _remove_mirror() -> void:
	for path: String in [_mirror_path, _mirror_path + ".tmp"]:
		if FileAccess.file_exists(path):
			assert_eq(DirAccess.remove_absolute(path), OK)
