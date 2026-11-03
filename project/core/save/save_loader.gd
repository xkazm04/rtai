class_name SaveLoader
extends RefCounted
## Loads the newest slot that survives every check: container (magic, lengths, hash), version,
## and the caller's own `accept` (a checkpoint's replay-to-hash). A slot that fails is
## quarantined (CORRUPT) or left alone (NEWER) and the other slot is tried. Both bad: FRESH, a
## one-line notice, the quarantined files kept for a bug report. Nothing is half-loaded:
## `accept` returns the finished object or null.

enum Status { LOADED, FRESH }


class Outcome:
	extends RefCounted
	var status: Status = Status.FRESH
	var slot: int = -1
	var seq: int = 0
	var point: String = ""
	var body: Dictionary = {}
	## What `accept` returned for the slot that was loaded.
	var value: Variant = null
	var notice_key: StringName = &""
	var notice: String = ""
	var lines: Array[String] = []


## `accept` is Callable(body: Dictionary) -> Variant, null to reject the slot.
static func load_latest(slots: SaveSlots, accept: Callable) -> Outcome:
	var out: Outcome = Outcome.new()
	var removed: int = slots.clear_stale_tmp()
	if removed > 0:
		out.lines.append("removed %d leftover tmp file(s) from a crashed write" % removed)
	var infos: Array[SaveSlots.Info] = slots.scan()
	infos.sort_custom(func(a: SaveSlots.Info, b: SaveSlots.Info) -> bool: return a.seq() > b.seq())
	var skipped: int = 0
	for info: SaveSlots.Info in infos:
		if info.kind == GtsvContainer.Kind.CORRUPT or info.kind == GtsvContainer.Kind.NEWER:
			skipped += 1
			_reject(slots, info, out)
	for info: SaveSlots.Info in infos:
		if info.kind != GtsvContainer.Kind.OK:
			continue
		var value: Variant = accept.call(info.envelope.get("body", {}))
		if value != null:
			return _loaded(out, info, value, skipped)
		info.reason = "the saved state did not re-simulate"
		info.kind = GtsvContainer.Kind.CORRUPT
		skipped += 1
		_reject(slots, info, out)
	out.notice_key = &"SAVE__NOTICE_NONE_READABLE" if skipped > 0 else &""
	if skipped > 0:
		out.notice = "Your saves could not be read. Starting the quest from the start."
	return out


static func _loaded(out: Outcome, info: SaveSlots.Info, value: Variant, skipped: int) -> Outcome:
	out.status = Status.LOADED
	out.slot = info.index
	out.seq = info.seq()
	out.point = str(info.envelope.get("point", ""))
	out.body = info.envelope.get("body", {})
	out.value = value
	if skipped > 0:
		out.notice_key = &"SAVE__NOTICE_FELL_BACK"
		out.notice = "A save was damaged. Loaded the last good one."
	return out


static func _reject(slots: SaveSlots, info: SaveSlots.Info, out: Outcome) -> void:
	var name: String = SaveSlots.IDS[info.index]
	if info.kind == GtsvContainer.Kind.CORRUPT:
		var err: Error = slots.quarantine(info.index)
		out.lines.append(
			"%s corrupt (%s): quarantined (%s)" % [name, info.reason, error_string(err)]
		)
	else:
		out.lines.append("%s refused (%s): left untouched" % [name, info.reason])
