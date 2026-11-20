class_name DentJabOrder
extends Node
## Only the punching body and the rigs named by this jab's damage signals cross the car band.
## RigDepthSort assigns the ordinary tilt order at priority 100, including fresh corpses.

var mark: DentJabMark
var _body: CanvasItem
var _view: GhostFormView
var _victims: Array[int] = []
var _swung: int = -1
var _saved: Dictionary[int, Vector2i] = {}


func bind(body: CanvasItem, view: GhostFormView, impact: DentJabMark) -> void:
	mark = impact
	body.add_child(mark)
	_body = body
	_view = view
	process_priority = 101
	set_process(false)
	@warning_ignore("return_value_discarded")
	view.arena.kill_landed.connect(_kill)
	@warning_ignore("return_value_discarded")
	view.arena.wounded.connect(_hit)


func _kill(f: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName) -> void:
	_hit(f, weapon)


func _hit(f: Fighter, weapon: StringName) -> void:
	if weapon != DentJab.WEAPON:
		return
	var swing: int = _view.pilot.ghosts.jab.swings
	if swing != _swung:
		_victims.clear()
		_swung = swing
	_victims.append(f.id)


func strike(jab: DentJab, fist: Vector2, facing: float) -> void:
	mark.place(jab.steps - jab.swung_step, _swung == jab.swings, fist, facing)


func sync(shown: bool) -> void:
	if not shown:
		mark.hide()
	var active: bool = (
		shown and ViewMode.shared().cards and GhostActs.jabbing(_view.pilot.ghosts.jab)
	)
	if not active and is_processing():
		_restore()
		_victims.clear()
	set_process(active)


func _process(_delta: float) -> void:
	_restore()
	_raise(_body)
	if _view.rigs != null:
		for id: int in _victims:
			var rig: CutRig = _view.rigs.rig_for(id)
			if rig != null and rig.is_visible_in_tree():
				_raise(rig)


func _raise(item: CanvasItem) -> void:
	var before: int = item.z_index
	var over: int = RenderLayers.z(&"vehicles") + 1 - GhostRim.KEY_Z
	var band_shift: int = over - RenderLayers.z(&"actors")
	item.z_index += maxi(band_shift, over - RigDepthSort.eff_z(item))
	_saved[item.get_instance_id()] = Vector2i(before, item.z_index)


func _restore() -> void:
	for id: int in _saved:
		var item: CanvasItem = instance_from_id(id) as CanvasItem
		var change: Vector2i = _saved[id]
		if item != null and item.z_index == change.y:
			item.z_index = change.x
	_saved.clear()


func _exit_tree() -> void:
	_restore()
