class_name JobStubWorld
extends StubQuestWorld
## StubQuestWorld plus the job-quest port (quest 1 collect-call): cues a test raises, the weapon
## in hand, the asks it records, and the goals a test marks reached. Nothing here simulates; the
## real mechanics are tested in their own features.

const PLACES: String = "res://data/tables/collect_call_places.json"

var cues: Dictionary[String, bool] = {}
var weapon: String = ""
var asks: Array[String] = []
var goals: Dictionary[String, bool] = {}


static func collect_call_places() -> QuestPlaces:
	return QuestPlaces.from_json_text(FileAccess.get_file_as_string(PLACES))


static func collect_call() -> QuestLoader.Result:
	return QuestLoader.load_package("collect-call", QuestRules.shipped(), collect_call_places())


func cue_raised(tag: String) -> bool:
	return cues.get(tag, false)


func weapon_name() -> String:
	return weapon


func ask(what: QuestWorld.Ask, location: String) -> void:
	asks.append("%s %s" % [QuestWorld.Ask.keys()[what], location])


func reached(goal: QuestWorld.Goal, location: String) -> bool:
	return goals.get("%s %s" % [QuestWorld.Goal.keys()[goal], location], false)


func reach(goal: QuestWorld.Goal, location: String) -> void:
	goals["%s %s" % [QuestWorld.Goal.keys()[goal], location]] = true
