class_name FoeThugCardView
extends CastFarCard
## Robot thug A drawn as a whole sprite at his robot rig's ground point. The rig stays the
## body (sim, hit shove, power-down); with the card on, the sprite is its only drawing.

const CARD: StringName = &"robot_thug_card"
const ID: StringName = &"robot_thug"
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
	var card: FoeThugCardView = rig.get_meta(CARD) if rig.has_meta(CARD) else null
	var sheets: CastCards.Sheets = CastCards.current(h.archetype)
	if sheets == null:
		if card != null:
			card.hide()
		return shown
	if card == null:
		card = FoeThugCardView.new()
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
	_hold_stop(moved, h)
	_shadow.follow(self, h.pos * SimConst.PX_PER_M)


## The rings belong on the ground point, not on the card's transform origin: the walk placement
## solves the torso mark onto the body, so the origin sits well below the feet at 70 px/m.
func ground_local(h: Fighter) -> Vector2:
	return transform.affine_inverse() * (h.pos * SimConst.PX_PER_M)


## A halt keeps the last planted drawing and placement, so the body does not jump to the plain
## standing cell (18 px at 32 px/m): a stop adds nothing to the walk's own drawing steps.
func _hold_stop(moved: bool, h: Fighter) -> void:
	if texture.resource_path != pose.sheets.walk:
		_planted_row = -1
	elif moved:
		_planted = transform
		_planted_row = frame_coords.y
	elif _planted_row >= 0:
		frame_coords.y = _planted_row
		transform = _planted
		transform.origin.y += sole_gap(h)


## Pixels from the held drawing's registered sole (the generated CastThugAnchors point) down to
## the ground row: the walk placement solves the torso, so a halt leaves the soles above it.
func sole_gap(h: Fighter) -> float:
	var path: String = texture.resource_path
	var marks: Array[Vector4] = CastCardKinds.foe_marks(
		path.get_file(), path.get_base_dir().get_file() == "p55"
	)
	var ink: Vector4 = marks[frame_coords.x * vframes + frame_coords.y]
	var sole: Vector2 = _planted * Vector2(-ink.x if flip_h else ink.x, ink.y)
	return h.pos.y * SimConst.PX_PER_M - sole.y
