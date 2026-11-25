# n30-cast-12: appliance warden hat, recolour candidate for the owner's call (tag `c12`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds, EXCEPT: no Godot at all in this call (the lane gate holds the lane's Godot
until ~15:05). Launched ~14:27. Hard stop 15:05 (report and END). No commit: evidence only, nothing in the repo changes.

## State
At death the warden changes hat: his walk sheet (`project/features/characters/art/view/p70/appliance_warden_planted8_armed_walk.png`
and `.../p55/...`; 5 facings across x 8 drawings down, cell = sheet width / 5 by sheet height / 8) wears a GREY bucket hat seen
from above; his hit and fall sheets (`appliance_warden_hit.png`, `appliance_warden_fall.png` beside it) wear a TAN CAMO cap.
Measured: no sheet draws him larger (`gtai-masters/n30/cast/warden_switch_64.png`). The owner will be asked: keep, or recolour
the walk's hat to match. Give him a picture of the recolour.

## Do (python + PIL only, scripts in `build/look/n30-c12/`)
1. Crop at 2x (nearest) the walk cells of facing right (column index 2) and down-right (column 1), drawings 1 and 5, at p70,
   and the hit cell of the same facing (read how hit is laid out first: print the sheet sizes). LOOK at them.
2. Build a hat mask in each walk cell: the grey hat pixels only (low saturation, the hat's value band, inside the head's top
   region: find the head as the top ~22 % of the figure's alpha bbox). Print the mask's pixel count per cell and save a mask
   overlay; LOOK at it: no pixel on the pole, the face, the vest or the outline ink (keep dark ink: value < ~45 out of 255 untouched).
3. Recolour the masked pixels to the hit cap's palette: sample the hit cap's mean tan and its light/dark camo tones, map the
   grey hat's luminance onto that tan ramp (keep the shading; this is a masked recolour, not a redraw; no new shapes).
4. Sheet `C:\Users\kazda\kiro\gtai-masters\n30\cast\warden_hat_candidate_2x.png` (1920x1080, dark grey background): rows =
   the 4 walk cells; columns = shipped walk | recoloured walk | shipped hit (same facing); a caption line of what is changed.
   LOOK at it and say honestly whether the recoloured hat reads as the same cap as the hit's (shape differs: bucket vs cap;
   that is the art, not the recolour).
5. Append an entry to `gtai-masters/n30/cast/frames.json` (re-read right before writing, keep every entry, valid JSON): file
   `warden_hat_candidate_2x.png`, title "Appliance warden: walk hat grey (shipped) | tan recolour candidate | hit cap", ppm "sheet 2x",
   before "warden_switch_64.png", note "candidate for the owner's call; not in the game".

## Allowlist
`build/look/n30-c12/**`, masters files. Repo art and code: read only. Anything else: NEED.

## Report
Sheet sizes, mask counts, the tan ramp sampled, what you saw, the frames.json count.
