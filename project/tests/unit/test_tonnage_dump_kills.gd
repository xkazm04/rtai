extends GutTest
## n31 ghost 7: a kill by Tonnage's deploy dump plays the press deaths (crush / thrown wave).

var stage: CollectCallStage
var arena: CombatArena
var squad: ArenaSquad
var pilot: StagePilot
var ghost: GhostDeploy
var row: GhostAttacks.DeployRow
var key: int
var kills: Array[Dictionary] = []


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	arena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	row = ghost.strike.attacks.deploy[&"tonnage"]
	pilot.ghosts.forms.selected = &"tonnage"
	key = 1 << pilot.actions.bit(&"ghost_deploy")
	kills.clear()
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(_on_kill)


func _on_kill(
	victim: Fighter, weapon: StringName, _d: Vector2, _a: Vector2, _k: StringName
) -> void:
	kills.append({"victim": victim, "weapon": weapon})


func _spawn(at: Vector2, id: StringName = &"contractor") -> Fighter:
	var foe: Fighter = squad.spawn_member(arena, at, id)
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = 1.0
	foe.hp = 1.0
	return foe


func _drive(bits: int = 0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 18.0)
	pilot.drive(stage, TickInput.new(aim | bits))


## Press, charge, move the foes onto the circle (relative to the drop centre), dump.
func _dump(offsets: Dictionary[Fighter, Vector2]) -> void:
	_drive(key)
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()
	for foe: Fighter in offsets:
		foe.pos = ghost.spot + offsets[foe]
	_drive()


func _weapon_of(foe: Fighter) -> StringName:
	for k: Dictionary in kills:
		if k["victim"] == foe:
			return k["weapon"]
	return &""


func test_a_kill_inside_crush_m_is_a_stomp() -> void:
	var near: Fighter = _spawn(Vector2(30, 0))
	_dump({near: Vector2(1, 0)})
	assert_false(near.alive())
	assert_eq(_weapon_of(near), &"stomp")


func test_a_kill_beyond_crush_m_is_the_stomp_wave() -> void:
	var far: Fighter = _spawn(Vector2(30, 0))
	_dump({far: Vector2(4, 0)})
	assert_false(far.alive())
	assert_eq(_weapon_of(far), &"stomp_wave")


func test_the_crush_ring_is_the_table_value() -> void:
	var crush: float = ghost.strike.attacks.num(&"tonnage", &"crush_m")
	var inside: Fighter = _spawn(Vector2(30, 0))
	var outside: Fighter = _spawn(Vector2(30, 5))
	_dump({inside: Vector2(crush - 0.05, 0), outside: Vector2(crush + 0.05, 0)})
	assert_eq(_weapon_of(inside), &"stomp")
	assert_eq(_weapon_of(outside), &"stomp_wave")


func test_the_dump_still_counts_its_kills_and_cracks_a_walker() -> void:
	var cop: Fighter = _spawn(Vector2(30, 0))
	var walker: Fighter = _spawn(Vector2(30, 5), &"war_machine")
	walker.max_hp = 100.0
	walker.hp = 100.0
	_dump({cop: Vector2(1, 0), walker: Vector2(3, 0)})
	assert_eq(ghost.strike.release_kills, 1)
	assert_true(
		TonnageCrack.is_open(squad.mind_for(walker), squad.moves.tonnage_armour_crack, stage.tick)
	)
