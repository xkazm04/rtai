# n30 combat call 09: a street walker's kill is pixel-identical after the card-fall routing

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start: **evidence commit by
minute 30, report and END by minute 45.** Never end uncommitted.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: before every launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names
`n23-street` (`grep -l n23-street "$LOCALAPPDATA"/gtai/runs/*.json`), re-check every 30 s. Only shipped tools launch Godot.

## What is known
`480268dcf` added `project/features/combat/kills/kill_card_fall.gd` (`KillCardFall`) and routes a killed card foe onto his own
fall sheet in `kill_fall_cells.gd`; `--kill-card-fall=grid` restores the old path. A street walker (no `CastCardPose`) must
take the old path untouched. Read `evidence/n30/kills/card_fall.md` for the commands the card-foe stills used
(`tools/film/kill_reel.mjs`, `--before=<rev>` renders a temp worktree at that rev). Not yet proven on screen.

## Do
1. Same-tick 64 px/m stills of a STREET victim (a street cop or a crowd walker, not a card foe) killed with the machine pistol
   (or the weapon card_fall.md used), before = `--before=73895c4a3` (the commit before the routing), after = HEAD, three ticks
   across the fall (start, mid, settled). Diff the PNGs: changed px in the whole frame; target 0 (if non-zero, find why:
   another lane's change in between? list the commits in 73895c4a3..HEAD that touch rendering). Save the pair to
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/street_fall_identity_pair_64.png` (labelled before | after) and append one
   `frames.json` entry there (re-read it just before writing; `{file,title,ppm,before,note}`).
2. Re-mutate the routing: `node tools/mutate/mutate.mjs --file=project/features/combat/kills/kill_card_fall.gd --tests=<the tests card_fall.md names> --max=6`
   (time budget 15 min; if it runs longer, stop it by its own pid and report). Quote killed/(killed+survived).
3. Append both results to `evidence/n30/kills/card_fall.md` under a heading `## Street walker identity (c09)`; commit
   (`n30 combat: street walker kill pixel-identical before/after the card-fall routing (N px)`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook
(~12 min possible); on a stale class cache run `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"`.
Do not touch docs/decisions.md, JOURNAL.md, REPORT.md. No product code changes in this call: if identity fails, report it.

## Allowlist
`evidence/n30/kills/**`, `build/**`, the masters dir. Any other path: stop and report a NEED.

## Report and END
Commands with result lines, diff px per tick, mutate score, what you saw in the pair, what you could not do.

## Session 3 clock and one more point (13:50)
Launched 13:50: evidence commit by **14:20**, report and END by **14:35** (hard). Another builder (c10, bond film) runs
in parallel in this worktree: it touches only `evidence/n30/bond/**`; share Godot through the runs ledger as above.
4. Correct the warden note in `evidence/n30/kills/card_fall.md` ("Warden at the switch"): the cast lane measured him at 64 px/m in
   delivered frames (`C:/Users/kazda/kiro/gtai-wt/n23-prologue/JOURNAL.md`, the 13:52 c06b line; still
   `C:/Users/kazda/kiro/gtai-masters/n30/cast/warden_switch_64.png`): cap walk / hit0 / fall row0 p70 36 / 28 / 28-31, p55 30 / 23 / 22-31;
   "walk cap 22" in our note was a wrong reading. No sheet draws him larger; what changes at the switch is the angle (steeper top-down
   walk vs frontal fall) and the hat colour (grey bucket -> tan camo cap). Add a dated `CORRECTION (c09, cast c06b)` paragraph under
   that heading (do not delete the old text), and commit it in the same commit as point 3.
