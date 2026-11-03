class_name EnemyFightFx
extends Node2D
## The pit fight's in-flight layer over the cast rigs (enemy-ai evidence, render only): rounds as
## tracers (enemy rounds warm paper, Rivet's nails steel), the gun tell (a thin vermilion aim line
## from the muzzle while the aim tracks, a thick one once it locks: dodge now), the melee windup
## arc, and a two-tick paper muzzle star on every shot. Positions in world px (the actors space).

const TRACER: Color = Color(1.0, 0.93, 0.7)
const NAIL: Color = Color(0.8, 0.85, 0.9)
const DANGER: Color = Color(0.93, 0.33, 0.16)
const FLASH: Color = Color(1.0, 0.97, 0.86)
const TAIL_M: float = 1.4
const FLASH_TICKS: int = 2

var pit: EnemyPit = null
var ppm: float = 32.0
## actor id -> the rig that draws it (the muzzle comes from the rig's gun hand)
var rig_of: Callable = Callable()
var rivet_shot_tick: int = -1000
var rivet_rig: CutRig = null


func _draw() -> void:
	if pit == null:
		return
	for s: Shot in pit.shots:
		var tail: Vector2 = s.pos - s.vel.normalized() * TAIL_M
		var c: Color = NAIL if s.from_rivet else TRACER
		draw_line(tail * ppm, s.pos * ppm, Color(c, 0.35), 4.0)
		draw_line((s.pos - s.vel.normalized() * TAIL_M * 0.5) * ppm, s.pos * ppm, c, 2.0)
	for e: EnemyAgent in pit.agents:
		if not e.alive():
			continue
		var at: Vector2 = _muzzle(e.id, e.pos)
		if e.state == EnemyAgent.State.WINDUP:
			_tell(e, at)
		if pit.tick - e.shot_tick < FLASH_TICKS and not e.melee():
			_star(at, e.aim)
	if rivet_rig != null and pit.tick - rivet_shot_tick < FLASH_TICKS:
		_star(rivet_rig.muzzle_local(), Vector2.from_angle(rivet_rig.facing))


func _tell(e: EnemyAgent, at: Vector2) -> void:
	if e.melee():
		var a: float = e.aim.angle()
		var r: float = e.arch.weapon.reach_m * ppm
		draw_arc(e.pos * ppm, r, a - 0.9, a + 0.9, 18, Color(DANGER, 0.85), 3.0)
		return
	var locked: bool = e.aim_locked(pit.roster.aim_lock_ticks)
	var w: float = 2.5 if locked else 1.0
	var reach: float = e.arch.attack_m * ppm
	draw_line(at, at + e.aim * reach, Color(DANGER, 0.9 if locked else 0.55), w)


func _star(at: Vector2, dir: Vector2) -> void:
	var d: Vector2 = dir.normalized()
	draw_circle(at + d * 3.0, 4.0, FLASH)
	draw_line(at, at + d * 13.0, FLASH, 3.0)
	draw_line(at + d * 4.0 - d.orthogonal() * 5.0, at + d * 4.0 + d.orthogonal() * 5.0, FLASH, 2.0)


func _muzzle(id: int, pos_m: Vector2) -> Vector2:
	if rig_of.is_valid():
		var rig: CutRig = rig_of.call(id)
		if rig != null and rig.plan.gun_arm >= 0:
			return rig.muzzle_local()
	return pos_m * ppm
