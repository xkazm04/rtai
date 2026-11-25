extends "res://dev/cast/cast_lineup.gd"
## n31 ground foe lift probe: each foe kind walks a straight line per facing through the real
## wave cast (the staging of cast_foot_film.gd); every captured tick is saved full (`_a`), without
## any drop shadow (`_b`) and without the foe (`_c`) for tools/ground/lift/foes.py.
## Flags: --subjects=a,b --gaits=walk,run --ppm=32|64 --out=<dir> [--capture=<ticks per facing>]
const KNOWN_FLAGS: PackedStringArray = ["--subjects", "--gaits", "--ppm", "--out", "--capture"]
const WARM: int = 24
const SPEEDS: Dictionary = {
	"patrol_cop": [3.2, 6.0],
	"riot_cop": [2.8, 0.0],
	"swat": [3.4, 6.0],
	"robot_thug": [2.4, 0.0],
	"robot_gunner": [2.2, 0.0],
	"contractor": [3.0, 0.0],
	"rocket_trooper": [3.2, 0.0],
	"sentry_turret": [0.0, 0.0],
	"shield_robot": [1.6, 0.0],
	"war_machine": [1.8, 0.0],
}
const CROPS: Dictionary = {"war_machine": Vector2i(448, 512), "shield_robot": Vector2i(256, 320)}
const CROP: Vector2i = Vector2i(192, 256)
const CARD_KEYS: Array[StringName] = [
	&"door_carrier_card",
	&"pile_driver_card",
	&"sentry_turret_card",
	&"robot_gunner_card",
	&"robot_thug_card",
]

var _log: FileAccess
var _failed: bool = false
var _capture_ticks: int = 40
var _crop: Vector2i = CROP


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	_out = args.text("--out")
	_ppm = int(args.number("--ppm", 32.0))
	_capture_ticks = int(args.number("--capture", 40.0))
	_pitch = 70
	if _ppm not in [32, 64] or DirAccess.make_dir_recursive_absolute(_out) != OK:
		_fail("expected --ppm=32|64 and a writable --out")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	var host: ArenaRigs = _open_wave()
	if host == null:
		_fail("could not open wave cast")
		return
	_log = FileAccess.open(_out.path_join("frames.jsonl"), FileAccess.WRITE)
	for subject: String in args.text("--subjects", ",".join(SPEEDS.keys())).split(","):
		for gait: String in args.text("--gaits", "walk,run").split(","):
			await _kind(host, subject, gait)
	_log.close()
	get_tree().quit(1 if _failed else 0)


func _kind(host: ArenaRigs, subject: String, gait: String) -> void:
	var pair: Array = SPEEDS[subject]
	var speed: float = pair[0 if gait == "walk" else 1]
	var standing: bool = subject == "sentry_turret"
	if speed <= 0.0 and not (standing and gait == "walk"):
		return
	_crop = CROPS.get(subject, CROP)
	var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, StringName(subject))
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(foe)
	for other: Fighter in _arena.hostiles:
		if other != foe:
			other.pos = PARK
	_arena.rivet.pos = MARK + Vector2.RIGHT * 12.0
	for octant: int in 8:
		await _line(host, foe, [subject, gait, octant, speed])
	foe.pos = PARK
	for t: int in 4:
		await _advance()


func _advance() -> void:
	_clock.complete_tick()
	await get_tree().process_frame


func _line(host: ArenaRigs, foe: Fighter, key: Array) -> void:
	var octant: int = key[2]
	var dir: Vector2 = Vector2.from_angle(octant * PI / 4.0)
	var speed: float = key[3]
	var step: Vector2 = dir * speed * SimClock.TICK_DT
	var start: Vector2 = MARK - step * (WARM + _capture_ticks * 0.5)
	foe.pos = start
	foe.facing = dir
	for tick: int in WARM + _capture_ticks:
		foe.pos = start + step * (tick + 1)
		foe.facing = dir
		await _advance()
		if tick >= WARM:
			await _capture(host, foe, key, tick - WARM)


func _rig_of(host: ArenaRigs, foe: Fighter) -> CutRig:
	var rig: CutRig = host.rigs.rig_for(foe.id)
	if rig == null and host.robots != null:
		rig = host.robots.rig_for(foe.id)
	return rig


func _hidden_items(rig: CutRig) -> Array[RID]:
	var items: Array[RID] = []
	var nodes: Array[Node] = _shadow.get_parent().find_children("*", "RigCastShadows", false, false)
	for n: Node in nodes:
		items.append((n as CanvasItem).get_canvas_item())
	for key: StringName in CARD_KEYS:
		if rig.has_meta(key):
			var card: Object = rig.get_meta(key)
			var own: Object = card.get("_shadow")
			if own is CanvasItem:
				items.append((own as CanvasItem).get_canvas_item())
	return items


func _cards(rig: CutRig) -> Array[RID]:
	var items: Array[RID] = []
	for key: StringName in CARD_KEYS:
		if rig.has_meta(key):
			var card: Object = rig.get_meta(key)
			if card is CanvasItem:
				items.append((card as CanvasItem).get_canvas_item())
	return items


func _capture(host: ArenaRigs, foe: Fighter, key: Array, tick: int) -> void:
	var rig: CutRig = _rig_of(host, foe)
	if rig == null:
		_failed = true
		return
	var stem: String = "%s_%s_o%d_t%03d" % [key[0], key[1], key[2], tick]
	var shadows: Array[RID] = _hidden_items(rig)
	var origin: Vector2i = Vector2i.ZERO
	var foot_at: Vector2i = Vector2i(_crop.x / 2, _crop.y * 3 / 4)
	var ground: Vector2 = rig.get_canvas_transform() * (foe.pos * SimConst.PX_PER_M)
	var cards: Array[RID] = _cards(rig)
	for pass_id: String in ["a", "b", "c"]:
		for item: RID in shadows:
			RenderingServer.canvas_item_set_visible(item, pass_id == "a")
		RenderingServer.canvas_item_set_visible(rig.get_canvas_item(), pass_id != "c")
		for item: RID in cards:
			RenderingServer.canvas_item_set_visible(item, pass_id != "c")
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		if pass_id == "a":
			origin = Vector2i(ground) - foot_at
		if (
			image.get_region(Rect2i(origin, _crop)).save_png(
				_out.path_join("%s_%s.png" % [stem, pass_id])
			)
			!= OK
		):
			_failed = true
	for item: RID in shadows:
		RenderingServer.canvas_item_set_visible(item, true)
	RenderingServer.canvas_item_set_visible(rig.get_canvas_item(), true)
	for item: RID in cards:
		RenderingServer.canvas_item_set_visible(item, true)
	var rig_at: Vector2 = rig.get_global_transform_with_canvas().origin - Vector2(origin)
	_write_meta(stem, key, tick, [ground - Vector2(origin), rig_at, rig])


func _write_meta(stem: String, key: Array, tick: int, more: Array) -> void:
	var at: Vector2 = more[0]
	var rig_at: Vector2 = more[1]
	var rig: CutRig = more[2]
	var speed: float = key[3]
	var row: Dictionary = {
		"stem": stem,
		"kind": key[0],
		"gait": key[1],
		"octant": key[2],
		"tick": tick,
		"ground_x": at.x,
		"ground_y": at.y,
		"rig_y": rig_at.y,
		"screen_ppm": float(_ppm),
		"phase": rig.phase,
		"speed": speed,
	}
	if not _log.store_line(JSON.stringify(row)):
		_failed = true
