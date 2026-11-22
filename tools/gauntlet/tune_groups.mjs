import { clamped } from './tune_state.mjs';

export const DAMAGE_GROUP = 'enemy_damage';
const damageKnob = (id) => /^enemy_weapon\.[^.]+\.(damage|splash_damage)$/.test(id)
  || /^[^.]+\.production_damage$/.test(id);

export function memberIds(id, entries) {
  return id === DAMAGE_GROUP ? [...entries.keys()].filter(damageKnob) : [id];
}

export function knobStep(id, requestedFactor, entries, baseline) {
  const factor = Math.min(1.25, Math.max(0.8, requestedFactor));
  const members = [];
  for (const member of memberIds(id, entries)) {
    const entry = entries.get(member);
    if (!entry) return null;
    const { knob, value: before } = entry;
    const first = baseline.values[member];
    const after = clamped(knob, before, first, before * factor);
    members.push({ id: member, file: knob.file, pointer: knob.pointer, ...(knob.row && { row: knob.row }),
      before, after, baseline: first });
  }
  if (!members.some((m) => m.before !== m.after)) return null;
  return id === DAMAGE_GROUP ? { id, factor, members } : members[0];
}

export function occupied(id, used) {
  if (used.has(id)) return true;
  if (id === DAMAGE_GROUP) return [...used].some(damageKnob);
  return damageKnob(id) && used.has(DAMAGE_GROUP);
}
