class_name EnemyRounds
extends RefCounted
## Projectile properties from enemies.json for hostile shots that carry only a weapon id.

static var _rows: Dictionary[StringName, EnemyRounds] = {}
static var _default: EnemyRounds

var _size: StringName = Shot.SMALL
var _radius_m: float = 0.0
var _damage: float = 0.0
var _melee: bool = false


static func size_of(weapon: StringName) -> StringName:
	return _lookup(weapon)._size


static func splash_m(weapon: StringName) -> float:
	return _lookup(weapon)._radius_m


static func is_blast(s: Shot) -> bool:
	return splash_m(s.weapon) > 0.0 or (s.spec != null and s.spec.splash_radius_m > 0.0)


static func splash_damage(weapon: StringName) -> float:
	return _lookup(weapon)._damage


static func is_melee(weapon: StringName) -> bool:
	return _lookup(weapon)._melee


## Install a synthetic weapon row without changing the shipped table. Reset reloads the table.
static func override_for_test(
	id: StringName, round_size: StringName, radius: float, damage: float
) -> void:
	if _default == null:
		_load_table()
	var row: EnemyRounds = EnemyRounds.new()
	row._size = round_size
	row._radius_m = radius
	row._damage = damage
	_rows[id] = row


static func reset() -> void:
	_rows.clear()
	_default = null


static func _lookup(weapon: StringName) -> EnemyRounds:
	if _default == null:
		_load_table()
	return _rows.get(weapon, _default)


static func _load_table() -> void:
	_default = EnemyRounds.new()
	var t: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	var weapons: Dictionary = t.object(t.raw, "weapons")
	for id: String in weapons:
		var row: Dictionary = t.object(weapons, id)
		var entry: EnemyRounds = EnemyRounds.new()
		entry._size = Shot.read_size(t, row, id)
		entry._melee = row.get("melee") == true
		if row.has("splash_radius_m"):
			entry._radius_m = t.num(row, "splash_radius_m")
		if row.has("splash_damage"):
			entry._damage = t.num(row, "splash_damage")
		_rows[StringName(id)] = entry
	if not t.ok():
		Log.error("enemy_rounds", str(t.errors()))
