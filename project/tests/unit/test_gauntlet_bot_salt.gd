extends GutTest

const WORLD_SEED: int = 137
const STREAMS: Array[StringName] = [
	&"test_player_aim", &"test_player_defence", &"test_player_forms", &"test_player_pick"
]


func after_each() -> void:
	LaunchArgs.parse()


func _draws(args: PackedStringArray) -> Array[int]:
	LaunchArgs.parse(args)
	var pilot: GauntletTestPlayer = GauntletTestPlayer.new()
	pilot.configure(&"average", &"random", WORLD_SEED)
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var session: ArenaSession = ArenaSession.open_with_args(
		bus, data, WORLD_SEED, pilot, ArenaArgs.new()
	)
	pilot.bind(GauntletRun.new(), session)
	var brain: GauntletBot = pilot._brain
	var draws: Array[int] = [
		brain._aim_rng.randi(),
		brain._defence._rng.randi(),
		brain._forms._rng.randi(),
		pilot._picker._rng.randi()
	]
	session.close()
	bus.free()
	data.free()
	return draws


func test_default_and_zero_draw_from_the_original_streams() -> void:
	var registry: RngRegistry = RngRegistry.new(WORLD_SEED)
	var original: Array[int] = []
	for stream: StringName in STREAMS:
		original.append(registry.stream(stream).randi())
	assert_eq(_draws([]), original)
	assert_eq(_draws(["--bot-salt=0"]), original)


func test_salt_one_resamples_each_private_stream_reproducibly() -> void:
	var original: Array[int] = _draws([])
	var salted: Array[int] = _draws(["--bot-salt=1"])
	for i: int in STREAMS.size():
		assert_ne(salted[i], original[i], String(STREAMS[i]))
	assert_eq(_draws(["--bot-salt=1"]), salted)
