class_name PressureLaunches
extends RefCounted
## Watches the hostile rocket rounds on a take: when the newest one left, and how many ticks one
## of Rivet's own rockets and a hostile one flew together.

var launch: int = -1000
var last: Shot
var paired_ticks: int = 0
var first_pair: int = 0


func observe(arena: CombatArena, tick: int) -> void:
	var own: bool = false
	var hostile: bool = false
	for shot: Shot in arena.shots:
		if shot is FoeRocketFlight.Round:
			hostile = true
			if not shot.has_meta(&"pressure_launch"):
				shot.set_meta(&"pressure_launch", tick)
				launch = tick
				last = shot
		elif shot.from_rivet and shot.weapon == &"rocket_launcher":
			own = true
	if own and hostile:
		paired_ticks += 1
		if first_pair == 0:
			first_pair = tick
