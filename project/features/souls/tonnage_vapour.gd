class_name TonnageVapour
extends RefCounted
## Short filaments hang between the palms. The flight mount owns the separate road-level column.

const CHEST: Dictionary = {
	"anchor_m": [0.0, 0.0],
	"length_m": 0.82,
	"width_m": 0.44,
	"stretch_k": 0.0,
	"swing_k": 0.45,
	"segments": 13,
	"fray": 0.12,
	"strands": 2,
	"spread_m": 0.08,
	"rise_m": 0.0,
	"wisps": 0,
	"flow_ticks": 83,
	"curl_m": 0.14,
}
const TOP_CHEST_M: float = 0.94
const TRAIL: float = 0.28


static func make() -> GhostTail:
	var row: GhostHoverRow.Tail = GhostHoverRow.Tail.new(DataTable.new(), CHEST)
	var tail: GhostTail = GhostTail.new(row)
	tail.name = &"ChestVapour"
	tail.reset(Vector2.ZERO, 0.0, 0.0)
	return tail


static func present(
	tail: GhostTail, centre: Vector2, cell: Sprite2D, yaw: float, ticks: int
) -> void:
	var flat: bool = ViewMode.shared().is_flat()
	var forward: Vector2 = Vector2.from_angle(yaw)
	# The painted chest already includes the tilt. Its falling vapour follows screen gravity,
	# with only the trailing component visible from directly overhead.
	var back: Vector2 = -forward * TRAIL
	if flat:
		centre += forward * TOP_CHEST_M * SimConst.PX_PER_M * tail.global_scale.y
	else:
		# The profiles expose the belly behind the near elbow. Front and rear sockets centre it.
		centre = cell.to_global(Vector2(-28.0 * forward.x, -82.0))
		back += Vector2.DOWN
	tail.global_position = centre
	tail.global_rotation = (-back).angle()
	tail.scale.x = back.length()
	tail.step(Vector2.ZERO, 0.0, 0.0, 0.0, ticks)
