class_name D5HeroRun
extends D5ShowcaseRun
## d5-close hero shot (item 4) and landmark-roof gate (item 3): Rivet versus two cops at a junction
## ringed by the four landmark roofs (union-fist mural, The Last Shift bar, HQ, pension bank).
## Tiers as D5ShowcaseRun; the "d5" tier also swaps the roofs to their D5 art
## (features/city/art/d5/roofs/). Deterministic: fixed cast, fixed clip ticks, no RNG.

const ROOFS: String = "res://features/city/art/roofs/"
const D5_GROUND: String = "res://features/city/art/d5/ground/"
const ROOFS_D5: String = "res://features/city/art/d5/roofs/"
## ground tiles with a D5 variant in D5_GROUND (print-aware joints / crosswalk wear),
## swapped in the "d5" tier
const D5_TILES: Array[String] = [
	"sidewalk_tone.png",
	"road_intersection_tone.png",
	"road_straight_tone_b.png",
	"road_straight_v_tone_b.png",
]
const LANDMARKS: Dictionary[String, Vector2] = {
	"building_mural": Vector2(9.7, -9.7),
	"building_bar": Vector2(-9.7, -9.7),
	"building_hq": Vector2(-9.7, 9.7),
	"building_pension_bank": Vector2(9.7, 9.7),
}
const PROPS: String = "res://features/city/art/props/"
## prop -> [x m, y m, w m, h m, rotation deg] (sizes from city_textures.json)
const PROP_SPOTS: Array[Array] = [
	["dumpster", 7.2, -4.9, 2.2, 1.5, 0.0],
	["fire_hydrant", 5.0, -5.1, 0.5, 0.5, 0.0],
	["payphone", 12.6, -4.7, 1.3, 1.3, 0.0],
	["trash_can", 10.4, -4.8, 0.7, 0.7, 0.0],
	["lamp_post", 4.7, -8.0, 3.2, 0.5, 90.0],
	["police_barrier", 11.4, -0.9, 0.8, 2.2, 0.0],
	["traffic_cone", 10.6, 1.4, 0.5, 0.5, 0.0],
	["traffic_cone", 10.9, -2.9, 0.5, 0.5, 0.0],
	["traffic_cone", 12.2, 1.6, 0.5, 0.5, 0.0],
	# the mock's wall-side crates (barrel_cluster prints vermilion = doctrine noise, not used)
	["crate_stack", -10.8, -4.8, 2.1, 1.4, 0.0],
	["crate_stack", 7.8, 4.8, 2.1, 1.4, 0.0],
]
## kerb shadow strips in metres (the pavement blocks' street-side edges facing down-right),
## stopping where D5HeroKerbs rounds the corner (radius 1.6 m)
const KERB_SHADOWS: Array[Rect2] = [
	Rect2(-20.0, -4.0, 14.4, 0.18),
	Rect2(5.6, -4.0, 14.4, 0.18),
	Rect2(-4.0, -20.0, 0.18, 14.4),
	Rect2(-4.0, 5.6, 0.18, 14.4),
]
## the LOCAL 9 union hall first: it lands beside the mural, where the mock has its LOCAL 9 roof
const NEIGHBOURS: Array[String] = [
	"building_union_hall", "building_tall", "building_osha", "building_helipad"
]
const ROOF_M: float = 8.4
## the 128 px/m kill-cam frames the shot: Rivet (4.8, -2.4), cop 2 (8.6, -0.9), the soul trail
const KILL_CAM_M: Vector2 = Vector2(6.6, -1.9)
const HERO_CAM_M: Vector2 = Vector2(5.6, -4.2)
const SHADOW_M: float = 1.1

## optional: a folder of keyed street-life sprites (D5HeroExtras); "" = none
var borrow_dir: String = ""
## the camera below the kill-cam zoom (world px); D5PanRun moves it
var hero_cam: Vector2 = HERO_CAM_M * PX
var soul_mode: String = "d5"
var _soul_mat: Material = null
var _roofs: Dictionary[String, Sprite2D] = {}
## neighbour roofs that have D5 art (the LOCAL 9 union hall): swapped with the landmarks
var _d5_neighbours: Array[Sprite2D] = []
var _shadows: Array[Polygon2D] = []
var _corners: Array[Node2D] = []
var _roof_at: Array[Vector2] = []


func _init() -> void:
	zooms = [1.0, 1.5, 2.0, 3.0, 4.0]
	cam = HERO_CAM_M * PX


func _frame_at(z: float) -> void:
	cam = KILL_CAM_M * PX if z >= 4.0 else hero_cam
	super._frame_at(z)


func _ground() -> void:
	_tile("road_intersection_tone", Vector2.ZERO)
	for k: int in [-1, 1]:
		for r: int in [1, 2, 3]:
			_tile("road_straight_tone_b", Vector2(k * r * 8, 0) * PX)
			_tile("road_straight_v_tone_b", Vector2(0, k * r * 8) * PX)
		for j: int in [-1, 1]:
			for r: int in [1, 2, 3]:
				for q: int in [1, 2, 3]:
					_tile("sidewalk_tone", Vector2(k * r * 8, j * q * 8) * PX)
	for roof: String in LANDMARKS:
		_roofs[roof] = _roof(roof, LANDMARKS[roof])
	# the blocks filled like the mock's: D4 neighbours 0.4 m (an alley) beyond each landmark
	var idx: int = 0
	for roof: String in LANDMARKS:
		var at: Vector2 = LANDMARKS[roof]
		for d: Vector2 in [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
			var name: String = NEIGHBOURS[idx % NEIGHBOURS.size()]
			var nb: Sprite2D = _roof(name, at + d * at.sign() * (ROOF_M + 0.4))
			if ResourceLoader.exists(ROOFS_D5 + name + ".png"):
				nb.set_meta(&"roof", name)
				_d5_neighbours.append(nb)
			idx += 1
	_kerb_shadows()
	_corners = D5HeroKerbs.corners(_world, PX)
	_corners.append_array(D5HeroDecals.place(_world, PX))  # d5-tier world additions
	_corners.append_array(D5HeroParapets.place(_world, PX, _roof_at, ROOF_M))
	for spot: Array in PROP_SPOTS:
		_prop(spot)
	if borrow_dir != "":
		_soul_mat = _soul_material()
		var n: int = D5HeroExtras.place(_world, borrow_dir, PX, _actors, _soul_mat)
		Log.info("dev", "d5_hero: %d borrowed sprites" % n)


## How the souls print: "d5" = look_d5_soul (default), "raw" = the D5 art as drawn (h22),
## "ghost" = the game's look_d4_item ghost print, a dot mesh at 64 px/m (h21, rejected).
func _soul_material() -> Material:
	if soul_mode == "raw":
		return null
	var mat: ShaderMaterial = ShaderMaterial.new()
	if soul_mode == "ghost":
		mat.shader = load("res://assets/shaders/look_d4_item.gdshader") as Shader
		mat.set_shader_parameter("ghost", 1.0)
	else:
		mat.shader = load("res://assets/shaders/look_d5_soul.gdshader") as Shader
	return mat


func _roof(roof: String, at: Vector2) -> Sprite2D:
	_shadow(at * PX)
	_roof_at.append(at)
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ROOFS + roof + ".png") as Texture2D
	s.scale = Vector2.ONE * ROOF_M * PX / s.texture.get_width()
	s.position = at * PX
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
	return s


func _prop(spot: Array) -> void:
	var s: Sprite2D = Sprite2D.new()
	var name: String = spot[0]
	var x: float = spot[1]
	var y: float = spot[2]
	var w: float = spot[3]
	var h: float = spot[4]
	var deg: float = spot[5]
	s.texture = load(PROPS + name + ".png") as Texture2D
	s.scale = Vector2(w * PX / s.texture.get_width(), h * PX / s.texture.get_height())
	s.position = Vector2(x, y) * PX
	s.rotation_degrees = deg
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


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
	_add_shadow(poly, at)


## Kerb shadows (gap 4): the raised kerb casts a thin hatched strip onto the street on the sides
## facing away from the light (down-right), the mock's kerb line. "d5" tier only, like _shadow.
func _kerb_shadows() -> void:
	for r: Rect2 in KERB_SHADOWS:
		var poly: Polygon2D = Polygon2D.new()
		var a: Vector2 = r.position * PX
		var b: Vector2 = r.end * PX
		poly.polygon = PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)])
		_add_shadow(poly, Vector2.ZERO)
		var mat: ShaderMaterial = poly.material
		mat.set_shader_parameter("tint", 0.55)
		mat.set_shader_parameter("stroke", 0.6)


func _add_shadow(poly: Polygon2D, at: Vector2) -> void:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/look_d5_shadow.gdshader") as Shader
	poly.material = mat
	poly.position = at
	poly.visible = false
	_world.add_child(poly)
	_shadows.append(poly)


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
	var sm: ShaderMaterial = _soul_mat as ShaderMaterial
	if sm != null and soul_mode == "d5":  # the soul print rides the D5 tier fade (56 -> 64 px/m)
		sm.set_shader_parameter("amount", clampf((_rigs.zoom * PX - 56.0) / 8.0, 0.0, 1.0))
	var dir: String = ROOFS_D5 if tier == "d5" else ROOFS
	for p: Polygon2D in _shadows:
		p.visible = tier == "d5"
		(p.material as ShaderMaterial).set_shader_parameter("zoom", _rigs.zoom)
	for c: Node2D in _corners:
		c.visible = tier == "d5"
	for n: Node in _world.get_children():
		var spr: Sprite2D = n as Sprite2D
		var tile: String = "" if spr == null else spr.texture.resource_path.get_file()
		if tile in D5_TILES:
			spr.texture = load((D5_GROUND if tier == "d5" else GROUND) + tile) as Texture2D
		elif spr != null and spr.texture.resource_path == PROPS + "lamp_post.png":
			spr.visible = tier != "d5"  # the D5 lamp (D5HeroDecals) replaces it
	for roof: String in _roofs:
		_roofs[roof].texture = load(dir + roof + ".png") as Texture2D
	for nb: Sprite2D in _d5_neighbours:
		var nb_name: String = nb.get_meta(&"roof")
		nb.texture = load(dir + nb_name + ".png") as Texture2D
