class_name RigCardSets
extends RefCounted
## The per view art rows of RigHeadCard (RigHeadCard.SET_CARDS): view.json `art` -> art_dir or
## art_dir/head part -> [strip, anchor y, width over the anchor part's, bust, raw], the row shape
## of RigHeadCard.CARDS. An empty path keeps the base strip and changes the rest. p55: Rivet's bust
## (rivet_bust.py), Dent's tan bust (ghost_card_tone.py), the street heads (street_head.py, from the
## assets library's keyed 55 sheets). p70: view70's widths for its own strips; the street
## heads reuse the p55 strips (view70 it5 REQUEST: compare the pitch, not two street art sets);
## Dent's p70 bust is cut from the library's dent_70 (n8), its width over the wider 70 cell.
## n8: the other lanes register their own rows without editing this file: one
## data/tables/card_sets/<lane>.json each (schema gtai.card-set/1), merged over SETS by all().

const SETS: Dictionary[String, Dictionary] = {
	"p55":
	{
		"rivet":
		["res://features/characters/art/view/p55/rivet_bust_card.png", 0.66, 1.25, true, true],
		"dent":
		["res://features/characters/art/view/p55/dent_bust_card.png", 0.75, 1.75, true, true],
		"cop/head_swat":
		["res://features/characters/art/view/p55/swat_head_card.png", 0.8, 1.68, false, true],
		"cop/head_cap":
		["res://features/characters/art/view/p55/cop_cap_card.png", 0.78, 1.73, false, true],
		"cop/head_helmet":
		["res://features/characters/art/view/p55/cop_riot_card.png", 0.82, 1.32, false, true],
		"ped/head_hair":
		["res://features/characters/art/view/p55/ped_hair_card.png", 0.74, 2.0, false, true],
		"ped/head_bald":
		["res://features/characters/art/view/p55/ped_bald_card.png", 0.74, 1.9, false, true],
		"ped/head_hat":
		["res://features/characters/art/view/p55/ped_hat_card.png", 0.74, 1.93, false, true],
		"ped/head_hood":
		["res://features/characters/art/view/p55/ped_hood_card.png", 0.74, 1.81, false, true],
		"ped/head_cap":
		["res://features/characters/art/view/p55/ped_cap_card.png", 0.74, 2.3, false, true],
		"thug":
		["res://features/characters/art/view/p55/thug_head_card.png", 0.86, 1.0, false, true],
	},
	"p70":
	{
		"rivet": ["", 0.86, 1.17, false, true],
		"king": ["", 0.80, 3.53, true, true],
		"dent":
		["res://features/characters/art/view/p70/dent_bust_card.png", 0.72, 2.1, true, true],
		"cop/head_swat":
		["res://features/characters/art/view/p55/swat_head_card.png", 0.8, 1.68, false, true],
		"cop/head_cap":
		["res://features/characters/art/view/p55/cop_cap_card.png", 0.78, 1.73, false, true],
		"cop/head_helmet":
		["res://features/characters/art/view/p55/cop_riot_card.png", 0.82, 1.32, false, true],
		"ped/head_hair":
		["res://features/characters/art/view/p55/ped_hair_card.png", 0.74, 2.0, false, true],
		"ped/head_bald":
		["res://features/characters/art/view/p55/ped_bald_card.png", 0.74, 1.9, false, true],
		"ped/head_hat":
		["res://features/characters/art/view/p55/ped_hat_card.png", 0.74, 1.93, false, true],
		"ped/head_hood":
		["res://features/characters/art/view/p55/ped_hood_card.png", 0.74, 1.81, false, true],
		"ped/head_cap":
		["res://features/characters/art/view/p55/ped_cap_card.png", 0.74, 2.3, false, true],
		"thug":
		["res://features/characters/art/view/p55/thug_head_card.png", 0.86, 1.0, false, true],
	},
}

const REG_DIR: String = "res://data/tables/card_sets"

static var _all: Dictionary[String, Dictionary] = {}


## SETS with every lane's card_sets/<lane>.json merged over it (files in name order; a later
## row replaces an earlier one). Read once per run.
static func all() -> Dictionary[String, Dictionary]:
	if _all.is_empty():
		_all = merged(REG_DIR)
	return _all


## SETS merged with the registration files under `dir` (a test points this at its own dir).
static func merged(dir: String) -> Dictionary[String, Dictionary]:
	var out: Dictionary[String, Dictionary] = {}
	for art: String in SETS:
		out[art] = SETS[art].duplicate()
	var files: PackedStringArray = DirAccess.get_files_at(dir)
	files.sort()
	for f: String in files:
		if f.get_extension() == "json":
			_merge_file(out, dir.path_join(f))
	return out


static func _merge_file(out: Dictionary[String, Dictionary], path: String) -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		Log.warn("view", "card set %s does not parse; skipped" % path)
		return
	var doc: Dictionary = parser.data
	var sets: Dictionary = doc.get("sets", {})
	for art: String in sets:
		if not out.has(art):
			out[art] = {}
		var rows: Dictionary = sets[art]
		for key: String in rows:
			var r: Dictionary = rows[key]
			out[art][key] = row_of(r)


## One registration row -> the positional row shape of RigHeadCard.CARDS.
static func row_of(r: Dictionary) -> Array:
	var anchor_y: float = r["anchor_y"]
	var width: float = r["width"]
	return [str(r["strip"]), anchor_y, width, r["bust"] == true, r["raw"] == true]
