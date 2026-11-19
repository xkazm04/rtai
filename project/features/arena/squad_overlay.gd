class_name SquadOverlay
extends CanvasLayer
## Live wave members only. Letters describe locomotion, even during a weapon windup or burst.
## A strafe has no point goal. Only draw a destination when the movement planner has one.

const S := EnemyAgent.State
const LETTER: Dictionary[int, String] = {S.ENGAGE: "E", S.COVER: "C", S.FLANK: "F", S.PANIC: "P"}
const COLORS: Dictionary[String, Color] = {
	"E": Color("#ffebaa"),
	"C": Color("#b4e08a"),
	"F": Color("#f2b84b"),
	"P": Color("#d2a8ff"),
	"G": Color.WHITE,
}

var _host: ArenaRigs
var _stage: ArenaStage
var _world: Node2D
var _unit: float
var _ink: Node2D = Node2D.new()


static func attach(world: Node2D, stage: ArenaStage, host: ArenaRigs = null) -> void:
	if OS.is_debug_build() and ArenaArgs.parse().has("--squad-overlay"):
		var overlay: SquadOverlay = SquadOverlay.new()
		overlay._host = host
		overlay._stage = stage
		overlay._world = world
		overlay._unit = Ink.PX_PER_M if host == null else SimConst.PX_PER_M
		world.add_child(overlay)


func _ready() -> void:
	layer = RenderLayers.canvas(&"hud")
	add_child(_ink)
	@warning_ignore("return_value_discarded")
	_ink.draw.connect(_draw_wave)


func _process(_delta: float) -> void:
	_ink.queue_redraw()


func _anchor(h: Fighter, screen: Transform2D) -> Vector2:
	if _host == null:
		var p: Vector2 = h.pos
		var view: ViewMode = ViewMode.shared()
		if view.cards and StreetQuestCards.GUARD.has(view.art) and h.kind != Fighter.Kind.BOSS:
			p.y -= StreetQuestCards.body_m() * (StreetQuestCards.FOOT_Y - 0.5) / view.ground_k()
		return screen * (p * _unit)
	var rig: CutRig = _host.rigs.rig_for(h.id)
	if rig == null:
		rig = _host.robots.rig_for(h.id)
	var card: Sprite2D = _host.wave_cards.card_for(h.id)
	if rig != null and rig.is_visible_in_tree():
		card = rig.head_card
		if card == null or not card.is_visible_in_tree():
			return rig.torso.get_global_transform_with_canvas().origin
	if card != null and card.is_visible_in_tree():
		return card.get_global_transform_with_canvas() * card.get_rect().get_center()
	return Vector2.INF


func _draw_wave() -> void:
	var screen: Transform2D = _world.get_global_transform_with_canvas()
	for h: Fighter in _stage.pit.standing:
		if not h.alive():
			continue
		var at: Vector2 = _anchor(h, screen)
		if not at.is_finite():
			continue
		var letter: String = "G"
		var goal: Vector2 = Vector2.INF
		var squad: ArenaSquad = _stage.arena.squad_ai
		if squad != null:
			if not squad.minds.has(h.id):
				continue
			var mind: SquadMind = squad.minds[h.id]
			letter = LETTER.get(mind.motion, "?")
			goal = mind.destination()
		elif h.pursuit != null:
			goal = h.pursuit.blocked_goal()
		var color: Color = COLORS.get(letter, Color.WHITE)
		if goal.is_finite():
			var end: Vector2 = screen * (goal * _unit)
			_ink.draw_line(at, end, Ink.INK, 3.0, true)
			_ink.draw_line(at, end, color, 1.0, true)
			_ink.draw_circle(end, 3.0, color, false, 1.3, true)
		var label: Vector2 = at + Vector2(-6.0, 6.0)
		var font: Font = ThemeDB.fallback_font
		_ink.draw_string_outline(font, label, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 5, Ink.INK)
		_ink.draw_string(font, label, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
