// Builds a filled fixture report from the template: optionally swaps in another data block, replaces
// every SLOT marker with a paragraph that uses bindings and a citation, and sets every confidence.
// Usage: node tests/fixture/fill.js <out.html> [data.json] [--break slot|key|source|xl|level|proto|note|empty|sources]
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const out = args[0];
const dataFile = args[1] && !args[1].startsWith('--') ? args[1] : null;
const bi = args.indexOf('--break');
const brk = bi >= 0 ? args[bi + 1] : null;

let html = fs.readFileSync(path.join(__dirname, '../../skills/nawah/assets/report-template.html'), 'utf8');
const dataRe = /(<script type="application\/json" id="nawah-data">)([\s\S]*?)(<\/script>)/;
const data = JSON.parse(dataFile ? fs.readFileSync(dataFile, 'utf8') : html.match(dataRe)[2]);
if (brk === 'xl') data.capabilities[0].size = 'XL';
if (brk === 'note') data.assumptionNotes.push({ key: 'arpuu', note: 'A typo in the key' });
if (brk === 'sources') { data.sources.push({ ...data.sources[0] }); delete data.meta.usdRateSource; }
html = html.replace(dataRe, (m, open, body, close) => `${open}\n${JSON.stringify(data, null, 2)}\n${close}`);

const ar = data.meta.lang === 'ar';
const para = (id) => ar
  ? `<p>يعرض هذا القسم (${id}) تحليله. تبلغ إيرادات السنة الثالثة في السيناريو الأساسي <span data-k="base.revenueY3"></span>، وشهر التعادل: <span data-k="base.breakEvenMonth"></span><sup data-src="1"></sup>.</p>`
  : `<p>This section (${id}) presents its analysis. Base-case revenue in year 3 is <span data-k="base.revenueY3"></span>; break-even month: <span data-k="base.breakEvenMonth"></span><sup data-src="1"></sup>.</p>`;
html = html.replace(/<!-- SLOT ([a-z-]+) -->/g, (m, id) => (brk === 'slot' && id === 'risks' ? m : brk === 'empty' && id === 'validation' ? '' : para(id)));
html = html.replace(/<span class="confidence" data-level=""><\/span>/g, '<span class="confidence" data-level="Medium"></span>');
if (brk === 'level') html = html.replace('<span class="confidence" data-level="Medium"></span>', '<span class="confidence" data-level="Sure"></span>');
if (brk === 'key') html = html.replace('<span data-k="base.revenueY3"></span>', '<span data-k="base.revenueY9"></span>');
if (brk === 'proto') html = html.replace('<span data-k="base.revenueY3"></span>', '<span data-k="constructor"></span>');
if (brk === 'source') html = html.replace('<sup data-src="1"></sup>', '<sup data-src="99"></sup>');
fs.writeFileSync(out, html);
