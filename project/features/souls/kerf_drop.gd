class_name KerfDrop
extends RefCounted
## n31 ghost 21 (the owner: no placement marker for any ghost). Kerf's drop deploy locks its
## target on the press (the deploy's own picker, GhostDeploySpot.kerf_target), stands Kerf at
## Rivet's side facing it through the wind-up and hands the strike the locked target on the
## charge's last tick. The lock follows the target; it breaks when the target dies, walks past
## range_m + SLACK_M from Rivet or goes behind a wall. A broken lock re-picks on the cut tick
## (row relock nearest, n31 ghost 24b: the deploy's picker from Rivet along the press's aim);
## only when that finds nobody (or relock none) does the cut whiff.

## How far past range_m the locked target may walk before the lock breaks.
const SLACK_M: float = 2.0

## The locked target (null = none: a whiff deploy, or no lock at all).
var target: Fighter = null
## True for a drop deployment: the strike takes the lock and never picks afresh.
var armed: bool = false
## Why the lock broke at the cut: &"dead", &"range", &"wall" (&"" = it held, or no lock); kept
## when the relock found a second foe.
var broke: StringName = &""
## The target whose lock broke (null = none broke).
var lost: Fighter = null
## True when the lock broke and the relock cut a second foe instead.
var relocked: bool = false
## The press's aim direction and aim point (the relock picks along them).
var aim: Vector2 = Vector2.ZERO
var aim_spot: Vector2 = Vector2.ZERO


func reset() -> void:
	target = null
	armed = false
	broke = &""
	lost = null
	relocked = false


## The press. False when nothing is locked and the row refuses (no deployment, no cooldown);
## else Kerf stands at Rivet's side (wall-clipped, as DentLane) facing the target or the aim.
func lock(stage: CollectCallStage, ghost: GhostDeploy) -> bool:
	reset()
	var attacks: GhostAttacks = ghost.strike.attacks
	aim = ghost.facing
	aim_spot = ghost.spot
	var foe: Fighter = GhostDeploySpot.kerf_target(stage, ghost.spot, ghost.facing, attacks)
	if foe == null and attacks.deploy[KerfStage.GHOST].no_target != &"whiff":
		return false
	armed = true
	target = foe
	var rivet: Fighter = stage.arena.rivet
	if foe != null and foe.pos != rivet.pos:
		ghost.facing = rivet.pos.direction_to(foe.pos)
	var side: Vector2 = ghost.facing.orthogonal() * rivet.radius_m
	ghost.spot = GhostDeploySpot.clip(stage, rivet.pos, rivet.pos + side)
	if foe != null and foe.pos != ghost.spot:
		ghost.facing = ghost.spot.direction_to(foe.pos)
	return true


## The target the strike cuts: the lock while it holds; once broken the relock's pick (null =
## a whiff); a hold deploy (not armed) picks at the release as before.
func cut_target(stage: CollectCallStage, ghost: GhostDeploy) -> Fighter:
	var attacks: GhostAttacks = ghost.strike.attacks
	if not armed:
		return GhostDeploySpot.kerf_target(stage, ghost.spot, ghost.facing, attacks)
	relocked = false
	broke = _broken(stage, attacks)
	if broke == &"":
		return target
	lost = target
	if attacks.deploy[KerfStage.GHOST].relock != &"nearest":
		return null
	var foe: Fighter = GhostDeploySpot.kerf_target(stage, aim_spot, aim, attacks)
	if foe == null:
		return null
	target = foe
	relocked = true
	return foe


## Why the lock no longer holds (&"" = it holds, or there is no lock).
func _broken(stage: CollectCallStage, attacks: GhostAttacks) -> StringName:
	if target == null:
		return &""
	if not target.alive():
		return &"dead"
	var from: Vector2 = stage.arena.rivet.pos
	var reach: float = attacks.deploy[KerfStage.GHOST].range_m + SLACK_M
	if from.distance_to(target.pos) > reach:
		return &"range"
	if not GhostDeploySpot.clear(stage, from, target.pos):
		return &"wall"
	return &""


## No cut: Kerf blinks dash_m along his facing from the origin (wall-clipped).
static func whiff(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	var dash: float = ghost.strike.attacks.num(KerfStage.GHOST, &"dash_m")
	ghost.spot = GhostDeploySpot.clip(stage, ghost.origin, ghost.origin + ghost.facing * dash)
