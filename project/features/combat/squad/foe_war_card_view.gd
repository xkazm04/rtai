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
var _k: float = 1.0


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
	card.sync_tint(rig.is_tinted())
	card.visible = shown
	return false


## The hit flash of the rig this card stands in for (rule: CastFarCard.tint_of).
## The vent keeps its own glow material.
func sync_tint(on: bool) -> void:
	var want: Material = CastFarCard.tint_of(on)
	if material != want:
		material = want


func sample(h: Fighter, arena: CombatArena, sheets: CastCards.Sheets) -> void:
	var moving: bool = _pose.previous.is_finite() and h.pos != _pose.previous
	_pose.travel(h.pos)
	var walk: String = walk_sheet(sheets.walk)
	var path: String = walk
	_k = sheets.body_scale
	var rows: int = walk_rows(walk)
	var cycle_m: float = walk_step_m(walk) * rows
	var row: int = _walk_row(rows, cycle_m, moving)
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
			rows = StreetWalkerCards.STRIDE_FRAMES
			row = _attack_row(e, stomp, arena.tick)
			if e.state == EnemyAgent.State.RECOVER:
				heat = float(h.cooldown) / mind.walker.attack.cooldown_ticks
	var stride: int = floori(_pose.walked * rows / cycle_m)
	var hold_foot: bool = moving and path == walk and stride == _step
	var last_ground: Vector2 = position
	_cell(path, rows, row, h)
	if hold_foot:
		position = last_ground
	_step = stride if path == walk else -1
	_shadow.visible = ViewMode.shared().cast_k > 0.0
	_louvres(heat, path == sheets.stomp)


## The drawing for the distance walked; standing takes the four's STAND_FRAME at the walk's rows.
func _walk_row(rows: int, cycle_m: float, moving: bool) -> int:
	if not moving:
		return floori(float(StreetWalkerCards.STAND_FRAME * rows) / StreetWalkerCards.STRIDE_FRAMES)
	return posmod(floori(_pose.walked / cycle_m * rows), rows)


## The shipped four-drawing walk gives way to the one CastWarAnchors.WALK selects (n29: the eight).
static func walk_sheet(path: String) -> String:
	if path.get_file() != CastWarAnchors.FOUR:
		return path
	return path.get_base_dir().path_join(CastWarAnchors.WALK)


static func walk_rows(path: String) -> int:
	return (
		CastWarAnchors.EIGHT_ROWS
		if path.get_file() == CastWarAnchors.EIGHT
		else CastWarAnchors.FOUR_ROWS
	)


## Metres walked per drawing: the four keeps the shipped stride, the eight its drawn advance.
static func walk_step_m(path: String) -> float:
	return (
		CastWarAnchors.EIGHT_STEP_M
		if path.get_file() == CastWarAnchors.EIGHT
		else CastWarAnchors.FOUR_STEP_M
	)


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
	# Scale first, then place: an anchored sole placed before a rescale would slide (n29 door).
	scale = (
		Vector2(1.0, 1.0 / ViewMode.shared().ground_k())
		* HEIGHT_M
		* _k
		* SimConst.PX_PER_M
		/ BODY_PX
	)
	position = h.pos * SimConst.PX_PER_M


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
