class_name QuestSystem
extends WorldSystem
## The quest runtime as a WorldSystem (ARC-04): the composition root registers it with a
## QuestWorld, it receives the WorldContext once, and steps the active QuestRunner on the fixed
## tick. One contract at a time; offer() a validated package to start it ringing.
## No RNG stream is taken: the runtime draws no random numbers (docs/decisions.md).

var runner: QuestRunner = null
var _world: QuestWorld
var _rules: QuestRules
var _ctx: WorldContext = null


func _init(world: QuestWorld, rules: QuestRules = QuestRules.shipped()) -> void:
	_world = world
	_rules = rules


func setup(ctx: WorldContext) -> void:
	_ctx = ctx


## Offers `pkg` (it rings). Refused while another contract is offered or active.
func offer(pkg: QuestPackage) -> bool:
	if runner != null and runner.state in [QuestRunner.State.OFFERED, QuestRunner.State.ACTIVE]:
		return false
	runner = QuestRunner.new(pkg, _world, _ctx.events, _rules)
	runner.offer()
	return true


func step(tick: int, _input: TickInput) -> void:
	if runner != null:
		runner.step(tick)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_8(1 if runner != null else 0)
	if runner != null:
		runner.write_state(out)
