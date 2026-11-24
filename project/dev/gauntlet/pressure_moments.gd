class_name PressureMoments
extends RefCounted
## Ticks at which a still shows what a take is about, for the film tool. Dev measurement only: it
## watches the arena after each tick and keeps the first tick of each kind (0 = none yet).

const NEAR_M: float = 4.0
const FAR_M: float = 2.5
const BACK_MIN_M: float = 2.0

## pair_dash: Rivet mid-dash with a hostile rocket within NEAR_M of him.
var dash_cross: int = 0
## pair_circle: the last tick the rocket that downs him is still FAR_M or more from him.
var before_fatal: int = 0
## guard6: a round turned back by the guard, at least BACK_MIN_M from Rivet on its way out.
var returned_flight: int = 0
## blade6: a rifle round strikes Rivet while the blade is mid-swing.
var struck_in_swing: int = 0
var _contacts: int = 0


func observe(take: PressureTake) -> void:
	var rivet: Fighter = take.arena.rivet
	var nearest: float = INF
	var turned: bool = false
	for shot: Shot in take.arena.shots:
		var gap: float = shot.pos.distance_to(rivet.pos)
		if shot is FoeRocketFlight.Round:
			nearest = minf(nearest, gap)
		elif shot.from_rivet and gap >= BACK_MIN_M:
			turned = true
	var dashing: bool = take.session.pilot.motion.phase == PlayerMotion.Phase.DASH
	if dash_cross == 0 and dashing and nearest <= NEAR_M:
		dash_cross = take.tick
	if rivet.alive() and nearest >= FAR_M and nearest <= NEAR_M + 1.0:
		before_fatal = take.tick
	if returned_flight == 0 and turned and take.take == "guard6":
		returned_flight = take.tick
	if take.contacts > _contacts and struck_in_swing == 0 and take.session.pilot.melee.busy():
		struck_in_swing = take.tick
	_contacts = take.contacts


func summary() -> Dictionary:
	return {
		"moment_dash_cross": dash_cross,
		"moment_before_fatal": before_fatal,
		"moment_returned_flight": returned_flight,
		"moment_struck_in_swing": struck_in_swing,
	}
