class_name PrologueStreet
extends RefCounted
## Beat three is driven by the same interact edge as the rest of the stage. Only a
## connected receiver holds Rivet in place. Accepting the radio can happen anywhere.

enum Phase { OUT, VOICES, PHONE, CALL, REQUEST, RING, RADIO, END }

const IDLE_TICKS: int = 2 * SimClock.TICK_RATE
const RING_TICKS: int = 42
const END_TICKS: int = 3 * SimClock.TICK_RATE

var phase: Phase = Phase.OUT
var phone: String
var answered_tick: int = -1
var request_tick: int = -1
var accepted_tick: int = -1
var end_tick: int = -1
var _start: int
var _lines: PrologueLines


func _init(lines: PrologueLines, phone_id: String) -> void:
	_lines = lines
	phone = phone_id


func enter(stage: PrologueStage, tick: int) -> void:
	phase = Phase.OUT
	_start = tick
	answered_tick = -1
	request_tick = -1
	accepted_tick = -1
	end_tick = -1
	_lines.stop_segment()
	stage.at_receiver = false
	stage.heat.set_level(0)
	stage.router = PayphoneRouter.new()


func step(stage: PrologueStage, tick: int) -> void:
	match phase:
		Phase.OUT:
			var gate: Vector2 = (stage.plan as PrologueYard).gate
			if stage.arena.rivet.pos.y >= gate.y or tick - _start >= IDLE_TICKS:
				phase = Phase.VOICES
				_lines.segment("b3_l01_rivet_voices", "b3_l01_rivet_voices", tick)
		Phase.VOICES:
			_lines.advance(tick, stage.interacted)
			if not _lines.busy():
				stage.router.queue_call(phone)
				stage.router.step(stage.heat.level)
				phase = Phase.PHONE
				_lines.segment("b3_l02_rivet_phone", "b3_l02_rivet_phone", tick)
		Phase.PHONE:
			_receiver(stage, tick)
		Phase.CALL:
			_lines.advance(tick, stage.interacted)
			if not _lines.busy():
				stage.at_receiver = false
				request_tick = tick
				phase = Phase.REQUEST
		Phase.REQUEST:
			if stage.interacted:
				accepted_tick = tick
				phase = Phase.RING
		Phase.RING:
			if tick - accepted_tick >= RING_TICKS:
				phase = Phase.RADIO
				_lines.segment("b3_l11_fax_location", "b3_l11_fax_location", tick)
		Phase.RADIO:
			_lines.advance(tick, stage.interacted)
			if not _lines.busy():
				phase = Phase.END
				end_tick = tick


func _receiver(stage: PrologueStage, tick: int) -> void:
	_lines.advance(tick, stage.interacted)
	if stage.router.connected(phone):
		answered_tick = tick
		stage.pilot.stop()
		stage.at_receiver = true
		phase = Phase.CALL
		_lines.segment("b3_l03_fax_son", "b3_l10_fax_channel", tick)
