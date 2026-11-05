extends GutTest
## Servo's defeat (ServoMoves._on_defeated): the fight stops ticking the moves once he is down, so
## the swarm is grounded at once. No drone stays in the air or in the hostiles, no parcel stays
## falling, no bomb goes off after the defeat, and carried crates land where their drones crashed.


func _fight() -> BossFight:
	var reg: RngRegistry = RngRegistry.new(11)
	var spec: BossSpec = BossSpec.shipped(&"servo")
	var f: BossFight = BossFight.new(spec, reg.stream(spec.rng), spec.arena.boss_at)
	f.moves.bind(f, reg)
	f.start(2)  # overtime: a hit past his hp downs him (no phase floor left)
	return f


func test_defeat_grounds_the_swarm() -> void:
	var f: BossFight = _fight()
	var m: ServoMoves = f.moves as ServoMoves
	var target: Vector2 = f.body.pos + Vector2(9.0, 0.0)
	assert_gt(m.swarm.launch_wave(target), 0, "a wave is up")
	for i: int in 30:
		@warning_ignore("return_value_discarded")
		f.step(i + 1, target, 0.5)
	assert_gt(m.bodies().size(), 0, "the drones are bodies before the defeat")
	var carried: int = (
		m
		. swarm
		. drones
		. filter(func(d: ServoDrone) -> bool: return d.parcel == ServoParcels.CRATE)
		. size()
	)
	var crates_before: int = m.swarm.parcels.crates.size()
	var up: int = m.swarm.alive()
	@warning_ignore("return_value_discarded")
	f.hurt(f.body.hp + 1.0)
	assert_eq(f.state, BossFight.State.DEFEATED)
	assert_eq(m.defeated_at, 30, "the beat is timed from the defeat tick")
	assert_eq(m.swarm.alive(), 0, "no drone stays in the air")
	assert_eq(m.bodies().size(), 0, "no drone body stays in the hostiles")
	assert_eq(m.crashes.size(), up, "every flying drone crashed")
	assert_eq(m.swarm.parcels.falling.size(), 0, "nothing stays falling")
	assert_eq(m.swarm.parcels.blasts.size(), 0, "no bomb goes off")
	assert_eq(m.swarm.parcels.crates.size(), crates_before + carried, "carried crates landed")


func test_fall_curves_settle() -> void:
	assert_almost_eq(ServoFall.scale_k(0), 1.0, 0.001, "starts at full size")
	assert_almost_eq(ServoFall.scale_k(240), 0.88, 0.01, "slumps to 0.88")
	assert_almost_eq(ServoFall.spin(300), 0.0, 0.001, "the pads spin down")
	assert_eq(ServoFall.tint(0), Color(2.0, 2.0, 2.0), "the flash")
	assert_eq(ServoFall.tint(400), ServoFall.GREY, "greyed out")
