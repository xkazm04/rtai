class_name ErrorCounter
extends Logger
## Counts engine and script errors while a scenario runs. GDScript has no exceptions: a runtime
## error aborts the function and the caller sees a default value, so without this a crashing
## scenario returns "" and passes. Loggers may be called from any thread, hence the mutex.

var _mutex: Mutex = Mutex.new()
var _count: int = 0
var _first: String = ""


# DEVIATION GDS-03: Logger._log_error is an engine virtual with 8 fixed parameters.
# gdlint: disable=function-arguments-number
func _log_error(
	function: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	_editor_notify: bool,
	_error_type: int,
	_script_backtraces: Array[ScriptBacktrace],
) -> void:
	_mutex.lock()
	_count += 1
	if _first == "":
		_first = "%s (%s:%d %s)" % [rationale if rationale != "" else code, file, line, function]
	_mutex.unlock()


# gdlint: enable=function-arguments-number


func reset() -> void:
	_mutex.lock()
	_count = 0
	_first = ""
	_mutex.unlock()


func count() -> int:
	_mutex.lock()
	var n: int = _count
	_mutex.unlock()
	return n


func first() -> String:
	_mutex.lock()
	var text: String = _first
	_mutex.unlock()
	return text
