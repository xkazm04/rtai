class_name QuestFailRule
extends RefCounted
## One row of quest_rules.json `fail_rules`: a fail code and its keyword groups. A failure-state
## phrase matches when every group has at least one of its keywords in it as whole words (so
## "cartridge destroyed" is not "car destroyed"; the spike matched substrings).

var code: StringName = &""
## Each group is a list of words; at least one word of every group must occur.
var groups: Array = []


## null when the row is malformed.
static func from_row(row: Variant) -> QuestFailRule:
	if not row is Dictionary:
		return null
	var d: Dictionary = row
	if not d.get("id") is String or not d.get("groups") is Array:
		return null
	var rule: QuestFailRule = QuestFailRule.new()
	rule.code = StringName(str(d["id"]))
	var raw_groups: Array = d["groups"]
	for group: Variant in raw_groups:
		if not group is Array:
			return null
		rule.groups.append(QuestJson.strings(group))
	return rule if not rule.groups.is_empty() else null


func matches(text: String) -> bool:
	var words: String = " %s " % " ".join(PackedStringArray(words_of(text)))
	for group: Variant in groups:
		var keywords: Array[String] = group
		var hit: bool = false
		for keyword: String in keywords:
			if words.contains(" %s " % keyword):
				hit = true
				break
		if not hit:
			return false
	return true


## Lower-case words of `text` (letters and digits; everything else separates).
static func words_of(text: String) -> Array[String]:
	var out: Array[String] = []
	var word: String = ""
	for ch: String in text.to_lower() + " ":
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			word += ch
		elif word != "":
			out.append(word)
			word = ""
	return out
