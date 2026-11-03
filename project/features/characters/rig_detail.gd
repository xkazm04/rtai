class_name RigDetail
extends RefCounted
## The D5 "Inked Grime" detail tier: from 56 px/m (full at 64 px/m) and closer (boss arenas,
## kill-cams), a rig whose body plan has a D5 part set (art/d5/<art_dir>/) gets one D5 overlay
## sprite per part, printed by look_d5_part.gdshader ON TOP of the untouched D4 part. The D5
## parts have the D4 file names, sizes, pivots and alpha (silhouette lock) and the overlay's
## alpha is the zoom fade (`amount`, 0 at ON_ZOOM -> 1 at FULL_ZOOM), so the switch itself
## changes no pixel and nothing ever moves an outline or the sticker halo. Parts printed with a
## palette swap keep their D4 print: the overlay would undo the swap.
## Overlays are made once per rig on first use, then only shown / hidden. Render-side only.

const ON_ZOOM: float = 1.75
const OFF_ZOOM: float = 1.6875
const FULL_ZOOM: float = 2.0
const D5_DIR: String = "d5/"
const OVERLAY: StringName = &"d5"
const FILTER_MIPS: CanvasItem.TextureFilter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
const SHADER_PATH: String = "res://assets/shaders/look_d5_part.gdshader"

static var active: bool = false
## false = the D5 tier never switches on (A/B evidence frames, a settings toggle).
static var enabled: bool = true
static var _mats: Array[ShaderMaterial] = []
static var _has: Dictionary[String, bool] = {}
static var _has_part: Dictionary[String, bool] = {}
static var _on: Dictionary[int, bool] = {}
static var _over: Dictionary[int, Array] = {}


## Called once a frame with the camera zoom (1.0 = 32 px/m); returns whether the tier is on.
static func set_view(zoom: float) -> bool:
	if active and zoom < OFF_ZOOM:
		active = false
	elif not active and zoom >= ON_ZOOM:
		active = true
	if _mats.is_empty():
		_build()
	for m: ShaderMaterial in _mats:
		m.set_shader_parameter("px_scale", CutRig.SC * zoom)
		m.set_shader_parameter("amount", smoothstep(ON_ZOOM, FULL_ZOOM, zoom))
	return active


static func has_d5(art_dir: String) -> bool:
	if not _has.has(art_dir):
		_has[art_dir] = FileAccess.file_exists(
			PartLibrary.ART_ROOT + D5_DIR + art_dir + "/parts.json"
		)
	return _has[art_dir]


## A D5 set can lack a part the D4 set gained later (d4-production's sleeve values and new looks):
## that part then gets no overlay and keeps its D4 print, instead of a missing-file load per rig.
static func has_part(dir: String, part: String) -> bool:
	var key: String = dir + "/" + part
	if not _has_part.has(key):
		_has_part[key] = ResourceLoader.exists(PartLibrary.ART_ROOT + key + ".png")
	return _has_part[key]


static func is_on(rig: CutRig) -> bool:
	return _on.get(rig.get_instance_id(), false)


## Puts the rig on the current tier and keeps its overlays on the parts' current textures.
static func sync(rig: CutRig) -> void:
	var id: int = rig.get_instance_id()
	var want: bool = enabled and active and has_d5(rig.plan.art_dir)
	if not want and not is_on(rig):
		return
	_on[id] = want
	if want and not _over.has(id):
		_make(rig)
	var over: Array = _over.get(id, [])
	for i: int in over.size():
		var o: Sprite2D = over[i]
		o.visible = want and rig.sprite_swaps[i] == 0
		var src: Texture2D = rig.sprites[i].texture
		if want and o.get_meta(&"src") != src:
			_point(o, rig, src)


## The hit flash: the D5 overlays print the tint too.
static func on_tint(rig: CutRig, tint: bool) -> void:
	for o: Sprite2D in _over.get(rig.get_instance_id(), []):
		o.material = _mats[1 if tint else 0]


static func _make(rig: CutRig) -> void:
	var over: Array[Sprite2D] = []
	for spr: Sprite2D in rig.sprites:
		var o: Sprite2D = Sprite2D.new()
		o.name = OVERLAY
		o.centered = false
		o.texture_filter = FILTER_MIPS
		o.material = _mats[1 if rig.is_tinted() else 0]
		spr.add_child(o)
		_point(o, rig, spr.texture)
		over.append(o)
	_over[rig.get_instance_id()] = over


## Points overlay o at the D5 art of the part its parent shows (src).
static func _point(o: Sprite2D, rig: CutRig, src: Texture2D) -> void:
	o.set_meta(&"src", src)
	var part: String = src.resource_path.get_file().get_basename()
	var dir: String = D5_DIR + rig.plan.art_dir
	o.texture = PartLibrary.texture(dir, part) if has_part(dir, part) else null
	o.offset = (o.get_parent() as Sprite2D).offset


static func _build() -> void:
	var sh: Shader = load(SHADER_PATH) as Shader
	for t: int in 2:
		var m: ShaderMaterial = ShaderMaterial.new()
		m.shader = sh
		m.set_shader_parameter("tint", float(t))
		_mats.append(m)
