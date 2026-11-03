class_name NoirShowcaseArgs
extends RefCounted
## The showcase fight's launch flags (lane noir, dev only; see showcase_fight.gd for usage).
## --out=<dir> --zoom=<z> --ink --d4 --noir-parts --coat --flashes=off --at=<x>,<y> --cars=<n>
## --car-pass. Unknown flags fail the run.

const KNOWN_FLAGS: PackedStringArray = [
	"--out",
	"--zoom",
	"--ink",
	"--d4",
	"--noir-parts",
	"--coat",
	"--flashes",
	"--at",
	"--cars",
	"--car-pass"
]

var out: String = "user://noir"
var zoom: float = 1.5
var ink: bool = false
var d4: bool = false
## --noir-parts: the rigs wear the noir part redraws (same sizes, same alpha, same pivots).
var noir_parts: bool = false
var at: Vector2 = NoirFrames.JUNCTION
## --cars=<n>: traffic cars around the fight (their headlights light the street). NOT for the hero:
## the sim's cars do not see the scripted fighters and drive through them.
var cars: int = 0
var coat: bool = false
var car_pass: bool = false
## --flashes=<v> as given ("" = not given: the params decide; "off" = the flashes-off mode).
var flashes: String = ""


## Reads `args` (the user args); false on an unknown flag.
func parse(args: PackedStringArray) -> bool:
	for arg: String in args:
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("showcase_fight: unknown argument %s" % arg)
			return false
		var v: String = arg.substr(flag.length() + 1)
		if flag == "--out":
			out = v
		elif flag == "--zoom":
			zoom = v.to_float()
		elif flag == "--cars":
			cars = v.to_int()
		elif flag == "--at":
			at = Vector2(v.get_slice(",", 0).to_float(), v.get_slice(",", 1).to_float())
		elif flag == "--flashes":
			flashes = v
		else:
			_switch(flag)
	return true


func _switch(flag: String) -> void:
	d4 = d4 or flag == "--d4"
	noir_parts = noir_parts or flag == "--noir-parts"
	car_pass = car_pass or flag == "--car-pass"
	coat = coat or flag == "--coat"
	ink = ink or flag == "--ink"
