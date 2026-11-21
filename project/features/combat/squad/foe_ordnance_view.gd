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
