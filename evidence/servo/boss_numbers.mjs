// The Servo fight's numbers (copied from evidence/king/boss_numbers.mjs; --tag names the run dir) (encounter-balance-simulation): full fights, seeds x bots, headless,
// three at a time. Writes evidence/king/numbers/<bot>-s<seed>.json and evidence/king/boss-numbers.json.
// node evidence/king/boss_numbers.mjs [--seeds=1,2,3,4,5] [--bots=dodge,human,stand] [--quit=18000]
import { spawn } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
const arg = (k, d) => (process.argv.find(a => a.startsWith(`--${k}=`)) || `=${d}`).split('=')[1];
const seeds = arg('seeds', '1,2,3,4,5').split(',');
const bots = arg('bots', 'dodge,human,stand').split(',');
const quit = arg('quit', '14400');
const tag = arg('tag', 'it5');
const G = process.env.GODOT_BIN || 'C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe';
const out = `evidence/servo/numbers-${tag}`;
mkdirSync(out, { recursive: true });
const flags = { dodge: [], human: ['--bot-human'], stand: ['--bot-stand'] };
const jobs = [];
for (const s of seeds) for (const b of bots) jobs.push({ s, b });
const run = ({ s, b }) => new Promise(res => {
  const tel = `${process.cwd()}/${out}/${b}-s${s}.json`.replaceAll(String.fromCharCode(92), '/');
  const a = ['--headless', '--path', 'project', 'res://dev/arena/arena.tscn', '--fixed-fps', '60', '--quit-after', quit, '--',
    '--rigs', '--boss=servo', '--bot=boss', `--seed=${s}`, `--telemetry=${tel}`, ...flags[b]];
  const p = spawn(G, a, { stdio: ['ignore', 'pipe', 'pipe'] });
  let log = '';
  p.stdout.on('data', d => (log += d)); p.stderr.on('data', d => (log += d));
  p.on('close', () => { writeFileSync(`${out}/${b}-s${s}.log`, log); res(); });
});
const pool = async n => { const q = [...jobs]; await Promise.all(Array.from({ length: n }, async () => { while (q.length) await run(q.shift()); })); };
await pool(3);
const rows = {};
for (const { s, b } of jobs) {
  const f = `${out}/${b}-s${s}.json`;
  if (!existsSync(f)) continue;
  const t = JSON.parse(readFileSync(f, 'utf8')), bf = t.boss_fight;
  const errs = (readFileSync(`${out}/${b}-s${s}.log`, 'utf8').match(/SCRIPT ERROR/g) || []).length;
  (rows[b] ||= []).push({ seed: +s, down_s: bf.defeated_tick >= 0 ? +(bf.defeated_tick / 60).toFixed(1) : null,
    hp_left: bf.hp_frac, phase: bf.phase, taken: bf.dealt, deaths: t.deaths, tries: bf.tries, landed: bf.landed,
    rolled: bf.rolled, moves: Object.fromEntries(Object.entries(bf.moves || {}).filter(([k]) => k !== 'windups')), adds: [bf.adds_landed, bf.adds_tries], ticks: t.ticks, script_errors: errs });
}
const sum = {};
for (const [b, rs] of Object.entries(rows)) {
  const done = rs.filter(r => r.down_s !== null);
  const per = {};
  for (const r of rs) for (const [k, n] of Object.entries(r.tries)) {
    per[k] ||= { tries: 0, landed: 0, rolled: 0 };
    per[k].tries += n; per[k].landed += r.landed[k] || 0; per[k].rolled += r.rolled[k] || 0;
  }
  for (const v of Object.values(per)) v.hit_rate = +(v.landed / Math.max(v.tries, 1)).toFixed(2);
  const mean = xs => xs.length ? +(xs.reduce((a, c) => a + c, 0) / xs.length).toFixed(1) : null;
  sum[b] = { n: rs.length, downed: done.length, ttk_mean_s: mean(done.map(r => r.down_s)),
    ttk_range_s: done.length ? [Math.min(...done.map(r => r.down_s)), Math.max(...done.map(r => r.down_s))] : null,
    taken_mean: mean(rs.map(r => r.taken)), deaths: rs.reduce((a, r) => a + r.deaths, 0),
    adds_landed_tries: rs.reduce((a, r) => [a[0] + r.adds[0], a[1] + r.adds[1]], [0, 0]), per_attack: per };
}
writeFileSync(`${out}/boss-numbers.json`, JSON.stringify({ schema: 'gtai.boss-numbers/1', boss: 'servo',
  contended: true, quit_after: +quit, summary: sum, runs: rows }, null, 2) + '\n');
console.log(JSON.stringify(sum, null, 1));
