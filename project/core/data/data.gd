extends Node
## Data autoload (DAT-05): reads every JSON table once at boot into typed objects.
## Lands with the first data ticket; until then it holds no tables.

var _errors: PackedStringArray = PackedStringArray()


func errors() -> PackedStringArray:
	return _errors.duplicate()


func reset() -> void:
	_errors.clear()
