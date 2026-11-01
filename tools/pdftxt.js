const fs = require('fs'), zlib = require('zlib');
const buf = fs.readFileSync(process.argv[2]);
let chunks = [], i = 0;
while (true) {
  const s = buf.indexOf('stream', i); if (s < 0) break;
  let p = s + 6; if (buf[p] === 13) p++; if (buf[p] === 10) p++;
  const e = buf.indexOf('endstream', p); if (e < 0) break;
  try {
    const inf = zlib.inflateSync(buf.slice(p, e)).toString('latin1');
    if (/T[Jj]/.test(inf)) chunks.push(inf);
  } catch (err) {}
  i = e + 9;
}
let txt = '';
const ESC = String.fromCharCode(92);
for (const c of chunks) {
  const re = new RegExp('\\((?:\\\\.|[^\\\\()])*\\)|TJ|Tj|TD|Td|T\\*|ET', 'g');
  let m;
  while ((m = re.exec(c))) {
    const t = m[0];
    if (t.charAt(0) === '(') {
      txt += t.slice(1, -1).split(ESC + '(').join('(').split(ESC + ')').join(')');
    } else if (t === 'TD' || t === 'Td' || t === 'T*' || t === 'ET') {
      txt += '\n';
    }
  }
  txt += '\n';
}
console.log(txt);
