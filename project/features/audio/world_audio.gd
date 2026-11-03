class_name WorldAudio
extends RefCounted
## Hangs the game's sound on the composition root's riot world (boot/world.gd): the AudioService
## under the world, the FX trigger sink (shot / projectile_end / death / player_hit voiced at the
## cue's position), the Events hooks, and the city bed. The listener is the camera focus.


static func attach(
	world: Node, ctx: WorldContext, view: CityView, city: CitySystem
) -> AudioService:
	var service: AudioService = AudioService.new(AudioTables.shipped(), ctx.rng.master_seed())
	world.add_child(service)
	var m_per_px: float = 1.0 / SimConst.PX_PER_M
	var triggers: FxTriggers = view.fx_triggers
	service.listener_fn = func() -> Vector2: return triggers.focus_px * m_per_px
	triggers.sink = func(id: StringName, pos_px: Vector2, tick: int) -> void:
		@warning_ignore("return_value_discarded")
		service.cue(id, pos_px * m_per_px, tick)
	var hooks: AudioHooks = AudioHooks.new()
	hooks.fx_cues = true
	service.add_child(hooks)
	hooks.attach(service, ctx.events, ctx.clock.tick, func() -> Vector2: return city.target)
	service.loops.set_on(&"city_ambience", true)
	return service
