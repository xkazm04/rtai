class_name RocketLead
extends RefCounted
## Extrapolate the tracked bearing and range about a planted trooper over lock plus flight.

static var _model: String = ""


static func shipped_orbit() -> bool:
	if _model.is_empty():
		var table: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
		var weapon: Dictionary = table.object(table.object(table.raw, "weapons"), "rocket")
		_model = table.text(weapon, "lead_model") if weapon.has("lead_model") else "linear"
		if not table.ok():
			Log.error("rocket-lead", str(table.errors()))
	return _model == "orbit"


static func orbit(
	origin: Vector2, previous: Vector2, target: Vector2, seconds: float, share: float
) -> Vector2:
	var before: Vector2 = previous - origin
	var now: Vector2 = target - origin
	var ticks: float = seconds * share * SimClock.TICK_RATE
	var radius: float = maxf(0.0, now.length() + (now.length() - before.length()) * ticks)
	return origin + now.normalized().rotated(before.angle_to(now) * ticks) * radius
