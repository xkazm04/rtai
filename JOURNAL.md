# JOURNAL - lane d5-city (branch d-city), day run 2026-11-03

Iteration 1 (09:04) died on a billing error before any turn; iteration 2 (10:04) is the first real session.

## 2026-11-03 iteration 2 (10:04 - 11:34)

- MILESTONE 10:20 item 1 doctrine: palette.json `blood` #A30509 / `blood_dark` #540005 (world, actors, fx),
  `cop_blue` #3A4766 (luma 0.28 = the charcoal's 0.29; actors, vehicles), `cop_blue_hi` #4F86E0 (badge,
  light bar); vermilion loses use `cop` and layer `vehicles`. Gates `blood_r` 0.30 / `blood_gr` 0.18 /
  `blue_gate` 0.08; PaletteTokens.classify order blood -> verm -> teal -> blue; count_inks().
  look_d4_item keeps blood and cop blue as chroma-gated plates (a nearest snap would turn mid greys navy);
  look_d4 gets a `blood` plate (profile key, 1 in every row). `noir` is now a look_profiles row (D4 under
  NoirLook, never in auto). accent_audit counts all four inks + "vermilion on cop"; accent_debt rows
  cop_vermilion_32/48/64 (owner d5-cast). Evidence `evidence/d5-city/01-doctrine/`: goldens 11/11 + 5/5
  worst 0.00 (bit-identical), audit junction cop 9412/9660/2060 px, block 10580/6964/2744 px.
  Gates: lint 13/13, unit 331/331, scenarios 8/0 (replay final cbeb734ff9b97c41).
- FRICTION: a parse error (Variant into maxi) hung the windowed accent_audit; killed my PIDs. Use
  `--headless --check-only -s <script>` before every windowed run (autoload errors there are expected).

## REQUESTS
- REQUEST 1 -> d5-cast: cop rig parts + cop crowd-atlas looks (patrol 29.3k, riot 24.7k vermilion texels)
  go cop_blue (#3A4766) / cop_blue_hi (#4F86E0) per palette.json; the item print already keeps both inks.
  Your `features/characters/print_part.gdshader` needs the same gates (look_d4_item.gdshader lines 55-59:
  blood r >= 0.30 and max(g,b) < 0.18 r; blue b - max(r,g) >= 0.08) or blue parts print as ink. When they
  land, delete accent_debt rows cop_vermilion_* (the selftest reports them as paid).
- REQUEST 2 -> d5-combat: blood in the world (ground_decals) now keeps its red under look_d4 (`blood`
  plate); paint pools/splats in palette `blood` / `blood_dark` (r >= 0.30, max(g,b) < 0.18 r).
- REQUEST 3 -> vehicles (owner of art/vehicles/police*): cruiser vermilion is now an offender on `vehicles`;
  repaint body accents cop_blue, light bar cop_blue_hi.
