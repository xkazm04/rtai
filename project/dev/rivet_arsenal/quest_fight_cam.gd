extends Node
## rivet-arsenal, dev capture only (quest1_clip.gd --cam=fight): gunplay's FightCam on quest 1's
## city camera, so a 64 px/m Dock 9 close-up keeps the cop Rivet fights in frame (the camera on
## Rivet alone left the deaths under the dialogue box at the frame's edge). Render only: the lean
## goes in as CityView.kick_px (inside the print lock, like the Hauler's shake); the city's focus,
## its streaming and the sim are never touched. Runs at process_priority 1 with the CityView moved
## to 1 too, after the view's _hauler_kick wrote kick_px and before the CityView places its camera.

## A jump of more ticks than this between two frames (stills mode) snaps instead of easing.
const SNAP_TICKS: int = 10
## The framed point sits this fraction of the screen height above its centre: quest 1's dialogue
## box covers the lower third, and the cops Rivet fights fell under it (Dock 9 stills 13740-13780).
const FRAME_UP: float = 0.12

var session: Quest1Session = null
var city_view: CityView = null
var _cam: FightCam = FightCam.new()
var _last: int = -1


func _ready() -> void:
	process_priority = 1
	if city_view != null:
		city_view.process_priority = 1


func _process(_delta: float) -> void:
	if session == null or city_view == null:
		return
	var arena: CombatArena = session.stage.arena
	if session.tick() - _last > SNAP_TICKS:
		_cam.at = Vector2.INF  # a still jumped the sim: frame the fight at once, no ease
	_last = session.tick()
	var at: Vector2 = _cam.step(arena, session.tick())
	city_view.kick_px += (at - arena.rivet.pos) * SimConst.PX_PER_M
	var screen_h: float = city_view.get_viewport_rect().size.y
	city_view.kick_px.y += FRAME_UP * screen_h / maxf(city_view.zoom, 0.01)
