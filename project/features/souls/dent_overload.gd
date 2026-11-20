class_name DentOverload
extends Node2D
## The road preview lives below actors and vehicles. DentView draws its blast above the wreck.
## Damage notifications retain the exact recipients even if a render frame skips the strike tick.

const FLASH_TICKS: int = 18
const END_TICKS: int = 27
const EXPAND_TICKS: int = 8
const CORE: Color = Color("#FFE7B0")
const DASHES: int = 36
const SPOKE_TICKS: int = 15

var dent: DentStage
var ppm: float
var still: bool
var _look: DentLook = DentLook.shipped()
var _stage: CollectCallStage
var _spokes: Node2D
var _nose: float = 0.0
var _tick: int = -1
var _contact_m: PackedVector2Array = []
var _landed_m: PackedVector2Array = []


func bind(stage: CollectCallStage, source: DentStage) -> void:
	dent = source
	_stage = stage
	_spokes = Node2D.new()
	_spokes.z_as_relative = false
	_spokes.z_index = RenderLayers.z(&"fx") + 1
	add_child(_spokes)
	@warning_ignore("return_value_discarded")
	_spokes.draw.connect(_draw_spokes)
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


func sync(scale_ppm: float, reduced: bool) -> void:
	ppm = scale_ppm
	still = reduced
	if dent.car != null:
		_nose = dent.car.head.angle()
	queue_redraw()
	_spokes.queue_redraw()


func _draw_spokes() -> void:
	var canvas: CanvasItem = _spokes
	var age: int = _stage.tick - dent.blast_tick
	if _tick != dent.blast_tick or age < 0 or age >= SPOKE_TICKS or still:
		return
	var alpha: float = 1.0 - float(age) / SPOKE_TICKS
	var c: Vector2 = dent.blast_at * ppm
	for i: int in _contact_m.size():
		var contact: Vector2 = _contact_m[i] * ppm
		var landed: Vector2 = _landed_m[i] * ppm
		var width: float = _look.ring_ink_m * ppm * 2.0
		canvas.draw_line(c, landed, Color(DentRoof.INK, alpha), width, true)
		canvas.draw_line(c, landed, Color(DentStrap.AMBER, alpha), width * 0.65, true)
		canvas.draw_line(c, contact, Color(Color.FLORAL_WHITE, alpha), width * 0.42, true)
		canvas.draw_circle(
			contact, width * 0.55, Color(Color.FLORAL_WHITE, alpha), true, -1.0, true
		)


static func shock_extent(age: int, reduced: bool) -> float:
	if reduced:
		return 1.0
	var t: float = clampf(float(age) / EXPAND_TICKS, 0.0, 1.0)
	return 1.0 - 0.68 * (1.0 - t) * (1.0 - t)


static func shock_alpha(age: int, reduced: bool) -> float:
	if age < 0 or age >= FLASH_TICKS:
		return 0.0
	return 0.3 if reduced else 0.55 * (1.0 - float(age) / FLASH_TICKS)


static func ring_alpha(age: int) -> float:
	return clampf(float(END_TICKS - age) / (END_TICKS - FLASH_TICKS), 0.0, 1.0)


func shock(canvas: CanvasItem, c: Vector2, radius: float, age: int) -> void:
	var alpha: float = shock_alpha(age, still)
	if alpha <= 0.0:
		return
	var r: float = radius * shock_extent(age, still)
	var pts: PackedVector2Array = [c]
	var colors: PackedColorArray = [Color(CORE, alpha)]
	var indices: PackedInt32Array = []
	for i: int in DASHES * 2:
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2.from_angle(TAU * i / (DASHES * 2)) * r)
		@warning_ignore("return_value_discarded")
		colors.append(Color(DentStrap.AMBER, alpha))
		indices.append_array([0, i + 1, (i + 1) % (DASHES * 2) + 1])
	RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(), indices, pts, colors)


func _draw() -> void:
	if dent == null:
		return
	var r: float = dent.num(&"blast_radius_m") * ppm
	if dent.car != null:
		var c: Vector2 = dent.car.pos * ppm
		if not still and dent.heat > 0.0:
			_clock_face(c, r, _nose, dent.heat)
		_dashes(c, r, 1.0, 1.0)
	if dent.blast_tick >= 0:
		var age: int = _stage.tick - dent.blast_tick
		if age >= 0 and age < END_TICKS:
			_dashes(dent.blast_at * ppm, r, 1.6, ring_alpha(age))


func _dashes(c: Vector2, r: float, weight: float, alpha: float) -> void:
	var span: float = TAU / DASHES
	for i: int in DASHES:
		var a: float = _nose + span * i
		draw_arc(
			c,
			r,
			a,
			a + span * 0.65,
			5,
			Color(DentRoof.INK, alpha),
			_look.ring_ink_m * ppm * weight,
			true
		)
		draw_arc(
			c,
			r,
			a,
			a + span * 0.65,
			5,
			Color(DentStrap.AMBER, alpha),
			_look.ring_edge_m * ppm * weight,
			true
		)


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
