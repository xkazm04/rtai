# Brief n26-01-keys: the owner's key layout

Lane `keys`, branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd). Cut from main `0779185ac`.

**Hard stop: 12:25 wall clock. Commit deadline: 12:20.** Commit each step as it lands (small commits, staged per path,
`git commit -- <paths>`). No amend, no rebase, no stash, no `add -A/./-u`, no `reset --hard`, never push.
Fix lint and format findings in your own edit and go on. If you run out of time, commit what is green and say what is left.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs only with `--position 0,1440`. First run one `"$GODOT_BIN" --headless --path project --import`
(main moved since the cache was made).

## The owner's words (2026-11-23)

"Lets make Sprint on Space bar"; "Make quick claw F. We will introduce numbers 1,2,3,4 for ghosts deploying ghosts as we
will have otherwise conflicts when all 4 ghosts in control. For entering car we can then use Dent's number which will be 1,
as his ability allows us to get into and drive". Shift is the dash burst only.

## What to build (all in `project/data/tables/input_actions.json` by key only: NO existing `bit` or `wire_bit` changes)

1. `sprint` (bit 5) gets key `Space`. `handbrake` (bit 1) keeps `Space` (read only in a car; check sprint is not read in a car
   and handbrake not on foot).
2. `dash` (bit 18) stays on `Shift`; `project/data/tables/rivet_motion.json` `dash.hold_sprints` -> `false` (burst only; holding
   Shift after the burst no longer sprints). Update the table `doc` and the input `doc` strings.
3. `melee` (bit 3, the quick claw) moves from `Space` to `F`; its mouse binding (2) and pad button stay.
4. `car` (bit 0) loses `F` and gets key `1` (pad Y stays).
5. Four NEW actions `ghost_deploy_1` .. `ghost_deploy_4`, keys `1`..`4`, bits 20..23, wire bits 33..36 (raise the schema
   maxima in `project/data/schemas/input_actions.schema.json`; check `TickInput`'s 48-bit mask and every place that packs
   buttons into fewer bits, e.g. the known `project/boot/collect_call/stage_pilot.gd` `put_32`, still writes byte-identical
   output for tapes that never press the new bits). Slot order = `ghost_forms.json` `forms` order: 1 dent, 2 kerf, 3 ohm,
   4 tonnage. No pad buttons on the four new rows (the pad keeps LB = `ghost_deploy` of the selected ghost, RB = cycle).
6. `ghost_deploy` (bit 19) loses `Q` (keeps pad LB 9). `power_gearbox` (bit 8, the cycle) loses `G` (keeps pad RB 10).
   `weapon_slot_1..4` (bits 11..14) lose keys `1`..`4` (keep their bits; wheel and Tab remain the weapon controls).
7. `project/features/souls/ghost_deploy.gd` (+ whatever reads the deploy input in `project/features/souls/**`): each
   `ghost_deploy_N` held = aim THAT form's range, release = deploy that form, same rules as today (cooldown per form, one
   ghost out at a time, refusals). A form the player does not own (not unlocked in `GhostForms`): the key does nothing (no
   aim, no refusal sound). The old `ghost_deploy` + `forms.selected` path stays exactly as it is for old tapes and the pad.
   Key 1 and a car: a `ghost_deploy_1` hold that starts on a tick where the car use (bit 0) is taken (Rivet enters a car or
   leaves one) is consumed by the car: no Dent aim, no deploy on release. Inside a car nothing deploys. Away from a car, 1 is
   Dent's deploy. Do not change whether entering needs Dent owned (keep today's rule) and do not change quest 1's rules.
   Keep files under 200 lines (hard 300), functions <= 40 lines; split into a new helper class if needed.
8. The deploy HUD chips (`project/features/souls/ghost_form_hud.gd` or wherever the ghost chips are drawn): each chip
   shows its number key (read from the InputMap through the existing key-name helper, not a literal). Teal stays for souls only.
9. Every on-screen prompt that names a key follows the table, not a literal: grep the prologue lesson cards
   (`project/boot/prologue/**` - READ ONLY for you except the strings below), gauntlet help, quest prompts (the car hint),
   `project/data/loc/en.po`, `project/boot/collect_call/objective_hint.gd` (`with_keys`, `key_name`, `[slotN]` via
   `RivetCarry.SLOT_ACTIONS`: a weapon slot now has no key, so a `[slotN]` prompt must name what the player now presses,
   e.g. the wheel/Tab, never an empty `[]`). Any prompt string with a literal "Space"/"F"/"Q"/"G"/"Shift"/"1".."4" for
   these actions: switch to the `[action]` form. Add new ghost prompt keys to `en.po` if needed.
   If a prompt lives in a file you do not own (prologue scripts, gauntlet code), do NOT edit it: report a NEED line.
10. The gauntlet bot (`project/features/gauntlet/bot/bot_forms.gd`) and `project/features/souls/ghost_deploy_bot.gd` /
    `ghost_pilot.gd`: the gauntlet bot now presses the per-ghost deploy action (`ghost_deploy_N` for the form it wants)
    instead of cycle + `ghost_deploy`. Prove pilot identity: same deploys at the same ticks, same wave results as before
    (run the gauntlet bot on seed 7 before and after; compare the result JSON except fields that only name the bit).
    If identity is impossible because the cycle ticks are gone, measure and report the difference exactly.

## Unit tests (new file `project/tests/unit/test_ghost_number_keys.gd`, plus edit existing input tests)
- each number 1..4 deploys its own form (with all four owned), regardless of `forms.selected`;
- 1 beside an enterable car enters it and does NOT deploy or aim Dent; 1 inside the car leaves it and does not deploy;
- a number for a form the player does not own does nothing (phase stays IDLE, no cooldown, `last_refusal` empty);
- the table: sprint/handbrake on Space, melee on F, dash on Shift, car on 1, Q and G bound to nothing, weapon slots keyless,
  no bit or wire bit of an existing row changed (pin them against the list in this brief).
- `rivet_motion` dash with `hold_sprints` false: holding dash after the burst gives run speed, not sprint speed.

## Acceptance
- `node tools/lint/lint.mjs` green; `node tools/tests/run_unit.mjs --changed` green, then the full `node tools/tests/run_unit.mjs`.
- `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` green, including the 60 s replay: every shipped
  tape and replay byte-identical (no file under `project/tests/golden`, `scenarios`, `parity`, `saves` changes).
- `node tools/gate/quick.mjs` before each commit.
- Mutate after the last code commit: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_deploy.gd --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).
- Add one decision line to `docs/decisions.md` (append one line at the end):
  `- [2026-11-23] DECISION n26 keys: ...` (the table, slot order, key 1 and the car, pad keeps LB/RB, hold_sprints false).

## Allowlist (anything else: stop and report a NEED line)
`project/data/tables/input_actions.json`, `project/data/schemas/input_actions.schema.json`, `project/data/tables/rivet_motion.json`
(+ its schema only if needed), `project/features/player/**`, the input plumbing that packs bits (`TickInput`, `PlayerActions`,
`PlayerCommand`, `stage_pilot.gd` packing only), `project/features/souls/ghost_deploy*.gd`, `ghost_form_hud.gd`,
`ghost_pilot.gd`, new `project/features/souls/ghost_number_*.gd` helpers, `project/features/gauntlet/bot/bot_forms.gd`,
`project/boot/collect_call/objective_hint.gd`, `project/data/loc/en.po`, `project/tests/**` for these, `docs/decisions.md`
(append one line), `.uid` files of new scripts, `tools/debt/baseline.json` through the debt tool only.

Forbidden (other lanes): `ghost_attacks.json`, `ghost_forms.json`, the rest of `project/features/souls/**` (melee lane),
`project/features/combat/kills/**`, `combat.json`, `enemies.json`, `weapons.json`, `project/boot/prologue/**`,
`prologue_stage.json`, cast art, `native/`. Never touch `main` or another worktree.

## End with
What you changed (files, commits), the test/scenario/lint/mutate results with numbers, the pilot identity result, and every NEED line.
