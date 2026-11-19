class_name ArenaWeaponRack
extends ArenaHook
## weapon-art's station (arena_stations/weapon-art.json, `weapon_art_rack`): the weapon wall in
## the hub (WeaponRackView). Interact at the east peg to take the rifle. The board and pegs stay
## in place under the actors. `--weapon-rack=off` disables the station.

## The first peg at the board's bottom edge, hub-relative metres: the board's top meets the hub's
## north wall (y -5); the y -3 dummies stand in front of it.
const AT_M: Vector2 = Vector2(-2.5, -3.15)

var _base: Vector2 = Vector2.ZERO
var _on: bool = true
var _rifle_at: Vector2
var _taken: bool = false
var _rack: WeaponRackView


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_base = stage.plan.base
	_on = not OS.get_cmdline_user_args().has("--weapon-rack=off")
	var slot: int = WeaponRackView.ORDER.find(WeaponArtKey.of(RivetCarry.RIFLE))
	_rifle_at = _base + AT_M + Vector2.RIGHT * slot * WeaponRackView.GAP_M


func step(stage: ArenaStage, _tick: int) -> void:
	if not _on or _taken or not stage.press_left or stage.pilot == null:
		return
	var rivet: Fighter = stage.arena.rivet
	if not rivet.alive() or rivet.pos.distance_to(_rifle_at) > WeaponPickups.REACH_M:
		return
	var carry: RivetCarry = stage.pilot.carry
	if carry == null:
		for hook: ArenaHook in stage.hooks:
			if hook is ArenaArsenal:
				var drawn: GunHand = stage.arena.gun
				carry = (hook as ArenaArsenal).arm(
					[rivet.weapon], drawn != null and drawn.tap, drawn
				)
				break
	if carry != null and carry.ground.collect(RivetCarry.RIFLE, true, stage.arena, carry):
		_taken = true
		stage.press_left = false
		if is_instance_valid(_rack):
			_rack.rifle_taken = true


func write_state(out: StreamPeerBuffer) -> void:
	if _taken:
		out.put_8(1)


func attach_view(view: Node) -> void:
	var v: CollectCallView = view as CollectCallView
	if not _on or v == null or v.print_stage == null:
		return
	_rack = WeaponRackView.new()
	_rack.origin_m = _base + AT_M
	_rack.z_index = RenderLayers.z(&"actors") - 2
	_rack.rifle_taken = _taken
	v.print_stage.actor_layer().add_child(_rack)


func telemetry() -> Dictionary:
	return {"rack": _on}
