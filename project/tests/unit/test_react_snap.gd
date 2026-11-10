extends GutTest
## Lane n7-ranged, owner combat note item 1: an electro bolt jolted the victim in place, so the
## hit did not read along the bolt. The stun family's snap_m throws the body along the blow on
## the hit frame and eases it back inside a third of a second; the convulsion carries on.

var _table: ReactTable
var _rig: CutRig


func before_each() -> void:
	_table = ReactTable.shipped()
	_rig = CutRig.new()
	_rig.actor_id = 7
	_rig.facing = 0.0


func after_each() -> void:
	_rig.free()


## The mean body offset along the blow (part px) over ticks [from, to) of a `kind` hit along +y.
func _along(table: ReactTable, from: int, to: int, kind: StringName = &"stun") -> float:
	var r: HumanReact = HumanReact.new()
	r.phase = 0.61
	r.play(_rig, kind, Vector2.DOWN, table)
	var sum: float = 0.0
	for tick: int in to:
		r.pre(_rig, SimClock.TICK_DT)
		if tick >= from:
			sum += r.off.dot(r.dir)
	return sum / float(to - from)


func test_the_stun_has_a_snap_in_the_table() -> void:
	assert_true(_table.ok())
	assert_gt(_table.snap(&"stun"), 0.1, "the electro stun is thrown along the bolt")
	assert_eq(_table.snap(&"flinch"), 0.0, "families without snap_m are untouched")


func test_the_body_is_thrown_along_the_bolt_on_the_hit_frames() -> void:
	var snap_px: float = _table.snap(&"stun") * HumanReact.PX_M
	assert_gt(_along(_table, 2, 8), 0.6 * snap_px, "most of the throw by the third tick")


func test_the_snap_is_gone_before_the_convulsion_ends() -> void:
	var snap_px: float = _table.snap(&"stun") * HumanReact.PX_M
	assert_lt(absf(_along(_table, 24, 60)), 0.25 * snap_px, "jolting in place again by 0.4 s")


func test_without_the_snap_the_stun_jolts_in_place() -> void:
	var plain: ReactTable = ReactTable.shipped()
	plain._snap.clear()
	var snap_px: float = _table.snap(&"stun") * HumanReact.PX_M
	assert_lt(absf(_along(plain, 2, 8)), 0.4 * snap_px, "the before: no throw along the bolt")


## n12 B1: a melee wound folded or spun over 8-9 ticks and drew under 1 px on the hit frame (claw
## on a riot cop: 0.3 px at hit + 3; the plasma wound's stagger 3 ticks). fold, spin and stagger
## now take the same hit-frame snap.
func test_the_melee_wounds_are_thrown_on_the_hit_frames() -> void:
	for kind: StringName in [&"fold", &"spin", &"stagger"]:
		var snap_px: float = _table.snap(kind) * HumanReact.PX_M
		assert_gt(snap_px, 0.0, "%s has a snap" % kind)
		var plain: ReactTable = ReactTable.shipped()
		plain._snap.clear()
		var with: float = _along(_table, 1, 3, kind)
		var without: float = _along(plain, 1, 3, kind)
		assert_gt(with - without, 0.6 * snap_px, "%s: the throw is there by the second tick" % kind)


func test_the_melee_stop_holds_the_thrown_frame() -> void:
	var feel: HitFeel = HitFeel.shipped(null)
	var row: Dictionary = feel.camera_row(&"claw", &"melee", false)
	var delay: int = row.get("hold_delay", 0)
	assert_eq(delay, 2, "the stop starts 2 ticks after the hit")
