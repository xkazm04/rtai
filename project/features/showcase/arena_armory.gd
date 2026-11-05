class_name ArenaArmory
extends ArenaHook
## The showcase's armory (arena_stations/showcase.json, `showcase_armory`): every finished table
## weapon laid on the hub floor in two rows east of Rivet's start, so the owner walks over a gun
## to take it into its empty carry slot, or presses interact over one to swap it for the held
## gun of that class (rivet-arsenal's WeaponPickups; PickupsView draws them). On with --armory,
## and by default in the showcase export (feature tag `showcase`) unless a --bot drives Rivet.
## Without a --loadout Rivet starts with the pistol. Off: nothing is laid, nothing hashed, so
## the arena's scenarios and replays do not move.

## The night's finished weapons in the director cut's order (ReelChapters), then the rest.
const ORDER: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"rocket_launcher",
	&"flamethrower",
	&"electro_gun",
	&"molotov",
	&"katana",
	&"chainsaw",
	&"plasma_sword",
	&"hand_cannon",
	&"plasma_rifle",
	&"ray_gun",
	&"homing_shard",
	&"mini_nuke",
	&"gatling",
	&"gloria",
	&"electro_baton",
]
## The first item's spot (hub-relative metres) and the grid: rows of PER_ROW, STEP_M apart (twice
## the pickup reach, so one step along a row never stands over two guns).
const FIRST_M: Vector2 = Vector2(1.5, -1.2)
const STEP_M: float = 1.8
const ROW_M: float = 1.5  # rows y -1.2 and 0.3: 1.2 m clear of the melee line and react_line
const PER_ROW: int = 8

var laid: int = 0


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	if not active(OS.get_cmdline_user_args(), OS.has_feature("showcase")):
		return
	var arsenal: ArenaArsenal = null
	for hook: ArenaHook in stage.hooks:
		if hook is ArenaArsenal:
			arsenal = hook as ArenaArsenal
	if arsenal == null:
		Log.warn("showcase", "armory: no carry station (rivet-arsenal) in the arena")
		return
	if arsenal.carry == null:
		@warning_ignore("return_value_discarded")
		arsenal.arm([&"pistol"], false)
	if arsenal.carry == null:
		return
	lay(arsenal.carry, stage.plan.base)
	Log.info("showcase", "armory: %d weapons on the hub floor" % laid)


## On with --armory, or in the showcase export without a --bot.
static func active(args: PackedStringArray, showcase_build: bool) -> bool:
	if args.has("--armory"):
		return true
	for arg: String in args:
		if arg.begins_with("--bot="):
			return false
	return showcase_build


## Lays every ORDER weapon the carry can hold and does not hold yet, in rows from FIRST_M.
func lay(carry: RivetCarry, base: Vector2) -> void:
	for id: StringName in ORDER:
		if carry.slot_of(id) < 0 or carry.slots.has(id):
			continue
		var row: float = floorf(float(laid) / PER_ROW)
		var at: Vector2 = FIRST_M + Vector2(float(laid % PER_ROW) * STEP_M, row * ROW_M)
		carry.ground.drop(id, base + at)
		laid += 1


func telemetry() -> Dictionary:
	return {"armory": laid} if laid > 0 else {}
