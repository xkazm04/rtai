# Brief 09 `doc-pass`: the loop doc after night 2, and a compare header fix (lane loop, n23)

Hard stop: 07:45 wall clock. Commit deadline: 07:40. Commit each step as it lands.
Fix lint and format findings in your own edit and go on. **Node only: no Godot process of yours** (the director's batches hold the lane's two Godot slots).

## 1. `tools/gauntlet/compare.mjs` header (small)

The arm header shows the tick cap for `cycle1` (216000) but not for `street` (`evidence/n23-loop/base-street/batch.json`), though both ran on the same tree. Find why (manifest field present in one and not the other?) and print the cap the same way for both, or `tick cap not recorded` when the manifest truly lacks it, never a guess. Add a test. Regenerate `build/n23/compare.{md,html}` with every arm whose batch exists now (main, street, merged = `moves/on`, cycle1, and cycle2 = `cycle2/after` if its `batch.json` exists).

## 2. `docs/gauntlet-loop.md`: replace the night-1 material that tonight superseded

Keep the structure and the style of the doc (short sentences, links to evidence). Edit only these sections; keep night 1's facts as one dated line each where they are history:

- **"What the owner sees in the morning, and what needs their pick"**: point at `REPORT.md`, the compare page (`tools/gauntlet/compare.mjs`, tonight's arms), each cycle's `tune-ledger.md` under `evidence/n23-loop/cycle<k>/`, `evidence/n23-loop/ablate/summary.md`, and `C:\Users\kazda\kiro\gtai-masters\n23\loop\frames.json`. Night 1's two open calls are answered: the floor (now the null-salt floor, link the section) and the opening budget (street's budget in tenths, `budget.unit` 10).
- **"Proposals"**: night 1's five became tonight's four moves and second ranks (built by the moves lane); say so in one line and keep the list as history under a dated sub-heading. Tonight's proposals live in `REPORT.md` (link it); do not copy them.
- **"Where the test player is unlike a person"**: add tonight's measured differences (numbers from the files named):
  - It keeps its own blast clearance by rule (`project/data/tables/test_player.json` `blast_margin_m`), so Rivet's own blast never hurts it (0 self damage measured in the controls-moves smoke); a person will hit himself.
  - It rolls each move opening once per target from its salted stream (`project/features/gauntlet/bot/`, BotMovePlan); Tonnage's armour crack was used 7 times in 10 average runs against Kerf's blink 672, Ohm's short-circuit 340, overkill carry 2250 (`evidence/n23-loop/moves/on/runs/`, `moves{}` per wave): the bot rarely sits in Tonnage beside a war machine in its stomp recovery.
  - It waits to repair: with repair off it stalls (ablation `repair-off`, seed 1, `evidence/n23-loop/ablate/summary.md`), and repair undid 100 % of each wave's damage on every merge tonight (compare page "Repair share").
  - Average and expert play the same game to wave 40: the expert's better aim and timing buy nothing while nothing threatens it (separation average -> expert: gap 0-1 wave, 1-2 of 9-15 seeds; compare page).
- **"Known gaps after night 1"** -> **"Known gaps after night 2"**: drop what was fixed (guard deflects now counted; the tick cap now handled by the wave limit and censoring), keep what still holds, add: `bot_brain.gd` mutation 5/12 killed (moves logic under-tested); the 216000-tick gauntlet cap makes an uncapped average run 8-10 min; enemy damage is only reachable through shared `enemies.json` until street's gauntlet `enemy_damage_k` is merged; Kerf's slice one-shots the war machine (moves lane finding), so boss-wave times measure Kerf, not the boss.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green (quote the count); `node tools/lint/lint.mjs` green; `node tools/evidence/cites.mjs docs/gauntlet-loop.md` shows no MISSING (quote its summary line).
- Read your edited sections back once for numbers: every number names its file.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`. Never kill a process you did not start. Do not touch `evidence/**` (the director's batches write there), `C:/Users/kazda/AppData/Local/Temp/gtai-*`, or another lane's worktree.

## Files

Allowlist: `tools/gauntlet/**`, `docs/gauntlet-loop.md`, output under `build/n23/`. Any other path: stop and report a NEED.
Forbidden: `project/**`, every table, `JOURNAL.md`, `REPORT.md`, `evidence/**`, `docs/decisions.md`, other worktrees.

## Repo law

Staged per path (`git commit -- <paths>`); no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`. Files about 200 lines (hard 300), functions <= 40 lines.

End with: files changed, commits, commands and results, anything not done and why.
