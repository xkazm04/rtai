class_name StreetHitClass
extends RefCounted
## n17 npc-react (owner: "impact on npcs are terrible"; brief item 5: every hit class reads
## differently at 32 px/m): a LIVING street person struck by a melee or shock blow drew no cell
## of its own (StreetWalkerHit.HOLD_S held only flinch and stagger), so a claw jab, a katana cut
## and an electro tap all read as the same shoved walk. The asset lane's it450 hit-class cells
## (street_hit.py CLASSES: a jab snaps the head back, a heavy blow doubles the body over, a shock
## throws the arms out, the arcs drawn on) now draw for the blow's class, faced by the blow like
## the other hit cells, for HOLD_S from the hit. ON false = the before (the shoved walk).
const ON: bool = true
## Rivet's melee weapon -> the drawn class of its blow (any other melee weapon: jab).
const MELEE: Dictionary[StringName, StringName] = {
	&"claw": &"jab",
	&"dent_jab": &"jab",
	&"katana": &"heavy",
	&"plasma_sword": &"heavy",
	&"chainsaw": &"heavy",
	&"electro_baton": &"shock",
}
## The hit class (non-melee) -> the drawn class: an electro round or stream throws the arms out.
const CLASSES: Dictionary[StringName, StringName] = {&"shock": &"shock"}
## Wound families that draw a class cell (a shield block or a duck into cover keeps its own).
const FAMILIES: Array[StringName] = [&"flinch", &"stagger", &"spin", &"fold", &"stun"]
## Seconds the class cell holds from the blow: a jab as long as a flinch's cell (a combo lands
## 3-4 jabs a second), a heavy blow as a stagger's, a shock through half the stun's convulsion.
const HOLD_S: Dictionary[StringName, float] = {&"jab": 0.2, &"heavy": 0.34, &"shock": 0.5}
## card row -> class -> grid (street_hit.py --only=classes); a row or class absent = no cell.
const GRIDS: Dictionary[String, Dictionary] = {
	"cop/head_cap":
	{
		&"jab": "p70/cop_patrol_jab_hit.png",
		&"heavy": "p70/cop_patrol_heavy_hit.png",
		&"shock": "p70/cop_patrol_shock_hit.png",
	},
	"cop/head_helmet":
	{
		&"jab": "p70/cop_riot_jab_hit.png",
		&"heavy": "p70/cop_riot_heavy_hit.png",
		&"shock": "p70/cop_riot_shock_hit.png",
	},
	"cop/head_swat":
	{
		&"jab": "p70/swat_jab_hit.png",
		&"heavy": "p70/swat_heavy_hit.png",
		&"shock": "p70/swat_shock_hit.png",
	},
}
## The class grids' draw scale (StreetWalkerHit.fill_of), ONE per kind so jab, heavy and shock
## swap without a pop: the standing jab's mean figure height = the kind's walk
## (tools/art/street_hit_size.py; at 1.0 patrol 0.96, riot 0.98 x; the SWAT by all 15 cells,
## 0.925 x: his jab ducks in two facings; the heavy is crouched and stands shorter).
const FILL: Dictionary[String, float] = {
	"cop_patrol_jab_hit.png": 1.04,
	"cop_patrol_heavy_hit.png": 1.04,
	"cop_patrol_shock_hit.png": 1.04,
	"cop_riot_jab_hit.png": 1.02,
	"cop_riot_heavy_hit.png": 1.02,
	"cop_riot_shock_hit.png": 1.02,
	"swat_jab_hit.png": 1.08,
	"swat_heavy_hit.png": 1.08,
	"swat_shock_hit.png": 1.08,
}


## The drawn class of a wounding blow (&"" = none): by Rivet's melee weapon, else by the hit class;
## only for a wound family that draws one.
static func blow_of(hit_class: StringName, weapon: StringName, family: StringName) -> StringName:
	if not ON or not FAMILIES.has(family):
		return &""
	if hit_class == &"melee":
		return MELEE.get(weapon, &"jab")
	return CLASSES.get(hit_class, &"")


## The class grid `row` draws for reaction `r` now ("" = none): a living wound with a drawn blow,
## inside its class's hold, on a row with that class drawn.
static func grid(r: HumanReact, row: String) -> String:
	if not ON or r == null or r.dying or r.blow == &"" or not GRIDS.has(row):
		return ""
	var g: Dictionary = GRIDS[row]
	var hold: float = HOLD_S.get(r.blow, 0.0)
	if not g.has(r.blow) or r.t >= hold:
		return ""
	return str(g[r.blow])
