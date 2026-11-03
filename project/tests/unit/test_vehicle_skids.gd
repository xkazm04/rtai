extends GutTest
## features/vehicles tyre marks: a sliding car lays two dashes per stamp (one per rear wheel), a
## car rolling straight lays none, and the count keeps going past the ring (old dashes recycled).

var _svc: VehicleService
var _skids: VehicleSkids


func before_each() -> void:
	_svc = VehicleService.new()
	_svc.profiles = VehicleProfile.load_all()
	_skids = autofree(VehicleSkids.new())
	_skids.service = _svc


func _car(sliding: bool) -> VehicleBody:
	var b: VehicleBody = _svc.spawn_parked(&"sedan", Vector2.ZERO, Vector2.RIGHT)
	b.vel = Vector2(12.0, 3.0)
	b.sliding = sliding
	return b


func test_a_slide_lays_two_dashes_per_stamp() -> void:
	var b: VehicleBody = _car(true)
	for k: int in 4:
		b.pos = Vector2(k * 1.0, 0.0)
		_skids._process(0.0)
	assert_eq(_skids.dashes(), 6, "3 stamps after the first point, 2 wheels each")


func test_rolling_straight_lays_none() -> void:
	var b: VehicleBody = _car(false)
	for k: int in 4:
		b.pos = Vector2(k * 1.0, 0.0)
		_skids._process(0.0)
	assert_eq(_skids.dashes(), 0)


func test_the_ring_is_capped() -> void:
	var b: VehicleBody = _car(true)
	for k: int in VehicleSkids.CAP:
		b.pos = Vector2(k * 1.0, 0.0)
		_skids._process(0.0)
	assert_gt(_skids.dashes(), VehicleSkids.CAP)
