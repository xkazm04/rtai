extends GutTest
## Quest strings by symbolic key (LOC-01) through tr(), with the @joke overlay (LOC-06) and the
## package-English fallback while no PO carries the key.

const KEY: StringName = &"QUEST__T__LINE__X"

var _translation: Translation = null


func after_each() -> void:
	if _translation != null:
		TranslationServer.remove_translation(_translation)
		_translation = null


func test_keys_are_stable_symbols() -> void:
	assert_eq(QuestText.symbol("the-valet"), "THE_VALET")
	assert_eq(QuestText.symbol("_selftest"), "SELFTEST")
	assert_eq(QuestText.symbol("b1--dumpster!"), "B1_DUMPSTER")
	assert_eq(
		QuestText.line_key("collect-call", "patch-ring-1"),
		&"QUEST__COLLECT_CALL__LINE__PATCH_RING_1"
	)
	assert_eq(QuestText.beat_key("collect-call", "b2"), &"QUEST__COLLECT_CALL__BEAT__B2")
	assert_eq(QuestText.cast_key("don-fax"), &"CAST__DON_FAX")


func test_untranslated_key_falls_back_to_package_english() -> void:
	assert_eq(QuestText.new().resolve(KEY, "source"), "source")
	assert_eq(QuestText.new(true).resolve(KEY, "source"), "source")


func test_translation_wins_and_joke_overlay_needs_the_pref() -> void:
	_add({KEY: "neutral", StringName(String(KEY) + QuestText.JOKE_SUFFIX): "salty"})
	assert_eq(QuestText.new(false).resolve(KEY, "source"), "neutral")
	assert_eq(QuestText.new(true).resolve(KEY, "source"), "salty")


func test_joke_pref_without_variant_keeps_the_base() -> void:
	_add({KEY: "neutral"})
	assert_eq(QuestText.new(true).resolve(KEY, "source"), "neutral")


func _add(messages: Dictionary[StringName, String]) -> void:
	_translation = Translation.new()
	_translation.locale = TranslationServer.get_locale()
	for key: StringName in messages:
		_translation.add_message(key, messages[key])
	TranslationServer.add_translation(_translation)
