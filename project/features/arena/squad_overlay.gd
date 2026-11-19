class_name SquadOverlay
extends CanvasLayer
## Live wave members only. Letters describe locomotion, even during a weapon windup or burst.
## A strafe has no point goal. Only draw a destination when the movement planner has one.

const S := EnemyAgent.State
const LETTER: Dictionary[int, String] = {S.ENGAGE: "E", S.COVER: "C", S.FLANK: "F", S.PANIC: "P"}
const COLORS: Dictionary[String, Color] = {
	"E": Color("#ffebaa"),
	"C": Color("#70e5e0"),
	"F": Color("#ffb668"),
	"P": Color("#ff90ac"),
	"G": Color.WHITE,
}

var _host: ArenaRigs
var _stage: ArenaStage
var _ink: Node2D = Node2D.new()


static func attach(host: ArenaRigs, stage: ArenaStage) -> void:
	if OS.is_debug_build() and ArenaArgs.parse().has("--squad-overlay"):
		var overlay: SquadOverlay = SquadOverlay.new()
		overlay._host = host
		overlay._stage = stage
		host.add_child(overlay)


func _ready() -> void:
	layer = RenderLayers.canvas(&"hud")
	add_child(_ink)
	@warning_ignore("return_value_discarded")
	_ink.draw.connect(_draw_wave)


func _process(_delta: float) -> void:
	_ink.queue_redraw()


func _draw_wave() -> void:
	var screen: Transform2D = _host.rigs.get_global_transform_with_canvas()
	for h: Fighter in _stage.pit.standing:
		if not h.alive():
			continue
		var rig: CutRig = _host.rigs.rig_for(h.id)
		if rig == null:
			rig = _host.robots.rig_for(h.id)
		if rig == null or not rig.is_visible_in_tree():
			continue
		var at: Vector2 = rig.get_global_transform_with_canvas().origin
		var letter: String = "G"
		var goal: Vector2 = Vector2.INF
		var squad: ArenaSquad = _stage.arena.squad_ai
		if squad != null:
			if not squad.minds.has(h.id):
				continue
			var mind: SquadMind = squad.minds[h.id]
			letter = LETTER[mind.motion]
			if mind._destination.is_finite():
				goal = mind.agent.goal
		elif h.pursuit != null and h.pursuit._blocked:
			goal = h.pursuit._goal
		var color: Color = COLORS[letter]
		if goal.is_finite():
			var end: Vector2 = screen * (goal * SimConst.PX_PER_M)
			_ink.draw_line(at, end, Ink.INK, 3.0, true)
			_ink.draw_line(at, end, color, 1.0, true)
			_ink.draw_circle(end, 3.0, color, false, 1.3, true)
		var label: Vector2 = at + Vector2(9.0, 10.0)
		var font: Font = ThemeDB.fallback_font
		_ink.draw_string_outline(font, label, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 5, Ink.INK)
		_ink.draw_string(font, label, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
