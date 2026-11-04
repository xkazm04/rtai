class_name ArenaArsenal
extends ArenaHook
## rivet-arsenal's carry station (arena_stations/rivet-arsenal.json, `rivet_arsenal_carry`):
## `--loadout=pistol,plasma_rifle,rocket_launcher,molotov` gives Rivet those table guns in their
## carry slots (RivetCarry on the live StagePilot); number keys 1-4, the wheel (weapon_next /
## weapon_prev) and reload then work in the arena's real fight, with WeaponHold's stow and draw.
## `--pickups=hand_cannon,rocket_launcher` lays those guns along the pit's way in (ArenaPitBot's
## entry), so a bot walking in picks them up (WeaponPickups). Shown by PickupsView.
## Without --loadout nothing changes (the arena keeps Gloria and its scenarios do not move).
## A bot (--bot=...) holds the trigger, so a semi gun re-taps.

var carry: RivetCarry = null
var _ctx: WorldContext = null
var _stage: ArenaStage = null


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	_ctx = ctx
	_stage = stage
	var ids: Array[StringName] = []
	var bot: bool = false
	var ground: PackedStringArray = PackedStringArray()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--loadout="):
			for id: String in arg.substr(10).split(",", false):
				ids.append(StringName(id))
		elif arg.begins_with("--pickups="):
			ground = arg.substr(10).split(",", false)
		bot = bot or arg.begins_with("--bot=")
	if not ids.is_empty() and arm(ids, bot) != null:
		for k: int in ground.size():
			var at: Vector2 = ArenaPitBot.ENTRY[mini(k + 1, ArenaPitBot.ENTRY.size() - 1)]
			carry.ground.drop(StringName(ground[k]), stage.plan.base + at)


## Gives Rivet `ids` (each into its class's slot) and draws the first one.
func arm(ids: Array[StringName], bot: bool) -> RivetCarry:
	var table: WeaponTable = WeaponTable.shipped()
	carry = RivetCarry.new(table, ArsenalTable.shipped(), _ctx.rng.stream(&"gunplay"))
	carry.tap = bot
	var first: int = -1
	for id: StringName in ids:
		var slot: int = carry.add(id)
		if slot < 0:
			Log.warn("rivet_arsenal", "loadout: %s is not a carried gun; skipped" % id)
		elif first < 0:
			first = slot
	if first < 0:
		carry = null
		return null
	carry.select(first, _stage.arena)
	_stage.pilot.carry = carry
	if _stage.arena.guard_tell == null:
		_stage.arena.guard_tell = GuardTell.from_table(table)
	Log.info("rivet_arsenal", "arena: Rivet carries %s" % [carry.slots])
	return carry


func attach_view(view: Node) -> void:
	var v: CollectCallView = view as CollectCallView
	if carry == null or v == null or v.print_stage == null:
		return
	var p: PickupsView = PickupsView.new()
	p.carry = carry
	p.z_index = RenderLayers.z(&"actors") - 1
	v.print_stage.actor_layer().add_child(p)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(carry.switches if carry != null else -1)


func telemetry() -> Dictionary:
	if carry == null:
		return {}
	var out: Dictionary = {"switches": carry.switches, "weapon": String(carry.weapon())}
	out["hold_switches"] = _stage.pilot.hold.switches
	out["picked"] = carry.ground.picked
	out["swapped"] = carry.ground.swapped
	return out
