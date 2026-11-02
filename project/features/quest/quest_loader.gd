class_name QuestLoader
extends RefCounted
## Loads `<root>/<id>/quest.json` (gtai.quest/1, PoF games/gtai/quests/<id>/ copied into the
## project's quests/<id>/) as JSON data (DAT-02, SEC-02: the JSON class, never str_to_var or
## .tres), validates it (QuestValidator) and only then builds the typed QuestPackage. A package
## with any error comes back as package == null plus the report: never half-built (DAT-05).

const ROOT: String = "res://quests"
const FILE: String = "quest.json"


class Result:
	extends RefCounted
	var package: QuestPackage = null
	var report: QuestReport = QuestReport.new()


static func load_package(
	id: String, rules: QuestRules, places: QuestPlaces, root: String = ROOT
) -> Result:
	var path: String = root.path_join(id).path_join(FILE)
	var result: Result = Result.new()
	if not FileAccess.file_exists(path):
		result.report.error(path, "file not found")
		return result
	var raw: Dictionary = QuestJson.parse_object(FileAccess.get_file_as_string(path))
	if raw.is_empty():
		result.report.error(path, "not a JSON object")
		return result
	return from_dict(raw, id, rules, places)


static func from_dict(
	raw: Dictionary, id: String, rules: QuestRules, places: QuestPlaces
) -> Result:
	var result: Result = Result.new()
	for e: String in rules.errors() + places.errors():
		result.report.error("setup", e)
	if not result.report.ok():
		return result
	result.report = QuestValidator.new(rules).check(raw, id, places)
	if result.report.ok():
		result.package = QuestBuilder.build(raw, rules)
	return result
