import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { enemyWeapons } from './enemy_weapons.mjs';
import { statCards } from './survival.mjs';
import { digest, TABLES } from './tune_state.mjs';

export const SNAPSHOT_TABLES = ['enemies', 'weapons', 'combat', 'gauntlet', 'gauntlet_bonuses', 'test_player'];

export function tableSnapshot(runner, root = ROOT) {
  const tables = {};
  const weapon_refs = {};
  const survival_tuning = {};
  let enemy_weapons = {};
  for (const name of SNAPSHOT_TABLES) {
    const file = name + '.json';
    const path = join(root, TABLES, file);
    if (!existsSync(path)) continue;
    const bytes = readFileSync(path);
    if (name === 'enemies') enemy_weapons = enemyWeapons(JSON.parse(bytes));
    if (name === 'combat') survival_tuning.repair_per_s = JSON.parse(bytes).rivet.repair_per_s;
    if (name === 'gauntlet' && runner === 'gauntlet') {
      const repair = JSON.parse(bytes).rivet;
      if (repair) survival_tuning.repair_per_s = repair.repair_per_s;
    }
    tables[file] = digest(bytes);
    if (name === 'gauntlet_bonuses') {
      const bonuses = JSON.parse(bytes);
      for (const row of bonuses.rows) if (row.kind === 'weapon') weapon_refs[row.id] = row.ref;
      survival_tuning.stat_cards = statCards(bonuses);
    }
  }
  return { tables, weapon_refs, enemy_weapons, survival_tuning };
}
