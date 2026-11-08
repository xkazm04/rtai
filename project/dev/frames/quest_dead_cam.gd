extends Node
## n9-world, dev capture only (quest1_clip.gd --cam=dead): leans quest 1's city camera toward the
## dead hostiles of the latest fight, so a 64 px/m Dock 9 close-up holds the contractors' plan
## corpses (the camera on Rivet, and --cam=fight on the live cop, left them off-frame at 64). Like
## dev/rivet_arsenal/quest_fight_cam.gd, render only: the lean goes in as CityView.kick_px; the
## focus, the streaming and the sim are never touched. No dead yet: the camera stays on Rivet.

## The dead within this many metres of the latest one are framed together (one fight's heap).
const CLUSTER_M: float = 8.0
## The framed point sits this fraction of the screen height above its centre (the dialogue box).
const FRAME_UP: float = 0.12

var session: Quest1Session = null
var city_view: CityView = null


func _ready() -> void:
	process_priority = 1
	if city_view != null:
		city_view.process_priority = 1


func _process(_delta: float) -> void:
	if session == null or city_view == null:
		return
	var arena: CombatArena = session.stage.arena
	var at: Vector2 = _latest_dead(arena)
	if at == Vector2.INF:
		return
	city_view.kick_px += (at - arena.rivet.pos) * SimConst.PX_PER_M
	var screen_h: float = city_view.get_viewport_rect().size.y
	city_view.kick_px.y += FRAME_UP * screen_h / maxf(city_view.zoom, 0.01)


## The centre of the dead around the one hurt last (hurt_tick = its death blow), or INF.
func _latest_dead(arena: CombatArena) -> Vector2:
	var last: Fighter = null
	for h: Fighter in arena.hostiles:
		if not h.alive() and (last == null or h.hurt_tick > last.hurt_tick):
			last = h
	if last == null:
		return Vector2.INF
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for h: Fighter in arena.hostiles:
		if not h.alive() and h.pos.distance_to(last.pos) <= CLUSTER_M:
			sum += h.pos
			n += 1
	return sum / n
