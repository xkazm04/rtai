class_name AlleyHook
extends ArenaHook
## n5-look: the alley stage (data/tables/arena_stations/look.json, area `alley`): a close-up back
## alley at 48 px/m where cops come in from both ends. Its waves are an ArenaPit of its own
## (zone = the alley inset, points = alley_decor.json "spawns", both ends), stepped on the tick
## after the stage; Rivet's death clears them. The view side (AlleyDecor) draws the puddles, the
## fence and the fire escapes in the print. Rules: data/tables/alley_decor.json.

const TABLE: String = "res://data/tables/alley_decor.json"
const SCHEMA: String = "gtai.alley-decor/1"

var waves: ArenaPit = ArenaPit.new()
var decor: Dictionary = {}
var _base: Vector2 = Vector2.ZERO
var _deaths: int = 0
var _floor_m: Rect2 = Rect2()


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	decor = t.raw
	_base = stage.plan.base
	var area: ArenaPlan.Area = stage.plan.area(station.area)
	_floor_m = area.rect if area != null else Rect2()
	var rule: Dictionary = t.object(t.raw, "waves")
	waves.zone = area.rect.grow(-t.num(rule, "trigger_inset_m")) if area != null else Rect2()
	waves.first_wave = roundi(t.num(rule, "first_wave"))
	waves.grow = roundi(t.num(rule, "grow"))
	waves.max_wave = roundi(t.num(rule, "max_wave"))
	waves.gap_ticks = roundi(t.num(rule, "gap_s") / SimClock.TICK_DT)
	for v: Variant in t.array(t.raw, "spawns"):
		var at: Vector2 = _base + t.vec({"v": v}, "v")
		if stage.cells == null or stage.cells.clear(at, 0.5):
			waves.points.append(at)
	_deaths = stage.deaths


func step(stage: ArenaStage, tick: int) -> void:
	if stage.deaths != _deaths:  # Rivet went down: the alley starts over, like the pit
		_deaths = stage.deaths
		waves.reset(stage.arena)
	waves.step(stage.arena, tick)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(waves.kills)
	out.put_32(waves.wave)


func telemetry() -> Dictionary:
	return {"alley_kills": waves.kills, "alley_waves": waves.wave}


func attach_view(view: Node) -> void:
	var v: CollectCallView = view as CollectCallView
	if v == null or v.print_stage == null:
		return
	var ground: AlleyDecor = AlleyDecor.new(decor, _base, false)
	ground.set_ground(_floor_m, station.props)
	_lay(v, ground, RenderLayers.z(&"ground") + 1, v.stage_view.scale)
	var walls: Array[Rect2] = []
	for p: ArenaStation.Prop in station.props:
		if p.kind == "wall_high":
			walls.append(Rect2(Ink.px(_base + p.at - p.size * 0.5), p.size * Ink.PX_PER_M))
	var mid: Vector2 = Ink.px(_floor_m.get_center())
	var along_x: bool = _floor_m.size.x > _floor_m.size.y
	var roofs: AlleyRoofs = AlleyRoofs.new(decor, _base, walls, mid, along_x)
	_lay(v, roofs, RenderLayers.z(&"ground") + 2, v.stage_view.scale)
	var over: AlleyDecor = AlleyDecor.new(decor, _base, true)
	over.material = v.print_stage.item_material()
	over.z_index = RenderLayers.z(&"roof_occluders")
	over.scale = v.cast_view.scale
	v.print_stage.actor_layer().add_child(over)
	_add_print_zone(v.print_stage)


## The alley's own floor level in the print (alley_decor.json `print`). d7-calls look-5 (owner,
## 2026-11-05): off by default, the lane is the pale paper; --alley-print=on = r2_a6's mid concrete.
func _add_print_zone(ps: PrintStage) -> void:
	var row: Dictionary = decor.get("print", {})
	if row.is_empty() or not OS.get_cmdline_user_args().has("--alley-print=on"):
		return
	var fade: float = row["fade_m"]
	var world: Dictionary = row["world"]
	ps.look_zones.append(LookZone.create(_floor_m, fade, world))


func _lay(v: CollectCallView, node: Node2D, z: int, s: Vector2) -> void:
	node.z_index = z
	node.scale = s
	v.print_stage.add_child(node)
