extends GutTest
## SIM-02: one seeded stream per system, isolated, stable across runs and engine versions.


func test_same_seed_same_sequence() -> void:
	var a: RandomNumberGenerator = RngRegistry.new(5).stream(&"ai")
	var b: RandomNumberGenerator = RngRegistry.new(5).stream(&"ai")
	for i: int in 100:
		assert_eq(a.randi(), b.randi())


func test_streams_are_isolated() -> void:
	var quiet: RngRegistry = RngRegistry.new(5)
	var busy: RngRegistry = RngRegistry.new(5)
	var drawn: int = 0
	for i: int in 1000:
		drawn += busy.stream(&"spawns").randi() & 1
	assert_gt(drawn, 0)
	assert_eq(busy.stream(&"ai").randi(), quiet.stream(&"ai").randi(), "spawn draws left ai alone")


func test_names_and_seeds_differ() -> void:
	var reg: RngRegistry = RngRegistry.new(5)
	assert_ne(reg.stream(&"ai").randi(), reg.stream(&"spawns").randi())
	assert_ne(RngRegistry.seed_for(5, &"ai"), RngRegistry.seed_for(6, &"ai"))
	assert_same(reg.stream(&"ai"), reg.stream(&"ai"), "one stream per name")


## Golden values: a change here silently breaks every recorded replay and seed.
func test_seed_derivation_is_pinned() -> void:
	assert_eq(RngRegistry.fnv1a32("ai"), 0x4424F79F)
	assert_eq(RngRegistry.seed_for(1, &"ai"), (1 << 32) | 0x4424F79F)
	assert_eq(RngRegistry.new(0x1_0000_0001).master_seed(), 1, "master seed is 32-bit")


func test_state_lists_streams_in_name_order() -> void:
	var reg: RngRegistry = RngRegistry.new(5)
	assert_not_null(reg.stream(&"b"))
	assert_not_null(reg.stream(&"a"))
	assert_eq(reg.names(), [&"a", &"b"] as Array[StringName])
