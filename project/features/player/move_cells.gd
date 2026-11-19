class_name MoveCells
extends RefCounted
## One active move on the rig. The views choose an actual strip and facing from their feed.
## The character renderer can then place the selected cell without depending on either view.

const DIR: String = "res://features/characters/art/rivet/moves/"
const TABLE: String = "res://data/tables/rivet_moves.json"
const ACTIVE: StringName = &"rivet_move_cell"
const VAULT: StringName = &"vault_cell"
const COVER: StringName = &"cover_cell"
static var _frames: Dictionary[StringName, int] = {}

var owner: StringName
var art: String
var path: String
var frame: int
var resolution: float
var foot_y: float


static func vault_cell(frame_no: int, ticks: int, enabled: bool) -> StringName:
	if not enabled or frame_no < 0 or frame_no >= ticks:
		return &""
	return &"vault_land" if frame_no * 3 >= ticks * 2 else &"vault_plant"


static func cover_cell(inside: bool, low: bool, enabled: bool) -> StringName:
	if not inside or not enabled:
		return &""
	return &"cover_low" if low else &"cover_high"


static func frame_of(pose: StringName, left: bool) -> int:
	if _frames.is_empty():
		var table: DataTable = DataTable.open(TABLE, "gtai.rivet-moves/1")
		var cells: Array = table.array(table.raw, "cells")
		for i: int in cells.size():
			_frames[StringName(str(cells[i]))] = i
	var id: StringName = StringName(String(pose) + "_left") if left else pose
	return _frames.get(id, -1)


static func strip(pitch: String, density: float) -> String:
	var file: String = "rivet_moves_x15.png" if density > 1.0 else "rivet_moves.png"
	return DIR + pitch + "/" + file


static func path_or(rig: Node, pitch: String, fallback: String) -> String:
	if fallback.is_empty() or not rig.has_meta(ACTIVE):
		return fallback
	var selected: MoveCells = rig.get_meta(ACTIVE)
	return selected.path if selected.art == pitch else fallback


static func shows(card: Sprite2D) -> bool:
	return card != null and card.texture != null and card.texture.resource_path.begins_with(DIR)


static func draw(rig: Node2D, card: Sprite2D, scale_px: float) -> bool:
	if not rig.has_meta(ACTIVE) or not shows(card):
		return false
	var selected: MoveCells = rig.get_meta(ACTIVE)
	card.frame = selected.frame
	card.flip_h = false
	var width: float = card.texture.get_width() / float(card.hframes)
	card.offset = Vector2(-width * 0.5, -selected.foot_y)
	card.global_rotation = 0.0
	card.global_scale = Vector2.ONE * scale_px / selected.resolution
	card.global_position = rig.global_position
	return true
