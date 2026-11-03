extends GutTest

const BIT: int = NoirFigureShadows.CAST_BIT


func _attach(caster: Node) -> NoirFigureShadows:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child_autofree(layer)
	layer.add_child(caster)
	return NoirFigureShadows.attach(layer, NoirLook.read_params(NoirLook.PARAMS), caster)


func test_params_set_the_sweep_and_the_reach() -> void:
	var fs: NoirFigureShadows = NoirFigureShadows.new(NoirLook.read_params(NoirLook.PARAMS))
	assert_gt(fs.len_px, 0.0, "the figures cast in the noir params")
	assert_gt(fs.reach_px, 0.0)
	var off: NoirFigureShadows = NoirFigureShadows.new({})
	assert_eq(off.len_px, 0.0, "no figures table: no figure shadows")
	fs.free()
	off.free()


func test_casters_and_their_later_children_carry_the_bit_others_do_not() -> void:
	var caster: Node2D = Node2D.new()
	var early: Sprite2D = Sprite2D.new()
	caster.add_child(early)
	var fs: NoirFigureShadows = _attach(caster)
	var late: Sprite2D = Sprite2D.new()
	early.add_child(late)
	var other: Sprite2D = Sprite2D.new()
	add_child_autofree(other)
	assert_ne(caster.visibility_layer & BIT, 0)
	assert_ne(early.visibility_layer & BIT, 0)
	assert_ne(late.visibility_layer & BIT, 0, "a part added later casts too")
	assert_eq(other.visibility_layer & BIT, 0)
	assert_eq(fs.visibility_layer & BIT, 0, "the shadow never casts itself")


func test_the_dead_cast_no_figure() -> void:
	var caster: Node2D = Node2D.new()
	var alive: CutRig = CutRig.new()
	var dead: CutRig = CutRig.new()
	dead.dead = true
	caster.add_child(alive)
	caster.add_child(dead)
	var fs: NoirFigureShadows = _attach(caster)
	fs._process(0.0)
	assert_ne(alive.visibility_layer & BIT, 0)
	assert_eq(dead.visibility_layer & BIT, 0, "a body lying flat casts no standing shadow")
	dead.dead = false
	fs._process(0.0)
	assert_ne(dead.visibility_layer & BIT, 0)
