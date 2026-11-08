class_name StreetWalkerRows
extends RefCounted
## The walkers' whole-figure art (StreetWalkerCards' tables, split so that file stays in its size
## limit, n10 perf): each view art's card rows, their strips and stride grids, and the walk grids'
## size step against the still figure.

const ROWS: Dictionary[String, String] = {
	"ped/head_hair": "ped_suit_full.png",
	"ped/head_bald": "ped_elder_full.png",
	"ped/head_hat": "ped_hat_full.png",
	"ped/head_hood": "ped_hood_full.png",
	"ped/head_cap": "ped_cap_full.png",
	"ped/head_punk": "ped_punk_full.png",
	"ped/head_shopper": "ped_shopper_full.png",
	"ped/head_jogger": "ped_jogger_full.png",
	"ped/head_worker": "ped_worker_full.png",
}
const STRIPS: Dictionary[String, Dictionary] = {"p70": ROWS, "p55": ROWS}
## view art -> card row -> stride grid (5 facings across, 4 frames down: contact, pass, contact,
## pass). A row here draws its frames instead of STRIPS' still figure.
const WALKS: Dictionary[String, Dictionary] = {
	"p70":
	{
		"ped/head_hair": "ped_suit_walk.png",
		"ped/head_bald": "ped_elder_walk.png",
		"ped/head_hat": "ped_hat_walk.png",
		"ped/head_hood": "ped_hood_walk.png",
		"ped/head_cap": "ped_cap_walk.png",
		"ped/head_punk": "ped_punk_walk.png",
		"ped/head_shopper": "ped_shopper_walk.png",
		"ped/head_jogger": "ped_jogger_walk.png",
		"ped/head_worker": "ped_worker_walk.png",
	},
}
## A grid's cell carries stride headroom, so its figures fill less of it than the still strip's:
## the size step (still figure height / walk figure height, per cell, the mean of the facings).
const WALK_FILL: Dictionary[String, float] = {
	"ped_suit_walk.png": 1.09,
	"ped_elder_walk.png": 1.08,
	"ped_hat_walk.png": 1.06,
	"ped_hood_walk.png": 1.07,
	"ped_cap_walk.png": 1.12,
	"ped_punk_walk.png": 1.01,
	"ped_shopper_walk.png": 1.09,
	"ped_jogger_walk.png": 1.12,
	"ped_worker_walk.png": 1.13,
}
