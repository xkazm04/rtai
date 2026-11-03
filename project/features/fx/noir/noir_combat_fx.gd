class_name NoirCombatFx
extends Node
## D-Noir combat wiring (lane noir): listens to the combat Events (actor_killed, player_hit)
## and answers with blood (BloodFx: a directional spurt along killer -> victim, a pool under
## the kill), a comic impact frame (ImpactFrame) and a hit-stop request. Events carry ids only,
## so the composition root hands in `locate`: Callable(id: int) -> Vector2 in metres, or
## Vector2.INF when unknown. Render-side only; the sim never waits on it unless the root
## honours `hit_stop` (it is a request, as the camera rig's hit-stop is).

signal hit_stop(ticks: int)

var blood: BloodFx = null
## What the player's body loses on player_hit (blood_fx.json `player`): a BloodFx drawing that
## fluid (oil for Rivet: sparks, then black). null = the player bleeds `blood`, with stains.
var player_fx: BloodFx = null
var impact: ImpactFrame = null
## Blood on the bodies (optional; set_stains hands it the px locate).
var stains: BloodStains = null
var locate: Callable = Callable()
## The player's actor id (player_hit has no victim id).
var player_id: int = 0
## Maps a world px position to screen uv for the impact burst (Callable(px) -> Vector2).
var to_screen_uv: Callable = Callable()
## World px per metre of the canvas the blood draws on (the city 32, quest 1's view 48).
var px_per_m: float = SimConst.PX_PER_M
var kills: int = 0
var hits: int = 0
var _stop_ticks: int = 5
## Wounded fighters: actor id -> bleed ticks left; where each last dripped (px) and when.
var _bleed: Dictionary[int, int] = {}
var _drip_at: Dictionary[int, Vector2] = {}
var _drip_t: Dictionary[int, int] = {}
var _was: Dictionary[int, Vector2] = {}


func bind(events: EventBus, p_blood: BloodFx, p_impact: ImpactFrame) -> void:
	blood = p_blood
	impact = p_impact
	var d: Dictionary = NoirLook.read_params(NoirLook.PARAMS)
	var imp: Dictionary = d.get("impact", {})
	_stop_ticks = imp.get("hit_stop_ticks", 5)
	@warning_ignore("return_value_discarded")
	events.actor_killed.connect(_on_actor_killed)
	@warning_ignore("return_value_discarded")
	events.player_hit.connect(_on_player_hit)


func _on_actor_killed(killer_id: int, victim_id: int, _kind: StringName) -> void:
	var at: Vector2 = _where(victim_id)
	if at == Vector2.INF:
		return
	var from: Vector2 = _where(killer_id)
	var dir: Vector2 = (at - from) if from != Vector2.INF else Vector2.RIGHT
	var px: Vector2 = at * px_per_m
	kills += 1
	if blood != null:
		blood.splash(px, dir.normalized(), "kill")
	if stains != null:
		stains.mark(victim_id, dir, "kill")
	if impact != null and not impact.can_fire():
		return
	if impact != null:
		var uv: Vector2 = Vector2(0.5, 0.5)
		if to_screen_uv.is_valid():
			uv = to_screen_uv.call(px)
		impact.fire(uv)
	hit_stop.emit(_stop_ticks)


func _on_player_hit(_weapon: StringName) -> void:
	var at: Vector2 = _where(player_id)
	if at == Vector2.INF or blood == null:
		return
	hits += 1
	var dir: Vector2 = Vector2.from_angle(hits * 2.4)
	if player_fx != null:
		var player: Dictionary = blood.p["player"]
		var kind: String = player.get("hit", "player_hit")
		player_fx.splash(at * px_per_m, dir, kind)
	else:
		blood.splash(at * px_per_m, dir, "player_hit")
		if stains != null:
			stains.mark(player_id, dir, "player_hit")
	_bleed[player_id] = blood.p["drip"]["bleed_ticks"]
	_drip_at[player_id] = at * px_per_m
	_drip_t[player_id] = 0


## The player's own fluid from blood_fx.json `player.fluid` (a new BloodFx, or null for blood);
## the host adds it to its canvas; step_ticks steps it (so it holds with the hit-stop).
func make_player_fx() -> BloodFx:
	var player: Dictionary = blood.p.get("player", {}) if blood != null else {}
	var fluid: String = player.get("fluid", "")
	var fx: BloodFx = BloodFx.new()
	if fluid.is_empty() or not fx.use_fluid(fluid):
		fx.free()
		return null
	player_fx = fx
	return fx


## Puts blood on the bodies too: `s` follows each body through this node's locate (in px).
func set_stains(s: BloodStains) -> void:
	stains = s
	s.locate = func(id: int) -> Vector2:
		var at: Vector2 = _where(id)
		return at if at == Vector2.INF else at * px_per_m


## Advances the drip trails on the fixed tick (the host calls it with the blood's step).
func step_ticks(n: int) -> void:
	if blood == null:
		return
	if player_fx != null:
		player_fx.step_ticks(n)
	var dp: Dictionary = blood.p["drip"]
	var every_px: float = dp["every_px"]
	var still: int = dp["still_ticks"]
	for id: int in _bleed.keys():
		var at: Vector2 = _where(id)
		_bleed[id] -= n
		if at == Vector2.INF or _bleed[id] <= 0:
			@warning_ignore("return_value_discarded")
			_bleed.erase(id)
			continue
		var px: Vector2 = at * px_per_m
		var move: Vector2 = px - _was.get(id, px)
		_was[id] = px
		_drip_t[id] += n
		if px.distance_to(_drip_at[id]) >= every_px or _drip_t[id] >= still:
			(player_fx if id == player_id and player_fx != null else blood).drip(px, move)
			_drip_at[id] = px
			_drip_t[id] = 0


## Fighters bleeding now (tests, evidence).
func bleeding() -> int:
	return _bleed.size()


func _where(id: int) -> Vector2:
	if not locate.is_valid():
		return Vector2.INF
	return locate.call(id)
