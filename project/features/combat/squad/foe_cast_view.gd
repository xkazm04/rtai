class_name FoeCastView
extends Node2D
## Join the arena's current feed to its post-selection rig pool. Rows absent from the feed were
## consumed, decayed or despawned. Far cast members include the gauntlet's live wave spawns.

const MOUNT: StringName = &"foe_cast_view"
const PUMP: StringName = &"cast_shotgun_pump"

var _rigs: CharacterRigs
var _arena: CombatArena
var _react: ReactLink
var _looks: ArenaSquadLooks = ArenaSquadLooks.new()
var _poses: Dictionary[Fighter, CastCardPose] = {}
var _rows: Dictionary[Fighter, int] = {}
var _far: Dictionary[int, CastFarCard] = {}
var _new_hosts: Array[Fighter] = []
var _launchers: Dictionary[Fighter, bool] = {}


static func attach(host: RigHost, arena: CombatArena) -> FoeCastView:
	var layer: FoeCastView = FoeCastView.new()
	var rigs: CharacterRigs = host.rigs
	host.react = ReactLink.make(arena)
	layer._rigs = rigs
	layer._arena = arena
	layer._react = host.react
	layer.y_sort_enabled = true
	layer.process_priority = rigs.process_priority + 1
	rigs.set_meta(MOUNT, true)
	rigs.add_child(layer)
	@warning_ignore_start("return_value_discarded")
	arena.wounded.connect(layer._wounded)
	arena.kill_landed.connect(layer._killed)
	@warning_ignore_restore("return_value_discarded")
	return layer


static func covers(rigs: CharacterRigs, h: Fighter) -> bool:
	return rigs.has_meta(MOUNT) and CastCards.current(h.archetype) != null


static func draws_launcher(h: Fighter) -> bool:
	return h.archetype == &"rocket_trooper" and h.alive() and CastCards.current(h.archetype) == null


## Called during normal arena feed construction, before the pool poses this tick.
func feed(h: Fighter, i: int) -> void:
	if h.archetype != &"patrol_cop":
		var host: CutRig = _rigs.rig_for(h.id)
		if host == null:
			_new_hosts.append(h)
		else:
			host.set_meta(StreetCopWalk.OTHER_ID, h.id)
	var sheets: CastCards.Sheets = null if h.machine else CastCards.current(h.archetype)
	if sheets == null:
		if _poses.has(h):
			var previous: CutRig = _rigs.rig_for(h.id)
			if previous != null and CastCardPose.of(previous) != null:
				StreetWalkerCards.release(previous)
		_looks.swing(h, _rigs.feed, i)
		if h.archetype == &"rocket_trooper":
			_launchers[h] = true
		return
	_looks.swing(h, _rigs.feed, i)
	var pose: CastCardPose = _pose_for(h)
	pose.sheets = sheets
	pose.travel(h.pos)
	pose.attack = attack_row(h, _arena)
	_rows[h] = i
	var rig: CutRig = _rigs.rig_for(h.id)
	if rig != null:
		if rig.has_meta(&"rocket_kneel"):
			rig.remove_meta(&"rocket_kneel")
			MotionRigPose.place(rig, Transform2D.IDENTITY)
		@warning_ignore("return_value_discarded")
		pose.bind(rig)


## A render-only sample on this fighter, shared by the near and far card.
static func set_pump(h: Fighter, progress: float) -> void:
	if progress >= 0.0:
		h.set_meta(PUMP, progress)
	elif h.has_meta(PUMP):
		h.remove_meta(PUMP)


static func attack_row(h: Fighter, arena: CombatArena) -> int:
	var lock_ticks: int = arena.guard_tell.lock_ticks if arena.guard_tell != null else 0
	var mind: SquadMind = arena.squad_ai.minds.get(h.id) if arena.squad_ai != null else null
	var age: int = arena.tick - mind.agent.shot_tick if mind != null else -1
	if h.archetype == &"sergeant_mulroney":
		if h.has_meta(PUMP):
			var progress: float = h.get_meta(PUMP)
			return 2 if progress < 0.5 else 3
		if age == 0:
			return 1
		return 0 if h.tell_left > 0 else -1
	return CastCardPose.attack_frame(h.tell_left, lock_ticks, age)


func _pose_for(h: Fighter) -> CastCardPose:
	var pose: CastCardPose = _poses.get(h)
	if pose == null:
		pose = CastCardPose.new()
		pose.actor_id = h.id
		_poses[h] = pose
	return pose


func _process(_delta: float) -> void:
	for h: Fighter in _new_hosts:
		var rig: CutRig = _rigs.rig_for(h.id)
		if rig != null:
			rig.set_meta(StreetCopWalk.OTHER_ID, h.id)
			if rig.head_card != null and rig.head_card.has_meta(StreetCopWalk.CONTACT):
				StreetWalkerCards.step(rig)
	_new_hosts.clear()
	for h: Fighter in _launchers:
		if CastCards.current(h.archetype) == null:
			FoeRocketPose._kneel(h, _rigs)
	_launchers.clear()
	for h: Fighter in _poses.keys():
		var id: int = h.id
		if not _rows.has(h):
			@warning_ignore("return_value_discarded")
			_poses.erase(h)
			if _far.has(id):
				_far[id].queue_free()
				@warning_ignore("return_value_discarded")
				_far.erase(id)
			continue
		var rig: CutRig = _rigs.rig_for(id)
		if rig != null:
			if _far.has(id):
				_far[id].hide()
			_near(rig, _poses[h])
		else:
			if not _far.has(id):
				_far[id] = CastFarCard.new()
				add_child(_far[id])
			var moving: bool = _rigs.feed.vel[_rows[h]].length() > StreetWalkerCards.MOVING
			_far[id].draw_pose(_poses[h], h, moving, _arena.tick)
	_rows.clear()


## A newly acquired or half-rate rig can miss the one-tick discharge. Reuse the street card's
## build/place functions when the pool has not yet shown this action or attack row.
func _near(rig: CutRig, pose: CastCardPose) -> void:
	var card: Sprite2D = rig.head_card
	if card == null:
		return
	var fresh: bool = pose.bind(rig)
	var path: String = pose.path_for(rig)
	if not fresh and card.get_meta(StreetWalkerCards.ON, "") == path:
		if path != pose.sheets.attack or card.frame_coords.y == pose.attack:
			return
	RigHeadCard.step(rig)
	StreetWalkerCards.step(rig)


func _wounded(h: Fighter, weapon: StringName) -> void:
	if h.machine or CastCards.current(h.archetype) == null:
		return
	var table: ReactTable = _react.pipe.table
	var cls: StringName = _react.hit_class_of(weapon)
	var wound: StringName = table.reaction_for(
		cls, _arena.hit_dir.rotated(-h.facing.angle()), false, false
	)
	var blow: StringName = StreetHitClass.blow_of(cls, weapon, wound)
	var pose: CastCardPose = _pose_for(h)
	pose.hit_hold = StreetHitClass.HOLD_S.get(blow, StreetWalkerHit.HOLD_S.get(wound, 0.0))


func _killed(h: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, kind: StringName) -> void:
	if h.machine or CastCards.current(h.archetype) == null:
		return
	var cls: StringName = ReactLink.KILL_KIND_CLASS.get(kind, _react.hit_class_of(weapon))
	var family: StringName = _react.pipe.table.death_for(cls)
	var pose: CastCardPose = _pose_for(h)
	pose.opens_on_hit = family in StreetWalkerHit.DEATH_KINDS
	pose.death_length = _react.pipe.table.length(family)
