# STANDARDS LAY-07 recipes. The Node commands are the source of truth; `just` is a shortcut.
# Needs GODOT_BIN pointing at the Godot 4.7.2 console binary (versions.toml).

godot := env_var_or_default("GODOT_BIN", "godot")

lint:
    node tools/lint/lint.mjs

test:
    node tools/tests/run_unit.mjs

scenarios:
    {{godot}} --headless --path project -s res://tests/run_scenarios.gd

ach *args="validate":
    node tools/achievements/gen.mjs {{args}}

evidence:
    node tools/evidence/run.mjs

import:
    {{godot}} --headless --path project --import

parity:
    @echo "parity: lands with the native port (NAT-06)" && exit 1

export:
    @echo "export: lands with the first export ticket (EXP-04)" && exit 1

audit:
    @echo "audit: tools/pck_audit lands with the first export ticket (EXP-05)" && exit 1
