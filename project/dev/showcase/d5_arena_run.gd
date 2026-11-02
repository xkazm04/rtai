class_name D5ArenaRun
extends D5ShowcaseRun
## d5-close evidence (the D5 "boss arena" venue, 64 px/m): Rivet versus two cops on King's
## chop-shop arena floor (features/city/art/d5/arena/king_arena.png, 12 m at 104 px/m), ringed by
## D4 asphalt, at 32, 48, 64 and 96 px/m in the usual tiers ("d4" = the same floor without the
## look_d5 print or the D5 character tier). No King rig exists yet: the arena is shown with the
## street cast. Deterministic: fixed cast, fixed clip ticks, no RNG.

const ARENA: String = "res://features/city/art/d5/arena/king_arena.png"
const ARENA_M: float = 12.0
const CAM_M: Vector2 = Vector2(1.2, 0.4)


func _init() -> void:
	zooms = [1.0, 1.5, 2.0, 3.0]
	cam = CAM_M * PX


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
