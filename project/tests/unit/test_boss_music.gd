extends GutTest
## BossMusic: the boss loop plays from the engage and stops on the defeat.


func test_the_loop_plays_until_the_boss_is_defeated() -> void:
	var spec: BossSpec = BossSpec.shipped(&"king")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(3).stream(spec.rng), Vector2.ZERO)
	f.start()
	var host: Node = Node.new()
	add_child_autofree(host)
	var m: BossMusic = BossMusic.attach(host, f)
	assert_true(m.playing(), "the boss loop is on from the engage")
	f.defeated.emit()
	assert_false(m.playing(), "the defeat stops the loop")
