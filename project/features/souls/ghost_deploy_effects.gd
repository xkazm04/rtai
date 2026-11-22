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


func _draw() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	if ghost.phase != GhostDeploy.Phase.ACTIVE:
		return
	var release: int = ghost.strike.release_tick
	var age: int = stage.tick - release
	var sec: float = age * SimClock.TICK_DT
	if ghost.form == HaulerStage.GHOST:
		var head: float = ghost.strike.attacks.num(ghost.form, &"press_ahead_m")
		var at: Vector2 = (ghost.spot + head * ghost.facing) * PPM
		HaulerMarks.draw(self, at, sec, ghost.strike.press.num(&"stomp_radius_m"), PPM, release)
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


func _bolt(ghost: GhostDeploy, target: Vector2, index: int, age: int) -> void:
	var start: Vector2 = body.bolt_tip(body.position + ghost.facing * 0.42 * PPM)
	if index == 0 and age < OhmBoltDraw.FLARE_TICKS and not calm:
		OhmFork.flash(self, start, ghost.facing, (0.22 - 0.035 * age) * PPM)
	var fade: float = OhmBoltDraw.fade(age, 0, calm)
	# The bolt lands even on a victim at the origin; the ring shows the short hop.
	var seed_i: int = index if calm else index + floori(age / 3.0)
	if fade > 0.0 and start.distance_to(target) > 1.0:
		var pts: PackedVector2Array = OhmBoltView.jag(start, target, seed_i, OhmView.JAG_M, PPM)
		OhmBoltDraw.stroke(self, pts, fade, 1.0)
	if fade > 0.0:
		OhmVictimRims.ring(self, target, 0.48 * PPM, fade)
