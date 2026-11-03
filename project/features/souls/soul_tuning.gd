class_name SoulTuning
extends RefCounted
## Typed reads from a soul's tuning block (powers.json `hauler` / `gearbox`), schema-checked.


static func num(t: Dictionary, key: StringName) -> float:
	var v: Variant = t.get(String(key))
	if v is float:
		return v
	if v is int:
		var i: int = v
		return float(i)
	return 0.0
