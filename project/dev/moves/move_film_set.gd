class_name MoveFilmSet
extends RefCounted
## The camera sees the same props the squad route map and blink collision see.


static func stations(crate_corner: bool) -> ArenaStations:
	var parts: ArenaStations = ArenaStations.new()
	var dock: ArenaStation = ArenaStation.new()
	for at: Vector2 in [Vector2(-10, -6.3), Vector2(18, -6.3), Vector2(-10, 6.3), Vector2(18, 6.3)]:
		_prop(dock, at, "cone", Vector2.ONE * 0.7)
	for at: Vector2 in [Vector2(-13, -8.4), Vector2(19, -8.4)]:
		_prop(dock, at, "cover_low", Vector2(4.4, 1.7))
	if crate_corner:
		# The far side of the plate is clear. A straight dash across Kerf's approach line
		# runs into the side of this crate while the carrier's shove faces the old position.
		_prop(dock, Vector2(3.52, 2.35), "cover_low", Vector2(3.5, 3.2))
	parts.stations.append(dock)
	return parts


static func _prop(station: ArenaStation, at: Vector2, kind: String, size_m: Vector2) -> void:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = kind
	prop.at = at
	prop.size = size_m
	station.props.append(prop)
