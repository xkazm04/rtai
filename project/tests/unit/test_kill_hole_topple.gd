extends GutTest
## The plasma kill's fall (showcase REQUEST 21): the holed body stands while it looks at the hole,
## then lies laid out along the shot, and the pose never compounds frame over frame.


func _topple(dir: Vector2) -> KillHoleFx.Topple:
	var root: Node2D = Node2D.new()
	var lay: Node2D = Node2D.new()
	root.add_child(lay)
	add_child_autofree(root)
	var h: KillHoleFx.Topple = KillHoleFx.Topple.new()
	h.body = root
	h.row = SignatureKill.new()
	h.row.hitstop_ticks = 3
	h.dir = dir
	return h


func test_the_body_stands_while_it_looks_at_the_hole() -> void:
	var h: KillHoleFx.Topple = _topple(Vector2.RIGHT)
	h.pose(3 + KillHoleFx.LOOK_TICKS, 64.0)
	var lay: Node2D = h.body.get_child(0) as Node2D
	assert_eq(lay.transform, Transform2D.IDENTITY)


func test_the_fallen_body_lies_along_the_shot() -> void:
	var h: KillHoleFx.Topple = _topple(Vector2.RIGHT)
	var lay: Node2D = h.body.get_child(0) as Node2D
	var down: int = 3 + KillHoleFx.LOOK_TICKS + KillHoleFx.TOPPLE_TICKS
	h.pose(down, 64.0)
	var once: Transform2D = lay.transform
	h.pose(down, 64.0)
	assert_eq(lay.transform, once, "the pose is absolute, not added each frame")
	assert_almost_eq(lay.position.x, KillHoleFx.FALL_M * 64.0, 0.01, "slid back along the shot")
	var along: float = (once.basis_xform(Vector2.RIGHT)).length()
	var across: float = (once.basis_xform(Vector2.DOWN)).length()
	assert_gt(along, across + 0.4, "stretched along the fall line, narrowed across it")
