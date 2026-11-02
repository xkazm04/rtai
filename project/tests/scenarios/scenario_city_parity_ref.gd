extends Scenario
## The parity harness itself, on two GDScript reference sims (runs everywhere, no native build):
## identical inputs stay bit-identical over the sweep, and a planted ulp-sized nudge is caught.
## The native-vs-reference gate is tests/parity/run_parity.gd (the CI native job).

const STEPS: int = 300


func run(_tree: SceneTree) -> String:
	var same: CityParity = CityParity.new()
	if not same.run(CitySimRef.new(), CitySimRef.new(), STEPS, -1):
		return "two reference sims diverged: %s" % JSON.stringify(same.result)
	var counters: Array = same.result["counters_a"]
	var live: int = 0
	for k: int in 4:
		var n: int = counters[k]
		live += n
	if live < 150:
		return "the parity world is too empty to prove anything (%d live actors)" % live
	var planted: CityParity = CityParity.new()
	if planted.run(CitySimRef.new(), CitySimRef.new(), STEPS, STEPS / 2):
		return "a planted mutation was not caught"
	Log.info("scenario", "city parity (ref vs ref): %s" % JSON.stringify(same.result))
	return ""
