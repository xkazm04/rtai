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


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wounded)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_killed)


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


## True while a landed drop's crater still shows after the ghost has gone.
func lingers() -> bool:
	if _drop == null or not _drop.live(stage.tick):
		_drop = null
		return false
	# A drop cancelled before its dump (Rivet died) leaves no ground.
	var active: bool = stage.pilot.ghosts.deploy.phase == GhostDeploy.Phase.ACTIVE
	if stage.tick < _drop.dump_tick and not active:
		_drop = null
	return _drop != null


func _draw() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	if ghost.phase != GhostDeploy.Phase.ACTIVE:
		if lingers():
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
