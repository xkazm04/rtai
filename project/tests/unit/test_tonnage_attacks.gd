extends GutTest
## Lane ghost-powers: Tonnage's attacks (ghost_attacks.json `tonnage`) on quest 1's stage through
## the bound pilot: the plates take armor_k of a hit while the form is on (and only then), the
## press slam lands ahead of the facing, a kill inside crush_m is the flattening kill (weapon
## stomp) and one farther out in the shockwave is the thrown standard death (stomp_wave).

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot
var _kills: Dictionary[int, StringName] = {}


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_stage.arena.rivet.facing = Vector2.RIGHT
	_kills.clear()
	@warning_ignore("return_value_discarded")
	_stage.arena.kill_landed.connect(_on_kill)


func _on_kill(v: Fighter, weapon: StringName, _d: Vector2, _a: Vector2, _k: StringName) -> void:
	_kills[v.id] = weapon


func _press(action: StringName) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	buttons |= PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	_pilot.drive(_stage, TickInput.new(buttons, 0, 0))
	_stage.intent.clear()


func _guard(off: Vector2) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	return g


func test_the_plates_take_armor_k_only_while_the_form_is_on() -> void:
	var rivet: Fighter = _stage.arena.rivet
	var k: float = _pilot.hauler.attacks.num(&"tonnage", &"armor_k")
	assert_almost_eq(k, 0.3, 0.001, "the shipped armour")
	_press(&"")
	_stage.arena.damage(rivet, 10.0, 7, &"pistol")
	assert_almost_eq(rivet.hp, rivet.max_hp - 10.0, 0.001, "base Rivet takes the full hit")
	_press(&"power_hauler")
	var before: float = rivet.hp
	_stage.arena.damage(rivet, 10.0, 7, &"pistol")
	assert_almost_eq(rivet.hp, before - 10.0 * k, 0.001, "Tonnage takes armor_k of it")


func test_the_slam_flattens_inside_crush_m_and_throws_the_ring() -> void:
	var near: Fighter = _guard(Vector2(1.6, 0.0))  # 0.7 m from the press head (0.9 ahead)
	var ring: Fighter = _guard(Vector2(-2.4, 0.0))  # 3.3 m behind the press head
	_press(&"power_hauler")
	_press(&"melee")
	for i: int in 40:
		_press(&"")
	assert_eq(_pilot.hauler.form.stomps, 1)
	var near_by: StringName = _kills.get(near.id, &"")
	var ring_by: StringName = _kills.get(ring.id, &"")
	assert_eq(near_by, &"stomp", "flattened under the press head")
	assert_eq(ring_by, &"stomp_wave", "thrown by the shockwave")
	assert_eq(_pilot.hauler.stomp_at, Vector2(200.9, 200.0), "the slam lands press_ahead_m ahead")
