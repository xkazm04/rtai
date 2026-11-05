class_name Quest1GhostStreet
extends RefCounted
## The quest 1 ghost-power scenarios' street (d7-calls ghost-powers-5): the shipped quest 1 locks
## Dent until his act and parks no ghost cars (collect_call_city.json `ghost_cars` []), so the
## scenarios that prove Dent's and Ohm's car attacks on the city put back what they test: Dent's
## act done (the unlock path) and the three cars ghost-powers fitted on the street.

const ACT_DENT: StringName = &"act_dent"
## ghost-powers' fit (dev/ghost-powers/ghost_cars_fit.gd), world metres, nose east.
const CARS: PackedVector2Array = [Vector2(279, 260.5), Vector2(364, 260), Vector2(386, 266)]


## Opens quest 1 on the city with `acts` done (ACT_DENT frees Dent) and the fitted cars parked
## (null on failure).
static func open(bus: EventBus, data: DataStore, acts: Array[StringName]) -> Quest1Session:
	Quest1Session.on_city = true
	Quest1Session.acts_done = acts
	var s: Quest1Session = Quest1Session.open(bus, data)
	Quest1Session.acts_done = []
	if s != null:
		@warning_ignore("return_value_discarded")
		ArenaCars.attach_at(s.world, s.stage, CARS)
	return s
