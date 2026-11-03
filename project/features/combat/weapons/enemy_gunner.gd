class_name EnemyGunner
extends RefCounted
## A hostile's readable shot: REST, then a TELL (the aim line shows; the gunner tracks the target
## for the first part, then holds the aim still for the last lock_ticks, the dodge window), then
## a VOLLEY of enemy_volley rounds at the locked point (a muzzle flash per round), then REST.
## Numbers come from weapons.json enemy_fire; enemy-ai drives when a gunner may start a tell.

enum State { REST, TELL, VOLLEY }

var id: int = 0
var pos: Vector2 = Vector2.ZERO
var trigger: Trigger
var state: State = State.REST
var aim_point: Vector2 = Vector2.ZERO
var tell_left: int = 0
var flash_left: int = 0
var shots_left: int = 0
var rest_left: int = 0
## Planted fault and A/B switch: keep tracking through the lock (no dodge window).
var track_through_lock: bool = false
var _table: WeaponTable
var _held: bool = false


static func make(p_id: int, p_pos: Vector2, weapon: StringName, table: WeaponTable) -> EnemyGunner:
	var g: EnemyGunner = EnemyGunner.new()
	g.id = p_id
	g.pos = p_pos
	g.trigger = Trigger.new(table.weapon(weapon))
	g._table = table
	g.rest_left = table.enemy_rest_ticks
	return g


## True while the tell shows (the view draws the aim line; audio plays the cock).
func telling() -> bool:
	return state == State.TELL


## True in the tell's last lock_ticks: the aim no longer follows the target.
func locked() -> bool:
	return state == State.TELL and tell_left <= _table.enemy_lock_ticks


## One 60 Hz tick: track `target_pos`, and fire into `sim` when the volley is due.
func step(sim: ProjectileSim, target_pos: Vector2) -> void:
	trigger.step()
	flash_left = maxi(flash_left - 1, 0)
	match state:
		State.REST:
			rest_left -= 1
			if rest_left <= 0:
				state = State.TELL
				tell_left = maxi(_table.enemy_tell_ticks, 1)
				aim_point = target_pos
		State.TELL:
			if track_through_lock or not locked():
				aim_point = target_pos
			tell_left -= 1
			if tell_left <= 0:
				state = State.VOLLEY
				shots_left = _table.enemy_volley
				_step_volley(sim)
		State.VOLLEY:
			_step_volley(sim)


func _step_volley(sim: ProjectileSim) -> void:
	_held = trigger.spec.auto or not _held
	if trigger.pull(_held):
		var muzzle: Vector2 = pos + (aim_point - pos).normalized() * 0.5
		sim.fire(trigger, muzzle, aim_point, Projectile.TEAM_ENEMY, id)
		flash_left = _table.enemy_flash_ticks
		shots_left -= 1
	if shots_left <= 0:
		state = State.REST
		rest_left = _table.enemy_rest_ticks
