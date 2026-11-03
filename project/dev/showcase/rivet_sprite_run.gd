class_name RivetSpriteRun
extends Node
## Rivet alone, idle, facing -y (the quest 1 cast convention), drawn by CharacterRigs at 120 px/m
## over flat black and then flat white, so an offline matte (masters tools/rivet_matte.py) can
## recover colour and alpha. The actors layer sits above nothing but the flat ground.

const PX: float = 32.0
const PPM: float = 120.0
const SETTLE_TICKS: int = 60
const CROP_M: float = 4.0

var out_dir: String = ""
var _ground: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _flat: ColorRect = ColorRect.new()
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


func _ready() -> void:
	_ground.layer = 0
	_actors.layer = 1
	for n: Node in [_ground, _actors, _bus, _data]:
		add_child(n)
	_flat.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ground.add_child(_flat)
	_actors.add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))
	var f: RigFeed = _rigs.feed
	f.count = 0
	@warning_ignore("return_value_discarded")
	f.put(0, 1, BodyPlan.Kind.RIVET, Vector2.ZERO, Vector2.ZERO)
	f.looks[0] = RigFeed.LOOK_AUTO


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	var z: float = PPM / PX
	var view: Vector2 = get_viewport().get_visible_rect().size
	_actors.transform = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	_rigs.zoom = z
	for bg: String in ["black", "white"]:
		_flat.color = Color.BLACK if bg == "black" else Color.WHITE
		for t: int in SETTLE_TICKS:
			var f: RigFeed = _rigs.feed
			_rigs.focus = f.pos[0]
			f.clip[0] = RigClips.Clip.NONE
			f.face[0] = -PI * 0.5
			_rigs.step_ticks(1)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		ok = _save(bg, view) and ok
	return 0 if ok else 1


func _save(bg: String, view: Vector2) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var side: int = roundi(CROP_M * PPM)
	var lo: Vector2i = Vector2i(view * 0.5) - Vector2i(side / 2, side / 2)
	var crop: Image = img.get_region(Rect2i(lo, Vector2i(side, side)))
	return crop.save_png(out_dir.path_join("rivet_on_%s.png" % bg)) == OK
