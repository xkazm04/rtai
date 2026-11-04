class_name ArenaWeaponRack
extends ArenaHook
## weapon-art's station (arena_stations/weapon-art.json, `weapon_art_rack`): the weapon wall in
## the hub (WeaponRackView), the whole arsenal hung muzzle up along the north edge. Render only:
## setup() keeps the stage base, attach_view() adds the wall under the actors; nothing is
## stepped or hashed, so the arena's scenarios and replays do not move.
## `--weapon-rack=off` hides it.

## The board's left end, bottom edge, hub-relative metres: the board's top meets the hub's
## north wall (y -5); the y -3 dummies stand in front of it.
const AT_M: Vector2 = Vector2(-2.5, -3.15)

var _base: Vector2 = Vector2.ZERO
var _on: bool = true


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_base = stage.plan.base
	_on = not OS.get_cmdline_user_args().has("--weapon-rack=off")


func attach_view(view: Node) -> void:
	var v: CollectCallView = view as CollectCallView
	if not _on or v == null or v.print_stage == null:
		return
	var rack: WeaponRackView = WeaponRackView.new()
	rack.origin_m = _base + AT_M
	rack.z_index = RenderLayers.z(&"actors") - 2
	v.print_stage.actor_layer().add_child(rack)


func telemetry() -> Dictionary:
	return {"rack": _on}
