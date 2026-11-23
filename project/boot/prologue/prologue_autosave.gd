class_name PrologueAutosave
extends WorldSystem
## Last in the embedded prologue's system order. Sample the finished stage on the tick
## that opens each checkpoint; the clock completes that tick immediately afterwards.

const QUEST: String = "prologue"

var tape: InputTape
var writing: bool = false
var last: Checkpoint
var _chapter: PrologueGame
var _span_count: int = 0


func _init(chapter: PrologueGame) -> void:
	_chapter = chapter
	tape = InputTape.new(chapter.live)
	chapter.world.loop().set_input(tape)


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	var spans: Array[Dictionary] = _chapter.encounter.spans
	if spans.size() == _span_count:
		return
	_span_count = spans.size()
	last = Checkpoint.new()
	last.quest = QUEST
	last.beat = spans.back()["id"]
	last.tick = tick + 1
	last.master_seed = _chapter.world.context().rng.master_seed()
	last.state_hash = _chapter.world.loop().state_hash()
	var history: Array[Array] = tape.history_before(last.tick)
	last.input_ticks.assign(history[0])
	last.inputs.assign(history[1])
	if writing:
		var meta: Dictionary = {
			"quest": QUEST, "beat": last.beat, "playtime_s": tick / SimClock.TICK_RATE
		}
		Save.autosave("prologue-" + last.beat, last.to_dict(), meta)


## Replay through the saved edge with writes disabled. Check both the state at the edge
## and its identity; a valid slot for another beat must never land partway through play.
func restore(cp: Checkpoint) -> bool:
	tape.preload_history(cp.input_ticks, cp.inputs, cp.tick)
	var world: World = _chapter.world
	while world.context().clock.tick() < cp.tick:
		world.loop().step()
	return (
		last != null
		and last.tick == cp.tick
		and last.beat == cp.beat
		and last.state_hash == cp.state_hash
	)
