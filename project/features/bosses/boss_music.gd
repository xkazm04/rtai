class_name BossMusic
extends Node
## The boss fight's sound in the arena (the dev arena attaches no StageAudio): the stinger and
## the boss loop (`audio_cues.json` boss_stinger, boss_loop) when the fight is engaged; on the
## defeat the loop stops and the stinger hits once more as the defeat beat. Render side only:
## it reads the fight, never writes it (its own AudioService; jitter seed fixed).

const SEED: int = 9000

var service: AudioService = null
var _fight: BossFight = null


static func attach(parent: Node, fight: BossFight) -> BossMusic:
	var m: BossMusic = BossMusic.new()
	m._fight = fight
	m.service = AudioService.new(AudioTables.shipped(), SEED)
	parent.add_child(m)
	m.add_child(m.service)
	@warning_ignore("return_value_discarded")
	fight.defeated.connect(m._on_defeated)
	if fight.state != BossFight.State.DEFEATED:
		m._cue(&"boss_stinger")
		m.service.loops.set_on(&"boss_loop", true)
	return m


func playing() -> bool:
	return service.loops.is_on(&"boss_loop")


func _on_defeated() -> void:
	service.loops.set_on(&"boss_loop", false)
	_cue(&"boss_stinger")


func _cue(id: StringName) -> void:
	@warning_ignore("return_value_discarded")
	service.cue(id, Vector2.ZERO, _fight.now())
