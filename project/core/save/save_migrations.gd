class_name SaveMigrations
extends RefCounted
## Chained pure migrations (SAV-04): STEPS[i] turns a save_version i+1 envelope into i+2. Each
## step takes a Dictionary and returns a new one; none touches disk. CURRENT is the version this
## build writes; a fixture for every released version lives in tests/saves/vN.sav.

const CURRENT: int = 1
## Callables (Dictionary) -> Dictionary, oldest first. Empty while version 1 is the only one.
const STEPS: Array[Callable] = []


## The envelope brought up to `target` through `steps`; unchanged when already there.
static func migrate(
	envelope: Dictionary, target: int = CURRENT, steps: Array[Callable] = STEPS
) -> Dictionary:
	var env: Dictionary = envelope.duplicate(true)
	var version: int = GtsvContainer.as_int(env.get("save_version"))
	while version < target and version >= 1 and version - 1 < steps.size():
		env = steps[version - 1].call(env)
		version += 1
		env["save_version"] = version
	return env
