class_name TestTmp
extends RefCounted
## The per-worktree, per-process scratch root for tests and scenarios:
## user://test_tmp/<worktree-id>/<pid>/. user:// is one shared folder for every checkout of the
## repo (use_custom_user_dir), so concurrent runs from two worktrees (or two runs from one) must
## never share a path. The worktree id is a short hash of the res:// directory, so it needs no
## launcher support. Tests and scenarios take every scratch path from here (the lint bans the
## raw user://test_tmp and user://test_save literals under tests/).
##
## Old run dirs of THIS worktree are pruned once per process on first use. Godot cannot probe
## a foreign pid (OS.is_process_running only knows children it spawned), so liveness is
## approximated by age: a run dir whose stamp is older than MAX_AGE_SEC is dead (a run lasts
## minutes). prune() refuses any path that is not directly under this worktree's folder, never
## touches the running pid's own dir, and never leaves user://test_tmp/<this worktree id>/.

const BASE: String = "user://test_tmp"
const STAMP: String = ".stamp"
const MAX_AGE_SEC: int = 86400

static var _root: String = ""


## The run root for this worktree and pid (created, and old runs pruned, on first call).
static func root() -> String:
	if _root == "":
		var wt_root: String = BASE.path_join(worktree_id())
		_root = wt_root.path_join(str(OS.get_process_id()))
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(_root)
		_touch(_root)
		@warning_ignore("return_value_discarded")
		prune(wt_root, _root, int(Time.get_unix_time_from_system()), MAX_AGE_SEC)
	return _root


## A created subdirectory of the run root.
static func dir(sub: String) -> String:
	var path: String = root().path_join(sub)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(path)
	return path


## Short stable id of this checkout: differs per worktree path, same across runs.
static func worktree_id() -> String:
	var here: String = ProjectSettings.globalize_path("res://").to_lower().replace("\\", "/")
	return here.trim_suffix("/").md5_text().substr(0, 8)


## True only for a path strictly inside user://test_tmp/<this worktree id>/ (no `..`).
static func is_own(path: String) -> bool:
	var prefix: String = BASE.path_join(worktree_id()) + "/"
	return path.begins_with(prefix) and path.length() > prefix.length() and not ".." in path


## Removes the run dirs under `wt_root` (one worktree's folder) whose stamp is older than
## `max_age` seconds at `now`, never `keep`. Refuses (returns 0) a `wt_root` outside this
## worktree's folder. Returns how many it removed.
static func prune(wt_root: String, keep: String, now: int, max_age: int) -> int:
	if not is_own(wt_root.path_join("x")):
		return 0
	var removed: int = 0
	for run: String in DirAccess.get_directories_at(wt_root):
		var path: String = wt_root.path_join(run)
		if path == keep or now - _stamp_time(path) <= max_age:
			continue
		_remove_tree(path)
		removed += 1
	return removed


static func _touch(path: String) -> void:
	var f: FileAccess = FileAccess.open(path.path_join(STAMP), FileAccess.WRITE)
	if f != null:
		f.close()


static func _stamp_time(path: String) -> int:
	var stamp: String = path.path_join(STAMP)
	if FileAccess.file_exists(stamp):
		return FileAccess.get_modified_time(stamp)
	return FileAccess.get_modified_time(path)


static func _remove_tree(path: String) -> void:
	if not is_own(path):
		return
	for d: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(d))
	for f: String in DirAccess.get_files_at(path):
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(path.path_join(f))
	@warning_ignore("return_value_discarded")
	DirAccess.remove_absolute(path)
