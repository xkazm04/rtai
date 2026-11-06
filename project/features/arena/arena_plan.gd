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
	## The floor stencils `name` (ArenaFloorView); a boss fight clears it (its HUD bar's band).
	var stenciled: bool = true


var base: Vector2 = Vector2.ZERO
var rivet_start: Vector2 = Vector2.ZERO
var zoom_ppm: Array[float] = [32.0]
var areas: Array[Area] = []
## The pit's wave rule as read (ArenaPit.from_plan reads its numbers).
var pit: Dictionary = {}
## Where the hub sits on the generated city for the proving block (--arena=city).
var city_base: Vector2 = Vector2.ZERO
## --rigs: the SHOOT recoil strength per weapon id (a weapon not listed kicks 1.0).
var rig_kick: Dictionary[StringName, float] = {}
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
	p.pit = t.object(t.raw, "pit")
	p.city_base = t.vec(t.object(t.raw, "city"), "base")
	var kicks: Dictionary = t.object(t.raw, "rig_kick")
	for w: Variant in kicks:
		p.rig_kick[StringName(str(w))] = t.num(kicks, str(w))
	p.errors = t.errors()
	return p


## The recoil strength a shot of this weapon plays on its rig (1.0 when the table has none).
func kick(weapon: StringName) -> float:
	return rig_kick.get(weapon, 1.0)


func area(id: String) -> Area:
	for a: Area in areas:
		if a.id == id:
			return a
	return null
