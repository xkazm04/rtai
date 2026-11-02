extends Node
## Log autoload (TEL-01): levels, categories and a ring buffer.
## The only file allowed to call print(). File sink and push_error routing: TODO (TEL-01).

enum Level { DEBUG, INFO, WARN, ERROR }

const RING_SIZE: int = 256
const LEVEL_TAGS: PackedStringArray = ["DEBUG", "INFO", "WARN", "ERROR"]

var min_level: Level = Level.INFO
var _ring: Array[String] = []


func debug(category: String, message: String) -> void:
	_write(Level.DEBUG, category, message)


func info(category: String, message: String) -> void:
	_write(Level.INFO, category, message)


func warn(category: String, message: String) -> void:
	_write(Level.WARN, category, message)


func error(category: String, message: String) -> void:
	_write(Level.ERROR, category, message)


## The newest lines, oldest first.
func recent() -> PackedStringArray:
	return PackedStringArray(_ring)


func reset() -> void:
	_ring.clear()


func _write(level: Level, category: String, message: String) -> void:
	var line: String = "[%s] %s: %s" % [LEVEL_TAGS[level], category, message]
	_ring.append(line)
	if _ring.size() > RING_SIZE:
		_ring.remove_at(0)
	if level < min_level:
		return
	if level == Level.ERROR:
		printerr(line)
	else:
		print(line)
