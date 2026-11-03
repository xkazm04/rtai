class_name Projectile
extends RefCounted
## One round, puff, rocket, bolt or bottle in flight (metres, 60 Hz). Bottles (THROWN) fly over
## bodies and burst at their aim point; everything else stops at the first body or cover.

const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1

var spec: WeaponSpec
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var left_m: float = 0.0
var damage: float = 0.0
var team: int = TEAM_PLAYER
var shooter_id: int = 0
var born_tick: int = 0


static func launch(p_spec: WeaponSpec, from: Vector2, dir: Vector2, team_id: int) -> Projectile:
	var p: Projectile = Projectile.new()
	p.spec = p_spec
	p.pos = from
	p.vel = dir.normalized() * p_spec.speed_mps
	p.left_m = p_spec.range_m
	p.damage = p_spec.damage
	p.team = team_id
	return p


## Moves one tick (never past the end of its range); returns the segment start.
func advance() -> Vector2:
	var from: Vector2 = pos
	var travel: float = minf(vel.length() * SimClock.TICK_DT, maxf(left_m, 0.0))
	pos += vel.normalized() * travel
	left_m -= travel
	return from


func spent() -> bool:
	return left_m <= 1e-6


func write_state(out: StreamPeerBuffer) -> void:
	out.put_float(pos.x)
	out.put_float(pos.y)
	out.put_float(left_m)
	out.put_32(team)
