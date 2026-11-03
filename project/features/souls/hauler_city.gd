class_name HaulerCity
extends RefCounted
## The Hauler form on the real city sim (CitySystem + RivetBody). Call step() once per tick AFTER
## the city stepped: it moves Rivet by the form's heavy movement (city.target for the next step),
## keeps his body class in sync (rivet_ghost while on: the tackle matrix knocks humans down) and
## turns a due stomp into a one-step body pulse (RivetBody.pulse: a radial knockdown in the sim).
## A pulse body is wide, so the step after it puts Rivet back where he stood. cued() is the sound
## hook (powers.json morph_cue / stomp_cue; the host routes it to AudioService.cue).

signal cued(id: StringName, at: Vector2, tick: int)

var form: HaulerForm = null
## Counters for evidence: knockdowns while transformed (ram + stomp) and by stomps alone.
var knocks: int = 0
var stomp_knocks: int = 0
var ticks_on: int = 0
## Where the last stomp landed (m) and the tick it did (-1 = none yet), for the ring.
var stomp_at: Vector2 = Vector2.ZERO
var stomp_tick: int = -1
var _city: CitySystem = null
var _pulsed: bool = false
var _hold: Vector2 = Vector2.ZERO


func _init(city: CitySystem, p_form: HaulerForm) -> void:
	_city = city
	form = p_form


## One tick: `want` is the move intent (unit or zero), `arm` true to start a stomp telegraph.
func step(tick: int, want: Vector2, arm: bool) -> void:
	var body: RivetBody = _city.body
	@warning_ignore("integer_division")
	var n: int = body.knocks.size() / SimConst.BR_STRIDE
	if _pulsed:
		cued.emit(form.id_of(&"stomp_cue"), _hold, tick)
		stomp_knocks += n
		body.pos = _hold
		_city.target = _hold
		_pulsed = false
	if form.on:
		knocks += n
		ticks_on += 1
	if arm:
		@warning_ignore("return_value_discarded")
		form.arm()
	var was_on: bool = form.on and form.morph_k() > 0.0
	form.step(want)
	if form.on and not was_on:
		cued.emit(form.id_of(&"morph_cue"), body.pos, tick)
	body.body_class = form.body_class
	if form.stomp_due():
		_stomp(tick, body)
		return
	_city.target = body.pos + form.vel * SimClock.TICK_DT
	_city.focus = _city.target


## The stomp as a RivetBody pulse: [stomp_radius_m, the slide speed that carries a body
## stomp_knock_m under the sim's slide deceleration, stomp_stun_s lying down].
static func pulse_of(p_form: HaulerForm) -> Vector3:
	var slide: float = sqrt(2.0 * RivetBody.SLIDE_DECEL * p_form.num(&"stomp_knock_m"))
	return Vector3(p_form.num(&"stomp_radius_m"), slide, p_form.num(&"stomp_stun_s"))


func _stomp(tick: int, body: RivetBody) -> void:
	@warning_ignore("return_value_discarded")
	form.stomp(body.pos, PackedVector2Array())
	body.pulse = pulse_of(form)
	form.vel = Vector2.ZERO
	_hold = body.pos
	_pulsed = true
	stomp_at = body.pos
	stomp_tick = tick
	_city.target = body.pos
