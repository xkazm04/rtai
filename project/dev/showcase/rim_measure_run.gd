class_name RimMeasureRun
extends Node
## One rig alone on flat asphalt, with and without halos: rim width = (area with - area without) /
## perimeter without, in screen px; edge contrast = luminance gap of the outer silhouette pixels to
## the ground. Writes <out>/rim-<tag>.json and a crop per kind and zoom.

const PPMS: Array[int] = [32, 48, 64, 128]
const GROUND: Color = Color(0.17, 0.17, 0.19)
const KINDS: Dictionary[String, BodyPlan.Kind] = {
	"rivet": BodyPlan.Kind.RIVET, "cop": BodyPlan.Kind.COP, "ped": BodyPlan.Kind.PED
}

var out_dir: String = ""
var tag: String = "run"
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()
var _layer: CanvasLayer = CanvasLayer.new()


func _ready() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = GROUND
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	add_child(_bus)
	add_child(_data)
	add_child(_layer)
	_layer.add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))


func shoot() -> int:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var result: Dictionary = {}
	for kind: String in KINDS:
		for ppm: int in PPMS:
			result["%s@%d" % [kind, ppm]] = await _measure(kind, ppm)
	var f: FileAccess = FileAccess.open(out_dir.path_join("rim-%s.json" % tag), FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(result, "  ", true))
	return 0


func _measure(kind: String, ppm: int) -> Dictionary:
	var z: float = ppm / 32.0
	var id: int = KINDS.keys().find(kind) + 1
	var view: Vector2 = get_viewport().get_visible_rect().size
	_layer.transform = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	_rigs.zoom = z
	var feed: RigFeed = _rigs.feed
	feed.count = 0
	@warning_ignore("return_value_discarded")
	feed.put(0, id, KINDS[kind], Vector2.ZERO, Vector2.ZERO)
	feed.looks[0] = RigFeed.LOOK_AUTO if kind == "rivet" else 0
	_rigs.focus = Vector2.ZERO
	for t: int in 40:
		feed.clip[0] = RigClips.Clip.NONE
		feed.face[0] = 0.0
		_rigs.step_ticks(1)
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var on: Image = get_viewport().get_texture().get_image()
	var rig: CutRig = _rigs.rig_for(id)
	for h: Sprite2D in rig.halos:
		h.visible = false
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var off: Image = get_viewport().get_texture().get_image()
	var stats: Dictionary = _stats(on, off)
	var box: Rect2i = Rect2i(
		Vector2i(view * 0.5) - Vector2i(2 * ppm, 2 * ppm), Vector2i(4 * ppm, 4 * ppm)
	)
	@warning_ignore("return_value_discarded")
	on.get_region(box).save_png(out_dir.path_join("rim-%s-%s-%d.png" % [tag, kind, ppm]))
	return stats


func _fg(img: Image, x: int, y: int) -> bool:
	return (
		img.get_pixel(x, y).is_equal_approx(GROUND) == false
		and (
			absf(img.get_pixel(x, y).get_luminance() - GROUND.get_luminance()) > 0.04
			or img.get_pixel(x, y).s > 0.3
		)
	)


## A foreground pixel with a ground pixel among its four neighbours.
func _is_edge(img: Image, x: int, y: int) -> bool:
	if not _fg(img, x, y):
		return false
	return not (
		_fg(img, x - 1, y) and _fg(img, x + 1, y) and _fg(img, x, y - 1) and _fg(img, x, y + 1)
	)


func _stats(on: Image, off: Image) -> Dictionary:
	var a_on: int = 0
	var a_off: int = 0
	var perim: int = 0
	var gap: float = 0.0
	var edge_n: int = 0
	for y: int in range(1, on.get_height() - 1):
		for x: int in range(1, on.get_width() - 1):
			a_on += 1 if _fg(on, x, y) else 0
			a_off += 1 if _fg(off, x, y) else 0
			perim += 1 if _is_edge(off, x, y) else 0
			if _is_edge(on, x, y):
				gap += absf(on.get_pixel(x, y).get_luminance() - GROUND.get_luminance())
				edge_n += 1
	return {
		"area_with_halo": a_on,
		"area_without": a_off,
		"perimeter_px": perim,
		"rim_width_px": snappedf(float(a_on - a_off) / maxf(perim, 1.0), 0.01),
		"edge_contrast": snappedf(gap / maxf(edge_n, 1.0), 0.001),
	}
