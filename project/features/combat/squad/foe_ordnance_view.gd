class_name FoeOrdnanceView
extends Node2D
## The hostile rocket uses the game's rocket body, smoke and impact art. Only the
## flight signal creates a blast mark, including when its shooter has already fallen.

var arena: CombatArena
var _marks: Array[Vector3] = []
var _ticks: Array[int] = []


static func attach(parent: Node2D, fight: CombatArena) -> void:
	if fight.squad_ai == null:
		return
	var view: FoeOrdnanceView = FoeOrdnanceView.new()
	view.arena = fight
	parent.add_child(view)
	@warning_ignore("return_value_discarded")
	fight.squad_ai.rockets.burst.connect(view._impact)


func _impact(at: Vector2, radius: float, _shot: Shot) -> void:
	_marks.append(Vector3(at.x, at.y, radius))
	_ticks.append(arena.tick)


func _process(_delta: float) -> void:
	while not _ticks.is_empty() and arena.tick - _ticks[0] >= FightAreasArt.BLAST_TICKS:
		_ticks.remove_at(0)
		_marks.remove_at(0)
	queue_redraw()


func _draw() -> void:
	for shot: Shot in arena.shots:
		if shot is FoeRocketFlight.Round:
			FightAreasArt._rocket(
				self, shot.pos, shot.vel.normalized(), shot.origin.distance_to(shot.pos), arena.tick
			)
	for i: int in _marks.size():
		FightAreasArt._blast(self, _marks[i], arena.tick - _ticks[i])
	for h: Fighter in arena.hostiles:
		if h.alive() and h.archetype == &"sentry_turret":
			_barrel(h)


func _barrel(h: Fighter) -> void:
	var mind: SquadMind = arena.squad_ai.minds.get(h.id)
	var base: Vector2 = Ink.px(h.pos + h.facing * 0.2)
	var tip: Vector2 = base + Ink.px(h.facing * 0.95)
	draw_line(base, tip, Ink.INK, 13.0, true)
	draw_line(base, tip, Ink.CREAM, 5.0, true)
	if mind == null or mind.turret.phase != FoeTurret.Phase.COOL:
		return
	var heat: float = float(h.cooldown) / mind.agent.arch.weapon.cooldown_ticks
	var amber: Color = Color(Color("#edab42"), heat)
	draw_circle(tip, 11.0, Color(amber, heat * 0.35))
	draw_line(base, tip, amber, 8.0, true)
