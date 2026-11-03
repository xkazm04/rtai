class_name PowersClipDrive
extends WorldSystem
## The Hauler clip's script on the fixed tick (registered after the city): plants a standing crowd
## on a sidewalk band and a tight group further on, then: stand 1 s, activate Hauler (0.4 s morph),
## drive east through the crowd at the tank's top speed, let go (momentum carries him), arm a stomp
## in the group (cops: 3 of the 9 are patrol cops), stand while they lie, and shrink back when
## the 8 s power runs out.
## --before = the same script without the power (base Rivet driven at the tank's speed).

const ACTIVATE_S: float = 1.0
const DRIVE_S: Vector2 = Vector2(1.5, 6.4)
const ARM_S: float = 7.0

var band: Vector2 = Vector2(-1, -1)
var powers: SoulPowers = null
var hauler: HaulerCity = null
var base_knocks: int = 0
## Three of the stomp group are patrol cops (they walk in on Rivet and can be rammed first).
var cops: bool = false
var _city: CitySystem
var _start: Vector2
var _before: bool = false


func _init(city: CitySystem, start: Vector2, before: bool) -> void:
	_city = city
	_start = start
	_before = before
	_city.focus = start
	_city.target = start
	var t: PowerTable = PowerTable.load_default()
	powers = SoulPowers.new(t)
	var form: HaulerForm = HaulerForm.new(t.hauler)
	form.bind(powers)
	hauler = HaulerCity.new(city, form)


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if tick == 0:
		band = _find_band(50.0)
		if band.x > 0.0:
			_plant()
		return
	if band.x < 0.0:
		return
	var t: float = tick * SimClock.TICK_DT
	var want: Vector2 = Vector2.RIGHT if t >= DRIVE_S.x and t < DRIVE_S.y else Vector2.ZERO
	if _before:
		@warning_ignore("integer_division")
		base_knocks += _city.body.knocks.size() / SimConst.BR_STRIDE
		var v: Vector2 = want * hauler.form.num(&"top_mps")
		_city.target = _city.body.pos + v * SimClock.TICK_DT
		_city.focus = _city.target
		return
	powers.tick()
	if tick == roundi(ACTIVATE_S * SimClock.TICK_RATE):
		@warning_ignore("return_value_discarded")
		powers.try_activate(&"hauler")
	hauler.step(tick, want, tick == roundi(ARM_S * SimClock.TICK_RATE))


func _plant() -> void:
	_city.target = band
	_city.focus = band
	_city.body.pos = band
	for col: int in 4:
		for row: int in range(-1, 2):
			_stand(band + Vector2(5.0 + col * 2.5, row * 0.9), col * 3 + row + 1)
	for k: int in 9:
		var ring: Vector2 = Vector2.from_angle(TAU * k / 9.0) * (1.4 + 0.5 * (k % 2))
		var kind: int = SimConst.K_COP if cops and k % 3 == 0 else SimConst.K_PED
		_stand(band + Vector2(25.0, 0.0) + Vector2(ring.x, ring.y * 0.6), k, kind)


func _stand(at: Vector2, look: int, kind: int = SimConst.K_PED) -> void:
	var v: int = look % SimConst.CLIP_VARIANTS
	var spec: Array = [kind, at.x, at.y, 1.0, 0.0, v, SimConst.F_PROMOTED, 0.0]
	@warning_ignore("return_value_discarded")
	_city.sim.spawn(PackedFloat64Array(spec + [0.0, 0]))


## A walkable band (sidewalk, kerb-side or lane) `length` m long near the start (bodies_clip's).
func _find_band(length: float) -> Vector2:
	for dy: int in range(-64, 65):
		for dx: int in range(-64, 65, 2):
			var p: Vector2 = Vector2(floorf(_start.x) + dx + 0.5, floorf(_start.y) + dy + 0.5)
			if _band_ok(p, length):
				return p
	Log.warn("powers_clip", "no sidewalk band near %s" % _start)
	return Vector2(-1, -1)


func _band_ok(p: Vector2, length: float) -> bool:
	for k: int in int(length) + 1:
		for row: int in range(-1, 2):
			var c: int = _city.sim.cell_at(p.x + k, p.y + row)
			if c < SimConst.C_LANE or c > SimConst.C_WALK:
				return false
	return true
