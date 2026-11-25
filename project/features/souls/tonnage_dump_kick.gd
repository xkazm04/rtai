class_name TonnageDumpKick
extends RefCounted
## n31 ghost 09: Tonnage's dump lands with the same camera shake as the Q-form stomp. Once per
## dump (the strike's release tick), never during the charge, never under reduced motion. The
## shake id is the tonnage deploy row's `dump_shake` (a camera.json id). `dump_hitstop` is in the
## table too, but a hit-stop needs SimClock.hold and the souls view has no clock: shake only.

## A dump this many ticks old or older is stale (a view attached late) and never kicks.
const FRESH_TICKS: int = 4

var kicks: int = 0
var shake_id: StringName = &""
var _kicked_tick: int = -1


static func shipped() -> TonnageDumpKick:
	var k: TonnageDumpKick = TonnageDumpKick.new()
	var t: DataTable = DataTable.open(GhostAttacks.PATH, GhostAttacks.SCHEMA)
	var row: Dictionary = t.object(t.object(t.raw, "deploy"), String(HaulerStage.GHOST))
	k.shake_id = StringName(t.text(row, "dump_shake"))
	return k


## One view frame. True when this call kicked the camera.
func step(ghost: GhostDeploy, tick: int, camera: CameraRig, calm: bool) -> bool:
	var land: int = ghost.strike.release_tick
	if land < 0 or land == _kicked_tick or ghost.strike.release_form != HaulerStage.GHOST:
		return false
	if tick - land >= FRESH_TICKS or tick < land:
		return false
	_kicked_tick = land
	if calm or camera == null:
		return false
	camera.kick(shake_id, land)
	kicks += 1
	return true
