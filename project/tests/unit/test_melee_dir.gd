extends GutTest
## n7-melee: a melee kill carries the blow's own line (Rivet -> victim), not the line of the last
## round flown (CombatArena.hit_dir was only ever set by rounds and the ghosts), so a signature cut
## throws its halves along the swing. Planted: PlayerMelee.sets_dir false keeps the stale line.

var _stage: CollectCallStage
var _pilot: StagePilot
var _dirs: Array[Vector2] = []


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(bus, data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_dirs.clear()
	assert_eq(_stage.arena.kill_landed.connect(_on_kill), OK)


func after_each() -> void:
	PlayerMelee.sets_dir = true


func _on_kill(_v: Fighter, _w: StringName, dir: Vector2, _at: Vector2, _k: StringName) -> void:
	_dirs.append(dir)


## A one-hit cop straight ahead (Rivet faces +y), a stale round's line across the arena, a mash.
func _kill_ahead() -> void:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + Vector2.DOWN * 1.0
	g.hp = 0.5
	_stage.arena.hit_dir = Vector2.UP  # a cop's round flying back at Rivet
	var melee: int = 1 << _pilot.actions.bit(&"melee")
	for t: int in 40:
		_pilot.drive(_stage, TickInput.new(melee if t % 4 == 0 else 0, 0, 0))
		_stage.intent.clear()


func test_a_melee_kill_carries_the_blow_line() -> void:
	_kill_ahead()
	assert_eq(_dirs.size(), 1, "the claw killed the cop")
	if _dirs.size() == 1:
		assert_almost_eq(_dirs[0].dot(Vector2.DOWN), 1.0, 0.01, "from Rivet to the cop")


func test_planted_stale_line_is_caught_by_the_check() -> void:
	PlayerMelee.sets_dir = false
	_kill_ahead()
	assert_eq(_dirs.size(), 1)
	if _dirs.size() == 1:
		assert_lt(_dirs[0].dot(Vector2.DOWN), 0.0, "the before keeps the stale round's line")
