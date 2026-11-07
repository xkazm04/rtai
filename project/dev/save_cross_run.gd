extends RefCounted
## save_cross's body, loaded once the autoloads exist. Exit 0 when the slot resumed, 1 when it
## was refused, 2 on bad arguments. `--save-cross=<mode>,<dir>[,<ticks>,<after>[,idle]]`.

const POINT: String = "handheld_cross"
## The scripted tape: every STEP ticks a new move direction, fire held on every other step.
const STEP: int = 20
const MOVES: Array[Vector2i] = [
	Vector2i(127, 0),
	Vector2i(90, 90),
	Vector2i(0, 127),
	Vector2i(-90, 90),
	Vector2i(-127, 0),
	Vector2i(-90, -90),
	Vector2i(0, -127),
	Vector2i(90, -90),
]


func run() -> int:
	var f: PackedStringArray = LaunchArgs.value("--save-cross").split(",")
	if f.size() < 2 or not (f[0] in ["write", "read"]):
		printerr("save_cross: --save-cross=write|read,<dir>[,ticks,after[,idle]] is required")
		return 2
	Save.use_root(f[1])
	var ticks: int = f[2].to_int() if f.size() > 2 else 1800
	var after: int = f[3].to_int() if f.size() > 3 else 600
	if f[0] == "write":
		var seed: int = LaunchArgs.value("--seed").to_int() if LaunchArgs.has("--seed") else 7
		printerr("save_cross: wrote %s" % _write(seed, ticks, f.size() > 4 and f[4] == "idle"))
	var out: SaveLoader.Outcome = Save.load_latest(Quest1Autosave.accept(Events, Data))
	var s: Quest1Session = out.value if out.status == SaveLoader.Status.LOADED else null
	if s == null:
		printerr("save_cross: slot refused (status %d) %s" % [out.status, out.lines])
		return 1
	var at: int = s.tick()
	var resumed: String = s.world.loop().state_hash()
	for i: int in after:
		s.step()
	printerr("save_cross: resumed tick %d hash %s" % [at, resumed])
	printerr(
		"save_cross: after +%d tick %d hash %s" % [after, s.tick(), s.world.loop().state_hash()]
	)
	s.world.free()
	return 0


## Plays `ticks` on the scripted tape (none when `idle`) and autosaves; "tick <n> hash <h>".
func _write(seed: int, ticks: int, idle: bool) -> String:
	var s: Quest1Session = Quest1Session.open(Events, Data, seed)
	var fire: int = 1 << s.actions.bit(&"fire")
	var at: Array[int] = []
	var packed: Array[int] = []
	for t: int in range(0, ticks, STEP):
		var m: Vector2i = MOVES[(t / STEP) % MOVES.size()]
		at.append(t)
		packed.append(TickInput.new(fire if (t / STEP) % 2 == 1 else 0, m.x, m.y).pack())
	if not idle:
		s.tape.preload_history(at, packed, ticks)
	while s.tick() < ticks:
		s.step()
	s.autosave.sink = func(point: String, body: Dictionary, meta: Dictionary) -> void:
		Save.autosave(point, body, meta)
	@warning_ignore("return_value_discarded")
	s.autosave.save_now(POINT)
	Save.flush()
	var line: String = "tick %d hash %s" % [s.tick(), s.world.loop().state_hash()]
	s.world.free()
	return line
