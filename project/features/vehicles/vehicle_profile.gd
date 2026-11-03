class_name VehicleProfile
extends RefCounted
## One archetype's handling numbers (data/tables/vehicle_handling.json, gtai.vehicle_handling/1),
## plus the shared damage and run-over rules. load_all() reads the table once; ids are the stable
## snake_case archetype ids (sedan, taxi, van, pickup, police_cruiser, ambulance, hatchback).

const TABLE: String = "res://data/tables/vehicle_handling.json"
const SCHEMA: String = "gtai.vehicle_handling/1"
const FIELDS: PackedStringArray = [
	"mass",
	"vmax",
	"reverse_max",
	"accel",
	"brake",
	"drag",
	"grip",
	"slide_grip",
	"drift_at",
	"handbrake_grip",
	"steer_rate",
]

var id: StringName = &""
var mass: float = 1450.0
var vmax: float = 28.0
var reverse_max: float = 6.0
var accel: float = 9.5
var brake: float = 18.0
var drag: float = 2.4
var grip: float = 18.0
var slide_grip: float = 6.5
var drift_at: float = 2.7
var handbrake_grip: float = 0.25
var steer_rate: float = 2.5


## Every profile in the table, by id.
static func load_all(path: String = TABLE) -> Dictionary[StringName, VehicleProfile]:
	var out: Dictionary[StringName, VehicleProfile] = {}
	var t: DataTable = DataTable.open(path, SCHEMA)
	for row: Variant in t.array(t.raw, "profiles"):
		var d: Dictionary = row if row is Dictionary else {}
		var p: VehicleProfile = VehicleProfile.new()
		p.id = StringName(t.text(d, "id"))
		for f: String in FIELDS:
			p.set(f, t.num(d, f))
		out[p.id] = p
	if not t.ok():
		Log.error("vehicles", str(t.errors()))
	return out


## The archetype of a sim car art id (the d4 traffic atlas cell: 0-2 sedans, 3 taxi, 4 van,
## 5 pickup, 6 ambulance, 7 grey sedan, 8 cruiser). sedan_b drives as the hatchback profile.
static func archetype_of_variant(variant: int, police: bool) -> StringName:
	if police:
		return &"police_cruiser"
	const BY_CELL: Array[StringName] = [
		&"sedan",
		&"hatchback",
		&"sedan",
		&"taxi",
		&"van",
		&"pickup",
		&"ambulance",
		&"sedan",
		&"sedan"
	]
	return BY_CELL[posmod(variant, BY_CELL.size())]
