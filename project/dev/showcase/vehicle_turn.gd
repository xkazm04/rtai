extends Node2D
## n8 vehicles: the 360-degree turn film. Three cars (sedan, police car, van) turn in place on a
## gridded asphalt patch under the shared view (--view=), one full circle every 6 s, each over a
## flat footprint the size of its collision box (the card must sit on it at every heading).
##   godot --rendering-driver d3d12 --fixed-fps 60 --path project
##     res://dev/showcase/vehicle_turn.tscn
##     --write-movie <abs>.avi --quit-after 400 -- --view=tilt70 --ppm=64 [--blend=8] [--upright=1]
##     [--set=street]: the taxi, the parked pickup and the ambulance instead
##     [--set=service]: the delivery truck and the depot van (art/<key>/service_cards.png, no sim
##     archetype yet: tools/art/vehicle_cards.py --set=service)

## [art id, footprint length m, width m]: the sedan, the police car, the van; the bike (atlas row
## VehicleViews.BIKE_ART, no sim bike yet) below the police car.
const CARS: Array[Vector3] = [
	Vector3(0, 4.6, 1.9), Vector3(8, 4.8, 1.95), Vector3(4, 5.2, 2.1), Vector3(9, 2.1, 0.8)
]
## --set=street: the taxi, the parked pickup, the ambulance (footprints from the traffic atlas).
const STREET: Array[Vector3] = [
	Vector3(3, 4.85, 1.95), Vector3(5, 5.15, 2.0), Vector3(6, 5.75, 2.2)
]
## --set=service: rows of the service atlas (the delivery truck, the depot van; lengths as cut).
const SERVICE: Array[Vector3] = [Vector3(0, 5.3, 2.3), Vector3(1, 4.9, 2.0)]
const SERVICE_DIR: String = "res://features/vehicles/art/%s/service_cards.png"
const GAP_M: float = 6.0
const DEG_PER_TICK: float = 1.0
const ASPHALT: Color = Color(0.27, 0.27, 0.28)
const GRID: Color = Color(0.36, 0.36, 0.37)
const FOOT: Color = Color(0.0, 0.0, 0.0, 0.35)

var _cards: VehicleCards = null
var _tick: int = 0
var _ppm: float = 32.0
var _cars: Array[Vector3] = CARS
var _service: Texture2D = null


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	_ppm = args.number("--ppm", _ppm)
	_cars = STREET if args.text("--set") == "street" else CARS
	if args.text("--set") == "service":
		_cars = SERVICE
		var path: String = SERVICE_DIR % ViewMode.shared().art
		_service = load(path) as Texture2D if ResourceLoader.exists(path) else null
	VehicleCards.blend_deg = args.number("--blend", VehicleCards.blend_deg)
	VehicleCards.upright_k = args.number("--upright", VehicleCards.upright_k)
	var cam: Camera2D = Camera2D.new()
	cam.zoom = ViewMode.shared().zoom_of(_ppm / SimConst.PX_PER_M)
	add_child(cam)
	_cards = VehicleCards.new()
	add_child(_cards)
	var vm: ViewMode = ViewMode.shared()
	var b: float = VehicleCards.blend_deg
	Log.info(
		"vehicle_turn",
		"view %s ppm %.0f blend %.1f upright %.2f" % [vm.id, _ppm, b, VehicleCards.upright_k]
	)


func _process(_delta: float) -> void:
	_tick += 1
	queue_redraw()
	var tex: Texture2D = _service if _cars == SERVICE else VehicleCards.atlas()
	if tex == null:
		return
	_cards.begin(tex)
	var head: Vector2 = _head()
	for i: int in _cars.size():
		_cards.put(int(_cars[i].x), _at(i), head, Color.WHITE)
	_cards.finish()


func _draw() -> void:
	var m: float = SimConst.PX_PER_M
	draw_rect(Rect2(Vector2(-14, -10) * m, Vector2(28, 20) * m), ASPHALT)
	for k: int in range(-14, 15):
		draw_line(Vector2(k, -10) * m, Vector2(k, 10) * m, GRID, 1.0)
	for k: int in range(-10, 11):
		draw_line(Vector2(-14, k) * m, Vector2(14, k) * m, GRID, 1.0)
	var head: Vector2 = _head()
	var side: Vector2 = head.orthogonal()
	for i: int in _cars.size():
		var c: Vector2 = _at(i) * m
		var hl: Vector2 = head * _cars[i].y * 0.5 * m
		var hw: Vector2 = side * _cars[i].z * 0.5 * m
		draw_colored_polygon(
			PackedVector2Array([c + hl + hw, c + hl - hw, c - hl - hw, c - hl + hw]), FOOT
		)


func _head() -> Vector2:
	return Vector2.from_angle(deg_to_rad(_tick * DEG_PER_TICK))


func _at(i: int) -> Vector2:
	if _cars == SERVICE:  # two long bodies: side on, they must not touch
		return Vector2((i - 0.5) * 7.0, 0.0)
	return Vector2((i - 1) * GAP_M, 0.0) if i < 3 else Vector2(0.0, 4.5)
