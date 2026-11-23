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
const CELL_RATIO: float = 256.0 / 192.0
const FILL: Dictionary[String, float] = {
	"p70/cop_patrol_armed_walk.png": 1.12,
	"p70/cop_patrol_planted_armed_walk.png": 1.12 * CELL_RATIO,
	"p70/cop_riot_armed_walk.png": 1.11,
	"p70/swat_armed_walk.png": 1.14,
	"p55/cop_patrol_armed_walk.png": 1.08,
	"p55/cop_patrol_planted_armed_walk.png": 1.08 * CELL_RATIO,
	"p55/cop_riot_armed_walk.png": 1.08,
	"p55/swat_armed_walk.png": 1.07,
}

## Both patrol grids carry this contact-to-pass displacement in their texels.
## The cutter keeps the original figure scale and pads above the ground line.
const ADVANCE: Array[Vector2] = [
	Vector2(0, 14), Vector2(10, 9), Vector2(13, 0), Vector2(10, -9), Vector2(0, -14)
]
## The authored down-right passing boot crosses the torso. A longer drawing interval exceeds the
## 12 px upper-body limit at the weight transfer. The same distance drives all patrol gaits.
const STEP_M: float = 0.135
const ORIGINAL: String = "cop_patrol_armed_walk.png"
const PLANTED: String = "cop_patrol_planted_armed_walk.png"
const OTHER_ID: StringName = &"other_patrol_host"
const FOOT_Y: float = 0.875
const CONTACT: StringName = &"patrol_sole_contact"


class Contact:
	extends RefCounted
	var cell: int = 0
	var walked: float = 0.0
	var face: Vector2i = Vector2i(-1, -1)
	var origin: Vector2
	var last: Vector2 = Vector2.INF

	func reset() -> void:
		last = Vector2.INF

	func place(at: Vector2, facing: Vector2i, texel: Vector2, ppm: float) -> Vector2:
		var step: float = STEP_M * ppm
		var motion: Vector2 = at - last
		if not last.is_finite() or motion.length() > ppm or facing != face:
			origin = at
			walked = 0.0
			cell = 0
		else:
			walked += motion.length()
			var next: int = floori(walked / step)
			if floori(next * 0.5) != floori(cell * 0.5):
				origin = at - motion.normalized() * fmod(walked, 2.0 * step)
			cell = next
		face = facing
		last = at
		var advance: Vector2 = ADVANCE[facing.x] * texel if posmod(cell, 2) else Vector2.ZERO
		if facing.y == 1:
			advance.x = -advance.x
		return origin + advance


## A lower-rate rig can move between pose ticks. Reapply the last planted world position
## before drawing it, leaving the card under its regular parent for depth, tint and visibility.
class RigContact:
	extends Contact
	var sprite: Sprite2D
	var target: Vector2 = Vector2.INF
	var actor: int = -1

	func pin() -> void:
		if target.is_finite() and sprite.is_inside_tree():
			sprite.global_position = target

	func release() -> void:
		if RenderingServer.frame_pre_draw.is_connected(pin):
			RenderingServer.frame_pre_draw.disconnect(pin)


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


static func bind(card: Sprite2D, path: String) -> void:
	if card.has_meta(CONTACT):
		var old: RigContact = card.get_meta(CONTACT)
		old.release()
		card.remove_meta(CONTACT)
	if path.get_file() != PLANTED:
		return
	var contact: RigContact = RigContact.new()
	contact.sprite = card
	card.set_meta(CONTACT, contact)
	@warning_ignore_start("return_value_discarded")
	RenderingServer.frame_pre_draw.connect(contact.pin)
	card.tree_exiting.connect(contact.release, CONNECT_ONE_SHOT)
	@warning_ignore_restore("return_value_discarded")


static func plant(rig: CutRig, card: Sprite2D) -> void:
	if not card.has_meta(CONTACT):
		return
	var contact: RigContact = card.get_meta(CONTACT)
	if contact.actor != rig.actor_id or rig.speed_now <= StreetWalkerCards.MOVING:
		contact.reset()
		contact.actor = rig.actor_id
		contact.target = Vector2.INF
	if rig.speed_now <= StreetWalkerCards.MOVING:
		return
	var facing: Vector2i = Vector2i(card.frame_coords.x, int(card.flip_h))
	contact.target = contact.place(
		rig.global_position, facing, card.global_scale, SimConst.PX_PER_M
	)
	card.frame_coords.y = posmod(contact.cell, StreetWalkerCards.STRIDE_FRAMES)
	card.global_position = contact.target


static func patrol_path(rig: CutRig, path: String) -> String:
	if not path.ends_with(ORIGINAL) and not path.ends_with(PLANTED):
		return path
	var other: bool = rig.has_meta(OTHER_ID) and rig.get_meta(OTHER_ID) == rig.actor_id
	return path.get_base_dir().path_join(ORIGINAL if other else PLANTED)
