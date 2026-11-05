class_name BloodVictims
extends RefCounted
## Whose fluid a kill prints (split out of CombatBlood at its 300-line stop, lane ghost-powers):
## the player (Rivet) and the robots drawn on rigs (ArenaRobotRigs) leak oil, humans bleed red,
## and a dry kill kind (burned, cauterised) prints nothing on a human. Render routing only.

enum Route { NONE, PLAYER, ROBOT, HUMAN }

## Kill kinds (events.json) that leave no red (lane human-reactions): a body burned to death lies
## charred (HumanReact's char tint); Kerf's slice (ghost-powers) cauterises the cut.
const DRY_KILLS: Array[StringName] = [&"burned", &"cauterised"]

## Actor ids drawn as robots: their death leaks oil, never red.
var robot_ids: Dictionary[int, bool] = {}


## True when a `kind` kill of `victim` prints nothing (a dry human kill; a robot always leaks).
func dry(kind: StringName, victim: int) -> bool:
	return kind in DRY_KILLS and not robot_ids.has(victim)


## How `victim`'s death prints, `player` being Rivet's actor id.
func route(victim: int, player: int) -> Route:
	if victim == player:
		return Route.PLAYER
	if robot_ids.has(victim):
		return Route.ROBOT
	return Route.HUMAN
