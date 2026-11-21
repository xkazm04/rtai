class_name BotMachineFight
extends RefCounted
## Keep circling the same way around a slow traverse. Reverse at a wall. A visible
## discharge opens a direct approach until the weapon could fire again.

var _id: int = -1
var _sign: float = 1.0


func advance(view: BotView, foe: BotView.Hostile) -> Vector2:
	var at: Vector2 = view.player().pos
	var inward: Vector2 = at.direction_to(foe.pos)
	var distance: float = at.distance_to(foe.pos)
	if not view.clear_line(at, foe.pos) or distance > 5.0:
		return view.chase(foe)
	var tangent: Vector2 = inward.orthogonal()
	if foe.id != _id:
		_id = foe.id
		_sign = -1.0 if tangent.dot(foe.facing) > 0.0 else 1.0
	if not view.walk_clear(at, at + tangent * _sign):
		if view.walk_clear(at, at - tangent * _sign):
			_sign = -_sign
	var frontal: bool = foe.facing.dot(-inward) > foe.front_cos
	var circle: float = 1.0 if frontal or distance < 1.6 else 0.5
	if foe.opening and distance > 1.6:
		circle = 0.25
	var approach: float = clampf((distance - 0.65) * 0.9, -0.4, 1.0)
	var move: Vector2 = (inward * approach + tangent * circle * _sign).normalized()
	return move if view.walk_clear(at, at + move * 0.6) else view.chase(foe)


## The stomp checks distance at impact, including behind a prop. Leave the ring
## radially. A late read or blocked exit can call for a roll or Tonnage's armour.
static func stomp(view: BotView, foe: BotView.Hostile, dodge: bool) -> BotDefence.Choice:
	var choice: BotDefence.Choice = BotDefence.Choice.new()
	var me: BotView.Player = view.player()
	var away: Vector2 = foe.pos.direction_to(me.pos)
	var gap: float = me.pos.distance_to(foe.pos)
	if gap > foe.stomp_m + 0.25:
		choice.hold_position = true
		return choice
	if away == Vector2.ZERO:
		away = -foe.facing
	var radius: float = foe.stomp_m + 0.35
	var exit: Vector2 = Vector2.INF
	for angle: float in [0.0, PI / 3.0, -PI / 3.0]:
		var point: Vector2 = foe.pos + away.rotated(angle) * radius
		if view.walk_clear(me.pos, point):
			exit = point
			break
	var escape: float = me.pos.distance_to(exit)
	var seconds: float = foe.tell_ticks * SimClock.TICK_DT
	if escape <= me.walk_mps * seconds:
		choice.action = &"sprint"
	elif me.can_roll and dodge and escape <= me.roll_m:
		choice.action = &"roll"
	elif me.forms.has(&"tonnage") and gap <= foe.stomp_m:
		choice.form = &"tonnage"
	else:
		choice.action = &"sprint"
	choice.move = me.pos.direction_to(exit) if exit.is_finite() else away
	choice.aim = -away
	return choice
