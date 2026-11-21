class_name GauntletSegment
extends RefCounted
## One placed block. All positions below are in world metres, including the station's props.

var id: StringName
var start_x: float
var length_m: float
var bounds: Rect2
var crossing: Rect2
var dressing: Dictionary
var station: ArenaStation = ArenaStation.new()
var spawns: Array[Vector2] = []


func _init(table: DataTable, row: Dictionary, x: float) -> void:
	id = StringName(table.text(row, "id"))
	start_x = x
	length_m = table.num(row, "length_m")
	var origin: Vector2 = Vector2(x, 0.0)
	dressing = table.object(row, "dressing")
	station.id = String(id)
	for prop: Dictionary in table.array(row, "props"):
		var p: ArenaStation.Prop = ArenaStation.Prop.new()
		p.kind = table.text(prop, "kind")
		p.at = origin + table.vec(prop, "at")
		p.size = table.vec(prop, "size")
		var rect: Rect2 = Rect2(p.at - p.size * 0.5, p.size)
		bounds = rect if station.props.is_empty() else bounds.merge(rect)
		station.props.append(p)
	for point: Array in table.array(row, "spawns"):
		spawns.append(origin + table.vec({"at": point}, "at"))
	if row.has("crossing"):
		var paint: Dictionary = table.object(row, "crossing")
		var size: Vector2 = table.vec(paint, "size")
		crossing = Rect2(origin + table.vec(paint, "at") - size * 0.5, size)


## Inside faces of the full-length side walls, inset by the moving body's radius.
func road_bounds(radius: float) -> Rect2:
	var top: float = bounds.position.y
	var bottom: float = bounds.end.y
	for prop: ArenaStation.Prop in station.props:
		if prop.kind != "wall_high" or prop.size.x < length_m:
			continue
		if prop.at.y < bounds.get_center().y:
			top = maxf(top, prop.at.y + prop.size.y * 0.5)
		else:
			bottom = minf(bottom, prop.at.y - prop.size.y * 0.5)
	return Rect2(start_x, top + radius, length_m, bottom - top - 2 * radius)


func end_x() -> float:
	return start_x + length_m
