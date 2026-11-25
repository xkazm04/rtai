class_name FoeTurretCardView
extends Sprite2D
## The plate centre stays on the fighter's ground point through the sweep and collapse.

const CARD: StringName = &"sentry_turret_card"
const PLATE_M: float = 1.4
const PLATE_PX: int = 160
const CELL: int = 256
const ANCHOR: Vector2 = Vector2(128, 141)
const HIT_TICKS: int = 12
const APRON: Rect2 = Rect2(0, 214, CELL, 10)

var _apron: Sprite2D
var _shadow: CardContactShadow


static func enabled(h: Fighter) -> bool:
	return ArenaRobotRigs.takes(h) and CastCards.current(h.archetype) != null


static func show_rig(host: ArenaRobotRigs, h: Fighter, rig: CutRig, shown: bool) -> bool:
	if h.archetype != &"sentry_turret":
		return shown
	var card: FoeTurretCardView = rig.get_meta(CARD) if rig.has_meta(CARD) else null
	var sheets: CastCards.Sheets = CastCards.current(h.archetype)
	if sheets == null:
		if card != null:
			card.hide()
		return shown
	if card == null:
		card = FoeTurretCardView.new()
		host.add_child(card)
		rig.set_meta(CARD, card)
		@warning_ignore("return_value_discarded")
		rig.tree_exiting.connect(card.queue_free, CONNECT_ONE_SHOT)
	card.update_fighter(h, host.arena, sheets)
	card.sync_tint(rig.is_tinted())
	card.visible = shown
	return false


static func attack_row(h: Fighter, mind: SquadMind, tick: int) -> int:
	if mind == null or mind.turret == null:
		return 0
	if mind.agent.shot_tick == tick:
		return 2
	if h.tell_left > 0:
		return 1
	return 3 if mind.turret.phase == FoeTurret.Phase.COOL else 0


## The hit flash of the rig this card stands in for (the rule is CastFarCard.tint_of).
func sync_tint(on: bool) -> void:
	var want: Material = CastFarCard.tint_of(on)
	if material != want:
		material = want


func update_fighter(h: Fighter, arena: CombatArena, sheets: CastCards.Sheets) -> void:
	_sync_apron(sheets.attack)
	var since: int = arena.tick - h.hurt_tick
	var path: String = sheets.attack
	var frames: int = 4
	var mind: SquadMind = arena.squad_ai.minds.get(h.id) if arena.squad_ai != null else null
	var row: int = attack_row(h, mind, arena.tick)
	if not h.alive():
		path = sheets.fall
		frames = 3
		row = StreetWalkerFall.fall_frame(clampf(since / 24.0, 0.0, 1.0))
	elif since >= 0 and since < HIT_TICKS:
		path = sheets.hit
		frames = 1
		row = 0
	if texture == null or texture.resource_path != path:
		texture = StreetStrips.get_tex(path)
		hframes = RigHeadCard.FRAMES
		vframes = frames
	var face: Vector2i = RigHeadCard.frame_of(h.facing.angle())
	frame_coords = Vector2i(face.x, row)
	flip_h = face.y != 0
	centered = false
	offset = -ANCHOR
	position = h.pos * SimConst.PX_PER_M
	# Bolt-plane depth from rear edge to front lip in the registered idle cells.
	var depth_px: float = 138.0 if ViewMode.shared().art == "p70" else 131.0
	scale = Vector2(1.0 / PLATE_PX, 1.0 / depth_px) * PLATE_M * SimConst.PX_PER_M
	if _shadow == null:
		_shadow = CardContactShadow.mount(self)
	_shadow.follow(self, position)


func _sync_apron(path: String) -> void:
	# Mirroring the gun to the left must leave the stripes on the bolted apron still.
	if _apron == null:
		_apron = Sprite2D.new()
		_apron.region_enabled = true
		_apron.region_rect = APRON
		_apron.centered = false
		_apron.position = APRON.position - ANCHOR
		add_child(_apron)
	if _apron.texture == null or _apron.texture.resource_path != path:
		_apron.texture = StreetStrips.get_tex(path)
