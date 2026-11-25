extends Node
## n31 ghost measure (dev only): how many foes one Tonnage deploy hits. Run through
## node tools/ghost/deploy_measure.mjs, or node tools/dev/run.mjs
## res://dev/ghost_n31/ghost_measure.tscn -- --mode=lab|play --out=<abs.json>
## [--radius=4,5,...] [--full=only|both] [--at=spot|rivet|both] [--charge=<ticks>] [--seeds=10]
## [--waves=4] [--profile=average] [--per-size=15] [--shapes-out=<abs>]
## [--fit=shipped|relaxed] (play: relaxed = dev bot spot, Ohm at 3+ bodies, Kerf any target)
## [--form=tonnage|ohm|dent|kerf] (default tonnage; ohm lab + play, dent and kerf play only)
## No --radius = main as shipped (the real GhostDeployStrike footprint).

const KNOWN_FLAGS: PackedStringArray = [
	"--mode",
	"--out",
	"--radius",
	"--full",
	"--at",
	"--charge",
	"--seeds",
	"--waves",
	"--profile",
	"--per-size",
	"--shapes-out",
	"--form",
	"--fit"
]
const SHAPES: String = "res://dev/ghost_n31/shapes.json"


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var mode: String = args.text("--mode")
	var path: String = args.text("--out")
	var unknown: bool = not args.values.keys().all(func(k: String) -> bool: return k in KNOWN_FLAGS)
	if unknown or mode not in ["lab", "play"] or not path.is_absolute_path():
		printerr("ghost_measure needs --mode=lab|play --out=<absolute.json>")
		get_tree().quit(2)
		return
	var report: Dictionary = {
		"schema": "gtai.ghost-n31-measure/1",
		"mode": mode,
		"tick_hz": SimClock.TICK_RATE,
		"rows": [],
	}
	var started: int = Time.get_ticks_msec()
	var form: StringName = _form(args.text("--form", "tonnage"))
	if form == &"" or (mode == "lab" and form not in [HaulerStage.GHOST, OhmStage.GHOST]):
		printerr("ghost_measure --form=tonnage|ohm|dent|kerf (lab: tonnage|ohm)")
		get_tree().quit(2)
		return
	report.form = form
	var ok: bool = _lab(args, report, form) if mode == "lab" else _play(args, report, form)
	report.wall_s = (Time.get_ticks_msec() - started) / 1000.0
	ok = ok and _write(path, JSON.stringify(report, "  ") + "\n")
	get_tree().quit(0 if ok else 1)


func _variants(args: ArenaArgs, form: StringName) -> Array[GhostN31Geometry]:
	var out: Array[GhostN31Geometry] = []
	var main: GhostN31Geometry = _lab_for(form).shipped_geometry()
	var ahead: float = main.ahead_m
	if not args.has("--radius"):
		out.append(main)
		return out
	var full: String = args.text("--full", "")
	var at: String = args.text("--at", "spot")
	for text: String in args.text("--radius").split(","):
		var r: float = text.to_float()
		if full != "only":
			out.append(GhostN31Geometry.new(r, false, false, ahead))
		if full != "":
			if at != "rivet":
				out.append(GhostN31Geometry.new(r, true, false, ahead))
			if at != "spot":
				out.append(GhostN31Geometry.new(r, true, true, ahead))
	return out


func _lab(args: ArenaArgs, report: Dictionary, form: StringName) -> bool:
	var file: FileAccess = FileAccess.open(SHAPES, FileAccess.READ)
	var shapes: Dictionary = GhostN31Shapes.parse(file.get_as_text() if file != null else "")
	if shapes.is_empty():
		Log.error("ghost-measure", "no shapes in %s (run play with --shapes-out first)" % SHAPES)
		return false
	var lab: GhostN31Lab = GhostN31Lab.new()
	lab.form = form
	var per: int = int(args.number("--per-size", 15))
	var shipped: bool = not args.has("--radius")
	var rows: Array = report.rows
	for geometry: GhostN31Geometry in _variants(args, form):
		for size: int in GhostN31Shapes.SIZES:
			var pool: Array = shapes.get(size, [])
			var picked: Array = GhostN31Shapes.spread(pool, per)
			for i: int in picked.size():
				var shape: Dictionary = picked[i]
				var row: Dictionary = lab.trial(shape, geometry, shipped)
				row.merge(geometry.to_dict())
				row.shipped = shipped
				row.shape_index = i
				rows.append(row)
		Log.info("ghost-measure", "lab %s done" % geometry.label())
	return true


func _play(args: ArenaArgs, report: Dictionary, form: StringName) -> bool:
	var shipped: bool = not args.has("--radius")
	var charge: int = int(args.number("--charge", 0))
	var profile: StringName = StringName(args.text("--profile", "average"))
	report.profile = profile
	var play: GhostN31Play = GhostN31Play.new()
	play.form = form
	play.fit = StringName(args.text("--fit", "shipped"))
	var rows: Array = report.rows
	for geometry: GhostN31Geometry in _variants(args, form):
		for seed_id: int in range(1, int(args.number("--seeds", 10)) + 1):
			var cut: GhostN31Geometry = null if shipped and charge == 0 else geometry
			var row: Dictionary = play.run_seed(
				seed_id, profile, int(args.number("--waves", 4)), cut, charge
			)
			row.merge(geometry.to_dict())
			row.shipped = shipped and charge == 0
			row.charge_ticks = charge
			row.fit = play.fit
			rows.append(row)
			var deploys: Array = row.get("deploys", [])
			Log.info(
				"ghost-measure",
				"play %s seed %d: %d deploys" % [geometry.label(), seed_id, deploys.size()]
			)
	var shapes_out: String = args.text("--shapes-out")
	return shapes_out == "" or _write(shapes_out, _shapes_json(play.shapes))


func _shapes_json(shapes: Dictionary) -> String:
	var sizes: Dictionary = {}
	for size: int in GhostN31Shapes.SIZES:
		var pool: Array = shapes[size]
		sizes[str(size)] = GhostN31Shapes.spread(pool, 15)
	var doc: String = "Foe offsets from their centroid and Rivet's, sampled from gauntlet play"
	doc += " (profile average, seeds 1..N) every 60 ticks the deploy bot would drop Tonnage."
	return (
		JSON.stringify({"doc": doc, "schema": GhostN31Shapes.SCHEMA, "sizes": sizes}, "  ") + "\n"
	)


func _write(path: String, text: String) -> bool:
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	return out != null and out.store_string(text)


func _lab_for(form: StringName) -> GhostN31Lab:
	var lab: GhostN31Lab = GhostN31Lab.new()
	lab.form = form
	return lab


func _form(text: String) -> StringName:
	var forms: Dictionary = {
		"tonnage": HaulerStage.GHOST,
		"ohm": OhmStage.GHOST,
		"dent": DentStage.GHOST,
		"kerf": KerfStage.GHOST
	}
	return forms.get(text, &"")
