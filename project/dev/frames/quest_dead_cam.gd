extends Node
## n9-world, dev capture only (quest1_clip.gd --cam=dead): leans quest 1's city camera toward the
## densest heap of dead hostiles, so a 64 px/m Dock 9 close-up holds the contractors' plan
## corpses (the camera on Rivet, and --cam=fight on the live cop, left them off-frame at 64). Like
## dev/rivet_arsenal/quest_fight_cam.gd, render only: the lean goes in as CityView.kick_px; the
## focus, the streaming and the sim are never touched. No dead yet: the camera stays on Rivet.

## The dead within this many metres of one another are framed together (one fight's heap).
const CLUSTER_M: float = 3.0
## The framed point sits this fraction of the screen height above its centre (the dialogue box).
const FRAME_UP: float = 0.12
## The framed point eases this share of the way per frame (a new death elsewhere pans, not cuts);
## a jump of more than SNAP_TICKS between two frames (stills mode) snaps.
const EASE: float = 0.06
const SNAP_TICKS: int = 10

var session: Quest1Session = null
var city_view: CityView = null
var _at: Vector2 = Vector2.INF
var _last: int = -1


func _ready() -> void:
	process_priority = 1
	if city_view != null:
		city_view.process_priority = 1


func _process(_delta: float) -> void:
	if session == null or city_view == null:
		return
	var arena: CombatArena = session.stage.arena
	var at: Vector2 = _heap_of(arena)
	if at == Vector2.INF:
		return
	if _at == Vector2.INF or session.tick() - _last > SNAP_TICKS:
		_at = at
	_last = session.tick()
	_at = _at.lerp(at, EASE)
	city_view.kick_px += (_at - arena.rivet.pos) * SimConst.PX_PER_M
	var screen_h: float = city_view.get_viewport_rect().size.y
	city_view.kick_px.y += FRAME_UP * screen_h / maxf(city_view.zoom, 0.01)


## The centre of the densest heap: the dead around the one with the most dead within CLUSTER_M
## (ties: hurt last), or INF. The latest-hurt alone wandered: shots into old corpses re-stamp it.
func _heap_of(arena: CombatArena) -> Vector2:
	var best: Fighter = null
	var best_n: int = 0
	for h: Fighter in arena.hostiles:
		if h.alive():
			continue
		var n: int = int(_near(arena, h.pos).z)
		if n > best_n or (n == best_n and h.hurt_tick > best.hurt_tick):
			best = h
			best_n = n
	if best == null:
		return Vector2.INF
	var c: Vector3 = _near(arena, best.pos)
	return Vector2(c.x, c.y) / c.z


## The dead within CLUSTER_M of `at`: (sum x, sum y, count).
func _near(arena: CombatArena, at: Vector2) -> Vector3:
	var c: Vector3 = Vector3.ZERO
	for h: Fighter in arena.hostiles:
		if not h.alive() and h.pos.distance_to(at) <= CLUSTER_M:
			c += Vector3(h.pos.x, h.pos.y, 1.0)
	return c
