# REPORT - n25 lane `path` (2026-11-23): the prologue becomes the start of the game


Branch `n25-path` from `main` `b3f4727c0`. Worktree `C:\Users\kazda\kiro\gtai-wt\int-n20`. Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n25\path\`. Briefs and Astra's final messages: `evidence/briefs/n25/`.

Final commit `667f70be2`. Gate: `node tools/gate/run.mjs --rev=HEAD` -> `gate: PASS` (lint 19/19 over 2050 files, unit 3801 pass /
0 fail / 2 skip, scenarios 68/68, parity bit for bit over 1200 steps with the planted mutation caught at 629, selftest goldens
11/11 + 5/5, release-compile 931/0), `build/gate/667f70be223a/gate.json` (git-ignored). No `--reels` run yet (after the freeze).
Determinism: replay `cbeb734ff9b97c41` and parity `94b2865f7f17d778` unchanged; every shipped tape and quest checkpoint byte-identical.

## What works

| Item | Evidence | Number |
|---|---|---|
| Lessons one at a time: one card owns the strip, 0.5 s gap, claw -> guard -> roll, roll only after the first pole catch | `32d64cc73`, `edb61ad00`; `lessons.mp4`, `lesson-{claw,guard,roll}.png` | pilot seed 7: strike 2056-2193, claw 2334-2454, guard 2485-2605, roll 2660-2780, wheel 4830, fire 4831-4951 (no overlap); film 35.02 s; mutate `prologue_prompts.gd` 17/19 |
| Mulroney's shotgun: 8 pellets, 26 deg cone, 9 m, 0.8 s pump with a moving fore-end, a cream marker and a clack | `9d7d3e6ee`, `537c00105`, `c5fba0f4e`; `shotgun.mp4`, `shotgun-pump-64ppm.png` | unit: 24 dmg at 2 m, 6 at 8 m, 0 at 11 m; pilot wave 2 57.43 s, 12 blasts, he falls last; film 20.0 s; mutate 17/20 |
| Player shotgun row (8 x 30, 13 deg, 9 m, 1.25 Hz, mag 5, reload 1.8 s, `enabled: false`, rifle stand-in art) | `9d7d3e6ee`; `shotgun-cone.png`, `shotgun-held-64ppm.png` | explicit loadouts only; pickup after the fight off |
| New game starts the prologue: the menu's Start runs it, its end card holds 3 s, then quest 1 opens in the same scene (no menu); Continue resumes a prologue save at its verified beat checkpoint; `--skip-prologue` keeps the direct quest 1 Start; embedded quest runners, films and tapes keep `start()` | `9a7109fbe`, `4e0e7ac20`, `a9dd5a2b5`, `fcd17bf37`; `newgame-to-quest1.mp4`, `film-quest1-first-line.png`; `scenario_prologue_handover` | menu pilot seed 7: Start 0, end card 9495, hand-over 9675, quest 1 first line 9676 = 161.27 sim s; two runs cmp-identical; scenarios 68/68, every shipped tape byte-identical, replay `cbeb734ff9b97c41`, parity `94b2865f7f17d778`; unit 3782/0; mutate `new_game_path.gd` 18/18 |
| Shotgun registered in the held-art registry with 15 tracked stand-in holes | `28972c074` | `test_held_classes`, `test_arsenal_audit` 15/15 |
| yard NEED served: `--yard-dressing` in the prologue entry's KNOWN_FLAGS | `3aead09f1` | dry run `flags checked: 1` |
| Mulroney's orders show the owner's whole line through its reading time (the short command strings are gone) | `e43aa8c92`; `mulroney-order-full-line.png`, frame 120 s of `newgame-to-quest1.mp4` | `test_prologue_dialogue` +46 lines |
| The money card is hidden through the prologue and appears with quest 1's HUD | `8cef3b4e3`; `hud-no-cash-before-after.png` (same tick, card gone) | additive `HudState.cash_visible`, default true; mutate `hud_state.gd` 1/1 |
| Mutate runs a full sample on `prologue_game.gd` (last night's runner failure: a test interrupted by a mutant was counted as infra; the CLI refused an in-lane scratch copy) | `c67e72538` | `prologue_game.gd` --max=40: 24 killed / 13 survived = 64.9 %, 3 invalid, **0 infra** |
| One film from the menu's Start through the prologue into quest 1's first line, real time | `672be84ed`; `newgame-to-quest1.mp4` (re-taken 06:05 on `667f70be2`: opens on the "Prologue" title card), `film-handover.png`, `film-quest1-first-line.png` | 170.70 s 1080p60 with sound (one take, longer than the 40 s clip rule on purpose: it is the whole path); film pilot ticks identical to the headless pilot |
| The title card names the chapter Start opens: "Prologue" on the real menu, "Quest 1: Collect Call" for `--skip-prologue` and embedded runners (one predicate for card and button) | `667f70be2`; `title-prologue.png` | mutate `quest1_card.gd` 4/4; unit +1 |
| The whole path timed by the menu pilot (lane item 5) | `node tools/dev/run.mjs newgame_pilot --bot --seed=7` on `667f70be2`, twice, results cmp-identical | Start 0, end card 9495, hand-over 9675, quest 1's first line 9676 = **161.27 s** of play; ~8.5 s wall headless each (CONTENDED) |
| Shotgun close-up at 64 px/m, both fighters in frame through the pump windows | `672be84ed`, `69f1099c2`; `shotgun-close-64ppm.mp4`, `shotgun-pump-64ppm.png` | 12.00 s 1080p60 |

Note on the lessons table: the wheel card waits for the player to open the wheel; the pilot opens it on the next tick, so it shows
1 tick in the pilot, as long as a human needs.

## What does not

- `hud_view.gd` mutate 0/20: draw code; no test reads the drawn money card, so the hide is evidenced by the still only.
- `prologue_game.gd` mutate 64.9 %: 13 survivors (the entry's wiring; the battle and prompts have their own tests).
- At 32 px/m Mulroney's pump reads as a small cream marker above his name tag; the 64 px/m close-up shows it, the 32 px/m clip barely.
- `shotgun-close-64ppm.mp4` is 12.00 s, under the 15 s clip floor (it covers two pump windows; the 32 px/m `shotgun.mp4` is 20 s).
- The yard still looks like the tiled floor in this lane's films: the rebuilt yard is the yard lane's, on its own branch.

## What blocked or slowed you

- Package 03 stopped itself at its first step (15 min): the arsenal audit wants 15 `shotgun` hole keys, the brief named one. Resumed with the authorization.
- Package 04 ran into the 75 min cap without a final message (about 10 min of mine to recover its numbers from `build/mutate` and the gate).
- Package 05 waited for my gate before it could start Godot (about 17 min idle by design: one Godot per lane).
- The real-time film re-take: 15 min of capture (Movie Maker at about 11 fps on a contended machine) + 2 min encode.
- Background watchers in Git Bash (`tasklist` loops) returned at once twice; PowerShell `Wait-Process` works (about 5 min lost in session 3).

## Calls for the owner

### The prologue's script vs quest 1's opening (found by package 03; quest 1 not edited)

| Prologue | Quest 1 opening |
|---|---|
| `b3_l08_fax_hideout`: Fax sends Rivet to "the skip on Harbor Road". | `b1-dumpster` opens in "Factory Row alleys"; `SLICE__HINT_HIDE` "Walk [move] to the dumpster, hide: [use]". The `harbor-skip` hide spot is used later, in `b6-hot-walk`. |
| `b3_l11_fax_location`: "Go to the Toner Room, I will wait for you there." | The place agrees; the immediate objective differs: Rivet hides and answers another phone before `b3-toner-room`. |
| `b3_l05_fax_talent` introduces Fax; `b3_l10_fax_channel` opens "Operation Dethrone"; `b3_stage_communicator` gives a radio "to avoid phone boots". | `patch-collect-call` offers "a collect call from: 'Fax.'"; `rivet-who-is-this` asks "Who is this?"; `fax-statistically` gives the address again. |
| `b3_l07_rivet_quiet`: "They stopped. They stopped talking."; the street beat clears heat to zero. | `rivet-my-hands` asks "Why is there whispering?"; `b1-dumpster` starts "at heat 2". |
| `b1_l02_rivet_three`: "Three. I did three."; Rivet uses a pistol in the prologue. | `rivet-line-stopped` recalls killing a cop "With another cop. THROUGH another cop."; `fax-slow-motion`: "two cops into a stamping press"; `b3-toner-room` calls Gloria "Rivet's first weapon". |

Quest 1's first shown line: `rivet-line-stopped`, "Okay. Okay okay okay. The line stopped." (quest tick 0).

### Does Rivet keep Mulroney's shotgun?

Today no (the script does not say so): `command.drops_shotgun: false` in `prologue_stage.json`, and the player row
`weapons.shotgun` is `enabled: false` (explicit loadouts only, rifle stand-in art). One value turns the drop on; the gun then
still needs drawn held art. See `shotgun-held-64ppm.png` for how it plays in Rivet's hands today.

### The panicked cops' run speed

Your pick was "keep it; decide after you play it". Unchanged tonight; watch the first 40 s of `newgame-to-quest1.mp4`.

## Merge notes

- `enemies.json`: one existing row changed by one string: `sergeant_mulroney.weapon` `rifle` -> `shotgun` (the contract); new
  `weapons.shotgun` row. `weapons.json`: one new row at the end. No existing number changed. The n24 pressure lane edits rows of both.
- `project/features/combat/ai/enemy_weapon.gd` +4 lines (optional `pellets`, `spread_deg`; defaults 1 and 0): n24 may touch this file.
- `project/data/tables/held_classes.json`, `project/dev/rivet_arsenal/arsenal_known_holes.json`: `shotgun` entries only.
- `project/features/hud/hud_state.gd` +1 (`cash_visible`, default true) and `hud_view.gd` (the cash card draw guarded by it):
  not an n24 file, but any lane drawing the HUD meets it.
- `project/boot/quest1_game.gd`: Start/Continue routing only (through `NewGamePath`); quest 1 lines and data untouched.
- `tools/mutate/`: a test interrupted by a mutant counts as killed, and an in-lane scratch copy is allowed (`c67e72538`).
- `prologue_stage.json`: path's blocks only: the old `weapons` stand-in shotgun row and `command.shotgun_half_deg` removed,
  `command.drops_shotgun: false` added (schema to match). The yard lane changed only `yard.dressing`; no `MILESTONE yard-shape`,
  so nothing was merged from n25-yard and the pilot's walkable area is unchanged.
- `project/boot/new_game_path.gd`, `project/boot/prologue/prologue_autosave.gd` (new), `project/boot/quest1_card.gd` (subtitle from
  `NewGamePath.starts_with_prologue`).
- `project/boot/launch_args.gd` KNOWN_FLAGS +`--skip-prologue` (debt accept line in the baseline).
- Root `JOURNAL.md` / `REPORT.md`: add/add with the yard lane, keep each lane's own.

## Next steps

1. The owner judges the script mismatches above; quest 1's opening is then rewritten to follow the prologue (heat 2 vs zero, the
   skip on Harbor Road vs the Factory Row dumpster, "Who is this?" after Fax has already spoken to Rivet).
2. Draw the player shotgun (held art; today the rifle stand-in) and decide whether Rivet keeps Mulroney's gun after the fight
   (`drops_shotgun` in `prologue_stage.json` `command`, today false).
3. A test that reads the HUD's drawn money card (`hud_view.gd` mutate 0/20) and a few for `prologue_game.gd`'s 13 survivors.
4. Re-take `newgame-to-quest1.mp4` on the merged yard so the morning film shows the rebuilt factory.
5. Voices (blocked outside this run).

## Astra ledger

| Call | Minutes | Verdict | Note |
|---|---|---|---|
| lessons | 53 | accepted | |
| shotgun | 47 | accepted | left 2 unit tests red (registry files outside its allowlist) |
| newgame | 15 | bounced | stopped at step 0b on a one-entry allowance; resumed |
| newgame (resume) | 53 | accepted | routing, save point, menu pilot, scenario; script mismatch table |
| faults | 75 | accepted | hit the 75 min cap with no final message; every item committed; I took the numbers from `build/mutate` and the gate |
| title | 27 | accepted | one predicate for card and button; still `title-prologue.png` |

Total: 6 calls, 270 min, 5 accepted, 1 bounced (and resumed).

What I would brief differently: name every registry an added weapon id must appear in (held classes, arsenal holes, audio cues)
up front instead of an allowlist of the files I guessed; give a package with a film in it a hard "final message by" time 10 min
before the cap; and list the title card among the surfaces a routing change shows (I found it in the film, not in the brief).
