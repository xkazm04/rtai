extends GutTest

const TURRET: StringName = &"sentry_turret"
const PHASE := FoeTurret.Phase

var arena: CombatArena
var squad: ArenaSquad
var gun: Fighter
var now: int = 0
var walls: ArenaWalls
var cull: ArenaDodges


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	gun = squad.spawn_member(arena, Vector2(14, 0), TURRET)
	gun.pos = Vector2(14, 0)
	gun.facing = Vector2.LEFT
	gun.cooldown = 0
	walls = ArenaWalls.new()
	cull = ArenaDodges.new()
	now = 0


func _step() -> SquadMind:
	now += 1
	cull.cull(arena, walls)
	arena.step(now)
	return squad.minds[gun.id]


func test_tell_sweep_and_cooling_keep_the_mount_fixed() -> void:
	var mount: Vector2 = gun.pos
	var tell: int = -1
	var cool: int = -1
	var sweeps: int = 0
	var fired: Dictionary[Shot, bool] = {}
	var sweep_start: int = -1
	for i: int in 600:
		var mind: SquadMind = _step()
		assert_eq(gun.pos, mount)
		var phase: int = mind.turret.phase
		if phase == PHASE.TELL and tell < 0:
			tell = now
		if phase == PHASE.TELL:
			assert_eq(mind.agent.state, EnemyAgent.State.WINDUP)
			assert_eq(mind.agent.state_ticks, now - tell)
		if phase == PHASE.SWEEP and sweep_start < 0:
			sweep_start = now
			assert_eq(mind.agent.state, EnemyAgent.State.FIRE)
		elif phase == PHASE.SWEEP and now == sweep_start + 1:
			assert_eq(mind.agent.shot_tick, now)
		if phase == PHASE.COOL and cool < 0:
			cool = now
			sweep_start = -1
		if cool >= 0 and phase != PHASE.COOL:
			assert_gte(now - cool, 20)
			assert_eq(now - cool, mind.agent.arch.weapon.cooldown_ticks)
			cool = -1
			tell = -1
			sweeps += 1
		assert_eq(GuardTell.telling(gun), phase in [PHASE.TELL, PHASE.SWEEP])
		_check_new_rounds(fired, mind, tell)
	assert_gte(sweeps, 2)
	assert_gt(fired.size(), 4)
	assert_lt(arena.rivet.hp, arena.rivet.max_hp)


func _check_new_rounds(fired: Dictionary[Shot, bool], mind: SquadMind, tell: int) -> void:
	for shot: Shot in arena.shots:
		if fired.has(shot):
			continue
		fired[shot] = true
		assert_eq(mind.agent.shot_tick, now)
		assert_eq(mind.turret.phase, PHASE.SWEEP)
		assert_gte(tell, 0)
		assert_gte(now - tell, mind.agent.arch.telegraph_ticks)
		assert_gte(now - tell, 20)


func test_sweep_stays_on_its_chosen_lane_and_fires_bursts_down_the_line() -> void:
	var angles: Array[float] = []
	var ticks: Array[int] = []
	var arch: EnemyRoster.Archetype = squad.pit.roster.archetype(TURRET)
	for i: int in 360:
		var mind: SquadMind = _step()
		if mind.turret.phase == PHASE.TELL:
			arena.rivet.pos = Vector2(14, 10)
		if mind.agent.shot_tick == now:
			var s: Shot = arena.shots.back()
			assert_eq(s.size, Shot.SMALL)
			assert_almost_eq(s.vel.normalized(), gun.facing, Vector2.ONE * 0.001)
			angles.append(Vector2.LEFT.angle_to(gun.facing))
			ticks.append(now)
		if mind.turret.phase == PHASE.COOL:
			break
	assert_gte(angles.size(), arch.weapon.burst * 2)
	if angles.size() < arch.weapon.burst * 2:
		return
	assert_almost_eq(angles[0], -FoeTurret.HALF_ARC, 0.001)
	assert_gt(angles[-1], deg_to_rad(20.0))
	for i: int in range(1, ticks.size()):
		var gap: int = arch.weapon.burst_gap_ticks * (2 if i % arch.weapon.burst == 0 else 1)
		assert_eq(ticks[i] - ticks[i - 1], gap)
		assert_almost_eq(angles[i] - angles[i - 1], gap * arch.turn_rad_per_tick, 0.001)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_prop_stops_small_rounds_in_the_committed_lane() -> void:
	for i: int in 300:
		var mind: SquadMind = _step()
		if mind.turret.phase == PHASE.TELL and walls.boxes.is_empty():
			walls.boxes.append(Rect2(5, -10, 1, 20))
	assert_gt(cull.blocked, 0)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_hit_direction_and_blast_choose_the_armour_at_impact() -> void:
	arena.rivet.pos = gun.pos + Vector2.UP
	gun.facing = Vector2.RIGHT
	assert_eq(FoeArmor.k(gun, Vector2.LEFT.rotated(deg_to_rad(59)), &"shot", squad), 0.25)
	assert_eq(FoeArmor.k(gun, Vector2.LEFT.rotated(deg_to_rad(61)), &"shot", squad), 1.0)
	arena.hit_dir = Vector2.LEFT
	arena.damage(gun, 4.0, 0, &"gloria")
	assert_eq(gun.hp, gun.max_hp - 1.0)
	arena.hit_dir = Vector2.RIGHT
	arena.damage(gun, 2.0, 0, &"gloria")
	assert_eq(gun.hp, gun.max_hp - 3.0)
	arena.hit_dir = Vector2.LEFT
	arena.damage(gun, 2.0, 0, &"rocket_launcher", &"blown")
	assert_eq(gun.hp, gun.max_hp - 5.0)


func test_placement_and_legacy_archetypes() -> void:
	var legacy: Array[StringName] = [
		&"patrol_cop", &"riot_cop", &"swat", &"robot_thug", &"robot_gunner", &"contractor"
	]
	assert_eq(squad.pit.roster.archetype(TURRET).placement, &"far")
	for id: StringName in legacy:
		gun.archetype = id
		assert_eq(squad.pit.roster.archetype(id).placement, &"any")
		for degrees: int in range(0, 360, 15):
			var dir: Vector2 = Vector2.from_angle(deg_to_rad(degrees))
			assert_eq(FoeArmor.k(gun, dir, &"shot", squad), 1.0)
	gun.archetype = &"shield_robot"
	assert_eq(FoeArmor.k(gun, -gun.facing, &"shot", squad), 0.2)
	assert_eq(FoeArmor.k(gun, -gun.facing, &"blown", squad), 1.0)


func test_station_weapon_knockback_cannot_displace_the_mount() -> void:
	var opts: ArenaArgs = ArenaArgs.parse(["--enemy-brain=squad", "--foe-mix=sentry_turret"])
	var session: ArenaSession = ArenaSession.open_with_args(Events, Data, 22, null, opts)
	var stage: ArenaStage = session.stage
	var weapons: GunplayHook = GunplayHook.new()
	weapons.link = HitLink.make(stage.arena, HitFeel.shipped(), WeaponTable.shipped())
	stage.hooks.append(weapons)
	var h: Fighter = stage.arena.squad_ai.spawn_member(stage.arena, Vector2(16, 25), TURRET)
	var mount: Vector2 = h.pos
	for tick: int in 600:
		if tick == 599:
			stage.arena.damage(h, h.max_hp * 5.0, 0, &"pistol")
			stage.arena.struck.emit(h, Vector2.RIGHT, true, &"pistol")
		elif tick % 30 == 0:
			stage.arena.struck.emit(h, Vector2.RIGHT, false, &"pistol")
		session.step()
		assert_eq(h.pos, mount)
	assert_false(h.alive())
	assert_gte(weapons.link.hits, 21)
	session.close()


func test_losing_the_fire_slot_cancels_the_aim_line() -> void:
	var mind: SquadMind = _step()
	for i: int in 90:
		if mind.turret.phase == PHASE.TELL:
			break
		mind = _step()
	assert_eq(mind.turret.phase, PHASE.TELL)
	mind.agent.token = false
	assert_null(mind.turret.step(mind.agent, gun, arena))
	assert_eq(mind.turret.phase, PHASE.IDLE)
	assert_eq(mind.agent.state, EnemyAgent.State.ENGAGE)
	assert_eq(gun.tell_left, 0)
