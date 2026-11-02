extends Node
## Save autoload (SAV-01..04): GTSV container, tmp/verify/bak/rename protocol, migrations.
## Lands before any persistent progress exists; until then it owns no slot.

var _active_slot: int = -1


func active_slot() -> int:
	return _active_slot


func reset() -> void:
	_active_slot = -1
