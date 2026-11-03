class_name SaveKit
extends RefCounted
## Helpers for the save tests: a scratch profile root under user://, synchronous writes through
## the real SaveWorker, file poking (truncate, flip, plant), and a directory census.

const SCRATCH: String = "user://test_save"


static func fresh_slots(name: String) -> SaveSlots:
	var root: String = SCRATCH.path_join(name)
	wipe(root)
	return SaveSlots.new(root)


static func wipe(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		for d: String in DirAccess.get_directories_at(path):
			wipe(path.path_join(d))
		for f: String in DirAccess.get_files_at(path):
			@warning_ignore("return_value_discarded")
			DirAccess.remove_absolute(path.path_join(f))
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(path)


## Autosaves `body` through a SaveWorker and waits; the Result.
static func save(slots: SaveSlots, body: Dictionary, point: String = "p") -> SaveWorker.Result:
	var worker: SaveWorker = SaveWorker.new(slots)
	var got: Array[SaveWorker.Result] = []
	@warning_ignore("return_value_discarded")
	worker.finished.connect(func(r: SaveWorker.Result) -> void: got.append(r))
	worker.submit({"point": point, "body": body, "meta": {"quest": "q", "beat": point}})
	worker.flush()
	return got[0]


static func bytes_of(path: String) -> PackedByteArray:
	return FileAccess.get_file_as_bytes(path)


static func put(path: String, bytes: PackedByteArray) -> void:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_buffer(bytes)
	f.close()


static func truncate(path: String, keep: int) -> void:
	put(path, bytes_of(path).slice(0, keep))


static func flip(path: String, at: int) -> void:
	var b: PackedByteArray = bytes_of(path)
	b[at] = b[at] ^ 0xFF
	put(path, b)


## Every file under `path`, relative, sorted.
static func census(path: String, prefix: String = "") -> Array[String]:
	var out: Array[String] = []
	for f: String in DirAccess.get_files_at(path):
		out.append(prefix + f)
	for d: String in DirAccess.get_directories_at(path):
		out.append_array(census(path.path_join(d), prefix + d + "/"))
	out.sort()
	return out


static func accept_all(body: Dictionary) -> Variant:
	return body


static func n_of(body: Dictionary) -> int:
	return GtsvContainer.as_int(body.get("n"))
