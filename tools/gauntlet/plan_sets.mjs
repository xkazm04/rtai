import { checkPlan } from './tune_git.mjs';

// knobStep records the rounded, clamped table values (including budget.unit) for every member.
export function planEdits(plan) {
  checkPlan(plan);
  return plan.changes.flatMap((change) => change.members ?? [change]);
}

export function setArguments(plan) {
  return planEdits(plan).map(({ file, pointer, after }) => '--set=' + file + '#' + pointer + '=' + after);
}
