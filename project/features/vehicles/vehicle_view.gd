class_name VehicleView
extends Node2D
## Draws VehicleService's cars (driven, parked, wrecks) the way the city draws traffic: the same
## quad mesh and look material as the crowd's car layer (handed in by the composition root, so the
## print matches), one MultiMesh per body texture (intact, d1, d2, hijacked; a wreck draws its d2
## cell in ink-darkened paint) plus a car-shaped ink shadow. Reads the service each frame and writes
## nothing back (render only; never sim state). Size and cell rules = CitySimRender cars.

const CAR_L: float = 204.8
const CAR_W: float = 102.4
const SHADOW_OFF: Vector2 = Vector2(5.12, 5.12)
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.45)
const WRECK_TINT: Color = Color(0.62, 0.6, 0.58, 1.0)
const CAP: int = 32

var service: VehicleService = null
var _bodies: Array[MultiMesh] = []
var _shadow: MultiMesh = null


## textures: one per VehicleBody.State up to HIJACKED (intact, d1, d2, hijacked); a null entry
## falls back to the intact atlas. car / shadow: the crowd's car and car-shadow layer nodes.
func setup(
	svc: VehicleService,
	textures: Array[Texture2D],
	car: MultiMeshInstance2D,
	shadow: MultiMeshInstance2D
) -> void:
	service = svc
	_shadow = _layer(shadow, textures[0], shadow.z_index)
	for k: int in VehicleBody.State.HIJACKED + 1:
		var tex: Texture2D = (
			textures[k] if k < textures.size() and textures[k] != null else textures[0]
		)
		_bodies.append(_layer(car, tex, car.z_index))


func _layer(like: MultiMeshInstance2D, tex: Texture2D, z: int) -> MultiMesh:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = like.multimesh.mesh
	mm.instance_count = CAP
	mm.visible_instance_count = 0
	mm.custom_aabb = AABB(Vector3(-1e7, -1e7, -10), Vector3(2e7, 2e7, 20))
	var node: MultiMeshInstance2D = MultiMeshInstance2D.new()
	node.multimesh = mm
	node.texture = tex
	node.material = like.material
	node.z_index = z
	add_child(node)
	return mm


func _process(_delta: float) -> void:
	if service == null:
		return
	var counts: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	counts.resize(_bodies.size())
	var ns: int = 0
	for b: VehicleBody in service.cars:
		if ns >= CAP:
			break
		var wreck: bool = b.state == VehicleBody.State.WRECK
		var k: int = VehicleBody.State.D2 if wreck else b.state
		var mm: MultiMesh = _bodies[k]
		var at: Vector2 = b.pos * SimConst.PX_PER_M
		var xf: Transform2D = Transform2D(b.head * CAR_L, Vector2(-b.head.y, b.head.x) * CAR_W, at)
		var tint: Color = WRECK_TINT if wreck else Color.WHITE
		_put(mm, counts[k], xf, tint, b)
		counts[k] += 1
		_put(_shadow, ns, xf.translated(SHADOW_OFF), SHADOW, b)
		ns += 1
	for k: int in _bodies.size():
		_bodies[k].visible_instance_count = counts[k]
	_shadow.visible_instance_count = ns


static func _put(mm: MultiMesh, i: int, xf: Transform2D, c: Color, b: VehicleBody) -> void:
	mm.set_instance_transform_2d(i, xf)
	mm.set_instance_color(i, c)
	mm.set_instance_custom_data(i, Color(float(b.art), float(b.state), 0.0, 0.0))
