class_name CityBlood
extends Node
## Composition-root glue (LAY-05) between the city and the combat blood (features/fx/combat_blood):
## puts a CombatBlood on the city view's actors canvas, follows the view's FX cues (the riot's sim
## deaths, Rivet's hits), splats the walls the sim calls solid, and steps it on the sim tick with
## the view's world lock each frame (after the view placed its camera: it is the view's child).

var blood: CombatBlood = CombatBlood.new()
var _city: CitySystem
var _view: CityView


static func attach(city: CitySystem, view: CityView) -> CityBlood:
	var glue: CityBlood = CityBlood.new()
	glue._city = city
	glue._view = view
	view.actor_layer().add_child(glue.blood)
	glue.blood.attach(view.fx_triggers)
	glue.blood.solid = glue._solid
	view.add_child(glue)
	return glue


func _process(_delta: float) -> void:
	if _view.clock != null:
		blood.step(_view.clock.tick(), _view.world_px)


func _solid(px: Vector2) -> bool:
	var c: int = _city.sim.cell_at(px.x / SimConst.PX_PER_M, px.y / SimConst.PX_PER_M)
	return c == SimConst.C_BUILD or c == SimConst.C_PROP
