class_name QuestFixture
extends RefCounted
## The quest-runtime test fixtures: the spike's `_selftest` gtai.quest/1 package (evolve
## quest-runtime f2fa88f, verbatim) and the yard places table it names; the shipped collect-call
## package (res://quests/, copied verbatim from PoF) with its STUB places; mutation helpers.

const ROOT: String = "res://tests/support/quests"
const ID: String = "_selftest"
const PLACES: String = "res://tests/support/quests/places.json"
const CC_ID: String = "collect-call"
const CC_PLACES: String = "res://tests/support/quests/collect_call_places.json"


static func places() -> QuestPlaces:
	return QuestPlaces.from_json_text(FileAccess.get_file_as_string(PLACES))


static func cc_places() -> QuestPlaces:
	return QuestPlaces.from_json_text(FileAccess.get_file_as_string(CC_PLACES))


static func cc_load() -> QuestLoader.Result:
	return QuestLoader.load_package(CC_ID, QuestRules.shipped(), cc_places())


## A fresh deep copy of the fixture's quest.json, to mutate.
static func raw() -> Dictionary:
	var path: String = ROOT.path_join(ID).path_join(QuestLoader.FILE)
	return QuestJson.parse_object(FileAccess.get_file_as_string(path)).duplicate(true)


static func load_raw(p: Dictionary) -> QuestLoader.Result:
	return QuestLoader.from_dict(p, ID, QuestRules.shipped(), places())


static func package() -> QuestPackage:
	return QuestLoader.load_package(ID, QuestRules.shipped(), places(), ROOT).package


## The fixture's raw beat `i` objective, for mutations.
static func objective(p: Dictionary, i: int) -> Dictionary:
	var beats: Array = p["beats"]
	var beat: Dictionary = beats[i]
	var o: Dictionary = beat["objective"]
	return o


static func line_row(p: Dictionary, i: int) -> Dictionary:
	var lines: Array = p["lines"]
	var l: Dictionary = lines[i]
	return l


static func difficulty(p: Dictionary) -> Dictionary:
	var d: Dictionary = p["difficulty"]
	return d
