extends GutTest
## Lane noir: the showcase fight is the same every run, and the silhouette flash (impact mode 4)
## hides the world for its ticks only, then restores what it hid.


func _run_fight() -> Array[String]:
	var fight: NoirFightScript = NoirFightScript.new()
	var feed: RigFeed = RigFeed.new(4)
	var log_lines: Array[String] = []
	for t: int in range(1, 700):
		for cue: Array in fight.step(t, feed):
			log_lines.append("%d %s %d" % [t, cue[0], cue[1]])
	return log_lines


func test_fight_kills_both_cops_once() -> void:
	var lines: Array[String] = _run_fight()
	var kills: Array[String] = lines.filter(func(s: String) -> bool: return s.contains("kill"))
	assert_eq(kills.size(), 2)
	assert_true(kills[0].ends_with(str(NoirFightScript.COP_A)))
	assert_true(kills[1].ends_with(str(NoirFightScript.COP_B)))


func test_fight_is_deterministic() -> void:
	assert_eq(_run_fight(), _run_fight())


func test_silhouette_flash_hides_then_restores() -> void:
	var impact: ImpactFrame = ImpactFrame.new()
	add_child_autofree(impact)
	impact.sequence = PackedInt32Array([4, 1])
	impact.panel_ticks = 0
	var world: Node2D = Node2D.new()
	add_child_autofree(world)
	impact.hide_on_flash = [world]
	impact.fire(Vector2(0.5, 0.5))
	assert_false(world.visible, "mode 4 hides the world")
	impact.step_ticks(1)
	assert_true(world.visible, "mode 1 shows it again")
	impact.step_ticks(1)
	assert_false(impact.active())
	assert_true(world.visible)


func test_held_panel_follows_the_sequence() -> void:
	var impact: ImpactFrame = ImpactFrame.new()
	add_child_autofree(impact)
	impact.sequence = PackedInt32Array([4, 4, 1])
	impact.panel_ticks = 8
	impact.fire(Vector2(0.9, 0.1))
	impact.step_ticks(10)
	assert_true(impact.active(), "the panel holds 8 ticks after the 3 flash ticks")
	impact.step_ticks(1)
	assert_false(impact.active())
