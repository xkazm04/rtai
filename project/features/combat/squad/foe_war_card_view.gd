class_name FoeWarCardView
extends Sprite2D
## The five sheets share a ground baseline; the foot lift and collapse are inside the cells.

const CARD: StringName = &"pile_driver_card"
const BASE_PX: float = 264.0
const HEIGHT_M: float = 2.6
const BODY_PX: float = 200.0
const HIT_TICKS: int = 12

var _pose: CastCardPose = CastCardPose.new()
var _vent: Sprite2D
var _shadow: Node2D = Node2D.new()
var _step: int = -1


static func show_rig(host: ArenaRobotRigs, h: Fighter, rig: CutRig, shown: bool) -> bool:
	if h.archetype != &"war_machine":
		return shown
	var card: FoeWarCardView = rig.get_meta(CARD) if rig.has_meta(CARD) else null
	var sheets: CastCards.Sheets = CastCards.current(h.archetype)
	if sheets == null:
		if card != null:
			card.hide()
		return shown
	if card == null:
		card = FoeWarCardView.new()
		host.add_child(card)
		rig.set_meta(CARD, card)
		@warning_ignore("return_value_discarded")
		rig.tree_exiting.connect(card.queue_free, CONNECT_ONE_SHOT)
	card.sample(h, host.arena, sheets)
	card.visible = shown
	return false


func sample(h: Fighter, arena: CombatArena, sheets: CastCards.Sheets) -> void:
	var moving: bool = _pose.previous.is_finite() and h.pos != _pose.previous
	_pose.travel(h.pos)
	var path: String = sheets.walk
	var row: int = StreetWalkerCards.stride_frame(_pose.walked / StreetQuestCards.STRIDE_M, moving)
	var rows: int = StreetWalkerCards.STRIDE_FRAMES
	var since: int = arena.tick - h.hurt_tick
	var heat: float = 0.0
	var mind: SquadMind = arena.squad_ai.minds.get(h.id) if arena.squad_ai != null else null
	if not h.alive():
		path = sheets.fall
		rows = StreetWalkerFall.FALL_FRAMES
		row = StreetWalkerFall.fall_frame(clampf(since / 24.0, 0.0, 1.0))
	elif since >= 0 and since < HIT_TICKS:
		path = sheets.hit
		rows = 1
		row = 0
	elif mind != null and mind.walker != null and mind.walker.attack != null:
		var stomp: bool = mind.walker.attack.melee
		var e: EnemyAgent = mind.agent
		var action: String = sheets.stomp if stomp else sheets.attack
		if not action.is_empty() and e.state in [EnemyAgent.State.WINDUP, EnemyAgent.State.RECOVER]:
			path = action
			row = _attack_row(e, stomp, arena.tick)
			if e.state == EnemyAgent.State.RECOVER:
				heat = float(h.cooldown) / mind.walker.attack.cooldown_ticks
	var stride: int = floori(_pose.walked * rows / StreetQuestCards.STRIDE_M)
	var hold_foot: bool = moving and path == sheets.walk and stride == _step
	var last_ground: Vector2 = position
	_cell(path, rows, row, h)
	if hold_foot:
		position = last_ground
	_step = stride if path == sheets.walk else -1
	_shadow.visible = ViewMode.shared().cast_k > 0.0
	_louvres(heat, path == sheets.stomp)


static func _attack_row(e: EnemyAgent, stomp: bool, tick: int) -> int:
	if e.state == EnemyAgent.State.WINDUP:
		var span: int = e.arch.alt_telegraph_ticks if stomp else e.arch.telegraph_ticks
		var locked: bool = e.timer * 2 <= span
		if stomp:
			return 0 if locked else 3
		return int(locked)
	var age: int = tick - e.shot_tick
	if not stomp:
		return 2 if age == 0 else 3
	# The sole lands in row 1, rebounds in row 2 and settles in row 3.
	if age == 0:
		return 1
	return 2 if age < CastCardPose.RECOVERY_TICKS else 3


func _ready() -> void:
	_shadow.show_behind_parent = true
	add_child(_shadow)
	# The boots are 1.8 m across. The three patrol contact rings sit under their ground line.
	for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
		var ink: Polygon2D = Polygon2D.new()
		ink.polygon = RigCastShadows.contact_ellipse(
			Vector2.ZERO, 0.9 * BODY_PX / HEIGHT_M * ring.x
		)
		ink.color = Color(RigCastShadows.SHADOW, ring.y)
		_shadow.add_child(ink)


func _cell(path: String, rows: int, row: int, h: Fighter) -> void:
	var face: Vector2i = RigHeadCard.frame_of(h.facing.angle())
	if texture == null or texture.resource_path != path:
		texture = StreetStrips.get_tex(path)
		hframes = RigHeadCard.FRAMES
		vframes = rows
		centered = false
		offset = Vector2(-texture.get_width() / float(hframes) * 0.5, -BASE_PX)
	frame_coords = Vector2i(face.x, row)
	flip_h = face.y != 0
	position = h.pos * SimConst.PX_PER_M
	scale = (
		Vector2(1.0, 1.0 / ViewMode.shared().ground_k()) * HEIGHT_M * SimConst.PX_PER_M / BODY_PX
	)


func _louvres(heat: float, stomp: bool) -> void:
	var col: int = frame_coords.x
	if heat <= 0.0 or frame_coords.y != 3 or col < 2:
		if _vent != null:
			_vent.hide()
		return
	if _vent == null:
		_vent = Sprite2D.new()
		_vent.region_enabled = true
		var glow: CanvasItemMaterial = CanvasItemMaterial.new()
		glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_vent.material = glow
		add_child(_vent)
	# Centres of the printed recovery grilles, in half-height cells, profile through back.
	var centres: PackedVector2Array = [Vector2(52, 74), Vector2(52, 84), Vector2(71, 85)]
	if ViewMode.shared().art == "p55":
		centres = [Vector2(49, 63), Vector2(54, 74), Vector2(72, 77)]
		if stomp:
			centres = [Vector2(46, 68), Vector2(47, 73), Vector2(71, 80)]
	elif stomp:
		centres = [Vector2(50, 70), Vector2(60, 78), Vector2(72, 88)]
	var size_px: Vector2 = texture.get_size() / Vector2(hframes, vframes)
	var centre: Vector2 = centres[col - 2] * size_px / 144.0
	var extent: Vector2 = Vector2(18, 21)
	_vent.texture = texture
	_vent.region_rect = Rect2(Vector2(frame_coords) * size_px + centre - extent * 0.5, extent)
	_vent.position = offset + centre
	_vent.flip_h = flip_h
	if flip_h:
		_vent.position.x *= -1.0
	_vent.modulate.a = clampf(heat, 0.0, 1.0)
	_vent.show()
