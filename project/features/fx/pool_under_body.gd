class_name PoolUnderBody
extends Node
## n11 combat (owner: the dead "should be static", and the pool read as left at the boots): a city
## kill's pool is laid where the sim put the victim, his feet, while the drawn body lies along the
## ground from there, so the pool spread at the boots (film it19, t365 on). This moves each kill's
## pool, before it shows (BloodFx pool.delay_ticks), to the chest of the body that came to rest
## nearest the kill (StreetDeadRests). Quest 1 and the arena hand the feet too while the rigs
## draw the dead (StreetQuestDeadPlan.pool_m). ON false = the pool at the feet. Render only.

const ON: bool = true
## A rest whose feet are this far (m) from the kill is another body.
const MATCH_M: float = 1.5

var moved: int = 0
## Pools that showed before their body lay down (left where they were; evidence).
var late: int = 0
var _fx: BloodFx
## Waiting pools: slot, kill x, kill y (px).
var _wait: Array[Vector3] = []
## Bodies that already took a pool (an older body near a new kill is not his).
var _used: Dictionary[int, bool] = {}


func _init(fx: BloodFx) -> void:
	_fx = fx
	name = "PoolUnderBody"


## Moves `blood`'s kill pools under their bodies, stepped each frame as its child (the city's
## CityBlood, quest 1 and the arena's CollectCallView).
static func attach(blood: CombatBlood) -> void:
	StreetDeadRests.reset()  # a new fight: no rest of the last one takes its pools
	var under: PoolUnderBody = PoolUnderBody.new(blood.blood)
	@warning_ignore("return_value_discarded")
	blood.bled.connect(under.on_bled)
	blood.add_child(under)


func _process(_delta: float) -> void:
	step(StreetDeadRests.all)


## A kill bled at `pos_px` (connect to CombatBlood.bled, emitted after its splash).
func on_bled(pos_px: Vector2, _dir: Vector2) -> void:
	if ON and _fx.ring.last_pool >= 0:
		_wait.append(Vector3(_fx.ring.last_pool, pos_px.x, pos_px.y))


## Moves the waiting pools whose body lies now in `rests` (actor -> feet xy, chest zw).
func step(rests: Dictionary[int, Vector4]) -> void:
	var keep: Array[Vector3] = []
	for w: Vector3 in _wait:
		var actor: int = _body_near(rests, Vector2(w.y, w.z))
		if actor < 0:
			if _fx.tick < _fx.ring.born_of(int(w.x)):
				keep.append(w)
			else:
				late += 1
			continue
		_used[actor] = true
		var r: Vector4 = rests[actor]
		if _fx.tick < _fx.ring.born_of(int(w.x)):  # never once it shows: it would jump
			_fx.ring.move(int(w.x), Vector2(r.z, r.w))
			moved += 1
		else:
			late += 1
	_wait = keep
	if _used.size() > rests.size() + 64:  # forget bodies the rests forgot
		for actor: int in _used.keys():
			if not rests.has(actor):
				@warning_ignore("return_value_discarded")
				_used.erase(actor)


## Pools still waiting for their body (tests).
func waiting() -> int:
	return _wait.size()


## The unused body whose feet are nearest `at` within MATCH_M, else -1.
func _body_near(rests: Dictionary[int, Vector4], at: Vector2) -> int:
	var best: float = MATCH_M * SimConst.PX_PER_M
	var out: int = -1
	for actor: int in rests:
		var r: Vector4 = rests[actor]
		var gap: float = at.distance_to(Vector2(r.x, r.y))
		if gap < best and not _used.has(actor):
			best = gap
			out = actor
	return out
