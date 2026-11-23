LAUNCH NOTE: wall-clock hard stop 04:10 (check the clock), commit deadline 04:05. Resume of package 03 `newgame`. Base: HEAD 3aead09f1 (step 0 committed).

# Follow-up: authorized, go on

1. Step 0b: you are authorized to add EVERY `shotgun` entry the arsenal audit asks for in
   `project/dev/rivet_arsenal/arsenal_known_holes.json` (`top/{held,reload,pickup}` and `{p55,p70}/{held,fire8,left,muzzle,reload,pickup}`,
   whatever the audit lists for `shotgun`: all are the same deliberate stand-in until the art is drawn). Keep your `held_classes.json`
   entry. Rerun `--select=test_held_classes,test_arsenal_audit` green, quote it, commit both files (one commit).
2. Then continue package 03 from step 1 exactly as the brief says (routing + `--skip-prologue`, prologue save point, the
   menu-to-quest-1 pilot + scenario, unit tests, decisions lines, stills, mutate). Your Start-caller survey stands: keep `start()`
   = "open quest 1" so those callers need no change.
3. Your script-mismatch table is good: keep it for the final message (I will put it in REPORT for the owner). Do not edit quest 1.
4. If time runs short, the order of value is: routing + flag (commit a) > pilot + scenario (commit c) > save point (commit b).
   Commit each as it lands; do not leave green work uncommitted at the hard stop.

All the law of the original brief binds (allowlist, forbidden n24 files, no amend/rebase, mutate --max=20, APPDATA export,
one Godot at a time, `--position 0,1440` on windowed runs). Fix lint and format findings in your own edit and go on.
