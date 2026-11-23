# Brief n24-pressure-06: finish the rocket and the nail, then the bot's dash

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
This resumes your rocket-nail session. AGENTS.md and STANDARDS.md bind.

**Wall clock: hard stop 00:08. Start your LAST commit no later than 23:55** (the hook takes about 10 minutes).
Whatever is not committed by then is reported, not committed. **Godot is yours alone from your start.**
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/pressure` (PowerShell: `$env:APPDATA=...`) before every Godot run.
Windowed runs: `--position 0,1440`.

## Git law
One commit per task, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, stash, amend, rebase,
reset --hard, merge. Fix lint and format findings in your own edit and go on. Mutate after a code commit:
`node tools/mutate/mutate.mjs --file=<main .gd> --max=20 --lines=<changed lines>`; quote the score. If mutate would push
you past 23:55, skip it and say so.

## Director's decisions on your NEEDs (23:08)
- `project/boot/collect_call/view/fx_view.gd`: you may add ONE line (a dispatch call) if you still need it. Prefer not to:
  `WeaponFxArt.shot()` is already called first for Rivet's rounds.
- `project/features/combat/weapons/art/weapon_fx_art.gd` and `project/data/tables/weapon_art.json` (its `round_k` and
  the rocket/nail entries): no lane owns them and no lane's branch touches them (checked 23:07). You may edit them for the
  rocket look and the nail size, smallest change that works. Every other file outside the allowlist below: NEED.
- Quest 1 digest: ACCEPTED. Update the pinned digest in `project/tests/scenarios/scenario_quest1_input.gd:90` to
  `c211ee9720fc` (one line; the decision line you wrote already gives the reason). Commit it with task 0.

## Allowlist
`project/data/tables/enemies.json` (numbers of `weapons`), `weapons.json` (`enemy_fire`; look fields of `gloria` and
`rocket_launcher`), `combat.json` (`guard`, `deflect`), `project/features/combat/enemy_round_look.gd`, `enemy_rounds.gd`,
`shot_draw.gd`, `project/features/combat/weapons/gun_fx*.gd`, the three files above, `project/features/gauntlet/**`,
`project/dev/gauntlet/**`, `gauntlet.json`, `test_player.json` (+ schemas), `gauntlet_run.schema.json` (own optional
fields), `tools/gauntlet/**`, `docs/gauntlet-loop.md`, tests named for these, `docs/decisions.md` (append one line at the
END), `evidence/n24-pressure/**`, `C:\Users\kazda\kiro\gtai-masters\n24\pressure\`.
Forbidden: `project/features/player/**`, `rivet_motion.json`, `input_actions.json`, `project/features/souls/**`,
characters and their art, `melee_*`, `signature_kills.json`.

## In this order, each committed before the next

### Task 0 - rocket rest + quest pin (one commit, at once)
`enemies.json` `weapons.rocket.cooldown_s` 0.55 -> 1.4 (keep speed 13, lead, `relocate_after_shots`). Director's measure:
same seeds, rocket deaths 6 -> 1 of 15, average median death wave 5 -> 6. Quest 1 pin as above. Check
`test_foe_rocket_sites`, `test_player_motion_dash_dodge`, and the quest 1 scenario (`--only=` it). One decisions line:
"rocket cooldown 1.4: 0.55 overshot, the rocket killed 6 of 15 runs before wave 6".

### Task R1 - Rivet's rocket (one commit)
The owner played `main` and said "Blue rocket does not fit style of the weapon". Your arena fixture draws a grey rocket
with a vermilion tip, so find where the owner sees blue: run the REAL gauntlet (`node tools/dev/run.mjs gauntlet
--windowed -- --position 0,1440` or its headless still path; the owner plays with the weapon wheel) holding the rocket
launcher, and capture the rocket in flight AND its blast; also check the bare-hands path, the blast/smoke/bead rings,
the trail, and any place `Shot.LARGE` / `EnemyRoundLook.LARGE_*` / `round: large` reaches a `from_rivet` round. Whatever
paints Rivet's rocket or its blast ice blue: draw it in the launcher's colours (steel casing, amber exhaust; vermilion only
as the warhead's danger mark). Enemy large rounds stay `EnemyRoundLook.LARGE_*`. If nothing is blue anywhere, say so with
the stills and still give the exhaust amber. A unit test: a `from_rivet` rocket never takes `EnemyRoundLook.LARGE_*`.
Before/after stills at 32 and 64 px/m, same tick, to `C:\Users\kazda\kiro\gtai-masters\n24\pressure\` (the 64 px/m still
must really be at 64: your t46 "64ppm" still looks like the 32 one; check the zoom).

### Task R2 - Gloria's nail (one commit)
Gloria is the first gun, a nail gun: its round is a small fast nail, clearly smaller than every later gun's round (today
47.2 x 12.8 px at 32 px/m, bigger than the Gatling). Make its drawn length and width the smallest of every player round
(target about 60 % of the next smallest by length and width; it must still read as a nail at 32 px/m). Write
`evidence/n24-pressure/rounds/sizes-after.md` (same table as sizes-before, Gloria at the bottom) and commit both size
files. Before/after stills of the nail in flight at 32 and 64 px/m.

### Task D - the bot dashes (one commit) - spec: `evidence/briefs/n24-pressure-04-bot-stall-dash.md` Task 2 + 2c
Dash out of a large round's path and out of the stomp's 3.5 m during its 0.8 s tell, `test_player.json` per profile
`dash_chance` (0.2 / 0.6 / 0.9) and `dash_read_ticks` (30 / 16 / 8), `dashes` per wave in the result. Unit test with a
fake view. Keep `bot_brain.gd` `_pack` / `_view` / `intent` / `_profile` names (lane ghost adds one line there).

### Task E - damage by source (one commit, only if D is committed before 23:40) - spec: brief 04 Task 1b.

### Not now
Brief 04 Task 1 (stall) and Task 3: drop. Note in the report what you know of the stall cause.

## Report
Per task: done / not done, sha, files, checks with their result lines, mutate score, stills (paths), where the blue was,
the size table, every NEED.
