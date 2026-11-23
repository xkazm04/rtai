class_name StreetCopWalk
extends RefCounted
## Armed city walks and their support-foot placement. Only patrol hosts select the fast gait.
const ENABLED: bool = true
const ARMED_ROWS: Dictionary[String, String] = {
	"cop/head_cap": "cop_patrol_armed_walk.png",
	"cop/head_helmet": "cop_riot_armed_walk.png",
	"cop/head_swat": "swat_armed_walk.png",
}
const WALKS: Dictionary[String, Dictionary] = {"p70": ARMED_ROWS, "p55": ARMED_ROWS}
## The size step per grid, keyed "<art>/<file>" (as StreetWalkerCards.WALK_FILL): the still
## strip's figure fill (0.985 of the cell) over the grid's mean figure height in the cell.
const CELL_RATIO: float = 256.0 / 192.0
const FILL: Dictionary[String, float] = {
	"p70/cop_patrol_armed_walk.png": 1.12,
	"p70/cop_patrol_planted_armed_walk.png": 1.12 * CELL_RATIO,
	"p70/cop_patrol_planted8_armed_walk.png": 1.12 * CELL_RATIO,
	"p70/cop_patrol_planted8_armed_run.png": 1.12 * CELL_RATIO,
	"p70/cop_riot_armed_walk.png": 1.11,
	"p70/swat_armed_walk.png": 1.14,
	"p55/cop_patrol_armed_walk.png": 1.08,
	"p55/cop_patrol_planted_armed_walk.png": 1.08 * CELL_RATIO,
	"p55/cop_patrol_planted8_armed_walk.png": 1.08 * CELL_RATIO,
	"p55/cop_patrol_planted8_armed_run.png": 1.08 * CELL_RATIO,
	"p55/cop_riot_armed_walk.png": 1.08,
	"p55/swat_armed_walk.png": 1.07,
}

## The four-drawing patrol's contact-to-pass displacement in texels.
const ADVANCE: Array[Vector2] = [
	Vector2(0, 14), Vector2(10, 9), Vector2(13, 0), Vector2(10, -9), Vector2(0, -14)
]
const ORIGINAL: String = "cop_patrol_armed_walk.png"
const FOUR: String = "cop_patrol_planted_armed_walk.png"
const EIGHT: String = "cop_patrol_planted8_armed_walk.png"
const RUN: String = "cop_patrol_planted8_armed_run.png"
## Set PLANTED to FOUR to restore the four-drawing patrol on every host at every speed.
const PLANTED: String = EIGHT
const RUN_MPS: float = 4.0
const FOUR_STEP_M: float = 0.135
const STEP_M: float = StreetPatrolAnchors.WALK_M if PLANTED == EIGHT else FOUR_STEP_M
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
	var travel: Vector2
	var path: String
	var drawings: int = 4
	var step_m: float = FOUR_STEP_M
	var registered: StreetPatrolPose
	var placed: Transform2D

	func configure(strip: String) -> void:
		if strip == path:
			return
		path = strip
		reset()
		drawings = StreetCopWalk.rows_of(strip)
		registered = null
		step_m = FOUR_STEP_M
		if drawings > 4:
			var running: bool = strip.get_file() == RUN
			registered = StreetPatrolPose.new()
			step_m = registered.configure(strip, drawings, running)

	func reset() -> void:
		last = Vector2.INF
		travel = Vector2.ZERO

	func place(at: Vector2, facing: Vector2i, texel: Vector2, ppm: float) -> Transform2D:
		var step: float = step_m * ppm
		var motion: Vector2 = at - last
		var half: int = drawings >> 1
		if not last.is_finite() or motion.length() > ppm or facing != face:
			origin = at
			walked = 0.0
			cell = 0
			travel = Vector2.ZERO
			if registered != null:
				registered.touchdown(facing, travel, step * half)
		else:
			walked += motion.length()
			if not motion.is_zero_approx():
				travel = motion.normalized()
			var next: int = floori(walked / step)
			if floori(float(next) / half) != floori(float(cell) / half):
				origin = at - travel * fmod(walked, half * step)
				if registered != null:
					registered.touchdown(facing, travel, step * half)
			cell = next
		face = facing
		last = at
		if registered != null:
			registered.stride = travel * step * half
			var phase: float = fmod(walked / step, 1.0) if walked > 0.0 else 0.5
			placed = registered.pose(origin, cell, face, texel, phase)
		else:
			var d: Vector2 = ADVANCE[face.x] * texel if posmod(cell, 2) else Vector2.ZERO
			if face.y == 1:
				d.x = -d.x
			placed = Transform2D(Vector2.RIGHT * texel.x, Vector2.DOWN * texel.y, origin + d)
		return placed


## A lower-rate rig can move between pose ticks. Reapply the last planted world position
## before drawing it, leaving the card under its regular parent for depth, tint and visibility.
class RigContact:
	extends Contact
	var sprite: Sprite2D
	var pinned: bool = false
	var actor: int = -1

	func pin() -> void:
		if pinned and sprite.is_inside_tree():
			sprite.global_transform = placed

	func release() -> void:
		if RenderingServer.frame_pre_draw.is_connected(pin):
			RenderingServer.frame_pre_draw.disconnect(pin)
		if sprite.tree_exiting.is_connected(release):
			sprite.tree_exiting.disconnect(release)


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
	if path.get_file() == StreetMulroneyAnchors.EIGHT:
		return CELL_RATIO
	return FILL.get(path.get_base_dir().get_file() + "/" + path.get_file(), 1.0)


static func bind(card: Sprite2D, path: String) -> void:
	if card.has_meta(CONTACT):
		var old: RigContact = card.get_meta(CONTACT)
		old.release()
		card.skew = 0.0
		card.remove_meta(CONTACT)
	if path.get_file() not in [PLANTED, RUN, StreetMulroneyAnchors.EIGHT]:
		return
	var contact: RigContact = RigContact.new()
	contact.configure(path)
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
		contact.pinned = false
	if rig.speed_now <= StreetWalkerCards.MOVING:
		return
	var facing: Vector2i = Vector2i(card.frame_coords.x, int(card.flip_h))
	card.global_transform = contact.place(
		rig.global_position, facing, card.global_scale, SimConst.PX_PER_M
	)
	card.frame_coords.y = posmod(contact.cell, contact.drawings)
	contact.pinned = true


static func rows_of(path: String) -> int:
	return 8 if path.get_file() in [EIGHT, RUN, StreetMulroneyAnchors.EIGHT] else 4


static func strip_for(speed_mps: float) -> String:
	return RUN if PLANTED == EIGHT and speed_mps > RUN_MPS else PLANTED


static func patrol_path(rig: CutRig, path: String) -> String:
	if path.get_file() not in [ORIGINAL, PLANTED, RUN]:
		return path
	var other: bool = rig.has_meta(OTHER_ID) and rig.get_meta(OTHER_ID) == rig.actor_id
	return path.get_base_dir().path_join(
		ORIGINAL if other else strip_for(rig.speed_now / SimConst.PX_PER_M)
	)
