class_name NoirFluid
extends RefCounted
## The look of one fluid of the noir blood FX (lane noir): blood (blood_fx.json `colour`) or a
## row of `fluids` (oil: white sparks in the air, black on the ground). Colours from data.

var ground: Color
var dark: Color
var sheen: Color
## The colour of a droplet in the air (sparks for oil); the ground colour by default.
var flight: Color
## An ink casing (px) around each droplet in the air; the fluid's own streak (< 0: physics).
var case_px: float = 0.0
var trail: float = -1.0
## A cream rim round each landed splat, in splat radii (oil on asphalt), and its tone; 0 = none.
var halo: float = 0.0
var halo_tone: Color = Color(0.93, 0.9, 0.82)


## A fluid from a colour row: blood, blood_dark, sheen [, flight, case_px, trail].
static func from(d: Dictionary) -> NoirFluid:
	var f: NoirFluid = NoirFluid.new()
	f.ground = NoirPack.rgb(d["blood"])
	f.dark = NoirPack.rgb(d["blood_dark"])
	f.sheen = NoirPack.rgb(d["sheen"])
	f.flight = NoirPack.rgb(d.get("flight", d["blood"]))
	f.case_px = d.get("case_px", 0.0)
	f.trail = d.get("trail", -1.0)
	f.halo = d.get("halo", 0.0)
	if d.has("halo_tone"):
		f.halo_tone = NoirPack.rgb(d["halo_tone"])
	return f
