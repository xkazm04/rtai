class_name D5ArenaRun
extends D5ShowcaseRun
## d5-close evidence (the D5 "boss arena" venue, 64 px/m): Rivet versus two cops on King's
## chop-shop arena floor (features/city/art/d5/arena/king_arena.png, 12 m at 104 px/m), in
## plain asphalt, at 32, 48, 64, 96 and 128 px/m (the boss kill-cam) in the usual tiers ("d4" =
## the same floor without the look_d5 print or the D5 character tier). No King rig exists yet:
## King is a STATIC plan-view sprite proposal (characters/art/d5/king/king_top.png, drawn as is
## on the actor layer, every tier) facing Rivet across the turntable. Deterministic: fixed
## cast, fixed clip ticks, no RNG.

const ARENA: String = "res://features/city/art/d5/arena/king_arena.png"
const ARENA_M: float = 12.0
const CAM_M: Vector2 = Vector2(0.3, 0.0)
const KING: String = "res://features/characters/art/d5/king/king_top.png"
const KING_M: Vector2 = Vector2(-2.7, -2.5)
## arm-disc to arm-disc width (the turnaround: 1.6x Rivet's bulk; 2.8 m read smaller than Rivet, a4)
const KING_W_M: float = 3.6
const KING_SHADOW_M: float = 0.7

## D4 roofs ringing the yard (left and right of the floor, 0.6 m of asphalt between)
const YARD_ROOFS: Array[String] = [
	"building_warehouse", "building_tall", "building_osha", "building_long"
]
const ROOF_M: float = 8.4
const YARD_D4: String = "res://features/city/art/roofs/"
const YARD_D5: String = "res://features/city/art/d5/roofs/"

var _shadow_node: Sprite2D = null
var _feet: Array[Node2D] = []
var _yard_roofs: Array[Sprite2D] = []


func _init() -> void:
	zooms = [1.0, 1.5, 2.0, 3.0, 4.0]
	cam = CAM_M * PX


## 128 px/m = the boss kill-cam, framed between King and Rivet; the other zooms frame the arena
func _frame_at(z: float) -> void:
	cam = (KING_M.lerp(Vector2(-0.4, 0.8), 0.5) if z >= 4.0 else CAM_M) * PX
	super._frame_at(z)


## the arena sits in plain asphalt (lane-marked road tiles read as a grid around it, round a2)
func _ground() -> void:
	var field: Polygon2D = Polygon2D.new()
	var e: float = 24.0 * PX
	field.polygon = PackedVector2Array(
		[Vector2(-e, -e), Vector2(e, -e), Vector2(e, e), Vector2(-e, e)]
	)
	field.color = D5HeroKerbs.ASPHALT
	_world.add_child(field)
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ARENA) as Texture2D
	s.scale = Vector2.ONE * ARENA_M * PX / s.texture.get_width()
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
	_yard()
	var king: Sprite2D = Sprite2D.new()
	king.texture = load(KING) as Texture2D
	king.scale = Vector2.ONE * KING_W_M * PX / king.texture.get_width()
	king.position = KING_M * PX
	# the sprite faces up the image: turn it toward Rivet's spot
	king.rotation = (Vector2(-0.4, 0.8) - KING_M).angle() + PI * 0.5
	king.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_actors.add_child(king)
	_king_shadow(king)


## King is 2.6 m tall: a hatched cast shadow down-right (the roofs' light), on the world layer under
## the print, so look_d4 inks it like the building shadows. "d5" tier only.
func _king_shadow(king: Sprite2D) -> void:
	var sh: Sprite2D = Sprite2D.new()
	sh.texture = king.texture
	sh.scale = king.scale
	sh.rotation = king.rotation
	sh.position = king.position + Vector2.ONE * KING_SHADOW_M * PX
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/look_d5_shadow.gdshader") as Shader
	sh.material = mat
	_world.add_child(sh)
	_shadow_node = sh


## The chop shop sits in a city block: D4 roofs left and right, with the hero scene's ink foot
## (D5HeroParapets, "d5" tier) on their street-facing edges.
func _yard() -> void:
	var at: Array[Vector2] = []
	var k: int = 0
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			var c: Vector2 = Vector2(
				sx * (ARENA_M * 0.5 + 0.6 + ROOF_M * 0.5), sy * (ROOF_M * 0.5 + 0.2)
			)
			var r: Sprite2D = Sprite2D.new()
			r.texture = load(YARD_D4 + YARD_ROOFS[k] + ".png") as Texture2D
			r.set_meta(&"roof", YARD_ROOFS[k])
			r.scale = Vector2.ONE * ROOF_M * PX / r.texture.get_width()
			r.position = c * PX
			r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_world.add_child(r)
			_yard_roofs.append(r)
			at.append(c)
			k += 1
	_feet = D5HeroParapets.place(_world, PX, at, ROOF_M)


func _tier(tier: String) -> void:
	D5RigShadow.on_tier(_world, _rigs, PX, _rigs.zoom * PX, tier)  # up close: hatched rig shadows
	D5HeroHaloInk.dev_switches(self, _look, _rigs.zoom * PX)  # D5_PRINT=thin, D5_HALO=ink (proposals)
	for n: Node2D in _feet:
		n.visible = tier == "d5"
	for r: Sprite2D in _yard_roofs:  # the yard roofs that have D5 art print it in the "d5" tier
		var roof: String = r.get_meta(&"roof")
		var file: String = roof + ".png"
		var d5: bool = tier == "d5" and ResourceLoader.exists(YARD_D5 + file)
		r.texture = load((YARD_D5 if d5 else YARD_D4) + file) as Texture2D
	D5HeroHaloInk.roof_rule(_yard_roofs, tier, _rigs.zoom * PX)  # proposal: ruled roof hatch overlays
	if _shadow_node != null:
		_shadow_node.visible = tier == "d5"
		(_shadow_node.material as ShaderMaterial).set_shader_parameter("zoom", _rigs.zoom)


## Rivet on the turntable's hazard ring, the cops closing from the open floor.
func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	var spots: PackedVector2Array = PackedVector2Array(
		[Vector2(-0.4, 0.8), Vector2(3.6, 2.4), Vector2(4.2, -1.2)]
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
	f.face[0] = (f.pos[2] - f.pos[0]).angle()
	f.aim[0] = f.pos[2]
	f.flags[0] = RigFeed.Flag.AIMING
