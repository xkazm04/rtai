class_name FoeGunnerCardView
extends CastFarCard
## Robot gunner A drawn as a whole sprite at his robot rig's ground point. The rig stays the
## body (sim, hit shove, power-down); with the card on, the sprite is its only drawing.

const CARD: StringName = &"robot_gunner_card"
const ID: StringName = &"robot_gunner"
const HIT_HOLD_S: float = 0.20

var pose: CastCardPose = CastCardPose.new()
var _shadow: CardContactShadow
var _planted: Transform2D
var _planted_row: int = -1


func _init() -> void:
	_shadow = CardContactShadow.mount(self)


## The sprite is a sibling so hiding the articulated rig also hides its detail children.
static func show_rig(host: ArenaRobotRigs, h: Fighter, rig: CutRig, shown: bool) -> bool:
	if h.archetype != ID:
		return shown
	var card: FoeGunnerCardView = rig.get_meta(CARD) if rig.has_meta(CARD) else null
	var sheets: CastCards.Sheets = CastCards.current(h.archetype)
	if sheets == null:
		if card != null:
			card.hide()
		return shown
	if card == null:
		card = FoeGunnerCardView.new()
		host.add_child(card)
		rig.set_meta(CARD, card)
		@warning_ignore("return_value_discarded")
		rig.tree_exiting.connect(card.queue_free, CONNECT_ONE_SHOT)
	card.pose.sheets = sheets
	if host.pipe != null:
		card.pose.death_length = host.pipe.table.length(&"death_robot")
	card.update_fighter(h, host.arena)
	card.sync_tint(rig.is_tinted())
	card.visible = shown
	return false


func update_fighter(h: Fighter, arena: CombatArena) -> void:
	var moved: bool = pose.previous.is_finite() and pose.previous != h.pos
	pose.travel(h.pos)
	pose.hit_hold = HIT_HOLD_S
	pose.opens_on_hit = false
	pose.attack = FoeCastView.attack_row(h, arena)
	draw_pose(pose, h, moved, arena.tick)
	_hold_stop(moved)
	_shadow.follow(self, h.pos * SimConst.PX_PER_M)


## A halt keeps the last planted drawing and placement, so the body does not jump to the plain
## standing cell (18 px at 32 px/m): a stop adds nothing to the walk's own drawing steps.
func _hold_stop(moved: bool) -> void:
	if texture.resource_path != pose.sheets.walk:
		_planted_row = -1
	elif moved:
		_planted = transform
		_planted_row = frame_coords.y
	elif _planted_row >= 0:
		transform = _planted
		frame_coords.y = _planted_row
