class_name DecayLedger
extends RefCounted
## One decay rule over keyed leftovers (CorpseDecay: the bodies, the stains): a key lingers
## linger_ticks, then fades over fade_ticks and is released. Keys sit in add order (oldest
## first). Early fade: while more than cap - room keys are still solid, the oldest solid one
## starts its fade now, so a horde never stacks more than about cap leftovers. Hard cap: while
## more than cap keys are drawn at all, the most faded one is released at once (`forced`: the
## only way a leftover can pop; `forced_alpha` keeps the most opaque one so a check can tell).
## Stepped on the 60 Hz sim tick, no RNG: a replay releases the same keys on the same ticks.

var linger_ticks: int = 360
var fade_ticks: int = 72
var cap: int = 16
var room: int = 4
## Keys released by the last step() (the hosts free their nodes, the sim prunes its bodies).
var released: PackedInt32Array = PackedInt32Array()
var total_released: int = 0
var early: int = 0
var forced: int = 0
var forced_alpha: float = 0.0
## The most keys drawn at once since boot (solid + fading).
var peak: int = 0
var _keys: PackedInt32Array = PackedInt32Array()
var _born: PackedInt32Array = PackedInt32Array()
## The tick each key's fade began (-1 while it is solid).
var _fade_from: PackedInt32Array = PackedInt32Array()
var _tick: int = 0


static func make(linger_s: float, fade_s: float, p_cap: int, p_room: int) -> DecayLedger:
	var l: DecayLedger = DecayLedger.new()
	l.linger_ticks = maxi(0, roundi(linger_s / SimClock.TICK_DT))
	l.fade_ticks = maxi(1, roundi(fade_s / SimClock.TICK_DT))
	l.cap = maxi(1, p_cap)
	l.room = clampi(p_room, 0, l.cap - 1)
	return l


## A new leftover at `tick` (a key already held is left as it is).
func add(key: int, tick: int) -> void:
	if _keys.has(key):
		return
	@warning_ignore("return_value_discarded")
	_keys.append(key)
	@warning_ignore("return_value_discarded")
	_born.append(tick)
	@warning_ignore("return_value_discarded")
	_fade_from.append(-1)


## Drops `key` without counting a release (a revived dummy is whole again).
func forget(key: int) -> void:
	var i: int = _keys.find(key)
	if i >= 0:
		_remove(i)


func has(key: int) -> bool:
	return _keys.has(key)


## Leftovers drawn now (solid + fading).
func count() -> int:
	return _keys.size()


func solid() -> int:
	var n: int = 0
	for f: int in _fade_from:
		n += 1 if f < 0 else 0
	return n


func step(tick: int) -> void:
	_tick = tick
	released.clear()
	for i: int in _keys.size():
		if _fade_from[i] < 0 and tick - _born[i] >= linger_ticks:
			_fade_from[i] = _born[i] + linger_ticks
	for i: int in range(_keys.size() - 1, -1, -1):
		if _fade_from[i] >= 0 and tick - _fade_from[i] >= fade_ticks:
			_release(i)
	var over: int = solid() - (cap - room)
	for i: int in _keys.size():
		if over <= 0:
			break
		if _fade_from[i] < 0:
			_fade_from[i] = tick
			early += 1
			over -= 1
	while _keys.size() > cap:
		var j: int = _most_faded()
		forced += 1
		forced_alpha = maxf(forced_alpha, alpha_at(j))
		_release(j)
	peak = maxi(peak, _keys.size())


## 1 while `key` lies solid, easing to 0 over its fade; 1 for a key the ledger does not hold.
func alpha(key: int) -> float:
	var i: int = _keys.find(key)
	return 1.0 if i < 0 else alpha_at(i)


## 0 while `key` lies solid, rising to 1 at the end of its fade (the sink).
func fade_k(key: int) -> float:
	var i: int = _keys.find(key)
	return 0.0 if i < 0 else _k(i)


func alpha_at(i: int) -> float:
	return 1.0 - smoothstep(0.0, 1.0, _k(i))


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(_keys.size())
	for i: int in _keys.size():
		out.put_32(_keys[i])
		out.put_32(_born[i])
		out.put_32(_fade_from[i])
	out.put_32(total_released)
	out.put_32(forced)


func _k(i: int) -> float:
	if _fade_from[i] < 0:
		return 0.0
	return clampf(float(_tick - _fade_from[i]) / float(fade_ticks), 0.0, 1.0)


func _most_faded() -> int:
	var best: int = 0
	for i: int in _keys.size():
		var f: int = _fade_from[i] if _fade_from[i] >= 0 else _tick + 1
		var b: int = _fade_from[best] if _fade_from[best] >= 0 else _tick + 1
		if f < b:
			best = i
	return best


func _release(i: int) -> void:
	@warning_ignore("return_value_discarded")
	released.append(_keys[i])
	total_released += 1
	_remove(i)


func _remove(i: int) -> void:
	_keys.remove_at(i)
	_born.remove_at(i)
	_fade_from.remove_at(i)
