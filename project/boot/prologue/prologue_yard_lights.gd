class_name PrologueYardLights
extends RefCounted
## A dressing supplies its own print inks. Each view owns its LightLayer and its light slots.

var grade: Dictionary
var kinds: Dictionary[StringName, Dictionary] = {}


func _init(table: DataTable, row: Dictionary) -> void:
	grade = table.object(row, "grade")
	for source: Dictionary in table.array(row, "kinds"):
		var kind: Dictionary = source.duplicate()
		kind["color"] = Color(table.text(source, "color"))
		kind["alt_color"] = Color(table.text(source, "alt_color"))
		kinds[StringName(table.text(source, "id"))] = kind


func install(layer: LightLayer) -> void:
	var id: StringName = StringName(str(grade["id"]))
	layer.grades[id] = grade
	layer.kinds.merge(kinds)
	layer.set_grade(id)
