class_name DentOverload
extends Node2D
## The road preview lives below actors and vehicles. DentView draws its blast above the wreck.
## Damage notifications retain the exact recipients even if a render frame skips the strike tick.

const DASHES: int = 36
const SPOKE_TICKS: int = 15

var dent: DentStage
var ppm: float
var still: bool
var _look: DentLook = DentLook.shipped()
var _tick: int = -1
var _contact_m: PackedVector2Array = []
var _landed_m: PackedVector2Array = []


func bind(stage: CollectCallStage, source: DentStage) -> void:
	dent = source
	z_as_relative = false
	z_index = RenderLayers.z(&"actor_shadows") + 1
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_kill)
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wound)


func _kill(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	_wound(victim, weapon)


func _wound(victim: Fighter, weapon: StringName) -> void:
	if weapon != &"dent_blast":
		return
	if _tick != dent.blast_tick:
		_tick = dent.blast_tick
		_contact_m.clear()
		_landed_m.clear()
	var radius: float = dent.num(&"blast_radius_m")
	var knock: float = dent.num(&"car_knock_m")
	var travel: Vector2 = victim.pos - dent.blast_at
	# DentStage applied a radial shove of knock * (1 - distance / radius) before damage.
	var distance_m: float = travel.length()
	if not is_equal_approx(knock, radius):
		distance_m = clampf((distance_m - knock) / (1.0 - knock / radius), 0.0, radius)
	@warning_ignore("return_value_discarded")
	_contact_m.append(dent.blast_at + travel.normalized() * distance_m)
	@warning_ignore("return_value_discarded")
	_landed_m.append(victim.pos)


func spokes(canvas: CanvasItem, age: int) -> void:
	if _tick != dent.blast_tick or age < 0 or age >= SPOKE_TICKS or still:
		return
	var alpha: float = 1.0 - float(age) / SPOKE_TICKS
	var c: Vector2 = dent.blast_at * ppm
	for i: int in _contact_m.size():
		var contact: Vector2 = _contact_m[i] * ppm
		var landed: Vector2 = _landed_m[i] * ppm
		var width: float = _look.ring_ink_m * ppm
		canvas.draw_line(c, landed, Color(DentRoof.INK, alpha), width, true)
		canvas.draw_line(c, landed, Color(DentStrap.AMBER, alpha), width * 0.65, true)
		canvas.draw_line(c, contact, Color(Color.FLORAL_WHITE, alpha), width * 0.42, true)
		canvas.draw_circle(
			contact, width * 0.55, Color(Color.FLORAL_WHITE, alpha), true, -1.0, true
		)


func _draw() -> void:
	if dent == null or dent.car == null:
		return
	var c: Vector2 = dent.car.pos * ppm
	var r: float = dent.num(&"blast_radius_m") * ppm
	var nose: float = dent.car.head.angle()
	if not still and dent.heat > 0.0:
		_clock_face(c, r, nose, dent.heat)
	var span: float = TAU / DASHES
	for i: int in DASHES:
		var a: float = nose + span * i
		draw_arc(c, r, a, a + span * 0.65, 5, DentRoof.INK, _look.ring_ink_m * ppm, true)
		draw_arc(c, r, a, a + span * 0.65, 5, DentStrap.AMBER, _look.ring_edge_m * ppm, true)


func _clock_face(c: Vector2, radius: float, nose: float, heat: float) -> void:
	# Leave the footprint clear in flat views, where cars are printed into the road canvas.
	var inner: float = minf(radius * 0.75, VehicleBody.PARKED_HALF.length() * ppm)
	var count: int = maxi(2, ceili(heat * DASHES * 2))
	var wash: PackedVector2Array = []
	for i: int in count + 1:
		var a: float = nose + TAU * heat * i / count
		@warning_ignore("return_value_discarded")
		wash.append(c + Vector2.from_angle(a) * radius)
	for i: int in range(count, -1, -1):
		var a: float = nose + TAU * heat * i / count
		@warning_ignore("return_value_discarded")
		wash.append(c + Vector2.from_angle(a) * inner)
	draw_colored_polygon(wash, Color(DentStrap.AMBER, _look.ring_fill_alpha))
	draw_line(wash[count], wash[count + 1], DentStrap.AMBER, _look.ring_edge_m * ppm, true)
