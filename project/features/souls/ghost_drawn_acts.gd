class_name GhostDrawnActs
extends RefCounted
## Combat cell timing stays live even when a form draws its own body.

const ACT_COLS: int = 4
const WINDUP_COL: int = 0
const CUT_COL: int = 1
const FOLLOW_COL: int = 2
const HIT_COL: int = 3
const JAB_SHIFT: int = 4  # Dent's optional jab cells occupy columns 4-6 on each side.
const JAB_COLS: Dictionary[String, int] = {"dent/p70": 7, "dent/p55": 7}
const JAB_LEFT_COLS: Dictionary[String, int] = {"dent/p70": 7, "dent/p55": 7}
const CUT_TICKS: int = 5
const FOLLOW_TICKS: int = 10
const HIT_TICKS: int = 10

var instant_windup: int = 0
var _windup: bool = false
var _seq: int = 0
var _fed: bool = false
var _act_from: int = -1
var _hurt: int = -1
var _tick: int = 0


func feed(seq: int, hurt: int, tick: int, windup: bool = false, release_tick: int = -1) -> void:
	if release_tick >= 0:
		_act_from = release_tick
		instant_windup = 0  # this cast already showed its wind-up before release
	elif _fed and seq > _seq:
		_act_from = tick
	_fed = true
	_seq = seq
	_hurt = hurt
	_tick = tick
	_windup = windup


## Last hurt tick supplied to feed(), or -1 when the form has never been hurt.
func hurt_tick() -> int:
	return _hurt


func act_col() -> int:
	if _windup:
		return WINDUP_COL
	var since: int = _tick - _act_from
	if _act_from >= 0 and since < CUT_TICKS + FOLLOW_TICKS:
		if since < instant_windup:
			return WINDUP_COL
		return CUT_COL if since < CUT_TICKS else FOLLOW_COL
	return HIT_COL if hurt_tick() >= 0 and _tick - hurt_tick() < HIT_TICKS else -1


static func jab_col(act: int, p_jab: bool, cols: int) -> int:
	var shift: bool = p_jab and act >= 0 and act != HIT_COL and cols > JAB_SHIFT
	return act + JAB_SHIFT if shift else act
