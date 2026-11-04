extends GutTest
## The electro corpse (showcase REQUEST 29): the plank is the rig cut in human-reactions' shock
## death sprawl, the live rig is left exactly as it was, and the plank waits hidden under the lay
## node until the drop lands.

var _rig: CutRig = null


func before_each() -> void:
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	_rig = CutRig.new()
	parent.add_child(_rig)
	_rig.setup(HumanPlan.ped(), RigVariant.crowd(0))
	_rig.drive(SimClock.TICK_DT)


func test_the_rig_is_left_as_it_was() -> void:
	var before: Array[Transform2D] = _transforms(_rig)
	_rig.c_sprawl = 0.2
	var plank: Node2D = KillSprawlCut.cut(_rig)
	plank.free()
	assert_eq(_transforms(_rig), before, "every node transform put back")
	assert_almost_eq(_rig.c_sprawl, 0.2, 0.0001, "the channels put back")
	assert_false(_rig.dead)


func test_the_plank_spreads_wider_than_the_standing_cut() -> void:
	var stand: Node2D = _stand()
	var plank: Node2D = KillSprawlCut.cut(_rig)
	assert_gt(plank.get_child_count(), 0, "the plank is the rig's own sprites")
	assert_gt(_spread(plank), _spread(stand) * 1.2, "arms flung out, legs laid long")
	stand.free()
	plank.free()


func test_the_plank_waits_hidden_under_the_lay_node() -> void:
	var stand: Node2D = _stand()
	var plank: Node2D = KillSprawlCut.cut(_rig)
	var root: Node2D = KillShockFx.wrap(stand, plank)
	add_child_autofree(root)
	var lay: Node2D = root.get_child(0) as Node2D
	assert_eq(lay.get_child_count(), 2)
	assert_true(lay.get_child(0) == stand and stand.visible)
	assert_true(lay.get_child(1) == plank and not plank.visible)


func _transforms(n: Node) -> Array[Transform2D]:
	var out: Array[Transform2D] = []
	for ch: Node in n.get_children():
		if ch is Node2D:
			out.append((ch as Node2D).transform)
		out.append_array(_transforms(ch))
	return out


func _spread(g: Node2D) -> float:
	var r: Rect2 = Rect2()
	for ch: Node in g.get_children():
		r = r.expand((ch as Node2D).position)
	return r.size.length()


func _stand() -> Node2D:
	var groups: Array[Node2D] = GibCut.cut(_rig, true)
	for i: int in groups.size():
		if i != SignatureKill.BODY:
			groups[i].free()
	return groups[SignatureKill.BODY]
