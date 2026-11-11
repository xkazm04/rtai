class_name StreetHitClass
extends RefCounted
## n17 npc-react (owner: "impact on npcs are terrible"; brief item 5: every hit class reads
## differently at 32 px/m): a LIVING street person struck by a melee or shock blow drew no cell
## of its own (StreetWalkerHit.HOLD_S held only flinch and stagger), so a claw jab, a katana cut
## and an electro tap all read as the same shoved walk. The asset lane's it450 hit-class cells
## (street_hit.py CLASSES: a jab snaps the head back, a heavy blow doubles the body over, a shock
## throws the arms out, the arcs drawn on) now draw for the blow's class, faced by the blow like
## the other hit cells, for HOLD_S from the hit. ON false or the launch flag --hit-class=off = the
## before (the shoved walk), so a film's before and after run one build at the same tick.
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
## card row -> class -> grid (street_hit.py --only=classes); a row or class absent = no cell (the
## hat, elder and shopper have no shock drawn: their stun keeps the shoved walk, as before).
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
	"thug":
	{
		&"jab": "p70/thug_jab_hit.png",
		&"heavy": "p70/thug_heavy_hit.png",
		&"shock": "p70/thug_shock_hit.png",
	},
	"ped/head_hair":
	{
		&"jab": "p70/ped_suit_jab_hit.png",
		&"heavy": "p70/ped_suit_heavy_hit.png",
		&"shock": "p70/ped_suit_shock_hit.png",
	},
	"ped/head_hood":
	{
		&"jab": "p70/ped_hood_jab_hit.png",
		&"heavy": "p70/ped_hood_heavy_hit.png",
		&"shock": "p70/ped_hood_shock_hit.png",
	},
	"ped/head_cap":
	{
		&"jab": "p70/ped_cap_jab_hit.png",
		&"heavy": "p70/ped_cap_heavy_hit.png",
		&"shock": "p70/ped_cap_shock_hit.png",
	},
	"ped/head_worker":
	{
		&"jab": "p70/ped_worker_jab_hit.png",
		&"heavy": "p70/ped_worker_heavy_hit.png",
		&"shock": "p70/ped_worker_shock_hit.png",
	},
	"ped/head_jogger":
	{
		&"jab": "p70/ped_jogger_jab_hit.png",
		&"heavy": "p70/ped_jogger_heavy_hit.png",
		&"shock": "p70/ped_jogger_shock_hit.png",
	},
	"ped/head_punk":
	{
		&"jab": "p70/ped_punk_jab_hit.png",
		&"heavy": "p70/ped_punk_heavy_hit.png",
		&"shock": "p70/ped_punk_shock_hit.png",
	},
	"ped/head_hat":
	{
		&"jab": "p70/ped_hat_jab_hit.png",
		&"heavy": "p70/ped_hat_heavy_hit.png",
	},
	"ped/head_bald":
	{
		&"jab": "p70/ped_elder_jab_hit.png",
		&"heavy": "p70/ped_elder_heavy_hit.png",
	},
	"ped/head_shopper":
	{
		&"jab": "p70/ped_shopper_jab_hit.png",
		&"heavy": "p70/ped_shopper_heavy_hit.png",
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
	# assets it454: the thug and six pedestrians (jab and heavy; none drew a shock), the jab at the
	# walk (the thug's: his thrown cell, he walks as parts); before fill: thug 0.97, suit 0.93,
	# hood 0.98, cap 0.93, worker 0.90, jogger 0.91, punk 1.00 x (cap, jogger, punk 0.01 under the
	# jab's: their heavy stood 3.4-3.7 % over the walk).
	"thug_jab_hit.png": 1.03,
	"thug_heavy_hit.png": 1.03,
	"ped_suit_jab_hit.png": 1.07,
	"ped_suit_heavy_hit.png": 1.07,
	"ped_hood_jab_hit.png": 1.03,
	"ped_hood_heavy_hit.png": 1.03,
	"ped_cap_jab_hit.png": 1.07,
	"ped_cap_heavy_hit.png": 1.07,
	"ped_worker_jab_hit.png": 1.11,
	"ped_worker_heavy_hit.png": 1.11,
	"ped_jogger_jab_hit.png": 1.09,
	"ped_jogger_heavy_hit.png": 1.09,
	"ped_punk_jab_hit.png": 0.99,
	"ped_punk_heavy_hit.png": 0.99,
	# assets it458: their shock at the kind's one FILL; the hat, elder and shopper jab and heavy
	"thug_shock_hit.png": 1.03,
	"ped_suit_shock_hit.png": 1.07,
	"ped_hood_shock_hit.png": 1.03,
	"ped_cap_shock_hit.png": 1.07,
	"ped_worker_shock_hit.png": 1.11,
	"ped_jogger_shock_hit.png": 1.05,  # the tossed ponytail and smoke stand 6.7 % over at 1.09
	"ped_punk_shock_hit.png": 0.99,
	"ped_hat_jab_hit.png": 1.05,
	"ped_hat_heavy_hit.png": 1.05,
	"ped_elder_jab_hit.png": 1.06,
	"ped_elder_heavy_hit.png": 1.06,
	"ped_shopper_jab_hit.png": 1.16,
	"ped_shopper_heavy_hit.png": 1.16,
}
## --hit-class=off read once: -1 unread, 1 off.
static var _off: int = -1


## The drawn class of a wounding blow (&"" = none): by Rivet's melee weapon, else by the hit class;
## only for a wound family that draws one.
static func blow_of(hit_class: StringName, weapon: StringName, family: StringName) -> StringName:
	if not on() or not FAMILIES.has(family):
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


## ON, unless the run was launched with --hit-class=off (read once).
static func on() -> bool:
	if _off < 0:
		_off = 1 if LaunchArgs.value("--hit-class") == "off" else 0
	return ON and _off == 0
