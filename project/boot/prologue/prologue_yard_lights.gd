class_name PrologueYardLights
extends RefCounted
## A dressing supplies its own print inks. Each view owns its LightLayer and its light slots.


class Pool:
	extends RefCounted
	var kind: StringName
	var at_m: Vector2


var grade: Dictionary
var kinds: Dictionary[StringName, Dictionary] = {}
var pools: Array[Pool] = []


func _init(table: DataTable, row: Dictionary) -> void:
	grade = table.object(row, "grade")
	for source: Dictionary in table.array(row, "kinds"):
		var kind: Dictionary = source.duplicate()
		kind["color"] = Color(table.text(source, "color"))
		kind["alt_color"] = Color(table.text(source, "alt_color"))
		kinds[StringName(table.text(source, "id"))] = kind
	for source: Dictionary in table.array(row, "pools"):
		var pool: Pool = Pool.new()
		pool.kind = StringName(table.text(source, "kind"))
		pool.at_m = table.vec(source, "at")
		pools.append(pool)


func install(layer: LightLayer) -> void:
	var id: StringName = StringName(str(grade["id"]))
	layer.grades[id] = grade
	layer.kinds.merge(kinds)
	layer.set_grade(id)
	for pool: Pool in pools:
		@warning_ignore("return_value_discarded")
		layer.add(pool.kind, pool.at_m * SimConst.PX_PER_M, 0.0, 0)
