class_name PrologueYard
extends ArenaPlan
## The floor art, Rivet's collision boxes and police navigation share one set of metre footprints.


class Wreck:
	extends RefCounted
	var id: String
	var footprint: Rect2
	var art: String


var yard: Rect2
var sidewalk: Rect2
var street: Rect2
var far_sidewalk: Rect2
var gate: Vector2
var exit_open: bool = false
var gate_width_m: float
var fences: Array[Rect2] = []
var wrecks: Array[Wreck] = []
var scorch_marks: Array[Rect2] = []
var stations: ArenaStations = ArenaStations.new()


static func from_stage(data: DataTable) -> PrologueYard:
	var plan: PrologueYard = PrologueYard.new()
	plan.rivet_start = data.vec(data.raw, "rivet_start")
	plan.yard = Rect2(Vector2.ZERO, data.vec(data.raw, "yard_size_m"))
	var layout: Dictionary = data.object(data.raw, "yard")
	plan._perimeter(data, layout)
	var station: ArenaStation = ArenaStation.new()
	for fence: Rect2 in plan.fences:
		station.props.append(_prop(fence, "wall_high"))
	for row: Dictionary in data.array(layout, "cover"):
		var wreck: Wreck = Wreck.new()
		wreck.id = data.text(row, "id")
		wreck.footprint = _rect(data, row)
		wreck.art = data.text(row, "art")
		plan.wrecks.append(wreck)
		station.props.append(_prop(wreck.footprint, "cover_high"))
	for row: Dictionary in data.array(layout, "scorch_marks"):
		plan.scorch_marks.append(_rect(data, row))
	plan.stations.stations.append(station)
	return plan


func _perimeter(data: DataTable, layout: Dictionary) -> void:
	var width: float = yard.size.x
	var depth: float = data.num(layout, "fence_depth_m")
	sidewalk = Rect2(0.0, yard.end.y, width, data.num(layout, "sidewalk_depth_m"))
	street = Rect2(0.0, sidewalk.end.y, width, data.num(layout, "street_depth_m"))
	far_sidewalk = Rect2(0.0, street.end.y, width, sidewalk.size.y)
	gate = Vector2(data.num(layout, "gate_x_m"), yard.end.y)
	gate_width_m = data.num(layout, "gate_width_m")
	var left: float = gate.x - gate_width_m * 0.5
	var right: float = gate.x + gate_width_m * 0.5
	fences = [
		Rect2(-depth, -depth, width + depth * 2.0, depth),
		Rect2(-depth, 0.0, depth, far_sidewalk.end.y),
		Rect2(width, 0.0, depth, far_sidewalk.end.y),
		Rect2(-depth, far_sidewalk.end.y, width + depth * 2.0, depth),
		Rect2(0.0, gate.y - depth, left, depth),
		Rect2(right, gate.y - depth, width - right, depth),
	]
	# The double gate stands open into the yard, a leaf along each side of the entry.
	var leaf: float = gate_width_m * 0.5
	fences.append(Rect2(left - depth, gate.y - leaf, depth, leaf))
	fences.append(Rect2(right, gate.y - leaf, depth, leaf))
	var area_row: ArenaPlan.Area = ArenaPlan.Area.new()
	area_row.id = "yard"
	area_row.rect = yard.merge(far_sidewalk)
	areas.append(area_row)


static func _rect(data: DataTable, row: Dictionary) -> Rect2:
	var size_m: Vector2 = data.vec(row, "size_m")
	return Rect2(data.vec(row, "at") - size_m * 0.5, size_m)


static func _prop(rect: Rect2, kind: String) -> ArenaStation.Prop:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.at = rect.get_center()
	prop.size = rect.size
	prop.kind = kind
	return prop
