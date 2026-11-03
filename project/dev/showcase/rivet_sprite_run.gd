class_name RivetSpriteRun
extends Node
## Rivet (or a patrol cop, gun out) alone, facing -y (the quest 1 cast convention), drawn by
## CharacterRigs at 120 px/m
## over flat black and then flat white, so an offline matte (masters tools/rivet_matte.py) can
## recover colour and alpha. The actors layer sits above nothing but the flat ground.

const PX: float = 32.0
const PPM: float = 120.0
const SETTLE_TICKS: int = 60
const CROP_M: float = 4.0

## The patrol cop look in RigVariant (rig_showcase casts look 5 as the patrol cop).
const COP_LOOK: int = 5

var out_dir: String = ""
var kind: String = "rivet"
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


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	var cop: bool = kind == "cop"
	var body: BodyPlan.Kind = BodyPlan.Kind.COP if cop else BodyPlan.Kind.RIVET
	@warning_ignore("return_value_discarded")
	f.put(0, 1, body, Vector2.ZERO, Vector2.ZERO)
	f.looks[0] = COP_LOOK if cop else RigFeed.LOOK_AUTO
	if cop:
		f.flags[0] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
		f.aim[0] = Vector2(0.0, -6.0 * PX)


func shoot() -> int:
	_cast()
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
	return crop.save_png(out_dir.path_join("%s_on_%s.png" % [kind, bg])) == OK
