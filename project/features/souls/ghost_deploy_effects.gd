class_name GhostDeployEffects
extends Node2D
## Cache the positions the arena actually hit, before victims move or fall. The view can miss
## a rendered frame without losing a contact and never selects a second set of victims.

const PPM: float = SimConst.PX_PER_M
const CONTACTS: Array[StringName] = [&"deploy_kerf", &"deploy_ohm", &"deploy_dent"]

var stage: CollectCallStage
var calm: bool
var body: GhostDeployBody
var _hit_tick: int = -1
var _hits: PackedVector2Array = []
## n31: Tonnage's drop ground (telegraph, dump, crater); outlives the ghost for the crater.
var _drop: TonnageDropMarks = null
## n31 ghost 12: Ohm's drop ground (creep telegraph, arc ring, scorch); outlives him for the scorch.
var _ohm_drop: OhmDropMarks = null
## n31 ghost 18b: Dent's drop ground (skid telegraph, dust wake, scuffed lane); outlives him.
var _dent_drop: DentDropMarks = null
## Ohm's ground sits under the actors while his bolts stay on the FX band above them.
var _ground: Node2D = Node2D.new()


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wounded)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_killed)
	_ground.z_as_relative = false
	_ground.z_index = RenderLayers.z(&"actors") - 2
	@warning_ignore("return_value_discarded")
	_ground.draw.connect(_draw_ground)
	add_child(_ground)


## Redraw the FX band and the ground layer under the actors.
func redraw() -> void:
	queue_redraw()
	_ground.queue_redraw()


func _wounded(foe: Fighter, weapon: StringName) -> void:
	_contact(weapon, foe.pos)


func _killed(
	foe: Fighter, weapon: StringName, dir: Vector2, at: Vector2, _kind: StringName
) -> void:
	_contact(weapon, at + dir * foe.radius_m)


func _contact(weapon: StringName, at: Vector2) -> void:
	if weapon not in CONTACTS:
		return
	if _hit_tick != stage.tick:
		_hits.clear()
		_hit_tick = stage.tick
	@warning_ignore("return_value_discarded")
	_hits.append(at * PPM)


## True while a landed drop's crater (Tonnage), scorch (Ohm) or scuff (Dent) still shows after
## the ghost has gone.
func lingers() -> bool:
	# A drop cancelled before its dump (Rivet died) leaves no ground.
	var active: bool = stage.pilot.ghosts.deploy.phase == GhostDeploy.Phase.ACTIVE
	if (
		_drop != null
		and (not _drop.live(stage.tick) or stage.tick < _drop.dump_tick and not active)
	):
		_drop = null
	var ohm: OhmDropMarks = _ohm_drop
	if ohm != null and (not ohm.live(stage.tick) or stage.tick < ohm.dump_tick and not active):
		_ohm_drop = null
	var dent: DentDropMarks = _dent_drop
	if dent != null and (not dent.live(stage.tick) or stage.tick < dent.ram_tick and not active):
		_dent_drop = null
	return _drop != null or _ohm_drop != null or _dent_drop != null


func _draw() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	if ghost.phase != GhostDeploy.Phase.ACTIVE:
		if lingers() and _drop != null:
			_drop.draw(self, stage.tick, PPM)
		return
	var release: int = ghost.strike.release_tick
	var age: int = stage.tick - release
	var sec: float = age * SimClock.TICK_DT
	if ghost.form == HaulerStage.GHOST:
		_slam(ghost, sec, release)
		return
	if _hit_tick != release:
		return
	for i: int in _hits.size():
		match ghost.form:
			KerfStage.GHOST:
				var dir: Vector2 = ghost.facing.rotated(deg_to_rad(KerfView.CUT_DEG))
				var k: float = clampf(1.0 - age / 15.0, 0.0, 1.0)
				KerfView.draw_cut(self, _hits[i], dir * PPM, k, 1.0)
			OhmStage.GHOST:
				_bolt(ghost, _hits[i], i, age)
			DentStage.GHOST:
				RamMarks.draw(self, _hits[i], ghost.facing, sec, PPM)


## A drop-mode deploy draws its own ground (TonnageDropMarks: the charge's crack front reaches
## the deploy's radius on the dump tick, the drawn ring is the damage ring); a hold-mode stomp
## keeps HaulerMarks' half-disc ahead.
func _slam(ghost: GhostDeploy, sec: float, release: int) -> void:
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[ghost.form]
	if row.drops():
		if _drop == null or _drop.press_tick != ghost.start_tick:
			var dump: int = ghost.start_tick + row.charge_ticks
			_drop = TonnageDropMarks.new(ghost.spot * PPM, ghost.start_tick, dump, row.radius_m)
		_drop.draw(self, stage.tick, PPM)
		return
	if ghost.dump.pending():
		return
	var head: float = ghost.strike.attacks.num(ghost.form, &"press_ahead_m")
	var at: Vector2 = (ghost.spot + head * ghost.facing) * PPM
	HaulerMarks.draw(self, at, sec, ghost.strike.press.num(&"stomp_radius_m"), PPM, release)


## Ohm's and Dent's drop rows draw their ground under the actors from the press (OhmDropMarks,
## DentDropMarks); the records outlive them for the scorch and the scuff.
func _draw_ground() -> void:
	track()
	if _ohm_drop != null:
		_ohm_drop.draw(_ground, stage.tick, PPM)
	if _dent_drop != null:
		_dent_drop.draw(_ground, stage.tick, PPM)


## Lay a new record on a drop's press (Ohm, Dent) and drop the ones that are done.
func track() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy.get(ghost.form)
	if ghost.phase == GhostDeploy.Phase.ACTIVE and row != null and row.drops():
		var press: int = ghost.start_tick
		var hit: int = press + row.charge_ticks
		if ghost.form == OhmStage.GHOST and (_ohm_drop == null or _ohm_drop.press_tick != press):
			_ohm_drop = OhmDropMarks.new(ghost.spot * PPM, press, hit, row.radius_m)
		if ghost.form == DentStage.GHOST and (_dent_drop == null or _dent_drop.press_tick != press):
			_dent_drop = DentDropMarks.new(ghost.origin, ghost.spot, press, hit, row.ram_half_m)
	@warning_ignore("return_value_discarded")
	lingers()


func _bolt(ghost: GhostDeploy, target: Vector2, index: int, age: int) -> void:
	var start: Vector2 = body.bolt_tip(body.position + ghost.facing * 0.42 * PPM)
	if index == 0 and age < OhmBoltDraw.FLARE_TICKS and not calm:
		OhmFork.flash(self, start, ghost.facing, (0.22 - 0.035 * age) * PPM)
	# Hold the faint end of the bolt on its original contact as the staff fades away.
	var glow_age: int = mini(age, roundi(OhmView.HANG_S * SimClock.TICK_RATE * 0.8))
	var fade: float = OhmBoltDraw.fade(glow_age, 0, calm)
	if age > glow_age:
		fade *= body.self_modulate.a
	# The bolt lands even on a victim at the origin; the ring shows the short hop.
	var seed_i: int = index if calm else index + floori(glow_age / 3.0)
	if fade > 0.0 and start.distance_to(target) > 1.0:
		var pts: PackedVector2Array = OhmBoltView.jag(start, target, seed_i, OhmView.JAG_M, PPM)
		OhmBoltDraw.stroke(self, pts, fade, 1.0)
	if fade > 0.0:
		OhmVictimRims.ring(self, target, 0.48 * PPM, fade)
