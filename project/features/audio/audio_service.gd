class_name AudioService
extends Node2D
## The game's sound (features/audio/README.md). cue(id, pos_m, tick) plays a data-table cue from a
## pool of positional players: pan and fade come from the distance to the listener (the camera
## focus), the variation and pitch jitter from AudioDice, and a per-frame cap keeps a riot from
## asking the mixer for fifty voices at once. Loops and the voice channel hang off it. Render-side
## only: it reads the game (FX cues, Events) and never writes the sim, so replay and parity are
## untouched.

const FAR_BUS: StringName = &"sfx_far"

var tables: AudioTables
var bank: SoundBank = SoundBank.new()
var dice: AudioDice
var buses: AudioBuses
var loops: AudioLoops
## Microseconds the last rendered frame's own work took (evidence: dev/audio/audio_riot.gd).
var process_us: int = 0
var voice: VoiceChannel = VoiceChannel.new()
## Cues played / dropped since boot, by id and by reason (evidence and tests).
var played: Dictionary[StringName, int] = {}
var dropped: Dictionary[StringName, int] = {}
## Where the listener is, in metres; set it, or give `listener_fn` (returns metres) to follow a
## camera.
var listener_m: Vector2 = Vector2.ZERO
var listener_fn: Callable = Callable()
## The sim clock (null = a fixed 1/60 frame): its frame_delta() paces fades and the duck.
var clock: SimClock = null
var frame_s: float = SimClock.TICK_DT
var _pool: Array[AudioStreamPlayer2D] = []
var _pool_cue: Array[StringName] = []
var _pool_prio: Array[int] = []
var _next_ok: Dictionary[StringName, int] = {}
var _frame_starts: int = 0
var _m_to_px: float = 32.0
var _cap: int = 4
var _far_m: float = 22.0
var _listener: AudioListener2D = AudioListener2D.new()


func _init(p_tables: AudioTables, master_seed: int) -> void:
	tables = p_tables
	dice = AudioDice.new(master_seed)
	buses = AudioBuses.new(tables.mix)
	loops = AudioLoops.new(tables, bank)
	_m_to_px = tables.mix_float("m_to_px", 32.0)
	_cap = int(tables.mix_float("voice_cap_per_frame", 4.0))
	_far_m = tables.mix_float("far_m", 22.0)


func _ready() -> void:
	buses.ensure()
	add_child(_listener)
	_listener.make_current()
	add_child(loops)
	add_child(voice)
	var n: int = int(tables.mix_float("pool_size", 24.0))
	for i: int in n:
		var p: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		p.attenuation = tables.mix_float("attenuation", 1.6)
		p.panning_strength = tables.mix_float("panning_strength", 0.7)
		add_child(p)
		_pool.append(p)
		_pool_cue.append(&"")
		_pool_prio.append(-1)


## Plays cue `id` at `pos_m` (metres) on sim tick `tick`; false when it was culled (see `dropped`).
func cue(id: StringName, pos_m: Vector2, tick: int) -> bool:
	var c: AudioCue = tables.cue(id)
	if c == null or c.loop:
		return false
	var why: StringName = _cull(c, pos_m, tick)
	if why != &"":
		return _drop(id, why)
	var s: AudioStream = bank.stream(c, dice.take(id, c.takes))
	var slot: int = _free_slot(c.priority)
	if s == null or slot < 0:
		return _drop(id, &"missing" if s == null else &"pool")
	_start(slot, c, s, pos_m)
	_next_ok[id] = tick + c.cooldown_ticks
	_frame_starts += 1
	played[id] = played.get(id, 0) + 1
	return true


## Why `c` should not start now ("" = it may).
func _cull(c: AudioCue, pos_m: Vector2, tick: int) -> StringName:
	if tick < _next_ok.get(c.id, -1):
		return &"cooldown"
	if c.max_m > 0.0 and pos_m.distance_to(listener_m) > c.max_m:
		return &"far"
	if _frame_starts >= _cap:
		return &"cap"
	if _active(c.id) >= c.max_voices:
		return &"voices"
	return &""


func _start(slot: int, c: AudioCue, s: AudioStream, pos_m: Vector2) -> void:
	var p: AudioStreamPlayer2D = _pool[slot]
	p.stop()
	p.stream = s
	p.bus = _bus_for(c, pos_m)
	p.volume_db = c.gain_db
	p.pitch_scale = maxf(c.pitch * dice.jitter(c.pitch_jitter), 0.05)
	p.max_distance = (c.max_m if c.max_m > 0.0 else 1000.0) * _m_to_px
	p.position = (pos_m if c.max_m > 0.0 else listener_m) * _m_to_px
	p.play()
	_pool_cue[slot] = c.id
	_pool_prio[slot] = c.priority


## Positional sfx heard from beyond far_m metres go through the muffling bus.
func _bus_for(c: AudioCue, pos_m: Vector2) -> StringName:
	if c.bus == &"sfx" and c.max_m > 0.0 and pos_m.distance_to(listener_m) > _far_m:
		return FAR_BUS
	return c.bus


## The bus the latest still-playing voice of cue `id` runs on (&"" when none): tests and evidence.
func bus_in_use(id: StringName) -> StringName:
	for i: int in _pool.size():
		if _pool_cue[i] == id and _pool[i].playing:
			return _pool[i].bus
	return &""


func _active(id: StringName) -> int:
	var n: int = 0
	for i: int in _pool.size():
		if _pool_cue[i] == id and _pool[i].playing:
			n += 1
	return n


## A finished player, else the lowest-priority one below `priority` (stolen), else -1.
func _free_slot(priority: int) -> int:
	var steal: int = -1
	for i: int in _pool.size():
		if not _pool[i].playing:
			return i
		if _pool_prio[i] < priority and (steal < 0 or _pool_prio[i] < _pool_prio[steal]):
			steal = i
	return steal


func _drop(id: StringName, reason: StringName) -> bool:
	var key: StringName = StringName("%s:%s" % [id, reason])
	dropped[key] = dropped.get(key, 0) + 1
	return false


func _process(_delta: float) -> void:
	var t0: int = Time.get_ticks_usec()
	_frame_starts = 0
	if listener_fn.is_valid():
		var at: Variant = listener_fn.call()
		if at is Vector2:
			listener_m = at
	_listener.position = listener_m * _m_to_px
	frame_s = clock.frame_delta() if clock != null else SimClock.TICK_DT
	buses.step_duck(voice.playing(), frame_s)
	loops.step(frame_s)
	voice.step(frame_s)
	process_us = Time.get_ticks_usec() - t0
