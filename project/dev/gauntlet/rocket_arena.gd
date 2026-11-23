extends Node
## Run one arm of the rocket pressure sweep through the production street trigger and projectile.

const KNOWN_FLAGS: PackedStringArray = ["--rest", "--model", "--lead", "--out"]

var _model: String
var _rest: float
var _share: float


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	_model = args.text("--model")
	_rest = args.text("--rest").to_float()
	_share = args.text("--lead").to_float()
	var out: String = args.text("--out")
	if (
		_model not in ["linear", "orbit"]
		or _rest <= 0.0
		or not out.is_absolute_path()
		or not args.text("--lead").is_valid_float()
		or _share < 0.0
		or _share > 1.0
	):
		Log.error("rocket-arena", "expected rest, model, lead and absolute output path")
		get_tree().quit(2)
		return
	var trials: Array[Dictionary] = _measure()
	if trials.is_empty():
		get_tree().quit(1)
		return
	var arm: Dictionary = {"rest_s": _rest, "model": _model, "share": _share, "trials": trials}
	var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	var ok: bool = file != null and file.store_string(JSON.stringify(arm, "  ") + "\n")
	get_tree().quit(0 if ok else 1)


func _measure() -> Array[Dictionary]:
	var trials: Array[Dictionary] = []
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var speed: float = PlayerMotion.from_table(table).sprint_mps
	for distance: float in [10.0, 14.0]:
		for seed_id: int in range(1, 4):
			for motion: String in ["standing", "circle", "circle_dash"]:
				var arena: FireGapArena = _trial(distance, seed_id, motion, speed)
				if not arena.measure():
					return []
				trials.append(
					{
						"distance_m": distance,
						"seed": seed_id,
						"motion": motion,
						"hits": arena.hit_ticks.size(),
						"launches": arena.fire_ticks.size(),
						"dashes": arena.dash_ticks.size()
					}
				)
	return trials


func _trial(distance: float, seed_id: int, motion: String, speed: float) -> FireGapArena:
	var rng: RngRegistry = RngRegistry.new(seed_id)
	var arena: FireGapArena = FireGapArena.new(
		CombatTuning.shipped(), Events, rng.stream(&"combat")
	)
	arena.prepare(&"rocket_trooper", motion, speed, distance)
	var mind: SquadMind = arena.squad_ai.mind_for(arena.foe)
	mind.agent.arch.weapon.cooldown_ticks = CombatTuning.ticks(_rest)
	mind.agent.arch.weapon.aim_lead = _share
	mind.rocket.orbit_lead = _model == "orbit"
	return arena
