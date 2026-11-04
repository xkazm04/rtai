class_name RigPool
extends Node2D
## Rigs pooled per body plan and prewarmed at load: building a rig (its part tree) cost about
## 16 ms in the city gate, so it never happens in play. A pooled rig stays in the tree, hidden;
## acquire() re-skins it (texture swaps), places it and shows it; release() hides it.
## grown counts rigs built after prewarm: a budget overrun, logged, never a hitch to hide.

static var _plans: Dictionary[int, BodyPlan] = {}

var grown: int = 0
var _free_rivet: Array[CutRig] = []
var _free_cop: Array[CutRig] = []
var _free_ped: Array[CutRig] = []
var _built: Dictionary[int, int] = {}


static func plan_of(kind: BodyPlan.Kind) -> BodyPlan:
	if not _plans.has(kind):
		match kind:
			BodyPlan.Kind.RIVET:
				_plans[kind] = RivetPlan.build()
			BodyPlan.Kind.COP:
				_plans[kind] = HumanPlan.cop()
			_:
				_plans[kind] = HumanPlan.ped()
	return _plans[kind]


## Builds n rigs of a plan up front. Returns the milliseconds it took (evidence for the budget).
func prewarm(kind: BodyPlan.Kind, n: int) -> float:
	var t0: int = Time.get_ticks_usec()
	_preload(plan_of(kind))
	for _i: int in n:
		var rig: CutRig = _build(kind)
		_free_list(kind).append(rig)
	return (Time.get_ticks_usec() - t0) / 1000.0


func acquire(kind: BodyPlan.Kind, look: RigVariant, at: Vector2, facing: float) -> CutRig:
	var free: Array[CutRig] = _free_list(kind)
	var rig: CutRig = null
	if free.is_empty():
		grown += 1
		Log.warn("characters", "rig pool %d grew past prewarm (%d)" % [kind, _built[kind]])
		rig = _build(kind)
	else:
		rig = free.pop_back()
	rig.apply_variant(look)
	rig.global_position = at
	rig.reset_state(facing)
	rig.modulate = Color.WHITE  # CorpseFade left a decayed corpse faded and sunk
	rig.scale = Vector2.ONE * CutRig.SC * rig.plan.size_k
	rig.visible = true
	return rig


func release(rig: CutRig) -> void:
	rig.visible = false
	rig.actor_id = -1
	_free_list(rig.plan.kind).append(rig)


func free_count(kind: BodyPlan.Kind) -> int:
	return _free_list(kind).size()


func built_count(kind: BodyPlan.Kind) -> int:
	return _built.get(kind, 0)


## Loads every cell a plan or its looks can show, so no texture loads from disk in play.
func _preload(p: BodyPlan) -> void:
	var lib: PartLibrary = PartLibrary.of(p.art_dir)
	for part: String in lib.sizes:
		@warning_ignore("return_value_discarded")
		lib.tex(part)


func _build(kind: BodyPlan.Kind) -> CutRig:
	var rig: CutRig = CutRig.new()
	var look: RigVariant = RigVariant.rivet() if kind == BodyPlan.Kind.RIVET else null
	if look == null:
		look = RigVariant.crowd(5 if kind == BodyPlan.Kind.COP else 0)
	add_child(rig)
	rig.setup(plan_of(kind), look)
	rig.visible = false
	_built[kind] = built_count(kind) + 1
	return rig


func _free_list(kind: BodyPlan.Kind) -> Array[CutRig]:
	if kind == BodyPlan.Kind.RIVET:
		return _free_rivet
	return _free_cop if kind == BodyPlan.Kind.COP else _free_ped
