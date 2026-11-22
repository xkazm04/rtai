extends GutTest
## A tap supplies one tick of sideways input after 15 stationary ticks. All subsequent
## movement is the committed dash and its ordinary braking. Every hit uses production damage.

const REACTION: int = 15

var arena: CombatArena
var squad: ArenaSquad
var actions: PlayerActions
var motion: PlayerMotion
var impact: Vector2
var radius: float
var elapsed: int


func _reset() -> void:
	arena = CombatArena.new(CombatTuning.shipped(), Events, RngRegistry.new(24).stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-40, -40, 80, 80), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	actions = PlayerActions.shipped()
	motion = PlayerMotion.shipped()
	impact = Vector2.INF
	radius = 0.0
	elapsed = 0
	@warning_ignore("return_value_discarded")
	squad.rockets.burst.connect(_landed)


func _landed(at: Vector2, splash_m: float, _shot: Shot) -> void:
	impact = at
	radius = splash_m


func _dodge(dodge: bool) -> void:
	var tap: bool = dodge and elapsed == REACTION
	var raw: TickInput = (
		TickInput.new(1 << actions.bit(&"dash"), 0, -127) if tap else TickInput.new()
	)
	var cmd: PlayerCommand = PlayerCommand.decode(raw, 0, actions)
	arena.rivet.pos += motion.step(cmd, arena.tuning.rivet["walk_mps"], actions)
	arena.rivet.exposed = not motion.invulnerable()
	assert_true(arena.rivet.exposed)
	elapsed += 1


func test_rocket_from_five_eight_and_twelve_metres() -> void:
	for gap: float in [5.0, 8.0, 12.0]:
		for dodge: bool in [false, true]:
			_reset()
			var h: Fighter = squad.spawn_member(arena, Vector2.RIGHT * gap, &"rocket_trooper")
			h.pos = Vector2.RIGHT * gap
			h.facing = Vector2.LEFT
			var w: EnemyWeapon = squad.pit.roster.archetype(h.archetype).weapon
			arena.shots.append(squad.rockets.launch(h, w, arena.rivet.pos, arena.guard_map))
			while not impact.is_finite() and elapsed < 150:
				_dodge(dodge)
				arena.tick = elapsed
				ArenaProjectiles.step_shots(arena)
			_check("rocket", gap, dodge, arena.rivet.radius_m)


func test_stomp_from_tell_at_three_distances_inside_reach() -> void:
	for gap: float in [1.8, 2.5, 3.5]:
		for dodge: bool in [false, true]:
			_reset()
			var h: Fighter = squad.spawn_member(arena, Vector2.RIGHT * gap, &"war_machine")
			h.pos = Vector2.RIGHT * gap
			h.facing = Vector2.LEFT
			h.cooldown = 0
			for i: int in 90:
				arena.step(i)
				if h.swing_left > 0:
					break
			assert_gt(h.swing_left, 0, "the reaction clock begins at the stomp tell")
			while not impact.is_finite() and elapsed < 100:
				_dodge(dodge)
				arena.step(arena.tick + 1)
			_check("stomp", gap, dodge, 0.0)


func _check(weapon: String, gap: float, dodge: bool, body_margin: float) -> void:
	assert_true(impact.is_finite())
	assert_gt(radius, 0.0)
	var clearance: float = arena.rivet.pos.distance_to(impact) - radius - body_margin
	var lost: float = arena.rivet.max_hp - arena.rivet.hp
	assert_eq(motion.dashes, int(dodge))
	assert_eq(lost == 0.0, dodge)
	assert_eq(clearance > 0.0, dodge)
	Log.info(
		"dash_probe",
		(
			"%s %.1fm dash=%s impact=%d clearance=%.3fm damage=%.2f"
			% [weapon, gap, dodge, elapsed, clearance, lost]
		)
	)


func test_a_bullet_that_intersects_the_burst_still_hits() -> void:
	_reset()
	elapsed = REACTION
	_dodge(true)
	assert_eq(motion.phase, PlayerMotion.Phase.DASH)
	var h: Fighter = Fighter.make(Fighter.Kind.GUARD, 91, arena.rivet.pos + Vector2.LEFT, 1.0)
	h.facing = Vector2.RIGHT
	var bullet: Shot = FoeAttacks.round_from(h, squad.pit.roster.archetype(&"patrol_cop").weapon)
	arena.shots.append(bullet)
	for i: int in 3:
		ArenaProjectiles.step_shots(arena)
	assert_lt(arena.rivet.hp, arena.rivet.max_hp)


func test_pistol_can_fire_and_an_existing_reload_advances_through_dash() -> void:
	for reload_first: bool in [false, true]:
		var stage: ArenaStage = VaultTrial.stage_for(false, null, false)
		var pilot: StagePilot = stage.pilot
		stage.arena.rivet.pos = Vector2(-20, -20)
		stage.arena.rivet.weapon = &"pistol"
		stage.guns = StageGuns.make(RngRegistry.new(24).stream(&"gunplay"))
		stage.guns.sync(stage.arena)
		pilot.hold.held = &"pistol"
		pilot.hold.state = WeaponHold.State.READY
		var trigger: Trigger = stage.arena.gun.trigger
		if reload_first:
			trigger.ammo -= 1
			trigger.start_reload()
		var start: int = trigger.reload_left
		var bits: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions)
		bits |= (1 << pilot.actions.bit(&"fire")) | (1 << pilot.actions.bit(&"dash"))
		stage.step(1, TickInput.new(bits, 0, -127))
		assert_eq(pilot.motion.phase, PlayerMotion.Phase.DASH)
		assert_eq(stage.shots_fired, 0 if reload_first else 1)
		if reload_first:
			assert_eq(trigger.reload_left, start - 1)
			for i: int in range(1, start):
				stage.step(i + 1, TickInput.new())
			assert_eq(trigger.ammo, trigger.spec.magazine)


func test_dash_advances_the_existing_melee_swing() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false, null, false)
	var pilot: StagePilot = stage.pilot
	stage.arena.rivet.pos = Vector2(-20, -20)
	stage.step(1, TickInput.new(1 << pilot.actions.bit(&"melee")))
	var combo: MeleeCombo = pilot.melee.combo
	assert_true(pilot.melee.busy())
	var swing_tick: int = combo.tick_in
	stage.step(2, TickInput.new(1 << pilot.actions.bit(&"dash"), 127, 0))
	assert_eq(pilot.motion.phase, PlayerMotion.Phase.DASH)
	assert_eq(combo.tick_in, swing_tick + 1)
	assert_eq(combo.starts, 1)
