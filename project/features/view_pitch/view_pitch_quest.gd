class_name ViewPitchQuest
extends RefCounted
## n8-view it15: quest 1 under the combined view (`combo`) eases to the boss pitch while the
## stage's boss (quest 1's Mertz, CombatArena.spawn_boss) is up and alive, and back to play once
## he is down, as ViewPitchHook does for the arena bosses (quest 1 has no arena hooks, so before
## this his fight stayed at 70). Only a row that eases gets it: top, tilt and tilt70 draw quest 1
## as before. View only: it reads the arena, never writes it. ON false = quest 1 stays at the
## play pitch all quest (the it14 build).

const ON: bool = true


## Adds a ViewPitchEase under `view` when the shared view row eases; null when it does not.
static func attach(view: Node, arena: CombatArena, clock: SimClock) -> ViewPitchEase:
	var pitch: ViewPitch = ViewPitch.of(String(ViewMode.shared().id))
	if not ON or ViewMode.shared().is_flat() or not pitch.eases():
		return null
	var ease: ViewPitchEase = ViewPitchEase.new()
	ease.name = &"view_pitch_ease"
	ease.pitch = pitch
	ease.clock = clock
	ease.boss_on = func() -> bool: return boss_up(arena)
	view.add_child(ease)
	return ease


## The stage's boss has stepped in and is still standing.
static func boss_up(arena: CombatArena) -> bool:
	return arena != null and arena.boss != null and arena.boss.alive()
