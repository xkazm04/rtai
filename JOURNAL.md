# JOURNAL - lane motion (n24, 2026-11-22)

- 17:21 session 1 start. main b3f4727c0. No NEED motion in other journals yet.
- 17:30 MILESTONE iface: TickInput.buttons is masked to 32 bits (`core/replay/tick_input.gd:16` `& 0xFFFFFFFF`). Wire bits used: 0-15 actions, 16-28 aim (heading 8 + valid + reach 4), 29 cover, 30 guard. **dash = row "bit": 18, "wire_bit": 31** (the last free wire bit). **ghost_deploy = row "bit": 19, "wire_bit": 32**: that needs the mask widened; motion's dash commit widens it to 48 bits (`& 0xFFFFFFFFFFFF`, pack() puts buttons at <<16, so bit 47 max = 2^63 safe, and below 2^53 for JSON doubles up to wire bit 36). Ghost may make the identical one-line edit; identical edits merge clean. Old tapes carry no bit >= 31, so they replay byte-identical.
- 17:24 ASTRA RUNNING legs since 17:24 (brief evidence/briefs/01-legs.md: films before, no-slide rule, every-weapon test)
- 17:40 DECISION sprint: `sprint` leaves Shift (keeps bit 5 and its pad button, keys []). On the keyboard the sprint is folded into the dash: holding Shift after the burst keeps sprint speed (`rivet_motion.json` `dash.hold_sprints` true; false = burst only). Why: the owner's "dash ... to support speed" with one key. Rejected: a second keyboard sprint key (one more key to learn), dropping keyboard sprint entirely (loses 9.3 m/s top speed the chase needs).
- 17:40 DECISION dash replay identity: dash state enters `PlayerMotion.write_state` only once a dash was used, so tapes without a dash press write the same bytes.
- 17:40 brief 02-dash written, waiting on legs (one Astra at a time).
