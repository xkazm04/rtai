extends GutTest
## combat-notes (owner note "animation of melee weapons", the claw jab hidden at 32 px/m): while
## a strike extends, the striking arm draws over every part of a human rig (Rivet stands in the
## victim at contact); cocked back and after the strike it is back at its own z. Planted fault:
## the night's z (strike_over off) leaves the claw under the human's head.

const W: float = 0.1
const A: float = 0.1
const R: float = 0.2


func after_each() -> void:
	RigArm.strike_over = true


func test_striking_arm_draws_over_a_human() -> void:
	var rig: CutRig = _rivet()
	var top: int = _top_z(_cop())
	rig.clips.strike(rig, W, A, R, BodyPlan.R)
	_tick(rig, W + SimClock.TICK_DT)  # the hit tick: full reach
	var side: RigLimbs = rig.sides[BodyPlan.R]
	gut.p(
		(
			"hit tick: arm z %d / %d, the human's top part z %d"
			% [side.upper.z_index, side.fore.z_index, top]
		)
	)
	assert_gt(side.upper.z_index, top, "the upper arm draws over the human")
	assert_gt(side.fore.z_index, top, "the forearm and claw draw over the human")
	assert_lt(side.fore.z_index, 60, "still under RivetHeldView (+60)")
	var off: RigLimbs = rig.sides[BodyPlan.L]
	assert_lt(off.fore.z_index, top, "the other arm keeps its z")


func test_cocked_and_after_at_own_z() -> void:
	var rig: CutRig = _rivet()
	rig.clips.strike(rig, W, A, R, BodyPlan.R)
	_tick(rig, W * 0.5)
	assert_lt(rig.c_reach, 0.0, "cocked back")
	assert_lte(rig.sides[BodyPlan.R].fore.z_index, rig.plan.arm_above + 1, "no lift while cocked")
	_tick(rig, W + A + R)
	assert_lte(rig.sides[BodyPlan.R].fore.z_index, rig.plan.arm_above + 1, "back after the strike")


func test_planted_night_z_hides_the_claw() -> void:
	RigArm.strike_over = false
	var rig: CutRig = _rivet()
	rig.clips.strike(rig, W, A, R, BodyPlan.R)
	_tick(rig, W + SimClock.TICK_DT)
	assert_lt(rig.sides[BodyPlan.R].fore.z_index, _top_z(_cop()), "planted: under the head")


func _rivet() -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.drive(SimClock.TICK_DT)
	return rig


func _cop() -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(HumanPlan.cop(), RigVariant.crowd(5))
	rig.drive(SimClock.TICK_DT)
	return rig


func _tick(rig: CutRig, s: float) -> void:
	for _k: int in roundi(s / SimClock.TICK_DT):
		rig.drive(SimClock.TICK_DT)


## The highest drawn z of any visible part under a rig (z_index adds up while z_as_relative).
func _top_z(rig: CutRig) -> int:
	var top: int = -4096
	var nodes: Array[Node] = [rig]
	var zs: Array[int] = [0]
	while not nodes.is_empty():
		var n: Node = nodes.pop_back()
		var base: int = zs.pop_back()
		for c: Node in n.get_children():
			var ci: CanvasItem = c as CanvasItem
			if ci == null:
				continue
			var z: int = base + ci.z_index if ci.z_as_relative else ci.z_index
			if ci is Sprite2D and ci.visible:
				top = maxi(top, z)
			nodes.append(c)
			zs.append(z)
	return top
