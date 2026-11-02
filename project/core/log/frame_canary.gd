class_name FrameCanary
extends RefCounted
## A background thread that sleeps 1 ms in a loop and records how late it wakes up. When a long
## main-thread frame coincides with a long canary gap, the WHOLE process was not running (the OS,
## another process, paging): an outside cause. A long frame with an on-time canary was the main
## thread's own work or a wait inside the engine (TEL-03 attribution, no admin profiler needed).

const SLEEP_USEC: int = 1000

var _thread: Thread = Thread.new()
var _mutex: Mutex = Mutex.new()
var _running: bool = false
var _max_gap_us: int = 0


func start() -> void:
	if _running:
		return
	_running = true
	var err: int = _thread.start(_loop, Thread.PRIORITY_NORMAL)
	_running = err == OK


func stop() -> void:
	if not _running:
		return
	_mutex.lock()
	_running = false
	_mutex.unlock()
	_thread.wait_to_finish()


## The longest gap (ms) the canary saw since the previous call.
func take_max_gap_ms() -> float:
	_mutex.lock()
	var gap: int = _max_gap_us
	_max_gap_us = 0
	_mutex.unlock()
	return gap / 1000.0


func _loop() -> void:
	var last: int = Time.get_ticks_usec()
	while true:
		OS.delay_usec(SLEEP_USEC)
		var now: int = Time.get_ticks_usec()
		_mutex.lock()
		_max_gap_us = maxi(_max_gap_us, now - last)
		var go_on: bool = _running
		_mutex.unlock()
		last = now
		if not go_on:
			return
