class_name RigHost
extends Node
## The shipped face of the arena's rig drawer: the members the combat views (CorpseFade,
## BrutalityHook, PlasmaScorchView, ShockArcsView) read and write. The dev-only ArenaRigs extends
## it and draws the rigs, so shipped code never names a dev/ class (a release export drops dev/).

var rigs: CharacterRigs = CharacterRigs.new()
## human-reactions: the wound families and the deaths by damage class on the hostiles' rigs.
var react: ReactLink = null
## Fighter ids a signature kill consumed (lane brutality): their body is gibs now, no rig.
var hidden: Dictionary[int, bool] = {}
## Fixtures whose body decayed (CorpseDecayHook.gone): undrawn until they stand up again.
var gone: Dictionary[int, bool] = {}
## The fight's corpse decay (CorpseFade wires it; null without one): the dropped pistols ink out.
var decay: CorpseDecay = null


## A decayed body left the fight: drop its per-fighter bookkeeping (the drawer overrides this).
func forget(_id: int) -> void:
	pass
