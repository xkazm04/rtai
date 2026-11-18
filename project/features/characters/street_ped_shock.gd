class_name StreetPedShock
extends RefCounted
## A living shock on these street looks holds the stiff, arched drawing while the current
## is on. On release the knees give, the hands catch the weight, then the figure stands.
## The same five directions are cut into both sheets. The facing stays on the attacker.

const ENABLED: bool = true
const ROWS: Array[String] = ["ped/head_hat", "ped/head_bald", "ped/head_shopper"]
## Fractions of the wound family's clock. The held stun loops at 0.70. Even the slowest
## full rig (a four-tick pose step) stays before LET_GO until the combat state releases it.
const LET_GO: float = 0.76
const KNEES_DOWN: float = 0.83
const RISE: float = 0.90
const UPRIGHT: float = 0.97
const CATCH_ROW: int = 1
const KNEEL_ROW: int = 2
const STAND_ROW: int = 0
## Procedural cutout envelopes when the camera looks straight down.
const ARCH: float = 0.45
const KNEE_TUCK: float = 0.72
const BRACE_REACH: float = 0.65


static func active(r: HumanReact, row: String) -> bool:
	return (
		ENABLED
		and r != null
		and not r.dying
		and (r.kind == &"stun" or r.blow == &"shock")
		and ROWS.has(row)
		and StreetHitClass.on()
	)


## Called for an active shock. A rig entering range mid-stun also has the family clock,
## even though it never saw the original weapon hit.
static func grid(r: HumanReact, row: String) -> String:
	if r.progress() < LET_GO:
		return StreetHitClass.GRIDS[row][&"shock"]
	return StreetWalkerFall.path_of(ViewMode.shared().art, row)


static func drop_row(p: float) -> int:
	if p >= UPRIGHT:
		return STAND_ROW
	if p < KNEES_DOWN or p >= RISE:
		return CATCH_ROW
	return KNEEL_ROW


## In a parts-only view the wardrobe pool still identifies the walker. Drive the same
## lock and release with the cutout's lean, leg tuck and arm reach.
static func pose_parts(r: HumanReact, rig: CutRig) -> bool:
	var v: RigVariant = rig.variant
	if v == null or v.kind != BodyPlan.Kind.PED or ViewMode.shared().cards:
		return false
	var row: String = StreetCrowdCards.pick(v.tag, rig.actor_id)
	if not active(r, "ped/" + v.head if row.is_empty() else row):
		return false
	var p: float = r.progress()
	if p < LET_GO:
		ReactPose.convulse(r, rig, 1.0)
		rig.c_lean = -ARCH
	else:
		var dip: float = smoothstep(LET_GO, KNEES_DOWN, p) * (1.0 - smoothstep(RISE, UPRIGHT, p))
		rig.c_tuck = KNEE_TUCK * dip
		rig.c_reach = BRACE_REACH * dip
		rig.c_lean = dip
	rig.gun_out = false
	return true


## A living knee catch uses the same foot point and fitted scale as the drawn fall.
static func place_drop(rig: CutRig, card: Sprite2D, scale_at_stand: float) -> void:
	var r: HumanReact = rig.react
	StreetWalkerHit.face(card, r.dir.rotated(rig.facing))
	# The short, three-row fall sheet has no kneel. Its last row is already prone.
	var row: int = mini(drop_row(r.progress()), card.vframes - 2)
	card.frame_coords = Vector2i(card.frame_coords.x, row)
	var size: Vector2 = Vector2.ONE * scale_at_stand * StreetFallFit.k(card)
	card.global_transform = Transform2D(0.0, size, 0.0, rig.global_position)
