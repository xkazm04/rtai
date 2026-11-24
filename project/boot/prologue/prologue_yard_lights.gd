class_name PrologueYardLights
extends RefCounted
## A dressing supplies its own print inks. Each view owns its LightLayer and its light slots.


class Pool:
	extends RefCounted
	var id: StringName
	var kind: StringName
	var at_m: Vector2


var grade: Dictionary
var kinds: Dictionary[StringName, Dictionary] = {}
var pools: Array[Pool] = []
var _floor: Dictionary[StringName, Dictionary] = {}


func _init(table: DataTable, row: Dictionary) -> void:
	grade = table.object(row, "grade")
	for source: Dictionary in table.array(row, "kinds"):
		var kind: Dictionary = source.duplicate()
		kind["color"] = Color(table.text(source, "color"))
		kind["alt_color"] = Color(table.text(source, "alt_color"))
		kinds[StringName(table.text(source, "id"))] = kind
		if source.has("floor_glow"):
			_read_glow(
				table, StringName(table.text(source, "id")), table.object(source, "floor_glow")
			)
	for source: Dictionary in table.array(row, "pools"):
		var pool: Pool = Pool.new()
		pool.id = StringName(table.text(source, "id"))
		pool.kind = StringName(table.text(source, "kind"))
		pool.at_m = table.vec(source, "at")
		pools.append(pool)


func _read_glow(table: DataTable, kind: StringName, row: Dictionary) -> void:
	_floor[kind] = {
		"color": Color(table.text(row, "color")),
		"radius_m": table.num(row, "radius_m"),
		"strength": table.num(row, "strength"),
	}


## The floor glow of a pool kind (color, radius_m, strength), or empty when the kind has none.
func floor_glow(kind: StringName) -> Dictionary:
	return _floor.get(kind, {})


func install(layer: LightLayer) -> void:
	var id: StringName = StringName(str(grade["id"]))
	layer.grades[id] = grade
	layer.kinds.merge(kinds)
	layer.set_grade(id)
	for pool: Pool in pools:
		@warning_ignore("return_value_discarded")
		layer.add(pool.kind, pool.at_m * SimConst.PX_PER_M, 0.0, 0)
