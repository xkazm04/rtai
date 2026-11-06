extends GutTest


func test_root_is_scoped_to_worktree_and_pid() -> void:
	var root: String = TestTmp.root()
	assert_true(root.begins_with(TestTmp.BASE.path_join(TestTmp.worktree_id())))
	assert_true(root.ends_with("/" + str(OS.get_process_id())))
	assert_eq(TestTmp.worktree_id().length(), 8)


func test_dir_creates_the_subdirectory() -> void:
	assert_true(DirAccess.dir_exists_absolute(TestTmp.dir("unit_probe/deep")))


func test_prune_removes_only_stale_run_dirs_of_the_worktree() -> void:
	var wt: String = TestTmp.dir("prune_probe")
	var stale: String = wt.path_join("111")
	var fresh: String = wt.path_join("222")
	var mine: String = wt.path_join("333")
	for d: String in [stale, fresh, mine]:
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(d.path_join("sub"))
		var f: FileAccess = FileAccess.open(d.path_join("sub").path_join("x"), FileAccess.WRITE)
		f.close()
	var now: int = int(Time.get_unix_time_from_system())
	assert_eq(TestTmp.prune(wt, mine, now + 1000, 500), 2, "stale + fresh both age out at +1000")
	assert_true(DirAccess.dir_exists_absolute(mine), "the keep dir is never removed")
	assert_false(DirAccess.dir_exists_absolute(stale))
	assert_eq(TestTmp.prune(wt, "", now, 500), 0, "nothing under max_age is removed")
	assert_true(DirAccess.dir_exists_absolute(mine))


func test_prune_refuses_paths_outside_this_worktrees_folder() -> void:
	var other: String = TestTmp.BASE.path_join("ffffffff_not_me")
	var victim: String = other.path_join("999")
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(victim)
	var far: int = int(Time.get_unix_time_from_system()) + 10_000_000
	assert_eq(TestTmp.prune(other, "", far, 1), 0, "another worktree's folder is refused")
	assert_true(DirAccess.dir_exists_absolute(victim), "and left intact")
	assert_eq(TestTmp.prune(TestTmp.BASE, "", far, 1), 0, "the shared base is refused")
	assert_eq(TestTmp.prune("user://", "", far, 1), 0)
	assert_false(TestTmp.is_own(TestTmp.root().path_join("../../x")), "no .. escapes")
	assert_false(TestTmp.is_own(TestTmp.BASE.path_join(TestTmp.worktree_id())), "the folder itself")
	assert_true(TestTmp.is_own(TestTmp.root()))
	@warning_ignore("return_value_discarded")
	DirAccess.remove_absolute(victim)
	@warning_ignore("return_value_discarded")
	DirAccess.remove_absolute(other)
