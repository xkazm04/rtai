class_name StreetCopWalk
extends RefCounted
## Lane d9 seams: an armed city cop under a view row with a grid here draws as one whole-figure
## card with the weapon drawn in its hands (the library's armed walk sheets, street_walk.py, toned
## to the cop head cards' navy by street_tone.py; the riot sheet's orange armband greyed by
## street_armband.py), stepping by the gait phase like StreetWalkerCards' peds. Every city cop is
## armed from tick 60, so before this they glided on head cards over top-down parts.
## The grid holds through aiming and firing (the drawn arms already point the weapon along the
## facing; swapping on every shot flickers); a baton strike, a throw or a reload goes to the parts,
## which draw that action. Dying goes to StreetWalkerFall's grids as before. ENABLED false = the
## head cards over parts (before); a row with no grid draws its head card over the parts.
const ENABLED: bool = true
## view art -> card row -> armed walk grid (5 facings across, 4 stride frames down).
const WALKS: Dictionary[String, Dictionary] = {
	"p70":
	{
		"cop/head_cap": "cop_patrol_armed_walk.png",
		"cop/head_helmet": "cop_riot_armed_walk.png",
		"cop/head_swat": "swat_armed_walk.png",
	},
	"p55":
	{
		"cop/head_cap": "cop_patrol_armed_walk.png",
		"cop/head_helmet": "cop_riot_armed_walk.png",
		"cop/head_swat": "swat_armed_walk.png",
	},
}
## The size step per grid, keyed "<art>/<file>" (as StreetWalkerCards.WALK_FILL): the still
## strip's figure fill (0.985 of the cell) over the grid's mean figure height in the cell.
const FILL: Dictionary[String, float] = {
	"p70/cop_patrol_armed_walk.png": 1.12,
	"p70/cop_riot_armed_walk.png": 1.11,
	"p70/swat_armed_walk.png": 1.14,
	"p55/cop_patrol_armed_walk.png": 1.08,
	"p55/cop_riot_armed_walk.png": 1.08,
	"p55/swat_armed_walk.png": 1.07,
}


## The armed walk grid for a living cop now ("" = none: no grid for this row/pitch, or an action
## the parts draw).
static func strip_of(rig: CutRig, art: String, row: String) -> String:
	if not ENABLED or rig.plan.art_dir != "cop" or StreetWalkerFall.down(rig):
		return ""
	if rig.strike_arm >= 0 or rig.throw_t >= 0.0 or rig.reload_k >= 0.0:
		return ""
	var rows: Dictionary = WALKS.get(art, {})
	return StreetWalkerCards.DIR + art + "/" + str(rows[row]) if rows.has(row) else ""


## The size step for a grid's resource path (1.0 = not one of ours).
static func fill_of(path: String) -> float:
	return FILL.get(path.get_base_dir().get_file() + "/" + path.get_file(), 1.0)
