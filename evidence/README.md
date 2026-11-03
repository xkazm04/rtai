# n-d4 night evidence index (lane d4-production, 2026-11-02 / 03)

One folder per iteration that left evidence in the tree; the full frame sets, masters, prompts and tools are in
`C:\Users\kazda\kiro\gtai-masters\night\d4-production\` (ladders `ladder.png` then `ladder2.png` from iteration 14, summary sheets `night_iter*_summary.png`).
The day-by-day record is `JOURNAL.md` (MILESTONE / CHECK / REJECTED / REQUESTS / NEXT entries).

| Folder | What is in it |
|---|---|
| `iter6/` | quest 1 places + cast art summary, the first quest view patch (superseded by `iter12/`), gates |
| `iter8/` | moving-traffic atlas, damage / hijack atlases, generic roofs; generator patch v1 (superseded by `iter10/`); traffic wiring patches (superseded: n-visual wired traffic itself); gates, bench PASS at 38136e8 |
| `iter10/` | inked paving joints, plaza flags, junction zebras; **generator patch v2**, **crowd slot patch**; gates, bench at 56b9b72 |
| `iter12/` | tank tracks, bollard, HUD numeral strip; quest 1 view patch (superseded by `iter14/`); gates at 297bd42 |
| `iter14/` | ink splat sticker (FX), Toner Room floor, inked arc ball, flat heat pip; **quest 1 view patch (final)**; muzzle fade patch for visual-engine; summary sheet; gates at 4477108 |

## Patches for code owners (apply after merging n-d4; none is committed as code)

| # | Owner | Patch | Note |
|---|---|---|---|
| 16 | quest 1 | `iter14/q1_view_art.patch` | 4 view files: places (+ Factory Row concrete, Harbor Road pavement + kerb), cast (incl. Rivet, patrol cops, Rivet's hide-spot peek from rig captures), HUD frames + inked cash counter, ink HP bar, the inked arc ball loop. Dry run (04:36, before the arc ball; with it unit 166/166 in scratch-q1): main 721fbbb + n-d4 merges with no conflict, the patch applies, lint 13/13, unit 166/166, scenarios 8/8; also applies with n-visual merged in |
| 19 | city / generator | `iter10/generator_art_pick_v2.patch` | generic roofs in the pick, no neighbour repeats, upright lettered roofs, plaza quarter turns, street variants cycle; moves the AST-12 golden list (included) |
| 21 | characters | `iter10/rig_variant_new_looks.patch` | crowd slots 3 and 7 use the hoodie / cap and overalls / bald parts |

| 23 | visual-engine | `iter14/fx_muzzle_fade.patch` | fx.json `muzzle.fade_from` 0 -> 0.6: the 3-tick flash prints as a solid inked star instead of dither fragments (crackle wants the same, REQUEST 14) |

## Optional requests to visual-engine (owner's eye)

- 20: the target's speckled slabs would come from the print pass grit, not texture specks.
- 22: the aquatint prints soft cloud blotches on the cream paving at 64 px/m (`masters:.../work/i12_strip64.png`).

## Owner decisions still open

REQUEST 24: who ships the in-world soul sprites (n-d5 has D5 ones in masters, unshipped; this lane can slice + ship).

HUD / lettering font for words (no font bundled; numerals are own art in `features/hud/art/hud_digits.png`), cop
uniform vermilion share, blood ink vs vermilion (the target paints it vermilion; we ship ink), teal robot eyes in the
quest 1 design notes (shipped as ink).

## Codex use

29 images, 194 cells, 7 rejected (camera breaks / front views), no usage limit hit. Every AI asset has a line in
`steam/ai-provenance/2026-11.jsonl`; procedural redraws carry a `code:` tool line.
