class_name KillRestSpin
extends RefCounted
## n17 npc-react (owner: "dead bodies are moving after killed"): a gib piece or blade half that has
## landed for good still turns for ~30 ticks after its slide stops, because GibSim._slide stops
## the slide by drag but lets the spin decay exponentially (the katana's halves crept from +38 to
## +67 at 32 px/m, film dr_katana). The sim is not changed tonight (replay hash), so the view draws
## a landed piece at the angle its spin will reach: it lands, slides without turning, and from then
## on its pixels never move. In the air (or held) nothing changes. ON false = the before.
const ON: bool = true
## The decay loop's cap (ticks): a spin that would take longer keeps what it reached.
const MAX_TICKS: int = 600


## The turn (rad) piece `i` of `g` still has to make, drawn ahead of time once it is down for good
## (no height, no bounce, not held); 0 otherwise.
static func left(g: GibSim, i: int) -> float:
	if not ON or g.wait[i] > 0 or g.z[i] > 0.0 or g.vz[i] != 0.0:
		return 0.0
	return turn_left(g.spin[i])


## The rotation GibSim._slide's spin decay adds from spin `s` (rad/s) until it reaches 0.
static func turn_left(s: float) -> float:
	var dt: float = SimClock.TICK_DT
	var total: float = 0.0
	for _t: int in MAX_TICKS:
		if s == 0.0:
			break
		s = move_toward(s, 0.0, absf(s) * 4.0 * dt + 0.2 * dt)
		total += s * dt
	return total
