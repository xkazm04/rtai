extends GutTest
## n7-melee: quest 1's carried blade (RivetCarry.sheathe). Key 2 draws the katana over the story's
## gun, a second press puts it away and Gloria comes back; when the story swaps the weapon (a
## picked-up rifle) the blade counts as put away, so the next press draws it again.
## Control: without sheathe (the arena's carry), a second press keeps the katana drawn.

var _arena: CombatArena
var _actions: PlayerActions
var _previous: int = 0


func before_each() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 1))
	_arena = stage.arena
	_arena.rivet.weapon = &"gloria"
	_actions = PlayerActions.shipped()
	_previous = 0


func _carry(sheathe: bool) -> RivetCarry:
	var rng: RandomNumberGenerator = RngRegistry.new(3).stream(&"quest_blade")
	var carry: RivetCarry = RivetCarry.new(WeaponTable.shipped(), ArsenalTable.shipped(), rng)
	carry.sheathe = sheathe
	assert_eq(carry.add(&"katana"), 1, "the katana rides on key 2")
	return carry


## One tick with key 2 down (`down`), as the pilot decodes it.
func _tick(carry: RivetCarry, down: bool) -> void:
	var bits: int = (1 << _actions.bit(&"weapon_slot_2")) if down else 0
	carry.step(
		PlayerCommand.decode(TickInput.new(bits, 0, 0), _previous, _actions), _actions, _arena
	)
	_previous = bits


func _press(carry: RivetCarry) -> void:
	_tick(carry, true)
	_tick(carry, false)


func test_key_2_draws_the_blade_and_puts_it_away() -> void:
	var carry: RivetCarry = _carry(true)
	_tick(carry, false)
	assert_eq(_arena.rivet.weapon, &"gloria", "nothing drawn before the press")
	_press(carry)
	assert_eq(_arena.rivet.weapon, &"katana")
	assert_null(_arena.gun, "the gun is away while the blade is out")
	_press(carry)
	assert_eq(_arena.rivet.weapon, &"gloria", "the second press gives Gloria back")
	assert_eq(carry.current, -1)


func test_a_story_weapon_puts_the_blade_away() -> void:
	var carry: RivetCarry = _carry(true)
	_press(carry)
	_arena.rivet.weapon = &"assault-rifle"  # he picks up a rifle with the blade out
	_tick(carry, false)
	assert_eq(carry.current, -1, "the rifle took the claw")
	_press(carry)
	assert_eq(_arena.rivet.weapon, &"katana", "key 2 draws the blade again")
	_press(carry)
	assert_eq(_arena.rivet.weapon, &"assault-rifle", "and putting it away gives the rifle back")


func test_planted_no_sheathe_keeps_the_blade_out() -> void:
	var carry: RivetCarry = _carry(false)
	_press(carry)
	_press(carry)
	assert_eq(_arena.rivet.weapon, &"katana", "the arena's carry has no put-away")


func test_quest_blade_flag() -> void:
	assert_eq(Quest1Game.blade_of(""), &"katana")
	assert_eq(Quest1Game.blade_of("off"), &"")
	assert_eq(Quest1Game.blade_of("electro_baton"), &"electro_baton")
