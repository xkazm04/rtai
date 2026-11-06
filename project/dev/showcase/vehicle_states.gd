extends Node2D
## n8 vehicles: the damage film. Four sedans turn slowly in place in a row, intact, dented (D1),
## smashed (D2) and a burning wreck (VehicleFire on the bonnet), while a police car drifts a
## circle south of them laying tyre marks, its light bar flashing, under --view= (no sim).
##   godot --rendering-driver d3d12 --fixed-fps 60 --path project <this scene's res:// .tscn>
##     --write-movie <abs>.avi --quit-after 600 -- --view=tilt70 --ppm=32 [--wear=0]
## --wear=0: the "before" (iteration 2): intact cards, the wreck tinted, no light bar flash.

const STATES: Array[int] = [0, 1, 2, 4]  # VehicleBody.State INTACT, D1, D2, WRECK
const GAP_M: float = 6.0
const DEG_PER_TICK: float = 0.5
## The drifting police car: art id, circle centre (m), radius (m), rad per tick, drift angle.
const COP_ART: int = 8
const RING: Vector3 = Vector3(0.0, 9.0, 6.0)
const RING_RATE: float = 0.03
const DRIFT_RAD: float = 0.45
const ASPHALT: Color = Color(0.27, 0.27, 0.28)
const GRID: Color = Color(0.36, 0.36, 0.37)

var _svc: VehicleService = VehicleService.new()
var _cards: VehicleCards = VehicleCards.new()
var _fire: VehicleFire = VehicleFire.new()
var _skids: VehicleSkids = VehicleSkids.new()
var _cop: VehicleBody = null
var _tick: int = 0
var _wear: bool = true


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var ppm: float = args.number("--ppm", 32.0)
	_wear = args.number("--wear", 1.0) > 0.0
	var cam: Camera2D = Camera2D.new()
	cam.zoom = ViewMode.shared().zoom_of(ppm / SimConst.PX_PER_M)
	cam.position = Vector2(0.0, 3.0) * SimConst.PX_PER_M
	add_child(cam)
	var p: VehicleProfile = VehicleProfile.load_all().get(&"sedan")
	for i: int in STATES.size():
		var b: VehicleBody = VehicleBody.new(i + 1, p, _at(i), Vector2.RIGHT)
		b.state = STATES[i] as VehicleBody.State
		_svc.cars.append(b)
	_cop = VehicleBody.new(9, p, Vector2.ZERO, Vector2.RIGHT)
	_cop.art = COP_ART
	_cop.sliding = true
	_svc.cars.append(_cop)
	_skids.service = _svc
	_fire.service = _svc
	add_child(_skids)
	add_child(_cards)
	add_child(_fire)
	Log.info("vehicle_states", "view %s ppm %.0f" % [ViewMode.shared().id, ppm])


func _process(_delta: float) -> void:
	_tick += 1
	queue_redraw()
	var head: Vector2 = Vector2.from_angle(deg_to_rad(_tick * DEG_PER_TICK))
	for b: VehicleBody in _svc.cars:
		if b != _cop:
			b.head = head
		if b.state == VehicleBody.State.WRECK:
			b.wreck_t = _tick * SimClock.TICK_DT
	var a: float = _tick * RING_RATE
	var tangent: Vector2 = Vector2(-sin(a), cos(a))
	_cop.pos = Vector2(RING.x, RING.y) + Vector2(cos(a), sin(a)) * RING.z
	_cop.vel = tangent * RING.z * RING_RATE * SimClock.TICK_RATE
	_cop.head = tangent.rotated(-DRIFT_RAD)
	var tex: Texture2D = VehicleCards.atlas()
	if tex == null:
		return
	_cards.begin(tex)
	for b: VehicleBody in _svc.cars:
		if _wear:
			var worn: int = VehicleCards.wear(b.state, b.id)
			_cards.put(b.art, b.pos, b.head, Color.WHITE, worn + VehicleCards.duty(b.art, 9.0))
			continue
		var wreck: bool = b.state == VehicleBody.State.WRECK
		_cards.put(b.art, b.pos, b.head, VehicleView.WRECK_TINT if wreck else Color.WHITE)
	_cards.finish()


func _draw() -> void:
	var m: float = SimConst.PX_PER_M
	draw_rect(Rect2(Vector2(-16, -8) * m, Vector2(32, 26) * m), ASPHALT)
	for k: int in range(-16, 17, 2):
		draw_line(Vector2(k, -8) * m, Vector2(k, 18) * m, GRID, 1.0)
	for k: int in range(-8, 19, 2):
		draw_line(Vector2(-16, k) * m, Vector2(16, k) * m, GRID, 1.0)


func _at(i: int) -> Vector2:
	return Vector2((i - 1.5) * GAP_M, 0.0)
