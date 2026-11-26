import test from "node:test";
import assert from "node:assert/strict";
import { print, VERM, AMBER, INK, lerp, SAMPLES } from "./amber_rule.mjs";

test("VERM and the collar stay VERM", () => {
  assert.equal(print(VERM, true, true), "VERM");
  assert.equal(print(VERM, false, true), "VERM");
});
test("no AMBER-INK blend prints VERM after the rule", () => {
  for (let t = 0; t <= 1.0001; t += 0.05) assert.notEqual(print(lerp(AMBER, INK, t), true, true), "VERM", `t ${t}`);
});
test("a 30% and 35% blend printed VERM before and print AMBER after; 50% is STEEL either way", () => {
  for (const t of [0.3, 0.35]) {
    assert.equal(print(lerp(AMBER, INK, t), true, false), "VERM");
    assert.equal(print(lerp(AMBER, INK, t), true, true), "AMBER");
  }
  assert.equal(print(lerp(AMBER, INK, 0.5), true, true), "STEEL");
});
test("the rule changes nothing when amber_ink is off", () => {
  for (const [, c] of SAMPLES) assert.equal(print(c, false, true), print(c, false, false));
});
