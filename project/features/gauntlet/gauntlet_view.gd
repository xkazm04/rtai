class_name GauntletView
extends CollectCallView
## CombatBlood asks for the victim's position on actor_killed, before CombatArena announces
## kill_landed and the street settles the fighter. Use the same free spot for both deposits.

var _street: GauntletStreet


func _init(street: GauntletStreet) -> void:
	_street = street
	var floor_view: GauntletFloor = GauntletFloor.new()
	floor_view.street = street
	stage_view.free()
	stage_view = floor_view


func _ready() -> void:
	super._ready()
	if blood != null:
		# The quest's pool hook reads the victim again before the fighter is moved.
		# With no second lookup, both human blood and machine oil use _locate's free point.
		blood.pool_at = Callable()
		blood.solid = _street.solid_px
		if blood.oil != null:
			blood.oil.solid = _street.solid_px


func _locate(id: int) -> Vector2:
	var arena: CombatArena = _stage.arena
	if id != arena.rivet.id:
		for foe: Fighter in arena.hostiles:
			if foe.id == id:
				return _street.rest.body_position(foe)
	return super._locate(id)
