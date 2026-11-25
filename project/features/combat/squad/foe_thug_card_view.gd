class_name FoeThugCardView
extends CastFarCard
## Robot thug A drawn as a whole sprite at his robot rig's ground point. The rig stays the
## body (sim, hit shove, power-down); with the card on, the sprite is its only drawing.

const CARD: StringName = &"robot_thug_card"
const ID: StringName = &"robot_thug"
const HIT_HOLD_S: float = 0.20

## Hip height 1.0 m (he is drawn about Rivet's height, body_scale 1.45): the patrol's contact
## rings (radius .5 x hip) under his ground point.
const HIP_M: float = 1.0

var pose: CastCardPose = CastCardPose.new()
var _shadow: Node2D = Node2D.new()
var _planted: Transform2D
var _planted_row: int = -1


func _init() -> void:
	_shadow.show_behind_parent = true
	add_child(_shadow)
	for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
		var ink: Polygon2D = Polygon2D.new()
		ink.polygon = RigCastShadows.contact_ellipse(
			Vector2.ZERO, RigCastShadows.CONTACT_R_HIPS * HIP_M * SimConst.PX_PER_M * ring.x
		)
		ink.color = Color(RigCastShadows.SHADOW, ring.y)
		_shadow.add_child(ink)


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
	_hold_stop(moved)
	_shadow.visible = ViewMode.shared().cast_k > 0.0
	_shadow.scale = Vector2.ONE / transform.get_scale()


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
