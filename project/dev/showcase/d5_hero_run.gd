class_name D5HeroRun
extends D5ShowcaseRun
## d5-close hero shot (item 4) and landmark-roof gate (item 3): Rivet versus two cops at a junction
## ringed by the four landmark roofs (union-fist mural, The Last Shift bar, HQ, pension bank).
## Tiers as D5ShowcaseRun; the "d5" tier also swaps the roofs to their D5 art
## (features/city/art/d5/roofs/). Deterministic: fixed cast, fixed clip ticks, no RNG.

const ROOFS: String = "res://features/city/art/roofs/"
const ROOFS_D5: String = "res://features/city/art/d5/roofs/"
const LANDMARKS: Dictionary[String, Vector2] = {
	"building_mural": Vector2(9.7, -9.7),
	"building_bar": Vector2(-9.7, -9.7),
	"building_hq": Vector2(-9.7, 9.7),
	"building_pension_bank": Vector2(9.7, 9.7),
}
const ROOF_M: float = 8.4
const SHADOW_M: float = 1.1

var _roofs: Dictionary[String, Sprite2D] = {}
var _shadows: Array[Polygon2D] = []


func _init() -> void:
	zooms = [1.0, 1.5, 2.0]
	cam = Vector2(5.6, -4.2) * PX


func _ground() -> void:
	_tile("road_intersection_tone", Vector2.ZERO)
	for k: int in [-1, 1]:
		for r: int in [1, 2]:
			_tile("road_straight_tone_b", Vector2(k * r * 8, 0) * PX)
			_tile("road_straight_v_tone_b", Vector2(0, k * r * 8) * PX)
		for j: int in [-1, 1]:
			for r: int in [1, 2]:
				for q: int in [1, 2]:
					_tile("sidewalk_tone", Vector2(k * r * 8, j * q * 8) * PX)
	for roof: String in LANDMARKS:
		_shadow(LANDMARKS[roof] * PX)
		var s: Sprite2D = Sprite2D.new()
		s.texture = load(ROOFS + roof + ".png") as Texture2D
		s.scale = Vector2.ONE * ROOF_M * PX / s.texture.get_width()
		s.position = LANDMARKS[roof] * PX
		s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_world.add_child(s)
		_roofs[roof] = s


## A cast shadow down-right of a roof (the mock's depth cue): a flat ink tint that look_d4
## prints as its dark wash step + hatch. Proposal for the city lane; only the "d5" tier shows it.
func _shadow(at: Vector2) -> void:
	var h: float = ROOF_M * 0.5 * PX
	var o: float = SHADOW_M * PX
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = PackedVector2Array(
		[
			Vector2(h, -h + o),
			Vector2(h + o, -h + o),
			Vector2(h + o, h + o),
			Vector2(-h + o, h + o),
			Vector2(-h + o, h),
			Vector2(h, h)
		]
	)
	poly.texture = _hatch_tex()
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	poly.position = at
	poly.visible = false
	_world.add_child(poly)
	_shadows.append(poly)


## A 48 px tile of diagonal pen strokes over a light ink tint (the mock's hatched shadow).
static func _hatch_tex() -> ImageTexture:
	var img: Image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y: int in 48:
		for x: int in 48:
			var line: bool = (x + y) % 8 < 3
			img.set_pixel(x, y, Color(0.09, 0.075, 0.106, 0.85 if line else 0.32))
	return ImageTexture.create_from_image(img)


## Rivet on the junction's north-east corner under the fist mural, facing two cops closing in.
func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	var spots: PackedVector2Array = PackedVector2Array(
		[Vector2(4.8, -2.4), Vector2(1.2, -0.6), Vector2(8.6, -0.9)]
	)
	var kinds: Array[BodyPlan.Kind] = [BodyPlan.Kind.RIVET, BodyPlan.Kind.COP, BodyPlan.Kind.COP]
	var looks: PackedByteArray = PackedByteArray([RigFeed.LOOK_AUTO, 5, 6])
	for i: int in kinds.size():
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kinds[i], spots[i] * PX, Vector2.ZERO)
		f.looks[i] = looks[i]


func _pose(t: int) -> void:
	super._pose(t)
	var f: RigFeed = _rigs.feed
	f.face[0] = (f.pos[1] - f.pos[0]).angle()
	f.aim[0] = f.pos[1]
	f.flags[0] = RigFeed.Flag.AIMING


func _tier(tier: String) -> void:
	var dir: String = ROOFS_D5 if tier == "d5" else ROOFS
	for p: Polygon2D in _shadows:
		p.visible = tier == "d5"
	for roof: String in _roofs:
		_roofs[roof].texture = load(dir + roof + ".png") as Texture2D
