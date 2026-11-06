class_name VehicleView
extends Node2D
## Draws VehicleService's cars (driven, parked, wrecks) the way the city draws traffic: the same
## quad mesh and look material as the crowd's car layer (handed in by the composition root, so the
## print matches), one MultiMesh per body texture (intact, d1, d2, hijacked, wreck: n-d4's burnt
## wrecks in the traffic atlas layout; without that atlas a wreck draws its d2 cell darkened) plus
## a car-shaped ink shadow, tyre marks (VehicleSkids) and burning wrecks (VehicleFire). Reads the
## service each frame and writes nothing back (render only; never sim state). Size and cell
## rules = CitySimRender cars. Sim traffic the service rammed to D1 or soul-hijacked keeps driving
## in the sim, drawn by the crowd layer with its intact art: the view lays the D1 / hijacked cell
## over it at the same transform (until the city's car shader picks art by custom.y itself).

const CAR_L: float = 204.8
const CAR_W: float = 102.4
const SHADOW_OFF: Vector2 = Vector2(5.12, 5.12)
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.45)
const WRECK_TINT: Color = Color(0.62, 0.6, 0.58, 1.0)
## n8: the kerb-parked cards drawn around the player (m; the camera sees ~40 m across at 32 px/m).
const PARKED_M: float = 60.0
const CAP: int = 32
## View lab (view.json cast_k): the roof height a cast shadow is thrown from (m).
const CAR_H_M: float = 1.4

var service: VehicleService = null
## Tyre marks under the cars (a child, drawn below the shadows).
var skids: VehicleSkids = VehicleSkids.new()
## Burning wrecks (a child, drawn over the car bodies).
var fire: VehicleFire = VehicleFire.new()
## n8: every car as a rotation set from art under a tilted view (null until setup).
var cards: VehicleCards = null
var _bodies: Array[MultiMesh] = []
var _shadow: MultiMesh = null
## True when the burnt wreck atlas was handed in (else wrecks draw d2, darkened).
var _burnt: bool = false
## [our node, the crowd node it mirrors]: the look may swap the crowd's material at runtime.
var _mirrors: Array[Array] = []
var _crowd_car: MultiMeshInstance2D = null
var _carded: bool = false


## textures: one per VehicleBody.State (intact, d1, d2, hijacked, wreck); a null or missing entry
## falls back to the intact atlas (the wreck to d2, darkened). car / shadow: the crowd's car and
## car-shadow layer nodes.
func setup(
	svc: VehicleService,
	textures: Array[Texture2D],
	car: MultiMeshInstance2D,
	shadow: MultiMeshInstance2D
) -> void:
	service = svc
	skids.service = svc
	skids.z_index = shadow.z_index - 1
	add_child(skids)
	_shadow = _layer(shadow, textures[0], shadow.z_index)
	_burnt = textures.size() > VehicleBody.State.WRECK and textures[VehicleBody.State.WRECK] != null
	for k: int in VehicleBody.State.WRECK + 1:
		var pick: int = VehicleBody.State.D2 if k == VehicleBody.State.WRECK and not _burnt else k
		var tex: Texture2D = (
			textures[pick] if pick < textures.size() and textures[pick] != null else textures[0]
		)
		_bodies.append(_layer(car, tex, car.z_index))
	fire.service = svc
	fire.z_index = car.z_index + 1
	add_child(fire)
	_crowd_car = car
	cards = VehicleCards.new()
	cards.z_index = car.z_index
	add_child(cards)


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
	_mirrors.append([node, like])
	return mm


func _process(_delta: float) -> void:
	if service == null:
		return
	for m: Array in _mirrors:
		var mine: MultiMeshInstance2D = m[0]
		var like: MultiMeshInstance2D = m[1]
		if mine.material != like.material:
			mine.material = like.material
	var counts: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	counts.resize(_bodies.size())
	var ns: int = 0
	var off: Vector2 = shadow_off()
	for b: VehicleBody in service.cars:
		if ns >= CAP:
			break
		var wreck: bool = b.state == VehicleBody.State.WRECK
		var k: int = b.state
		var mm: MultiMesh = _bodies[k]
		var xf: Transform2D = car_xf(b.pos, b.head)
		var tint: Color = WRECK_TINT if wreck and not _burnt else Color.WHITE
		_put(mm, counts[k], xf, tint, b)
		counts[k] += 1
		_put(_shadow, ns, xf.translated(off), SHADOW, b)
		ns += 1
	_marked_traffic(counts)
	for k: int in _bodies.size():
		_bodies[k].visible_instance_count = counts[k]
	_shadow.visible_instance_count = ns
	_draw_cards()


## Under a tilt with art for its pitch: every car (the service's and the sim's traffic) as a card,
## the flat body layers (ours and the crowd's) hidden; their ground shadows stay. Never touches the
## layers in a view with no card atlas (`top` stays bit-identical).
func _draw_cards() -> void:
	var tex: Texture2D = VehicleCards.atlas()
	var on: bool = tex != null
	if on != _carded:
		_carded = on
		_crowd_car.visible = not on
		for m: Array in _mirrors:
			var mine: MultiMeshInstance2D = m[0]
			if m[1] == _crowd_car:
				mine.visible = not on
	if not on:
		return
	cards.begin(tex)
	for b: VehicleBody in service.cars:
		var wreck: bool = b.state == VehicleBody.State.WRECK
		cards.put(b.art, b.pos, b.head, WRECK_TINT if wreck else Color.WHITE)
	var recs: PackedFloat64Array = service.world.cars_near(service.world.player_pos(), 1e6)
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		var art: int = int(recs[r + 7])
		cards.put(
			art, Vector2(recs[r + 2], recs[r + 3]), Vector2(recs[r + 4], recs[r + 5]), Color.WHITE
		)
	VehicleParked.put_near(cards, service.world.player_pos(), PARKED_M, WRECK_TINT)
	cards.finish()


## The car shadow's offset: SHADOW_OFF, plus under a view's cast shadows (cast_k) the roof's
## shadow thrown down-right; the car-shaped quad is moved, not swept, so half the roof's throw
## keeps it joined to the car (top: exactly SHADOW_OFF).
static func shadow_off() -> Vector2:
	var view: ViewMode = ViewMode.shared()
	if view.cast_k <= 0.0:
		return SHADOW_OFF
	return SHADOW_OFF + view.cast_dir() * CAR_H_M * view.cast_k * SimConst.PX_PER_M * 0.5


## A car's quad at `pos` metres facing `head` (CitySimRender cars: x axis head * CAR_L, y axis
## its left normal * CAR_W, origin in world px).
static func car_xf(pos: Vector2, head: Vector2) -> Transform2D:
	return Transform2D(head * CAR_L, Vector2(-head.y, head.x) * CAR_W, pos * SimConst.PX_PER_M)


static func _put(mm: MultiMesh, i: int, xf: Transform2D, c: Color, b: VehicleBody) -> void:
	mm.set_instance_transform_2d(i, xf)
	mm.set_instance_color(i, c)
	mm.set_instance_custom_data(i, Color(float(b.art), float(b.state), 0.0, 0.0))


## Overlays for the marked sim traffic (VehicleTraffic.state D1 / HIJACKED), at the sim's own
## car transform (CitySimRender: x axis head * CAR_L, y axis its left normal * CAR_W).
func _marked_traffic(counts: PackedInt32Array) -> void:
	var book: VehicleTraffic = service.traffic
	if book == null or book.state.is_empty():
		return
	var recs: PackedFloat64Array = service.world.cars_near(service.world.player_pos(), 1e6)
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		var st: int = book.state.get(int(recs[r]), VehicleBody.State.INTACT)
		if st != VehicleBody.State.D1 and st != VehicleBody.State.HIJACKED:
			continue
		if counts[st] >= CAP:
			continue
		var head: Vector2 = Vector2(recs[r + 4], recs[r + 5])
		var xf: Transform2D = car_xf(Vector2(recs[r + 2], recs[r + 3]), head)
		var mm: MultiMesh = _bodies[st]
		mm.set_instance_transform_2d(counts[st], xf)
		mm.set_instance_color(counts[st], Color.WHITE)
		mm.set_instance_custom_data(counts[st], Color(recs[r + 7], float(st), 0.0, 0.0))
		counts[st] += 1
