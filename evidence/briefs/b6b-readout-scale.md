# Follow-up b6b: go on with b6 (both parts)

Granted: `project/tests/unit/test_rivet_wheel_pilot.gd` joins the Part A allowlist. Change the tick-1 assertion to the new contract (readout visible during the first 60 ticks) and add the tick-60 hidden case there or in the new test; say so in the commit message.

Standing rule for the rest of this call: a unit test that asserts the old behaviour of a file you are allowed to change may be updated to the new contract without asking; name each such test in your report. Do not weaken any other assertion. Anything else outside the allowlist: stop and report a NEED.

Same brief otherwise (`evidence/briefs/b6-readout-scale.md`). **Hard stop: 07:50 wall clock. Commit deadline: 07:45.** Part A first and committed, then Part B.
