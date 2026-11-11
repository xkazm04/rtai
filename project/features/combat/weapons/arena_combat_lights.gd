class_name ArenaCombatLights
extends Node
## n12 E1 (light from combat): the arena's and the city block fight's shots and blasts light the
## street like the city riot's already do (FxSystem kinds -> LightLayer): a new round within
## `radius_m` of the focus starts the `muzzle_flash` light (a 4-tick paper fan) at its muzzle along
## its flight, a new blast the `explosion` light (paper core, vermilion rim, 36 ticks). Into the
## stage's LightLayer: its pool cap (lights.json max_lights) and its eviction of the oldest timed
## light hold; nothing is allocated per shot. Each start spends from the shared photosensitivity
## budget (FlashBudget.spend_light: a kill beat always still fits). Off under reduced motion,
## `--feel=off` or lights.json combat_lights.on false (the before). Render only: it reads the
## arena on its own tick and writes nothing back.

const TABLE: String = "res://data/tables/lights.json"

var arena: CombatArena = null
var lights: LightLayer = null
## The view's focus (world px) and whether reduced motion is on, set by the host each frame.
var focus_px: Vector2 = Vector2.ZERO
var reduced_motion: bool = false
var budget: FlashBudget = FlashBudget.new()
var on: bool = false
var muzzle: bool = true
var blast: bool = true
var radius_px: float = 0.0
var started: int = 0
var refused: int = 0
var _seen: Dictionary[int, bool] = {}
var _blast_tick: int = -1
var _last_tick: int = -1


static func make(p_arena: CombatArena, p_lights: LightLayer) -> ArenaCombatLights:
	var c: ArenaCombatLights = ArenaCombatLights.new()
	c.arena = p_arena
	c.lights = p_lights
	c.read(TABLE)
	return c


## Made and added under `parent` for `arena`, lighting into `p_lights`; reduced motion from `rig`.
## n15: a clockless `stage` (the dev arena's) steps its lights on the arena's tick, the tick they
## are added on, so they age out (PrintStage.light_tick).
static func attach(
	parent: Node,
	p_arena: CombatArena,
	p_lights: LightLayer,
	rig: CameraRig,
	stage: PrintStage = null
) -> void:
	if stage != null and stage.clock == null:
		stage.light_tick = func() -> int: return p_arena.tick
	var c: ArenaCombatLights = make(p_arena, p_lights)
	c.reduced_motion = rig != null and rig.reduced_motion
	parent.add_child(c)


## combat_lights from the lights table (absent = off).
func read(path: String) -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var row: Dictionary = d.get("combat_lights", {})
	on = row.get("on", false) == true and HitFeel.feel_flag() != "off"
	muzzle = row.get("muzzle", true) == true
	blast = row.get("blast", true) == true
	var r: float = row.get("radius_m", 0.0)
	radius_px = r * SimConst.PX_PER_M


func _process(_delta: float) -> void:
	if arena == null or lights == null:
		return
	if arena.tick != _last_tick:
		budget.step_ticks(maxi(1, arena.tick - _last_tick) if _last_tick >= 0 else 1)
		_last_tick = arena.tick
		if arena.rivet != null:
			focus_px = arena.rivet.pos * SimConst.PX_PER_M
		step(arena.tick)


## One sim tick: new rounds and new blasts start their lights.
func step(tick: int) -> void:
	var live: Dictionary[int, bool] = {}
	for s: Shot in arena.shots:
		var id: int = s.get_instance_id()
		live[id] = true
		if not _seen.has(id) and muzzle:
			_light(&"muzzle_flash", s.pos * SimConst.PX_PER_M, s.vel.angle(), tick)
	_seen = live
	var areas: FightAreas = arena.areas
	if areas == null:
		return
	var newest: int = _blast_tick
	for i: int in mini(areas.blasts.size(), areas.blast_ticks.size()):
		var bt: int = areas.blast_ticks[i]
		if bt > _blast_tick and blast:  # the list is pruned from the front: go by its ticks
			var b: Vector3 = areas.blasts[i]
			_light(&"explosion", Vector2(b.x, b.y) * SimConst.PX_PER_M, 0.0, tick)
		newest = maxi(newest, bt)
	_blast_tick = newest


func _light(kind: StringName, at_px: Vector2, angle: float, tick: int) -> void:
	if not on or reduced_motion:
		return
	if radius_px > 0.0 and at_px.distance_to(focus_px) > radius_px:
		return
	if not budget.spend_light():
		refused += 1
		return
	@warning_ignore("return_value_discarded")
	lights.add(kind, at_px, angle, tick)
	started += 1
