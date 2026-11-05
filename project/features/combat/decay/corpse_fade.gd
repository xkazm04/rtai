class_name CorpseFade
extends Node
## CorpseDecay drawn (render only, no RNG): runs after the rigs posed the frame (process_priority
## above CharacterRigs) and, for each decaying body on a full rig, inks it out (tints it to ink)
## and sinks it into its stain (shrinks it by CorpseDecay.sink): a fade, not a pop. Never alpha:
## the D5 part print discards a part under alpha 0.45 and stipples it cream above.
## It wires the rest once they exist: ArenaRigs skips `gone` fixtures, the corpse soaks fade with
## their body (CorpseStains.body_alpha), the signature kills' gibs, dust piles and prints fade with
## their victim's body and stain (KillView.decay), and every CombatBlood under the game takes the
## stains' life for its decals and pools. Released ids are drained from the hook every frame:
## their rig bookkeeping and kill nodes are freed, so a long fight's node count stays flat.

const PRIORITY: int = 10

var hook: CorpseDecayHook = null
var stage: ArenaStage = null
var view: CollectCallView = null
var _rigs: ArenaRigs = null
var _kills: KillView = null
var _bloods_set: bool = false


func _ready() -> void:
	process_priority = PRIORITY


func _process(_delta: float) -> void:
	if hook == null or stage == null:
		return
	_wire()
	var d: CorpseDecay = hook.decay
	for id: int in hook.out_bodies:
		if _rigs != null:
			_rigs.forget(id)
		if _kills != null:
			_kills.release_body(id)
	for id: int in hook.out_stains:
		if _kills != null:
			_kills.release_stain(id)
	hook.out_bodies.clear()
	hook.out_stains.clear()
	if _rigs == null:
		return
	for h: Fighter in stage.arena.hostiles:
		if h.alive():
			continue
		var rig: CutRig = _rigs.rigs.rig_for(h.id)
		if rig != null and d.bodies.fade_k(h.id) > 0.0:
			rig.modulate = Color.WHITE.lerp(ArtIds.INK, d.ink_of(h.id))
			rig.scale = Vector2.ONE * CutRig.SC * rig.plan.size_k * d.sink_of(h.id)


func _wire() -> void:
	if _rigs == null:
		for ch: Node in get_parent().get_children():
			if ch is ArenaRigs:
				_rigs = ch as ArenaRigs
				_rigs.gone = hook.gone
				_rigs.decay = hook.decay  # combat-notes: a dropped pistol inks out with its body
	if _kills == null:
		for h: ArenaHook in stage.hooks:
			if h is BrutalityHook and (h as BrutalityHook).view != null:
				_kills = (h as BrutalityHook).view
				_kills.decay = hook.decay
	if view != null and view.stains != null and not view.stains.body_alpha.is_valid():
		view.stains.body_alpha = hook.decay.bodies.alpha
	if not _bloods_set:
		_bloods_set = true
		_set_bloods(get_parent())


## The stains' life on every blood under the game (the print stage's, the city block's).
func _set_bloods(root: Node) -> void:
	var s: DecayLedger = hook.decay.stains
	if root is CombatBlood:
		for fx: BloodFx in [(root as CombatBlood).blood, (root as CombatBlood).oil]:
			if fx != null:
				fx.set_decal_life(s.linger_ticks, s.fade_ticks)
	for c: Node in root.get_children():
		_set_bloods(c)
