class_name TonnageDumpKick
extends RefCounted
## n31 ghost 09: a drop deploy's dump kicks the camera once on the dump tick (Tonnage's dump, and
## Ohm's discharge since n31 ghost 12). Once per dump (the strike's release tick), never during
## the charge, never under reduced motion. The shake id is the drop row's `dump_shake`
## (GhostAttacks.DeployRow, a camera.json id; none = no kick). `dump_hitstop` is in the table
## too, but a hit-stop needs SimClock.hold and the souls view has no clock: shake only.

## A dump this many ticks old or older is stale (a view attached late) and never kicks.
const FRESH_TICKS: int = 4

var kicks: int = 0
## The id of the last kick (Tonnage's until one lands).
var shake_id: StringName = &""
var _attacks: GhostAttacks
var _kicked_tick: int = -1


static func shipped() -> TonnageDumpKick:
	var k: TonnageDumpKick = TonnageDumpKick.new()
	k._attacks = GhostAttacks.shipped()
	k.shake_id = k.shake_of(HaulerStage.GHOST)
	return k


## The form's dump shake id: &"" for a hold row or a row without one.
func shake_of(form: StringName) -> StringName:
	var row: GhostAttacks.DeployRow = _attacks.deploy.get(form)
	if row == null or not row.drops():
		return &""
	return row.dump_shake


## One view frame. True when this call kicked the camera.
func step(ghost: GhostDeploy, tick: int, camera: CameraRig, calm: bool) -> bool:
	var land: int = ghost.strike.release_tick
	var id: StringName = shake_of(ghost.strike.release_form)
	if land < 0 or land == _kicked_tick or id == &"":
		return false
	if tick - land >= FRESH_TICKS or tick < land:
		return false
	_kicked_tick = land
	if calm or camera == null:
		return false
	shake_id = id
	camera.kick(id, land)
	kicks += 1
	return true
