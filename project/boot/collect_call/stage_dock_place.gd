class_name StageDockPlace
extends RefCounted
## Dock 9 on the city's own dock block (n18 districts item 5, behind --quest1-places): the stage
## points that belong to Dock 9 (collect_call_city.json `dock_place`: its markers, spawn points,
## the crates and their metal) leave the fitted street and sit around the `dock_9` place
## (data/tables/places.json, CityPlaces): the stage anchor (the bonded storage's middle) stands
## out_m in front of the place's door along its facing, the stage's north turned to face the
## building, the street's squash kept. Every other stage point stays on the street.

const FLAG: String = "--quest1-places"
## the stage's "out of the building" direction: Dock 9's crates and vault cage are stage north
const STAGE_FACING: Vector2 = Vector2.DOWN

var ids: Dictionary[String, bool] = {}
var place: Dictionary = {}
var _anchor_stage: Vector2 = Vector2.ZERO
var _anchor_world: Vector2 = Vector2.ZERO
var _squash: Vector2 = Vector2.ONE
var _turn: float = 0.0


## The frame from the `dock_place` row; null when the row or its place does not resolve.
static func make(row: Dictionary, squash: Vector2, places: CityPlaces) -> StageDockPlace:
	var p: Dictionary = places.place(str(row.get("place", "")))
	if p.is_empty():
		Log.error("stage", "dock_place: place %s does not resolve" % row.get("place", ""))
		return null
	var d: StageDockPlace = StageDockPlace.new()
	d.place = p
	var facing: Vector2 = p["facing"]
	var door: Vector2 = p["door"]
	var out_m: float = row.get("out_m", 0.0)
	var anchor: Array = row.get("stage_anchor", [0.0, 0.0])
	var ax: float = anchor[0]
	var ay: float = anchor[1]
	d._anchor_stage = Vector2(ax, ay)
	d._anchor_world = door + facing * out_m
	d._squash = squash
	d._turn = STAGE_FACING.angle_to(facing)
	for key: String in ["markers", "spawn_points", "props"]:
		for id: Variant in row.get(key, []):
			d.ids[str(id)] = true
	return d


## The shipped city's frame (generator + places table): built only when the flag is on.
static func shipped(row: Dictionary, squash: Vector2) -> StageDockPlace:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	return make(row, squash, CityPlaces.shipped(gen))


func has(id: String) -> bool:
	return ids.has(id)


## A Dock 9 stage point in world metres.
func w(p: Vector2) -> Vector2:
	return _anchor_world + ((p - _anchor_stage) * _squash).rotated(_turn)


## A stage offset (metres, not squashed: the metal keeps its true spacing) turned with the dock.
func turn(v: Vector2) -> Vector2:
	return v.rotated(_turn)
