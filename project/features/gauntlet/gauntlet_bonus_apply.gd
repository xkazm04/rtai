class_name GauntletBonusApply
extends RefCounted
## Each stage owns its CombatTuning. Capture its starting values before the first grant.

var _stage: ArenaStage
var _run: GauntletRun
var _arsenal: ArenaArsenal = ArenaArsenal.new()
var _hp: float
var _walk: float
var _repair: float


func _init(stage: ArenaStage, ctx: WorldContext, run: GauntletRun) -> void:
	_stage = stage
	_run = run
	var arena: CombatArena = stage.arena
	_hp = arena.rivet.max_hp
	_walk = arena.tuning.rivet["walk_mps"]
	_repair = arena.tuning.rivet["repair_per_s"]
	_arsenal.setup(stage, ctx)


func owned() -> Array[StringName]:
	var ids: Array[StringName] = [_stage.arena.rivet.weapon]
	if _stage.pilot.carry != null:
		ids.append_array(_stage.pilot.carry.slots)
	var forms: GhostForms = _stage.pilot.ghosts.forms
	for id: StringName in forms.table.order:
		if forms.locks.allows(forms.table, id):
			ids.append(id)
			if forms.bond.ready(id):
				ids.append(StringName("master_" + String(id)))
	return ids


func apply(row: Dictionary) -> bool:
	var ref: StringName = row["ref"]
	match str(row["kind"]):
		"mastery":
			return _stage.pilot.ghosts.forms.bond.master(ref)
		"effect":
			return MoveBonus.apply(_stage, row)
		"weapon":
			return _weapon(ref)
		"ghost":
			var forms: GhostForms = _stage.pilot.ghosts.forms
			var form: GhostFormDef = forms.table.form(ref)
			if form == null:
				return false
			if not forms.locks.done.has(form.unlock):
				forms.locks.done.append(form.unlock)
			if not forms.locks.allows(forms.table, forms.selected):
				forms.selected = ref
		"stat":
			var k: float = row["k"]
			_run.mods.add(ref, k)
			_stats()
		_:
			return false
	return true


func _weapon(ref: StringName) -> bool:
	# Wheel controls can create the carry before the first weapon grant.
	var carry: RivetCarry = _stage.pilot.carry
	if carry == null:
		return _arsenal.arm([ref], _run.profile != &"human") != null
	var slot: int = carry.add(ref)
	if slot < 0:
		return false
	carry.tap = _run.profile != &"human"
	carry.select(slot, _stage.arena)
	return true


func _stats() -> void:
	var arena: CombatArena = _stage.arena
	var rivet: Fighter = arena.rivet
	var max_hp: float = _hp * _run.mods.value(&"hp_max")
	rivet.hp = minf(max_hp, rivet.hp + max_hp - rivet.max_hp)
	rivet.max_hp = max_hp
	arena.tuning.rivet["walk_mps"] = _walk * _run.mods.value(&"speed")
	arena.tuning.rivet["repair_per_s"] = _repair * _run.mods.value(&"regen")
	if _stage.pilot.guard != null:
		_stage.pilot.guard.meter_k = _run.mods.value(&"guard_meter")
