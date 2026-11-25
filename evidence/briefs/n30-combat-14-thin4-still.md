# n30 combat call 14: the owner's alternative for the thin hop/stun: 3 px (shipped) | 4 px, same tick, stills only

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start: **evidence commit by minute
20, report and END by minute 30 (hard).** Never end uncommitted, and never end with the product file still edited (restore it first).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: before every launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names
`n23-street` (re-check every 30 s). Only shipped tools launch Godot.

## Why
The owner asked for the thin hop and stun look back (`a0f9c8bed`: `THIN_BODY_PX` 3, `THIN_CORE_PX` 1.5 in
`project/features/combat/weapons/art/weapon_fx_electro.gd:30`). At 3 px the stars read cream/tan, not amber. The REPORT offers
4 px as a one-value alternative: the owner needs to SEE it beside 3 px.

## Do
1. Read `evidence/n30/electric/thin.md` (the take command `node tools/film/owner_takes.mjs <dir> 64 electro_gun_hop`, hop tick
   121, stun tick 150, the crop boxes and the hop/stun box colour counts it used).
2. 3 px = the shipped frames: re-take at HEAD (`build/p5-takes/n30-thin3`) unless thin.md's after frames are still on disk at the
   same ticks (then reuse them; say which).
3. Edit ONLY line 30 to `THIN_BODY_PX: float = 4.0` (leave the core at 1.5), take again (`build/p5-takes/n30-thin4`), then restore
   with `git checkout -- project/features/combat/weapons/art/weapon_fx_electro.gd` and prove `git status --short` shows no
   `project/` path.
4. Same boxes as thin.md: amber / red / teal px in the hop box at t121 and the stun box at t150, 3 px vs 4 px. Make
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/thin_3_vs_4_pair_64.png`: two rows (hop t121, stun t150, the same crops
   thin.md used, scaled like `stun_thin_pair_64.png`), columns "3 px (shipped)" | "4 px (one value)", labelled. LOOK at it and
   say in one sentence per row which reads as amber current.
5. Append a `## 3 px vs 4 px (c14)` section to `evidence/n30/electric/thin.md` (commands, counts table, what you saw), append one
   `frames.json` entry in the masters dir (re-read it just before writing; `{file,title,ppm,before,note}`), and commit thin.md
   (`n30 combat: thin hop/stun 3 px vs 4 px stills for the owner (no code change)`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook.
Do not touch docs/decisions.md, JOURNAL.md, REPORT.md.

## Allowlist
Commit only `evidence/n30/electric/thin.md`. Temporary edit (restored, never committed): line 30 of `weapon_fx_electro.gd`.
`build/**` and the masters dir freely. Any other path: stop and report a NEED.

## Report and END
Counts table, what you saw per row, `git status --short` after restore, commit hash, what you could not do.

## Clock override (launched 14:49)
The parent session dies at 15:15: **restore line 30 the moment the 4 px take is on disk**, evidence commit by **15:07**, END by
**15:11**. If the 4 px take is not on disk by 15:02, restore the file, commit nothing, and report what you have.
