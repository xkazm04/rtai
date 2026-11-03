class_name SaveSlots
extends RefCounted
## The two autosave slots (SAV-06): `<root>/auto_a/state.sav` and `<root>/auto_b/state.sav`, plus
## `<root>/meta.json`. Reads classify each slot; the write target is always the older one; a
## corrupt slot is quarantined to `state.sav.corrupt` (the newest one per slot only, so the file
## count stays bounded). A NEWER slot is never a target and never renamed (SAV-04).

const IDS: Array[String] = ["auto_a", "auto_b"]
const FILE: String = "state.sav"
const META: String = "meta.json"

var root: String


class Info:
	extends RefCounted
	var index: int = 0
	var kind: GtsvContainer.Kind = GtsvContainer.Kind.MISSING
	var reason: String = ""
	var envelope: Dictionary = {}

	func seq() -> int:
		return GtsvContainer.as_int(envelope.get("seq")) if kind == GtsvContainer.Kind.OK else -1


func _init(p_root: String) -> void:
	root = p_root


func slot_path(index: int) -> String:
	return root.path_join(IDS[index]).path_join(FILE)


func meta_path() -> String:
	return root.path_join(META)


func read(index: int) -> Info:
	var info: Info = Info.new()
	info.index = index
	var path: String = slot_path(index)
	if not FileAccess.file_exists(path):
		return info
	var decoded: GtsvContainer.Decoded = GtsvContainer.decode(FileAccess.get_file_as_bytes(path))
	info.kind = decoded.kind
	info.reason = decoded.reason
	if decoded.kind == GtsvContainer.Kind.OK:
		info.envelope = SaveMigrations.migrate(decoded.envelope)
	return info


func scan() -> Array[Info]:
	return [read(0), read(1)]


## Highest valid sequence number across both slots, or 0 when there is none.
func highest_seq(infos: Array[Info]) -> int:
	return maxi(infos[0].seq(), infos[1].seq()) if infos[0].seq() >= 0 or infos[1].seq() >= 0 else 0


## Slot index for the next write, or -1 when both slots belong to a newer game.
## Missing and corrupt slots first, then the valid slot with the lower sequence number.
func pick_target(infos: Array[Info]) -> int:
	var best: int = -1
	var best_rank: int = 1 << 60
	for info: Info in infos:
		if info.kind == GtsvContainer.Kind.NEWER:
			continue
		var rank: int = info.seq() if info.kind == GtsvContainer.Kind.OK else -1
		if rank < best_rank:
			best_rank = rank
			best = info.index
	return best


## Renames the slot's file to `state.sav.corrupt` (replacing the previous one).
func quarantine(index: int) -> Error:
	var path: String = slot_path(index)
	var dead: String = path + ".corrupt"
	if FileAccess.file_exists(dead):
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(dead)
	return DirAccess.rename_absolute(path, dead)


## Removes tmp files a crash mid-write left behind; the number removed.
func clear_stale_tmp() -> int:
	var removed: int = 0
	for index: int in IDS.size():
		var tmp: String = SlotFile.tmp_path(slot_path(index))
		if FileAccess.file_exists(tmp) and DirAccess.remove_absolute(tmp) == OK:
			removed += 1
	return removed
