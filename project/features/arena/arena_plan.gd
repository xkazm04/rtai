class_name ArenaPlan
extends RefCounted
## The arena's floor plan (data/tables/arena.json, gtai.arena/1): the areas (rects in metres from
## the hub), where Rivet starts and the zoom steps. `base` puts the hub in world metres.

const TABLE: String = "res://data/tables/arena.json"
const SCHEMA: String = "gtai.arena/1"


class Area:
	extends RefCounted
	var id: String = ""
	var name: String = ""
	var rect: Rect2 = Rect2()


var base: Vector2 = Vector2.ZERO
var rivet_start: Vector2 = Vector2.ZERO
var zoom_ppm: Array[float] = [32.0]
var areas: Array[Area] = []
var errors: Array[String] = []


static func shipped(p_base: Vector2 = Vector2.ZERO) -> ArenaPlan:
	var p: ArenaPlan = ArenaPlan.new()
	p.base = p_base
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	p.rivet_start = p_base + t.vec(t.raw, "rivet_start")
	p.zoom_ppm.clear()
	for z: Variant in t.array(t.raw, "zoom_ppm"):
		p.zoom_ppm.append(t.num({"z": z}, "z"))
	for v: Variant in t.array(t.raw, "areas"):
		var d: Dictionary = v if v is Dictionary else {}
		var a: Area = Area.new()
		a.id = t.text(d, "id")
		a.name = t.text(d, "name")
		var r: Array = t.array(d, "rect")
		if r.size() == 4:
			var at: Vector2 = t.vec({"v": [r[0], r[1]]}, "v")
			a.rect = Rect2(p_base + at, t.vec({"v": [r[2], r[3]]}, "v"))
		p.areas.append(a)
	p.errors = t.errors()
	return p


func area(id: String) -> Area:
	for a: Area in areas:
		if a.id == id:
			return a
	return null
