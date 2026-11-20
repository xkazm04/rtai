# n21-kerf brief 03b (--resume of attacks): what the director saw in your first evidence

Same rules and allowlist as brief 03. **Wall-clock hard stop: HARDSTOP. Commit deadline: COMMITBY.** Fix lint and
format findings in your own edits and go on. Never amend, never rebase. Stage per path. Mutate `--max=20`.
`export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf` before every Godot run.

## Seen (14:10, `charges_3views_64.png`, `kerf_beat_first_slice_32.png`)
1. **Overhead charge count does not read.** Toward and away tilt read at 64 and at 32 px/m (good). In the
   overhead column the curled ribbon lies OVER the back plate and hides the slots, and at 32 px/m the three
   slots are a few pixels. Fix: in the top rig draw both tail sprites UNDER the torso (z order / child order),
   and make the overhead lit/dark patches big enough to count at 32 px/m (a rounded patch per slot, at least
   3 px wide and 5 px long at 32 px/m; scale the mask in the top view only). Re-shoot `charges_3views_64.png`
   with the 32 px/m row showing 2/3 in the overhead panel countably.
2. **A zigzag line lies along the slot** (`kerf_beat_first_slice_32.png`, x 870..1250, y ~520): a thin teal
   polyline that zigzags over the straight slot from the after-image to the victim. Find what draws it (the
   shared flight tail / wisp whose segments still trail along the 9 m jump? the legacy `KerfView._path`? a
   sight line?). Whatever it is, on the blink tick the shared tail/wisp must restart at his new position (or be
   hidden for the blink's RETURN_TICKS), so the only line between after-image and Kerf is the one straight
   slot. If the fix needs a shared flight file (`ghost_tail.gd`, `ghost_flight.gd`: polish's), do it from your
   side (hide or reset through Kerf's own mount) or stop and write `NEED polish:` with the exact hook.
3. **The cutting blade must read on the arrival frame.** In the reel still he arrives as the CRUISE arrow
   (both blades back). On the press tick and the next CUT ticks the right blade must be thrust forward along the
   travel line in the top view and in tilt, as brief 03 item 2 says. Check the strip frames and make it so.
4. Then finish brief 03's evidence list (both slice strips with press/+3/+15, before/after vs n20, the films,
   legacy byte compare, scenario digests before/after, mutate).

## Final message
Commits, what each of 1-3 was and how it was fixed, the counts, digests, mutate scores, evidence paths, undone.
