extends GutTest
## The data-driven FX (core/render/fx_system.gd): every kind loads in palette inks, particles
## live on the sim tick, both budgets (per frame, per pool) drop and count, and the FX sheet
## cells swap in only when the sheet is present.

## Any imported texture stands in for the sheet here (the loader only checks it exists).
const SHEET: String = "res://features/city/art/props/traffic_light.png"
const ROW: Dictionary = {
	"atlas": {"cells": [8, 8], "count": 1, "mode": "anim"},
	"count": 10,
	"doc": "t",
	"drag": 0,
	"grow": 0,
	"id": "boom",
	"life_ticks": 30,
	"light": "",
	"shape": "disc",
	"size_m": 1,
	"speed_mps": 0,
	"spread_deg": 360,
	"token": "paper",
}


func test_every_kind_loads_on_the_fx_band_in_a_palette_ink() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	for k: StringName in [
		&"muzzle",
		&"tracer",
		&"impact",
		&"explosion",
		&"smoke",
		&"debris",
		&"ink_splat",
		&"crackle",
		&"casing",
		&"spark"
	]:
		assert_true(fx.kinds.has(k), String(k))
		var c: Color = fx.kinds[k]["color"]
		assert_ne(c, Color.MAGENTA, "%s token" % k)
		assert_ne(PaletteTokens.shared().classify(c), 2, "%s is not teal (the dead only)" % k)
	assert_eq(fx.z_index, RenderLayers.z(&"fx"))


func test_particles_expire_on_the_tick() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	assert_true(fx.spawn(&"impact", Vector2.ZERO, 0.0, 10))
	var count: int = fx.kinds[&"impact"]["count"]
	var life: int = fx.kinds[&"impact"]["life_ticks"]
	fx.step(10)
	assert_eq(fx.alive(), count)
	fx.step(10 + life)
	assert_eq(fx.alive(), 0)


func test_the_frame_budget_drops_and_counts() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	for i: int in fx.max_spawns_per_frame:
		assert_true(fx.spawn(&"muzzle", Vector2(i, 0), 0.0, 0))
	assert_false(fx.spawn(&"muzzle", Vector2.ZERO, 0.0, 0))
	assert_eq(fx.dropped, 1)
	fx.step(1)
	assert_true(fx.spawn(&"muzzle", Vector2.ZERO, 0.0, 1), "the budget resets each frame")


func test_spawns_are_the_same_every_run() -> void:
	var a: FxSystem = autofree(FxSystem.new())
	var b: FxSystem = autofree(FxSystem.new())
	for fx: FxSystem in [a, b]:
		@warning_ignore("return_value_discarded")
		fx.spawn(&"debris", Vector2(5, 5), 1.0, 0)
		fx.step(0)
		fx.step(3)
	assert_eq(a._pool.pos, b._pool.pos)


func test_sheet_cells_pick_by_seed_and_animate_by_age() -> void:
	assert_eq(FxPool.cell({}, 5, 0.5), 0.0, "no sheet: the analytic shape")
	var pick: Dictionary = {"cell0": 4.0, "cell_n": 2.0, "anim": false, "life_ticks": 10.0}
	assert_eq(FxPool.cell(pick, 0, 0.0), 5.0)
	assert_eq(FxPool.cell(pick, 9, 0.99), 6.0)
	var paced: Dictionary = {
		"cell0": 24.0, "cell_n": 4.0, "anim": true, "frame_ticks": 3.0, "life_ticks": 240.0
	}
	assert_eq(FxPool.cell(paced, 0, 0.3), 25.0)
	assert_eq(FxPool.cell(paced, 3, 0.3), 26.0)
	assert_eq(FxPool.cell(paced, 200, 0.3), 28.0, "holds the last frame")
	var spread: Dictionary = {"cell0": 8.0, "cell_n": 8.0, "anim": true, "life_ticks": 32.0}
	assert_eq(FxPool.cell(spread, 4, 0.0), 10.0)
	assert_eq(FxPool.cell(spread, 31, 0.0), 16.0)


func test_a_present_sheet_overrides_the_row() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	var table: Dictionary = {
		"atlas": {"cols": 8, "doc": "t", "path": SHEET, "rows": 4},
		"kinds": [ROW],
		"max_particles": 8,
		"max_spawns_per_frame": 2,
		"schema": "gtai.fx/1",
	}
	fx.kinds.clear()
	assert_eq(fx._load(JSON.stringify(table)), 8)
	assert_true(fx.atlas_live)
	var k: Dictionary = fx.kinds[&"boom"]
	var count: float = k["count"]
	var cell0: float = k["cell0"]
	assert_eq(count, 1.0, "the atlas block wins")
	assert_eq(cell0, 8.0)
	var anim: bool = k["anim"]
	assert_true(anim)


func test_a_missing_sheet_keeps_the_placeholder_row() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	var table: Dictionary = {
		"atlas": {"cols": 8, "doc": "t", "path": "res://no/such_sheet.png", "rows": 4},
		"kinds": [ROW],
		"max_particles": 8,
		"max_spawns_per_frame": 2,
		"schema": "gtai.fx/1",
	}
	fx.atlas_live = false
	fx.kinds.clear()
	@warning_ignore("return_value_discarded")
	fx._load(JSON.stringify(table))
	assert_false(fx.atlas_live)
	var count: float = fx.kinds[&"boom"]["count"]
	assert_eq(count, 10.0)
	assert_false(fx.kinds[&"boom"].has("cell0"))


func test_emissive_kinds_go_to_the_glow_twin() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	fx.glow = autofree(FxSystem.new())
	assert_true(fx.spawn(&"explosion", Vector2.ZERO, 0.0, 0))
	assert_true(fx.spawn(&"smoke", Vector2.ZERO, 0.0, 0))
	fx.step(0)
	fx.glow.step(0)
	var smoke: float = fx.kinds[&"smoke"]["count"]
	var blast: float = fx.kinds[&"explosion"]["count"]
	assert_eq(fx.alive(), int(smoke), "smoke is lit: it stays under the lights")
	assert_eq(fx.glow.alive(), int(blast), "the blast draws above the lights")


func test_every_sheet_block_stays_inside_the_grid() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FxSystem.TABLE))
	var grid: Dictionary = d["atlas"]
	var cols: float = grid["cols"]
	var rows: float = grid["rows"]
	for row: Dictionary in d["kinds"]:
		if not row.has("atlas"):
			continue
		var a: Dictionary = row["atlas"]
		var cells: Array = a["cells"]
		var first: float = cells[0]
		var n: float = cells[1]
		var kid: String = row["id"]
		assert_gt(n, 0.0, kid)
		assert_lte(first + n, cols * rows, "%s cells inside the %dx%d sheet" % [kid, cols, rows])


func test_ground_kinds_go_to_the_ground_twin() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	fx.ground = autofree(FxSystem.new())
	assert_true(fx.spawn(&"ink_splat", Vector2.ZERO, 0.0, 0))
	assert_true(fx.spawn(&"impact", Vector2.ZERO, 0.0, 0))
	fx.step(0)
	fx.ground.step(0)
	var splat: int = fx.kinds[&"ink_splat"]["count"]
	var chips: int = fx.kinds[&"impact"]["count"]
	assert_eq(fx.ground.alive(), splat)
	assert_eq(fx.alive(), chips)


func test_a_frame_without_a_tick_or_spawn_skips_and_a_spawn_still_draws() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	var count: int = fx.kinds[&"impact"]["count"]
	assert_true(fx.spawn(&"impact", Vector2.ZERO, 0.0, 5))
	fx.step(5)
	fx.step(5)
	assert_eq(fx.last_us, 0, "no tick, no spawn: nothing rewritten")
	assert_true(fx.spawn(&"impact", Vector2.ONE, 0.0, 5))
	fx.step(5)
	assert_eq(fx.alive(), count * 2, "a spawn inside the same tick still draws")
