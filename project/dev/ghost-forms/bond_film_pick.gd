class_name BondFilmPick
extends GauntletPickView
## The rest screen drawn for the film. The bot decides after a long look at a hand with a bond
## card, the card leaves the hand (the free mastery), the new hand is held, then the second pick.
## Only the presentation waits: the sim is paused for the whole offer.

const LOOK_FRAMES: int = 150
const TAKE_FRAMES: int = 30
const CHANGED_FRAMES: int = 90
const SECOND_FRAMES: int = 60

var _after_mastery: bool = false
var _hand_has_mastery: bool = false


func _present(ids: Array[StringName]) -> void:
	super._present(ids)
	_hand_has_mastery = ids.any(_is_mastery)


func advance() -> void:
	if not _hand_has_mastery and not _after_mastery:
		super.advance()
		return
	_frames += 1
	var decide: int = CHANGED_FRAMES if _after_mastery else LOOK_FRAMES
	var wait: int = SECOND_FRAMES if _after_mastery else TAKE_FRAMES
	if _frames == decide:
		_decide()
	elif _frames == decide + wait:
		_choose(_selected_slot)


func _decide() -> void:
	_selected_slot = pilot.pick(waves.pending)
	for i: int in _cards.get_child_count():
		(_cards.get_child(i) as Button).modulate.a = 1.0 if i == _selected_slot else 0.48


func _choose(index: int) -> void:
	var took_mastery: bool = index >= 0 and index < waves.pending.size()
	took_mastery = took_mastery and _is_mastery(waves.pending[index])
	_after_mastery = took_mastery
	super._choose(index)
	if waves.pending.is_empty():
		_after_mastery = false


static func _is_mastery(id: StringName) -> bool:
	return String(id).begins_with("master_")
