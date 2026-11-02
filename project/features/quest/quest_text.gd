class_name QuestText
extends RefCounted
## Quest strings by stable symbolic key (LOC-01), resolved through tr() (GDS-08). Keys are
## derived from the package's stable ids, with `__` between fields (kebab ids never produce it):
##   QUEST__COLLECT_CALL__LINE__PATCH_RING_1, QUEST__<quest>__BEAT__<beat>, CAST__<character>.
## Profanity (LOC-06): the base key is the neutral line; with the joke pref on, `<KEY>@joke` is
## used when a translation exists. Until the PO pipeline extracts quest text (tools/po_lint is a
## stub), a key with no translation falls back to the package's English (docs/decisions.md).

const JOKE_SUFFIX: String = "@joke"

var joke: bool = false


static func line_key(quest_id: String, line_id: String) -> StringName:
	return StringName("QUEST__%s__LINE__%s" % [symbol(quest_id), symbol(line_id)])


static func beat_key(quest_id: String, beat_id: String) -> StringName:
	return StringName("QUEST__%s__BEAT__%s" % [symbol(quest_id), symbol(beat_id)])


static func cast_key(character_id: String) -> StringName:
	return StringName("CAST__%s" % symbol(character_id))


## `the-valet` -> `THE_VALET`, `_selftest` -> `SELFTEST`: upper case, every run of other
## characters one `_`, none at the ends.
static func symbol(id: String) -> String:
	var out: String = ""
	for ch: String in id.to_upper():
		var alnum: bool = (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9")
		if alnum:
			out += ch
		elif not out.ends_with("_"):
			out += "_"
	return out.trim_prefix("_").trim_suffix("_")


func _init(p_joke: bool = false) -> void:
	joke = p_joke


## The string to show for `key`: the @joke variant when wanted and translated, else the
## translation, else `source` (the package's English).
func resolve(key: StringName, source: String) -> String:
	if joke:
		var joke_key: String = String(key) + JOKE_SUFFIX
		var variant: String = tr(joke_key)
		if variant != joke_key:
			return variant
	var text: String = tr(key)
	return text if text != String(key) else source
