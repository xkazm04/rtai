export function enemyWeapons(table) {
  return Object.fromEntries(table.archetypes.map((a) => {
    const weapons = [a.weapon, a.alt_weapon];
    if (!a.explicit_spawn && !table.weapons[a.weapon]?.melee) weapons.push(a.production_weapon);
    return [a.id, [...new Set(weapons.filter(Boolean))]];
  }));
}

// Shared weapons only identify a shooter when the death-wave roster disambiguates them.
export function killerEnemy(run, catalog, enemyIds) {
  const by = run.death?.by;
  if (!by || by === 'timeout') return null;
  if (enemyIds.has(by) || Object.hasOwn(catalog, by)) return by;
  const owners = Object.keys(catalog).filter((id) => catalog[id].includes(by));
  if (owners.length === 1) return owners[0];
  const present = run.waves.find((w) => w.n === run.death.wave)?.enemies ?? {};
  const possible = owners.filter((id) => present[id] > 0);
  return possible.length === 1 ? possible[0] : null;
}
