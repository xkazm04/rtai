extends GutTest
## The human-like boss bot: it reads about READ_P of the tells, never before its reaction time,
## and the same seed reads the same tells (the fight replays).


func _fight() -> BossFight:
	var spec: BossSpec = BossSpec.shipped(&"king")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(5).stream(spec.rng), Vector2.ZERO)
	f.moves.bind(f, RngRegistry.new(5))
	return f


func _reads(seed_value: int, n: int) -> Array[bool]:
	var read: BossBotRead = BossBotRead.new(RngRegistry.new(seed_value).stream(&"boss_bot"))
	var f: BossFight = _fight()
	var out: Array[bool] = []
	for i: int in n:
		f.state = BossFight.State.IDLE
		read.see(f)
		f.state = BossFight.State.WINDUP
		f.t = 60
		read.see(f)
		out.append(read.reacts(f))
	return out


func test_reads_about_seven_in_ten_tells() -> void:
	var reads: Array[bool] = _reads(3, 400)
	var n: int = reads.count(true)
	assert_between(n, 250, 310, "about READ_P of 400 tells read (%d)" % n)


func test_the_same_seed_reads_the_same_tells() -> void:
	assert_eq(_reads(9, 50), _reads(9, 50))


func test_never_reacts_before_its_reaction_time() -> void:
	var read: BossBotRead = BossBotRead.new(RngRegistry.new(1).stream(&"boss_bot"))
	var f: BossFight = _fight()
	f.state = BossFight.State.WINDUP
	f.t = BossBotRead.REACT_TICKS - 1
	read.see(f)
	assert_false(read.reacts(f), "no read in the first REACT_TICKS of a windup")
