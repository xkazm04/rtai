extends GutTest
## Owner note 2026-11-04 (reel chapter 14): the homing shard's victim reacted late. The burst kill
## now flinches on the tick each drawn shard lands, the first on the kill tick itself. A planted
## fault (every flinch two ticks late) must fail the same check.

const TORSO: int = 1
const HEAD: int = 0


func _kills() -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	return SignatureKills.new(table, RngRegistry.new(11).stream(&"brutality"))


## The tick each shard's own share first moves the torso (Callable(age, n) -> Vector3).
func _onsets(f: Callable) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	for n: int in KillShardJolt.HITS.size():
		var one: Callable = func(age: int) -> Vector3: return f.call(age, n)
		@warning_ignore("return_value_discarded")
		out.append(KillShardJolt.first_motion(one, 60))
	return out


func test_each_shard_moves_the_body_on_its_landing_tick() -> void:
	var real: Callable = func(age: int, n: int) -> Vector3:
		return KillShardJolt.hit(age, n, TORSO, 3)
	assert_eq(_onsets(real), KillShardJolt.HITS, "every flinch starts on its shard's tick")


func test_a_delayed_trigger_is_caught() -> void:
	var late: Callable = func(age: int, n: int) -> Vector3:
		return KillShardJolt.hit(age - 2, n, TORSO, 3)
	assert_ne(_onsets(late), KillShardJolt.HITS, "the planted two-tick lag fails the check")


func test_the_snap_is_back_along_the_shot_and_the_head_leads() -> void:
	var torso: Vector3 = KillShardJolt.at(2, TORSO, 3)
	var head: Vector3 = KillShardJolt.at(2, HEAD, 3)
	assert_gt(torso.x, 0.1, "the first shard throws the torso back")
	assert_gt(head.x, torso.x, "the head snaps further than the torso")
	assert_lt(absf(KillShardJolt.at(2, 4, 3).x), torso.x * 0.5, "the feet stay planted")


func test_the_live_burst_flinches_on_the_kill_tick() -> void:
	var kills: SignatureKills = _kills()
	var fx: KillBurstFx = autofree(KillBurstFx.new())
	fx.bind(kills, 48.0, false)
	kills.tick = 120
	assert_true(kills.on_kill(KillEvent.make(7, Vector2(4, 4), Vector2.RIGHT, &"homing_shard")))
	var serial: int = kills.consumed[7]
	var j: Vector3 = fx.jolt(serial, TORSO)
	assert_gt(j.x, 1.0, "the body moves on the very tick the shard lands (px at 48 px/m)")
	kills.tick = 120 + 200
	assert_eq(fx.jolt(serial, TORSO), Vector3.ZERO, "after the pop the parts fly free")


func test_other_kills_do_not_flinch() -> void:
	var kills: SignatureKills = _kills()
	var fx: KillBurstFx = autofree(KillBurstFx.new())
	fx.bind(kills, 48.0, false)
	assert_true(kills.on_kill(KillEvent.make(8, Vector2(4, 4), Vector2.RIGHT, &"rocket_launcher")))
	assert_eq(fx.jolt(kills.consumed[8], TORSO), Vector3.ZERO)
