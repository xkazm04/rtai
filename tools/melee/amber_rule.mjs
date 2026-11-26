// Node mirror of the item print's opaque-colour branch (look_d4_item.gdshader, `else`), before and
// after the amber print rule (evidence/n31-melee/05-amber/look_d4_item.patch). Sim-free, view only.
import { fileURLToPath } from "node:url";

export const CREAM = [0.949, 0.91, 0.835];
export const VERM = [0.91, 0.314, 0.165];
export const TEAL = [0.122, 0.71, 0.659];
export const AMBER = [0.929, 0.671, 0.259];
export const INK = [0.09, 0.075, 0.106];
export const STEEL = [0.561, 0.533, 0.506];

const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
export const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
export const lerp = (a, b, t) => a.map((v, i) => v + (b[i] - v) * t);

// Returns the printed ink name. Ties keep the earlier candidate, as the shader's strict `<` does.
export function print(col, amberInk, rule) {
  const cands = [["CREAM", CREAM], ["STEEL", STEEL], ["INK", INK], ["VERM", VERM]];
  if (amberInk) cands.push(["AMBER", AMBER]);
  let [o, best] = ["CREAM", Infinity];
  for (const [n, c] of cands) { const d = dist(col, c); if (d < best) { best = d; o = n; } }
  const dv = dist(col, VERM);
  if (rule && amberInk && o === "VERM") {
    const ab = INK.map((v, i) => v - AMBER[i]);
    const t = Math.min(1, Math.max(0, col.reduce((s, v, i) => s + (v - AMBER[i]) * ab[i], 0) / ab.reduce((s, v) => s + v * v, 0)));
    const seg = dist(col, AMBER.map((v, i) => v + ab[i] * t));
    if (seg <= dv) o = t < 0.5 ? "AMBER" : "INK";
  }
  if (dist(col, TEAL) < best) o = "TEAL";
  return o;
}

export const SAMPLES = [
  ["pure VERM", VERM],
  ["Rivet collar (VERM fill)", VERM],
  ["plasma HOT core (kill_hole_fx HOT)", [1.0, 0.96, 0.78]],
  ["EMBER #E9A23B (kill_hole_fx)", hex("#E9A23B")],
  ["sear ramp EMBER->CHAR 25%", lerp(hex("#E9A23B"), [0.16, 0.11, 0.09], 0.25)],
  ["sear ramp EMBER->CHAR 50%", lerp(hex("#E9A23B"), [0.16, 0.11, 0.09], 0.5)],
  ["sear ramp EMBER->CHAR 75%", lerp(hex("#E9A23B"), [0.16, 0.11, 0.09], 0.75)],
  ["sear CHAR (plasma_scorch_view)", [0.16, 0.11, 0.09]],
  ["flame ember hot #FFD23A", hex("#FFD23A")],
  ["flame ember rim #EE6A1C", hex("#EE6A1C")],
  ["50% AMBER/INK blend", lerp(AMBER, INK, 0.5)],
  ["rim #EE6A1C half to INK", lerp(hex("#EE6A1C"), INK, 0.5)],
];

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  console.log("| sample | before | after |\n|---|---|---|");
  for (const [n, c] of SAMPLES) console.log(`| ${n} | ${print(c, true, false)} | ${print(c, true, true)} |`);
}
