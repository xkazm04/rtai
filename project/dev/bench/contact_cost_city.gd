class_name ContactCostCity
extends Node
## Freeze the bench riot on a single tick. The separate reference world runs the same inputs.
## Capture the actual shadow node before and after the shipping bake, including its item print.

const SEED: int = 777
const TICKS: int = 90

var city: CitySystem
var reference: CitySystem
var view := CityView.new()
var bounds: Rect2
var snapshot_hash: String
var _world := World.new()
var _people: CityCharacters
var _shadow: MultiMeshInstance2D
var _meshes: Array[Mesh] = []
var _textures: Array[Texture2D] = []
var _materials: Array[Material] = []
var _hips: Vector2
var _clips: PackedInt32Array
var _rids: Array[RID]


func prepare() -> bool:
	city = _riot(_world, true)
	if city.sim.backend_name() != &"native":
		return false
	view.zoom = 1.0
	add_child(view)
	view.setup(city)
	_shadow = view.crowd.nodes[SimConst.RL_PED_SHADOWS]
	_capture_shadow()
	_people = CityCharacters.new(city, view, _world.context())
	await _people.bake()
	if not _people.rigs.atlas.baked or _shadow.multimesh.mesh == _meshes[0]:
		return false
	_capture_shadow()
	await view.prewarm()
	for tick: int in TICKS:
		_world.loop().step()
		await get_tree().process_frame
	# Let the view pose the final tick and finish streaming before disabling its automatic write.
	for frame: int in 90:
		await get_tree().process_frame
	view.set_process(false)
	var half: Vector2 = view.get_viewport_rect().size * 0.5 / SimConst.PX_PER_M
	half += Vector2.ONE * CityView.VIEW_MARGIN_M
	half.y /= ViewMode.shared().ground_k()
	bounds = Rect2(city.focus - half, half * 2.0)
	_rids = view.crowd.rids()
	_clips = CrowdAtlas.clip_table()
	_hips = Vector2(
		CityCrowdContact.standing_hip(BodyPlan.Kind.PED),
		CityCrowdContact.standing_hip(BodyPlan.Kind.COP)
	)
	return _prepare_reference() and city.sim.heat_level() == 3 and city.source.failures.is_empty()


func switch(writer: CitySimBackend, contact: bool) -> void:
	var index: int = int(contact)
	_shadow.multimesh.mesh = _meshes[index]
	_shadow.texture = _textures[index]
	_shadow.material = _materials[index]
	writer.set_render(_rids, _clips, _hips if contact else Vector2.ZERO)


func _capture_shadow() -> void:
	_meshes.append(_shadow.multimesh.mesh)
	_textures.append(_shadow.texture)
	_materials.append(_shadow.material)


func _riot(world: World, native: bool) -> CitySystem:
	var bus := EventBus.new()
	world.add_child(bus)
	world.start(bus, Data, SEED)
	add_child(world)
	world.set_process(false)
	var system := CitySystem.new(native)
	world.add_system(system)
	var driver := BenchDriver.new(system, "riot")
	world.add_system(driver)
	driver.mount_heat(world, 3)
	return system


func _prepare_reference() -> bool:
	var world := World.new()
	reference = _riot(world, false)
	for tick: int in TICKS:
		world.loop().step()
	var snapshot: PackedFloat64Array = city.sim.snapshot()
	if (
		snapshot != reference.sim.snapshot()
		or city.sim.get_variants() != reference.sim.get_variants()
	):
		return false
	snapshot_hash = _world.loop().state_hash()
	var rigs: CharacterRigs = _people.rigs
	var slots: PackedInt32Array = rigs.rest.ids().duplicate()
	for row: int in rigs.feed.count:
		if rigs.full_row(row) and rigs.feed.ids[row] != CityCharacters.RIVET_ID:
			@warning_ignore("return_value_discarded")
			slots.append(rigs.feed.ids[row])
	reference.sim.set_rig_slots(slots)
	reference.sim.set_person_px(CrowdAtlas.cell_world_px())
	return reference.sim.heat_level() == 3 and reference.source.failures.is_empty()
