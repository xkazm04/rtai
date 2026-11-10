class_name StreetWalkerHit
extends RefCounted
## n11 combat (owner: "character reactions on being shot/killed is poor"): under a view row with a
## whole-figure card the wound families (ReactPose) moved only the hidden parts, so a body that took
## a round and lived did not visibly react at the game's view. Now the wound shoves and tips the
## card along the blow, and for a kind with a drawn hit grid (art/view/p70/<kind>_hit.png, 5 facings
## by 1, tools/art/street_hit.py) the figure draws thrown back off the planted boot for the first
## part of the family. The grid is picked by the blow, not the body's facing: the drawn pose arches
## away from the shot, so the figure drawn is the one facing the shooter, from any side. ON false =
## the card ignores wounds (the before).
const ON: bool = true
const DRAWN: bool = true
## card row -> hit grid, drawn under every view art (p55's bosses reuse the p70 sheets).
const GRIDS: Dictionary[String, String] = {
	"cop/head_cap": "p70/cop_patrol_hit.png",
	"cop/head_helmet": "p70/cop_riot_hit.png",
	"cop/head_swat": "p70/swat_hit.png",
	"ped/head_hair": "p70/ped_suit_hit.png",
	"ped/head_worker": "p70/ped_worker_hit.png",
	"thug": "p70/thug_hit.png",
	"ped/head_hood": "p70/ped_hood_hit.png",
	"ped/head_cap": "p70/ped_cap_hit.png",
	"ped/head_bald": "p70/ped_elder_hit.png",
	"ped/head_hat": "p70/ped_hat_hit.png",
	"ped/head_jogger": "p70/ped_jogger_hit.png",
	"ped/head_punk": "p70/ped_punk_hit.png",
	"ped/head_shopper": "p70/ped_shopper_hit.png",
}
## it14: a kind with drawn wound sites (the asset lane's shoulder clutch and gut fold, street_hit.py
## SITES) draws them on a LIVING wound: a flinch clutches the shoulder, a stagger folds over the
## gut; the thrown-back cell stays the death's opening. SITES false = every wound the thrown cell.
const SITES: bool = true
const SITE_GRIDS: Dictionary[String, Dictionary] = {
	"cop/head_cap":
	{&"flinch": "p70/cop_patrol_shoulder_hit.png", &"stagger": "p70/cop_patrol_gut_hit.png"},
}
## Family -> seconds the drawn cell holds from the blow (the rest of the family is the shoved walk).
const HOLD_S: Dictionary[StringName, float] = {&"flinch": 0.2, &"stagger": 0.34}
## A death of these kinds opens on the same thrown-back cell over the fall grid's buckle (a body
## wilting on its feet read as no hit at all), until StreetWalkerFall's mid-fall frame takes it.
const DEATH_KINDS: Array[StringName] = [&"death_bullet", &"death_blast", &"death_melee"]
## it21: a drawn hit cell fills its cell's height (street_hit.py) but is drawn from a shallower
## camera than the walk strips and fall grids, so its head and torso drew at about 0.65 x the
## walking figure's: walk -> shrink -> grow over a death's first frames (film it20). Each
## thrown-back grid draws at FILL x that (tools/art/street_hit_fill.py: its figure's thickness
## against the mid-fall row it hands over to), scaled about the planted boot. The site grids
## (SITE_GRIDS) were drawn at the walk's scale and keep 1. FILL_ON false = the before.
const FILL_ON: bool = true
const FILL: Dictionary[String, float] = {
	"cop_patrol_hit.png": 1.37,
	"cop_riot_hit.png": 1.20,
	"ped_cap_hit.png": 1.39,
	"ped_elder_hit.png": 1.17,
	"ped_hat_hit.png": 1.34,
	"ped_hood_hit.png": 1.35,
	"ped_jogger_hit.png": 1.29,
	"ped_punk_hit.png": 1.25,
	"ped_shopper_hit.png": 1.33,
	"ped_suit_hit.png": 1.40,
	"ped_worker_hit.png": 1.19,
	"swat_hit.png": 1.31,
	"thug_hit.png": 1.17,
}
## The card's tip at the family's peak (rad, away from the blow on screen).
const LEAN: float = 0.22
## How much of the parts' body travel the rigid card takes on.
const SHOVE_GAIN: float = 1.0


## The hit grid this rig draws now ("art/file.png"; "" = none): a wound family with a drawn cell,
## still inside its hold, on a row with a grid.
static func grid_of(rig: CutRig, row: String) -> String:
	var r: HumanReact = rig.react
	if not ON or not DRAWN or r == null or not GRIDS.has(row):
		return ""
	if r.dying:
		var open: bool = DEATH_KINDS.has(r.kind) and r.progress() < StreetWalkerFall.FALL_AT[1]
		return GRIDS[row] if open else ""
	if not HOLD_S.has(r.kind) or r.t >= float(HOLD_S[r.kind]):
		return ""
	var sites: Dictionary = SITE_GRIDS.get(row, {}) if SITES else {}
	return str(sites[r.kind]) if sites.has(r.kind) else GRIDS[row]


## True when `path` is one of the hit grids (StreetWalkerCards drops it when the hold ends).
static func is_grid(path: String) -> bool:
	return path.ends_with("_hit.png")


## The scale a hit grid at `path` draws at, of its cell's height (1 for any other strip).
static func fill_of(path: String) -> float:
	if not FILL_ON or not is_grid(path):
		return 1.0
	return FILL.get(path.get_file(), 1.0)


## Faces the drawn cell by the blow: the figure faces the shooter and arches away from the shot.
static func face(card: Sprite2D, blow: Vector2) -> void:
	var f: Vector2i = RigHeadCard.frame_of((-blow).angle())
	card.frame_coords = Vector2i(f.x, 0)
	card.flip_h = f.y == 1


## The wound's push on the card this step, world px (x, y) and the tip in rad (z).
static func shove(rig: CutRig) -> Vector3:
	var r: HumanReact = rig.react
	if not ON or r == null or r.dying or r.kind == &"" or r.off == Vector2.ZERO:
		return Vector3.ZERO
	var world: Vector2 = rig.global_transform.basis_xform(r.off) * SHOVE_GAIN
	var e: float = clampf(r.off.length() / maxf(r.travel, 1.0), 0.0, 1.0)
	var side: float = signf(world.x) if absf(world.x) > 0.01 else 1.0
	return Vector3(world.x, world.y, side * LEAN * e)
