# Brief n20-ohm-03b (resume): same bolt package, back inside Ohm's files

The director stopped your session at 02:12 (your work tree is exactly as you left it; nothing was reverted yet;
any Godot you had running was killed with it). Your commits 5e8b8d550 and 066779cca are accepted. The uncommitted
work broke the file-ownership law and the "do not delete docs to fit a size cap" rule. Fix that first, then finish
brief 03 (`evidence/briefs/n20-ohm-03-bolt.md`) as before. Environment as before (APPDATA, GODOT_BIN, d3d12,
`--position 0,1440`, one Godot, own PIDs only).

## 1. Revert what is not Ohm's (`git checkout -- <path>`, one path at a time)
- `project/features/combat/kills/kill_mark_art.gd`, `kill_shock_fx.gd`, `kill_view.gd`: nobody owns these tonight.
  The director saved your diff as `evidence/patches/n20-ohm-kill-rim-only.patch` and will raise it as a morning
  Call (the shock-kill X-ray over a falling spectral-Ohm victim). Revert all three.
- `project/features/souls/ghost_hand.gd` is flight's: revert it and put `ohm_prongs` in an Ohm file (`ohm_fork.gd`),
  calling the public `GhostHand.local_to`.
- `tools/debt/baseline.json`: revert your hand edit. Only `node tools/debt/debt.mjs --update` may change it, and only
  when `--check` prints `tighten:`.
- Restore every `##` doc line you removed in `ohm_view.gd` (the 8-line header and the n15 note) and in the combat files
  (they come back with the revert). If `ohm_view.gd` then passes 200 lines, move CODE out to `ohm_bolt_view.gd` /
  `ohm_fork.gd`, never comments.

## 2. The two stun-spark call sites: one line each, line count unchanged
You may change exactly one existing line in each of `project/features/combat/react/shock_arcs_view.gd` and
`project/features/combat/weapons/fight_areas_art.gd`, adding and removing no lines and no comments or constants
(their sizes sit at the debt cap). Route the spark COUNT through Ohm's code instead of adding an `if`:
- shock_arcs_view.gd: `ShockJolt.arcs(self, c, ppm, arena.tick + h.id, n)` ->
  `ShockJolt.arcs(self, c, ppm, arena.tick + h.id, OhmVictimRims.arcs(h, n))`, which returns `Vector2i.ZERO` for a
  rim-marked victim (check `ShockJolt.arcs` then draws nothing).
- fight_areas_art.gd: wrap the `n` on the `var n: int = StunCrowd.cap().w if light.has(h.id) else 2` line as
  `OhmVictimRims.sparks(h, ...)` returning 0 for a marked victim; read `WeaponFxElectro.stun` to be sure a count of 0
  draws nothing AND returns true (else `_stun` draws its fallback). If 0 cannot do that without editing those
  files, leave that site unchanged and say so; do not add lines.
If gdformat would wrap the changed line (over the line limit), shorten the helper's name rather than add lines.
Both are legacy-identical when not spectral (a test: legacy look -> the counts pass through unchanged).

## 3. Then finish brief 03
Build items 2 to 8, acceptance 1 to 4 as written there (test_ohm_bolt_draw.gd, lint, `--changed`, scenarios incl.
replay, the two strips + press4_close_64 + cancel_vent_32 into `C:\Users\kazda\kiro\gtai-masters\n20\ohm\bolt\`,
quick gate, staged per path, mutate on `features/souls/ohm_bolt_draw.gd`). The diff of every file outside
`ohm_*`/`test_ohm_*` must be the two single lines above; show `git diff --stat` of your final commit.

Hard stop: commit what is finished by 03:00 and report (the director's session ends at 03:17). If the strips are
not done by then, commit the code and say which frames exist.
