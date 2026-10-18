// Runs the report template's model script and checks its figures against hand-computed values.
// Usage: node tests/model_test.js
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');

const html = fs.readFileSync(path.join(__dirname, '../skills/nawah/assets/report-template.html'), 'utf8');
const src = (html.match(/<script id="nawah-model">([\s\S]*?)<\/script>/) || [])[1];
if (!src) { console.log('FAIL the template has no <script id="nawah-model">'); process.exit(1); }
const ctx = { Intl };
vm.createContext(ctx);
vm.runInContext(src, ctx);
const M = ctx.NawahModel;

let failures = 0;
function t(name, fn) {
  try { fn(); console.log('ok   ' + name); } catch (e) { failures++; console.log('FAIL ' + name + ': ' + e.message); }
}
const close = (a, b, eps = 1e-6) => assert.ok(Math.abs(a - b) <= eps * Math.max(1, Math.abs(b)), `${a} != ${b}`);
const eq = (a, b) => assert.deepStrictEqual(JSON.parse(JSON.stringify(a)), b);

// 10 new customers a month, no churn, no growth: customers(m) = 10m, revenue(m) = 200m.
const simple = { arpu: 20, grossMargin: 0.8, churn: 0, cac: 40, newCustomersMonth1: 10, monthlyGrowth: 0, fixedMonthlyCost: 1000 };
const caps = [
  { name: 'a', release: 'MVP', size: 'S' },
  { name: 'b', release: 'MVP', size: 'M' },
  { name: 'c', release: 'v1', size: 'L' },
];
const data = {
  meta: { lang: 'en', currency: 'USD', audience: 'investor', title: 'T' },
  market: { tam: 1e9, sam: 1e8, som: 1e6 },
  assumptions: simple,
  scenarios: { conservative: { fixedMonthlyCost: 5000 }, base: {}, optimistic: { newCustomersMonth1: 20 } },
  team: { developers: 2, monthlyCost: 9000 },
  capabilities: caps,
};

t('unit economics', () => {
  const u = M.unitEconomics({ arpu: 20, grossMargin: 0.8, churn: 0.05, cac: 40 });
  close(u.ltv, 320); close(u.ltvToCac, 8); close(u.paybackMonths, 2.5);
});
t('no churn means no LTV, payback still known', () => {
  const u = M.unitEconomics(simple);
  assert.strictEqual(u.ltv, null); assert.strictEqual(u.ltvToCac, null); close(u.paybackMonths, 2.5);
});
t('negative churn is rejected', () => assert.throws(() => M.unitEconomics({ ...simple, churn: -0.1 }), /churn/));
t('a number written as text is rejected', () => assert.throws(() => M.unitEconomics({ ...simple, arpu: '20' }), /arpu must be a number/));
t('churn and growth compound', () => {
  close(M.project({ ...simple, newCustomersMonth1: 100, churn: 0.1 }, 0).months[2].customers, 271);
  const q = M.project({ ...simple, newCustomersMonth1: 100, churn: 0.1, monthlyGrowth: 0.1 }, 0);
  close(q.months[1].customers, 200); close(q.months[2].customers, 301);
});
t('growth above 100 % a month is rejected', () => assert.throws(() => M.project({ ...simple, monthlyGrowth: 8 }, 0), /monthlyGrowth must be at most 1 \(0\.08 means 8 %\)/));
t('formatters reject a value that is not a finite number', () => {
  const F = M.formatters({ lang: 'en', currency: 'EGP' });
  for (const k of ['money', 'usd', 'dec', 'dec2', 'int', 'pct', 'compact'])
    for (const x of [NaN, Infinity, -Infinity, undefined]) assert.throws(() => F[k](x), /must be a number/, k + '(' + x + ')');
  assert.strictEqual(F.int(1234.4), '1,234');
});
t('yearly totals and break-even', () => {
  const p = M.project(simple, 10000);
  close(p.years[0].revenue, 15600); close(p.years[0].costs, 19920); close(p.years[0].net, -4320);
  close(p.years[2].revenue, 73200);
  close(p.months[21].cumulative, -320); close(p.months[22].cumulative, 1960);
  assert.strictEqual(p.breakEvenMonth, 23);
});
t('no break-even within 36 months', () => {
  const p = M.project({ ...simple, fixedMonthlyCost: 5000 }, 10000);
  assert.strictEqual(p.breakEvenMonth, null); close(p.months[35].cumulative, -97840);
});
t('ROI over 36 months', () => close(M.roi(M.project(simple, 10000), 10000), 46160 / 87040));
t('duration from sizes', () => {
  const d = M.sizeDuration(caps, 2);
  eq(d.byRelease, { MVP: { weeksLow: 3, weeksHigh: 7 }, v1: { weeksLow: 3, weeksHigh: 9 } });
  assert.strictEqual(d.weeksLow, 6); assert.strictEqual(d.weeksHigh, 16);
});
t('an XL capability must be split', () => assert.throws(() => M.sizeDuration([{ name: 'x', release: 'MVP', size: 'XL' }], 2), /"x" is XL: split it/));
t('a size named after an Object property is rejected', () => assert.throws(() => M.sizeDuration([{ name: 'x', release: 'MVP', size: 'constructor' }], 2), /size "constructor"/));
t('an unknown release is rejected', () => assert.throws(() => M.sizeDuration([{ name: 'x', release: 'v3', size: 'S' }], 2), /release "v3"/));
t('default team velocity', () => eq(M.teamVelocity({ developers: 2 }), [24, 32]));
t('a bad team velocity is rejected', () => assert.throws(() => M.teamVelocity({ developers: 2, velocity: [30, 20] }), /team.velocity/));
t('duration from points', () => eq(M.pointsDuration(120, [24, 32]), { weeksLow: 8, weeksHigh: 10 }));
t('duration from points per release', () => {
  const d = M.pointsDurationByRelease({ MVP: 80, v1: 40 }, [24, 32]);
  eq(d.byRelease, { MVP: { weeksLow: 5, weeksHigh: 7 }, v1: { weeksLow: 3, weeksHigh: 4 } });
  assert.strictEqual(d.weeksLow, 8); assert.strictEqual(d.weeksHigh, 11);
});
t('drift', () => {
  close(M.drift({ weeksLow: 6, weeksHigh: 16 }, { weeksLow: 8, weeksHigh: 10 }), 2 / 11);
  close(M.drift({ weeksLow: 6, weeksHigh: 16 }, { weeksLow: 12, weeksHigh: 16 }), 3 / 11);
});
t('build cost', () => {
  const c = M.buildCost(9000, { weeksLow: 6, weeksHigh: 16 });
  close(c.low, 9000 * 6 * 12 / 52); close(c.high, 9000 * 16 * 12 / 52);
});
t('computeAll: figures and formatted values', () => {
  const c = M.computeAll(data);
  assert.strictEqual(c.scenarios.base.breakEvenMonth, 28);
  assert.strictEqual(c.drift, null);
  const v = c.values;
  assert.strictEqual(v['base.breakEvenMonth'], '28');
  assert.strictEqual(v['conservative.breakEvenMonth'], 'Not within 36 months');
  assert.strictEqual(v['base.revenueY3'], '$73,200');
  assert.strictEqual(v['base.roi'], '33%');
  assert.strictEqual(v.durationWeeks, '6 – 16');
  assert.strictEqual(v.sizedWeeks, '6 – 16');
  assert.strictEqual(v['weeks.MVP'], '3 – 7');
  assert.strictEqual(v.ltv, '—');
  assert.strictEqual(v.paybackMonths, '2.5');
  assert.strictEqual(v.buildCost, '$12,462 – $33,231');
  assert.ok(!('drift' in v) && !('base.revenueY3.usd' in v));
});
t('computeAll: the backlog replaces the sizing and reports the drift', () => {
  const c = M.computeAll({ ...data, backlog: { pointsByRelease: { MVP: 80, v1: 40 } } });
  close(c.drift, 1.5 / 11);
  assert.strictEqual(c.values.durationWeeks, '8 – 11');
  assert.strictEqual(c.values.sizedWeeks, '6 – 16');
  assert.strictEqual(c.values['weeks.MVP'], '5 – 7');
  assert.strictEqual(c.values.drift, '14%');
  assert.strictEqual(c.values.backlogPoints, '120');
  close(c.buildCost.low, 9000 * 8 * 12 / 52); close(c.buildCost.high, 9000 * 11 * 12 / 52);
});
t('computeAll: stories for the MVP only keep v1 in the duration, from its sizing', () => {
  const c = M.computeAll({ ...data, backlog: { pointsByRelease: { MVP: 80 } } });
  assert.strictEqual(c.values['weeks.MVP'], '5 – 7');
  assert.strictEqual(c.values['weeks.v1'], '3 – 9');
  assert.strictEqual(c.values.durationWeeks, '8 – 16');
  close(c.drift, 1 / 5); // MVP only: sized 3–7 against points 5–7
  close(c.buildCost.low, 9000 * 8 * 12 / 52); close(c.buildCost.high, 9000 * 16 * 12 / 52);
});
t('computeAll: another currency also gives USD values', () => {
  const v = M.computeAll({ ...data, meta: { ...data.meta, currency: 'EGP', usdRate: 0.02 } }).values;
  assert.strictEqual(v['base.revenueY3.usd'], '$1,464');
  assert.ok(/73,200/.test(v['base.revenueY3']) && !/\$/.test(v['base.revenueY3']));
});
t('computeAll: another currency needs its USD rate', () => assert.throws(() => M.computeAll({ ...data, meta: { ...data.meta, currency: 'EGP' } }), /usdRate/));
t('computeAll: Arabic values use Latin digits and Arabic text', () => {
  const v = M.computeAll({ ...data, meta: { ...data.meta, lang: 'ar' } }).values;
  assert.strictEqual(v['conservative.breakEvenMonth'], 'لا يتحقق خلال 36 شهرًا');
  assert.ok(/28/.test(v['base.breakEvenMonth']) && !/[٠-٩]/.test(Object.values(v).join(' ')));
});
t('computeAll: every value is text without NaN, undefined or Infinity', () => {
  const v = M.computeAll({ ...data, backlog: { pointsByRelease: { MVP: 80 } } }).values;
  for (const [k, x] of Object.entries(v)) assert.ok(typeof x === 'string' && !/NaN|undefined|Infinity/.test(x), k + ' = ' + x);
});
t('computeAll: a missing part fails clearly', () => assert.throws(() => M.computeAll({ meta: data.meta }), /data block needs "market"/));
t('computeAll: market sizes must narrow', () => assert.throws(() => M.computeAll({ ...data, market: { tam: 1, sam: 2, som: 1 } }), /tam >= sam >= som/));

t('every binding report.md documents exists', () => {
  const ref = fs.readFileSync(path.join(__dirname, '../skills/nawah/references/report.md'), 'utf8');
  const table = (ref.split(/^## Bindings\s*$/m)[1] || '').split(/^## /m)[0];
  const keys = [];
  for (const line of table.split('\n')) {
    const cell = (line.match(/^\| ([^|]+) \|/) || [])[1];
    if (!cell || /^Key|^-/.test(cell)) continue;
    for (const k of cell.match(/`([^`]+)`/g) || []) keys.push(k.slice(1, -1));
  }
  assert.ok(keys.length >= 10, 'found only ' + keys.length + ' keys under "## Bindings"');
  const expand = (k) => k.includes('<s>') ? ['conservative', 'base', 'optimistic'].flatMap((s) => expand(k.replace('<s>', s)))
    : k.includes('<n>') ? [1, 2, 3].flatMap((n) => expand(k.replace('<n>', n)))
    : k.includes('<r>') ? ['MVP', 'v1'].flatMap((r) => expand(k.replace('<r>', r)))
    : [k];
  const v = M.computeAll({ ...data, meta: { ...data.meta, currency: 'EGP', usdRate: 0.02 }, backlog: { pointsByRelease: { MVP: 80, v1: 40 } } }).values;
  for (const k of keys.flatMap(expand)) assert.ok(k in v, `report.md documents "${k}", which the model doesn't produce`);
});

console.log(failures ? `${failures} test(s) failed` : 'all model tests pass');
process.exit(failures ? 1 : 0);
