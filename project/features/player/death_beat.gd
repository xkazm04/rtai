class_name DeathBeat
extends RefCounted
## Rivet's death beat (owner, d8 verdict "yes"): a destroyed Rivet lies in his death sprawl
## (RigClips.die, which every rig host plays from the DEAD flag) for combat.json
## `rivet.death_beat_s` before the respawn cut; the stage ignores his input meanwhile. The view
## veils the frame in ink over the beat's last FADE_IN_S and lifts it over FADE_OUT_S after the
## cut (DeathVeil). `death_beat_s` 0 (or absent) = d8's instant respawn. Sim timing, no art.

const FADE_IN_S: float = 0.4
const FADE_OUT_S: float = 0.3
const LONG_AGO: int = 1 << 20

var beat_ticks: int = 0
var dead_ticks: int = 0
var since_respawn: int = LONG_AGO


static func of(tuning: CombatTuning) -> DeathBeat:
	var b: DeathBeat = DeathBeat.new()
	var s: float = tuning.rivet["death_beat_s"] if tuning.rivet.has("death_beat_s") else 0.0
	b.beat_ticks = CombatTuning.ticks(s)
	return b


## Steps one sim tick; true while a dead Rivet must stay down (the beat still runs). False for a
## live Rivet, and on the tick the beat ends (the caller respawns him then).
func holding(alive: bool) -> bool:
	if alive:
		dead_ticks = 0
		since_respawn = mini(since_respawn + 1, LONG_AGO)
		return false
	dead_ticks += 1
	if dead_ticks < beat_ticks:
		return true
	dead_ticks = 0
	since_respawn = 0 if beat_ticks > 0 else since_respawn
	return false


## The ink veil's opacity 0..1: rising over the beat's last FADE_IN_S, falling after the cut.
func veil() -> float:
	if dead_ticks > 0:
		var left: int = beat_ticks - dead_ticks
		return clampf(1.0 - float(left) / float(CombatTuning.ticks(FADE_IN_S)), 0.0, 1.0)
	return clampf(1.0 - float(since_respawn) / float(CombatTuning.ticks(FADE_OUT_S)), 0.0, 1.0)
