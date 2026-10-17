// Structural lint of a nawah backlog.md: ids and nesting, labels, story wording, acceptance criteria,
// duplicate ids, points, priorities, releases, dependencies (unknown, cycles, later releases) and traceability.
// Usage: node tests/lint_backlog.js <backlog.md>   prints one problem per line; exit 1 when there are any.
const fs = require('fs');

const LABELS = {
  E: ['Goal', 'Success metric', 'Release', 'Parent'],
  F: ['Description', 'Release'],
  S: ['Story', 'Value', 'Priority', 'Release', 'Points', 'Depends on', 'Acceptance criteria', 'Out of scope', 'NFR', 'Open questions'],
};
const RELEASES = ['MVP', 'v1', 'v2'];
const ID = { 2: /^E(\d+)$/, 3: /^F(\d+)\.(\d+)$/, 4: /^S(\d+)\.(\d+)\.(\d+)$/ };
const TYPE = { 2: 'E', 3: 'F', 4: 'S' };
const order = (r) => RELEASES.indexOf(r);

function lint(text) {
  const problems = [], items = [], trace = [];
  let cur = null, epic = null, feature = null, section = null;
  for (const line of text.replace(/\r/g, '').split('\n')) {
    const h = line.match(/^(#{2,4}) (\S+) — .+$/);
    if (h) {
      const level = h[1].length, id = h[2], m = id.match(ID[level]);
      cur = { id, type: TYPE[level], fields: {}, ac: [], inAc: false, deps: [] };
      items.push(cur);
      section = 'item';
      if (!m) { problems.push(`${id}: a level-${level} heading needs an id like ${{ 2: 'E1', 3: 'F1.2', 4: 'S1.2.3' }[level]}`); continue; }
      if (level === 2) { epic = cur; feature = null; continue; }
      const parent = level === 3 ? epic : feature, want = level === 3 ? `E${m[1]}` : `F${m[1]}.${m[2]}`;
      cur.parent = parent ? parent.id : null;
      if (!parent || parent.id !== want) problems.push(`${id}: id doesn't match its parent ${parent ? parent.id : '(none)'}`);
      if (level === 3) feature = cur;
      continue;
    }
    if (/^## Traceability\s*$/.test(line)) { section = 'trace'; cur = null; continue; }
    if (/^#/.test(line)) { section = null; cur = null; continue; }
    if (section === 'trace') {
      const row = line.match(/^\|([^|]*)\|([^|]*)\|\s*$/);
      if (row && !/^\s*-/.test(row[1]) && !/Brief MVP item/.test(row[1])) trace.push(...(row[2].match(/S\d+\.\d+\.\d+/g) || []));
      continue;
    }
    if (!cur) continue;
    if (cur.inAc) {
      const a = line.match(/^\d+\.\s+(.*)$/);
      if (a) { cur.ac.push(a[1]); continue; }
      cur.inAc = false;
    }
    const f = line.match(/^([A-Z][A-Za-z ]*):\s*(.*)$/);
    if (f) { cur.fields[f[1]] = f[2].trim(); if (f[1] === 'Acceptance criteria') cur.inAc = true; }
  }

  const byId = new Map();
  for (const it of items) { if (byId.has(it.id)) problems.push(`${it.id}: duplicate id`); else byId.set(it.id, it); }
  for (const it of items) {
    for (const l of LABELS[it.type]) if (!(l in it.fields)) problems.push(`${it.id}: missing "${l}:"`);
    if ('Release' in it.fields && !RELEASES.includes(it.fields.Release)) problems.push(`${it.id}: Release must be MVP, v1 or v2`);
    if (it.type !== 'S') continue;
    const f = it.fields;
    if ('Priority' in f && !['Must', 'Should', 'Could'].includes(f.Priority)) problems.push(`${it.id}: Priority must be Must, Should or Could`);
    if ('Points' in f && !['1', '2', '3', '5', '8'].includes(f.Points)) problems.push(`${it.id}: Points must be 1, 2, 3, 5 or 8`);
    if ('Story' in f && !/^As an? .+, I want .+, so that .+/.test(f.Story)) problems.push(`${it.id}: Story must read "As a <role>, I want <capability>, so that <benefit>"`);
    if ('Acceptance criteria' in f && it.ac.length < 3) problems.push(`${it.id}: needs at least 3 acceptance criteria (has ${it.ac.length})`);
    it.ac.forEach((a, n) => { if (!/^Given .+ When .+ Then .+/.test(a)) problems.push(`${it.id}: AC ${n + 1} is not "Given … When … Then …"`); });
    const deps = (f['Depends on'] || 'none').trim();
    it.deps = deps === 'none' ? [] : deps.split(/\s*,\s*/).filter(Boolean);
    for (const d of it.deps) {
      const t = byId.get(d);
      if (!t || t.type !== 'S') problems.push(`${it.id}: depends on unknown ${d}`);
      else if (order(t.fields.Release) > order(f.Release)) problems.push(`${it.id}: ${f.Release} story depends on ${t.fields.Release} story ${d}`);
    }
  }

  const state = new Map();
  const visit = (id, path) => {
    if (state.get(id) === 2) return;
    if (state.get(id) === 1) { problems.push(`dependency cycle: ${path.slice(path.indexOf(id)).concat(id).join(' → ')}`); return; }
    state.set(id, 1);
    for (const d of byId.get(id).deps) if (byId.has(d) && byId.get(d).type === 'S') visit(d, path.concat(id));
    state.set(id, 2);
  };
  for (const it of items) if (it.type === 'S') visit(it.id, []);

  for (const it of items) {
    if (it.type === 'S' || !RELEASES.includes(it.fields.Release)) continue;
    const kids = items.filter((k) => k.parent === it.id && RELEASES.includes(k.fields.Release));
    const kind = it.type === 'E' ? 'feature' : 'story';
    if (!kids.length) { problems.push(`${it.id}: has no ${kind} with a release`); continue; }
    const earliest = kids.map((k) => k.fields.Release).sort((a, b) => order(a) - order(b))[0];
    if (earliest !== it.fields.Release) problems.push(`${it.id}: Release is ${it.fields.Release}, but its earliest ${kind} is ${earliest}`);
  }

  if (!trace.length) problems.push('Traceability: the table is missing or lists no stories');
  for (const s of trace) if (!byId.has(s)) problems.push(`Traceability: unknown story ${s}`);
  return problems;
}

const problems = lint(fs.readFileSync(process.argv[2], 'utf8'));
for (const p of problems) console.log(p);
process.exit(problems.length ? 1 : 0);
