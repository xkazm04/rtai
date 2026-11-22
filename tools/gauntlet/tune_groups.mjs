import { baselineValue, clamped } from './tune_state.mjs';

export const DAMAGE_GROUP = 'enemy_damage';
export const REPAIR_GROUP = 'rivet_repair';
const repairMembers = ['rivet.repair_per_s', 'rivet.repair_delay_s'];
const damageKnob = (id) => /^enemy_weapon\.[^.]+\.(damage|splash_damage)$/.test(id)
  || /^[^.]+\.production_damage$/.test(id);

export const isGroup = (id) => id === DAMAGE_GROUP || id === REPAIR_GROUP;

export function memberIds(id, entries) {
  if (id === REPAIR_GROUP) return repairMembers;
  return id === DAMAGE_GROUP ? [...entries.keys()].filter(damageKnob) : [id];
}

export function scaledValue(id, knob, before, baseline, factor) {
  if (id === REPAIR_GROUP) {
    // The catalog direction makes survival harder. A factor below one reverses both directions.
    const { direction, ...bounds } = knob;
    return clamped(bounds, before, baseline, direction === 'down' ? before / factor : before * factor);
  }
  return clamped(knob, before, baseline, before * factor);
}

export function knobStep(id, requestedFactor, entries, baseline) {
  const factor = Math.min(1.25, Math.max(0.8, requestedFactor));
  const members = [];
  for (const member of memberIds(id, entries)) {
    const entry = entries.get(member);
    if (!entry) return null;
    const { knob, value: before } = entry;
    const first = baselineValue(entry, baseline);
    const after = scaledValue(id, knob, before, first, factor);
    members.push({ id: member, file: knob.file, pointer: knob.pointer, ...(knob.row && { row: knob.row }),
      before, after, baseline: first });
  }
  if (!members.some((m) => m.before !== m.after)) return null;
  return isGroup(id) ? { id, factor, members } : members[0];
}

export function occupied(id, used) {
  if (used.has(id)) return true;
  if (id === REPAIR_GROUP || repairMembers.includes(id))
    return used.has(REPAIR_GROUP) || repairMembers.some((member) => used.has(member));
  if (id === DAMAGE_GROUP) return [...used.keys()].some(damageKnob);
  return damageKnob(id) && used.has(DAMAGE_GROUP);
}
