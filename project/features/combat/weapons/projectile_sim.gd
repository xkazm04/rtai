class_name ProjectileSim
extends RefCounted
## The shooting model as data: rounds in flight, the bodies they hit, cover that stops them and
## the fire on the ground. Deterministic (60 Hz ticks, swept tests, one RNG stream for spread).
## hit/killed are the hooks the hit-feel module, audio and enemy reactions listen to.

signal hit(target: RangeTarget, amount: float, hit_class: StringName, dir: Vector2)
signal killed(target: RangeTarget, shooter_id: int, weapon_class: StringName)

var projectiles: Array[Projectile] = []
var targets: Array[RangeTarget] = []
## Cover, walls and building footprints (metres); rounds stop at them, bottles fly over.
var cover: Array[Rect2] = []
## Fire on the ground: x, y = centre, z = radius, w = dps; ticks left in patch_ticks.
var patches: Array[Vector4] = []
var patch_ticks: Array[int] = []
## The last chain arcs (VFX reads them; cleared each tick).
var chain_arcs: Array[PackedVector2Array] = []
var tick: int = 0
var shots_fired: int = 0
var hits_landed: int = 0
var _rng: RandomNumberGenerator
var _table: WeaponTable


func _init(rng: RandomNumberGenerator, table: WeaponTable) -> void:
	_rng = rng
	_table = table


## Launches the shot `trigger` just released, from `muzzle` toward `aim_point`.
func fire(
	trigger: Trigger, muzzle: Vector2, aim_point: Vector2, team: int, shooter_id: int
) -> void:
	var w: WeaponSpec = trigger.spec
	var aim: Vector2 = (aim_point - muzzle).normalized()
	if aim == Vector2.ZERO:
		return
	for i: int in w.pellets:
		var p: Projectile = Projectile.launch(w, muzzle, trigger.shot_dir(aim, _rng), team)
		p.shooter_id = shooter_id
		p.born_tick = tick
		if w.kind == WeaponSpec.Kind.THROWN:
			p.left_m = minf(muzzle.distance_to(aim_point), w.range_m)
		if team == Projectile.TEAM_ENEMY:
			p.vel *= _table.enemy_speed_scale
			p.damage *= _table.enemy_damage_scale
		projectiles.append(p)
	trigger.add_bloom()
	shots_fired += 1


func step(p_tick: int) -> void:
	tick = p_tick
	chain_arcs.clear()
	for t: RangeTarget in targets:
		if t.alive():
			t.step()
	for p: Projectile in projectiles.duplicate():
		_step_projectile(p)
	_step_burning()
	_step_patches()


## The one hp chokepoint for this model: emits hit, then killed on the lethal hit.
func hurt(t: RangeTarget, amount: float, hit_class: StringName, dir: Vector2, by: int) -> void:
	if not t.alive() or amount <= 0.0:
		return
	t.hp = maxf(t.hp - amount, 0.0)
	t.hurt_tick = tick
	hit.emit(t, amount, hit_class, dir)
	if not t.alive():
		killed.emit(t, by, hit_class)


func add_patch(at: Vector2, radius: float, ticks_left: int, dps: float) -> void:
	for i: int in patches.size():
		if Vector2(patches[i].x, patches[i].y).distance_to(at) < patches[i].z * 0.5:
			patch_ticks[i] = maxi(patch_ticks[i], ticks_left)
			return
	patches.append(Vector4(at.x, at.y, radius, dps))
	patch_ticks.append(ticks_left)


## A digest of the whole state (determinism and replay checks).
func digest() -> int:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	out.put_32(tick)
	out.put_32(projectiles.size())
	for p: Projectile in projectiles:
		p.write_state(out)
	for t: RangeTarget in targets:
		t.write_state(out)
	out.put_32(patches.size())
	return hash(out.data_array)


func _step_projectile(p: Projectile) -> void:
	var from: Vector2 = p.advance()
	var best_t: float = 2.0
	var victim: RangeTarget = null
	if p.spec.kind != WeaponSpec.Kind.THROWN:
		for box: Rect2 in cover:
			var tc: float = Sweep.rect(from, p.pos, box)
			if tc >= 0.0 and tc < best_t:
				best_t = tc
		for t: RangeTarget in targets:
			if t.alive() and t.team != p.team:
				var tt: float = Sweep.circle(from, p.pos, t.pos, t.radius_m)
				if tt >= 0.0 and tt < best_t:
					best_t = tt
					victim = t
	if best_t <= 1.0:
		_end(p, victim, from.lerp(p.pos, best_t))
	elif p.spent():
		_end(p, null, p.pos)


func _end(p: Projectile, victim: RangeTarget, at: Vector2) -> void:
	projectiles.erase(p)
	if victim != null:
		hits_landed += 1
	var bursts: bool = p.spec.kind in [WeaponSpec.Kind.ROCKET, WeaponSpec.Kind.THROWN]
	if victim != null or bursts or p.spec.patch_ticks > 0:
		Impact.land(self, p, victim, at)


func _step_burning() -> void:
	for t: RangeTarget in targets:
		if t.alive() and t.burn_ticks > 0:
			t.burn_ticks -= 1
			hurt(t, t.burn_dps * SimClock.TICK_DT, &"burn", Vector2.ZERO, 0)


func _step_patches() -> void:
	for i: int in range(patches.size() - 1, -1, -1):
		var c: Vector2 = Vector2(patches[i].x, patches[i].y)
		for t: RangeTarget in targets:
			if t.alive() and t.pos.distance_to(c) <= patches[i].z + t.radius_m:
				t.burn_ticks = maxi(t.burn_ticks, 30)
				t.burn_dps = maxf(t.burn_dps, patches[i].w)
		patch_ticks[i] -= 1
		if patch_ticks[i] <= 0:
			patches.remove_at(i)
			patch_ticks.remove_at(i)
