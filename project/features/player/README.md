# features/player

Rivet under the player's hands (slice-play lane). Depends only on `core/` (LAY-05).

- `PlayerActions`: the action table `data/tables/input_actions.json` (`gtai.input-actions/1`):
  the bit each action takes in `TickInput.buttons`, its default keys / mouse / gamepad bindings,
  the aim quantisation and the movement feel. `install()` registers them into the InputMap at
  boot, so a settings screen rebinds the InputMap, never code.
- `LiveInput` (an `InputSource`): devices into one quantised `TickInput` per tick, so a recorded
  run replays bit-identically (SIM-05). The aim heading rides in `buttons` above `aim_shift`.
- `PlayerCommand`: a `TickInput` decoded into move / aim / held / pressed-this-tick.
- `TopDownMover`: acceleration, a capped turn rate and a strafe penalty on the 60 Hz tick.

Default bindings: WASD / arrows move, the mouse aims, left click fires, Space or right click is
the electroshock melee, E interacts (phones, hide spots, allies, the torch, rifles), F is
enter/exit car (a stub until the `vehicles` lane's API lands), Esc/P pauses. Gamepad: left stick
or d-pad moves, right stick aims, right trigger fires, A interacts, X melee, Y car, Back pauses.

Quest 1 wires these to its stage in `boot/collect_call/stage_pilot.gd`.
