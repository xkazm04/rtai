class_name QuestReport
extends RefCounted
## What the quest loader found: errors block the package, warnings only describe it.
## Every message starts with the JSON path it is about (`beats[1].objective.verb: ...`).

var errors: Array[String] = []
var warnings: Array[String] = []


func error(at: String, message: String) -> void:
	errors.append("%s: %s" % [at, message])


func warn(at: String, message: String) -> void:
	warnings.append("%s: %s" % [at, message])


func ok() -> bool:
	return errors.is_empty()
