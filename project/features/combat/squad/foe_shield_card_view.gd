class_name FoeShieldCardView
extends CastFarCard
## The door carrier uses a whole sprite at its robot rig's ground point.

const CARD: StringName = &"door_carrier_card"
const HEIGHT_M: float = 2.0
## The down-facing walk spans 158 source pixels at 55 degrees and 163 at 70.
const BODY_PX: float = 160.0
const HIT_HOLD_S: float = 0.20
const STEP_PX: float = (
	StreetQuestCards.STRIDE_M * SimConst.PX_PER_M / StreetWalkerCards.STRIDE_FRAMES
)

var pose: CastCardPose = CastCardPose.new()
var _walk_cell: int = -1


static func enabled(h: Fighter) -> bool:
	return ArenaRobotRigs.takes(h) and CastCards.current(h.archetype) != null


## The sprite is a sibling so hiding the articulated rig also hides its detail children.
static func show_rig(host: ArenaRobotRigs, h: Fighter, rig: CutRig, shown: bool) -> bool:
	if h.archetype != &"shield_robot":
		return shown
	var card: FoeShieldCardView = rig.get_meta(CARD) if rig.has_meta(CARD) else null
	var sheets: CastCards.Sheets = CastCards.current(h.archetype)
	if sheets == null:
		if card != null:
			card.hide()
		return shown
	if card == null:
		card = FoeShieldCardView.new()
		host.add_child(card)
		rig.set_meta(CARD, card)
		@warning_ignore("return_value_discarded")
		rig.tree_exiting.connect(card.queue_free, CONNECT_ONE_SHOT)
	card.pose.sheets = sheets
	card.update_fighter(h, host.arena)
	card.sync_tint(rig.is_tinted())
	card.visible = shown
	return false


func update_fighter(h: Fighter, arena: CombatArena) -> void:
	var moved: bool = pose.previous.is_finite() and pose.previous != h.pos
	pose.travel(h.pos)
	pose.hit_hold = HIT_HOLD_S
	pose.opens_on_hit = false
	pose.attack = attack_row(h, arena)
	var last_ground: Vector2 = position
	draw_pose(pose, h, moved, arena.tick)
	if texture.resource_path == pose.sheets.walk:
		var cell: int = frame * 2 + int(flip_h)
		if (
			moved
			and cell == _walk_cell
			and position.distance_squared_to(last_ground) <= STEP_PX * STEP_PX
		):
			position = last_ground
		_walk_cell = cell
	else:
		_walk_cell = -1
	scale = Vector2.ONE * HEIGHT_M * pose.sheets.body_scale * SimConst.PX_PER_M / BODY_PX


static func attack_row(h: Fighter, arena: CombatArena) -> int:
	var mind: SquadMind = arena.squad_ai.minds.get(h.id) if arena.squad_ai != null else null
	if mind == null or mind.shield == null:
		return -1
	if mind.shield.lunge_left > 0:
		return 2
	var lock_ticks: int = ceili(mind.agent.arch.telegraph_ticks * 0.5)
	return CastCardPose.attack_frame(h.swing_left, lock_ticks, arena.tick - mind.agent.shot_tick)
