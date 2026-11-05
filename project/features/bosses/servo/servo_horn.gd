class_name ServoHorn
extends Node
## The depot's shift horn (docs/bosses/servo.md, phase 2): rush hour opens with one long, deep
## blast (`audio_cues.json` servo_horn, the vehicles lane's horn pitched down, not positional)
## as the belt starts and the bay doors roll up. Render side only: it listens to the fight's
## phase_changed and never writes the fight (its own AudioService; jitter seed fixed).

const SEED: int = 9100
## The phase index that blows the horn (0 depot, 1 rush hour, 2 overtime).
const RUSH: int = 1

var service: AudioService = null
var _fight: BossFight = null
var _blown: int = 0


static func attach(parent: Node, fight: BossFight) -> ServoHorn:
	var h: ServoHorn = ServoHorn.new()
	h._fight = fight
	h.service = AudioService.new(AudioTables.shipped(), SEED)
	parent.add_child(h)
	h.add_child(h.service)
	@warning_ignore("return_value_discarded")
	fight.phase_changed.connect(h._on_phase)
	return h


## Times the horn has sounded.
func blown() -> int:
	return _blown


func _on_phase(index: int, _id: StringName) -> void:
	if index != RUSH:
		return
	_blown += 1
	@warning_ignore("return_value_discarded")
	service.cue(&"servo_horn", Vector2.ZERO, _fight.now())
