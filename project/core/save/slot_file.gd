class_name SlotFile
extends RefCounted
## The SAV-03 write for one file: tmp -> flush -> close -> read back and verify length and
## hash -> rename over the target. With two rotating slots there is no `.bak`: the other slot is
## the fallback, and a write only ever targets the older one. A failure removes the tmp and
## leaves the target exactly as it was (or, in the one window between Windows' delete-then-
## rename steps, absent, which the other slot covers).

## Test seam: called with the tmp path after it is closed and before it is verified.
static var after_tmp: Callable = Callable()


static func tmp_path(path: String) -> String:
	return path + ".tmp"


static func write(path: String, bytes: PackedByteArray) -> Error:
	var made: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if made != OK:
		return made
	var tmp: String = tmp_path(path)
	var file: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var stored: bool = file.store_buffer(bytes)
	file.flush()
	file.close()
	if not stored:
		return _drop(tmp, ERR_FILE_CANT_WRITE)
	if after_tmp.is_valid():
		after_tmp.call(tmp)
	var back: PackedByteArray = FileAccess.get_file_as_bytes(tmp)
	if back != bytes:
		return _drop(tmp, ERR_FILE_CORRUPT)
	var err: Error = DirAccess.rename_absolute(tmp, path)
	if err != OK and FileAccess.file_exists(path):
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(path)
		err = DirAccess.rename_absolute(tmp, path)
	return err if err == OK else _drop(tmp, err)


static func _drop(tmp: String, err: Error) -> Error:
	if FileAccess.file_exists(tmp):
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(tmp)
	return err
