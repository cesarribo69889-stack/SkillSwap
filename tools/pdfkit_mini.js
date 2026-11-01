// Generador de PDF minimo (sin dependencias externas).
// Solo cubre lo necesario para los wireframes: rectangulos, lineas, circulos
// y texto Helvetica con codificacion WinAnsi.

const WINANSI = {
  0x20ac: 0x80, 0x201a: 0x82, 0x0192: 0x83, 0x201e: 0x84, 0x2026: 0x85,
  0x2020: 0x86, 0x2021: 0x87, 0x02c6: 0x88, 0x2030: 0x89, 0x0160: 0x8a,
  0x2039: 0x8b, 0x0152: 0x8c, 0x017d: 0x8e, 0x2018: 0x91, 0x2019: 0x92,
  0x201c: 0x93, 0x201d: 0x94, 0x2022: 0x95, 0x2013: 0x96, 0x2014: 0x97,
  0x02dc: 0x98, 0x2122: 0x99, 0x0161: 0x9a, 0x203a: 0x9b, 0x0153: 0x9c,
  0x017e: 0x9e, 0x0178: 0x9f
};

function toWinAnsi(str) {
  let out = '';
  for (const ch of str) {
    const c = ch.codePointAt(0);
    if (c < 0x100) out += String.fromCharCode(c);
    else if (WINANSI[c] !== undefined) out += String.fromCharCode(WINANSI[c]);
    else out += '?';
  }
  return out;
}

function esc(str) {
  return toWinAnsi(str).replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');
}

// Anchos de glifo de Helvetica / Helvetica-Bold (unidades de 1/1000 em).
const W_REG = {};
const W_BOLD = {};
(function initWidths() {
  const reg = '278 278 355 556 556 889 667 191 333 333 389 584 278 333 278 278 556 556 556 556 556 556 556 556 556 556 278 278 584 584 584 556 1015 667 667 722 722 667 611 778 722 278 500 667 556 833 722 778 667 778 722 667 611 722 667 944 667 667 611 278 278 278 469 556 333 556 556 500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722 500 500 500 334 260 334 584';
  const bold = '278 333 474 556 556 889 722 238 333 333 389 584 278 333 278 278 556 556 556 556 556 556 556 556 556 556 333 333 584 584 584 611 975 722 722 722 722 667 611 778 722 278 556 722 611 833 722 778 667 778 722 667 611 722 667 944 667 667 611 333 278 333 584 556 333 556 611 556 611 556 333 611 611 278 278 556 278 889 611 611 611 611 389 556 333 611 556 778 556 556 500 389 280 389 584';
  const r = reg.split(' ').map(Number), b = bold.split(' ').map(Number);
  for (let i = 0; i < r.length; i++) { W_REG[32 + i] = r[i]; W_BOLD[32 + i] = b[i]; }
})();

function widthOf(str, size, bold) {
  const tbl = bold ? W_BOLD : W_REG;
  let total = 0;
  for (const ch of toWinAnsi(str)) {
    const c = ch.charCodeAt(0);
    total += tbl[c] !== undefined ? tbl[c] : (c >= 0xc0 ? (bold ? 611 : 556) : 500);
  }
  return total * size / 1000;
}

class Page {
  constructor(doc, w, h) { this.doc = doc; this.w = w; this.h = h; this.ops = []; }
  // Todas las APIs usan el origen arriba-izquierda; aqui se convierte.
  _y(y) { return this.h - y; }

  rect(x, y, w, h, o = {}) {
    const ops = [];
    if (o.fill) ops.push(`${o.fill.join(' ')} rg`);
    if (o.stroke) ops.push(`${o.stroke.join(' ')} RG`);
    ops.push(`${o.lw || 0.5} w`);
    ops.push(`${f(x)} ${f(this._y(y + h))} ${f(w)} ${f(h)} re`);
    ops.push(o.fill && o.stroke ? 'B' : o.fill ? 'f' : 'S');
    this.ops.push(ops.join('\n'));
  }

  roundRect(x, y, w, h, r, o = {}) {
    const y0 = this._y(y + h), y1 = this._y(y);
    const k = r * 0.5523;
    const ops = [];
    if (o.fill) ops.push(`${o.fill.join(' ')} rg`);
    if (o.stroke) ops.push(`${o.stroke.join(' ')} RG`);
    ops.push(`${o.lw || 0.5} w`);
    ops.push(`${f(x + r)} ${f(y0)} m`);
    ops.push(`${f(x + w - r)} ${f(y0)} l`);
    ops.push(`${f(x + w - r + k)} ${f(y0)} ${f(x + w)} ${f(y0 + r - k)} ${f(x + w)} ${f(y0 + r)} c`);
    ops.push(`${f(x + w)} ${f(y1 - r)} l`);
    ops.push(`${f(x + w)} ${f(y1 - r + k)} ${f(x + w - r + k)} ${f(y1)} ${f(x + w - r)} ${f(y1)} c`);
    ops.push(`${f(x + r)} ${f(y1)} l`);
    ops.push(`${f(x + r - k)} ${f(y1)} ${f(x)} ${f(y1 - r + k)} ${f(x)} ${f(y1 - r)} c`);
    ops.push(`${f(x)} ${f(y0 + r)} l`);
    ops.push(`${f(x)} ${f(y0 + r - k)} ${f(x + r - k)} ${f(y0)} ${f(x + r)} ${f(y0)} c`);
    ops.push('h');
    ops.push(o.fill && o.stroke ? 'B' : o.fill ? 'f' : 'S');
    this.ops.push(ops.join('\n'));
  }

  circle(cx, cy, r, o = {}) {
    const y = this._y(cy), k = r * 0.5523;
    const ops = [];
    if (o.fill) ops.push(`${o.fill.join(' ')} rg`);
    if (o.stroke) ops.push(`${o.stroke.join(' ')} RG`);
    ops.push(`${o.lw || 0.5} w`);
    ops.push(`${f(cx - r)} ${f(y)} m`);
    ops.push(`${f(cx - r)} ${f(y + k)} ${f(cx - k)} ${f(y + r)} ${f(cx)} ${f(y + r)} c`);
    ops.push(`${f(cx + k)} ${f(y + r)} ${f(cx + r)} ${f(y + k)} ${f(cx + r)} ${f(y)} c`);
    ops.push(`${f(cx + r)} ${f(y - k)} ${f(cx + k)} ${f(y - r)} ${f(cx)} ${f(y - r)} c`);
    ops.push(`${f(cx - k)} ${f(y - r)} ${f(cx - r)} ${f(y - k)} ${f(cx - r)} ${f(y)} c`);
    ops.push(o.fill && o.stroke ? 'B' : o.fill ? 'f' : 'S');
    this.ops.push(ops.join('\n'));
  }

  line(x1, y1, x2, y2, o = {}) {
    this.ops.push([
      `${(o.color || [0, 0, 0]).join(' ')} RG`,
      `${o.lw || 0.5} w`,
      o.dash ? `[${o.dash}] 0 d` : '[] 0 d',
      `${f(x1)} ${f(this._y(y1))} m ${f(x2)} ${f(this._y(y2))} l S`,
      '[] 0 d'
    ].join('\n'));
  }

  // y = linea base del texto medida desde arriba
  text(x, y, str, o = {}) {
    const size = o.size || 8;
    const font = o.bold ? '/F2' : '/F1';
    let tx = x;
    if (o.align === 'center') tx = x - widthOf(str, size, o.bold) / 2;
    else if (o.align === 'right') tx = x - widthOf(str, size, o.bold);
    this.ops.push([
      'BT',
      `${(o.color || [0, 0, 0]).join(' ')} rg`,
      `${font} ${f(size)} Tf`,
      `${f(tx)} ${f(this._y(y))} Td`,
      `(${esc(str)}) Tj`,
      'ET'
    ].join('\n'));
  }

  width(str, size, bold) { return widthOf(str, size, bold); }

  // Corta el texto con puntos suspensivos si excede maxW
  clip(str, size, bold, maxW) {
    if (widthOf(str, size, bold) <= maxW) return str;
    let s = str;
    while (s.length > 1 && widthOf(s + '…', size, bold) > maxW) s = s.slice(0, -1);
    return s + '…';
  }

  // Devuelve un array de lineas ajustadas a maxW
  wrap(str, size, bold, maxW) {
    const words = str.split(' ');
    const lines = [];
    let cur = '';
    for (const wd of words) {
      const test = cur ? cur + ' ' + wd : wd;
      if (widthOf(test, size, bold) > maxW && cur) { lines.push(cur); cur = wd; }
      else cur = test;
    }
    if (cur) lines.push(cur);
    return lines;
  }
}

function f(n) { return (Math.round(n * 100) / 100).toString(); }

class Doc {
  constructor() { this.pages = []; }
  addPage(w = 842, h = 595) { const p = new Page(this, w, h); this.pages.push(p); return p; }

  build() {
    const objs = [];
    const add = (s) => { objs.push(s); return objs.length; };

    const fontReg = add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');
    const fontBold = add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>');
    const res = add(`<< /Font << /F1 ${fontReg} 0 R /F2 ${fontBold} 0 R >> >>`);

    const pagesId = objs.length + 1 + this.pages.length * 2;
    const kids = [];
    for (const p of this.pages) {
      const content = p.ops.join('\n');
      const cid = add({ stream: content });
      const pid = add(`<< /Type /Page /Parent ${pagesId} 0 R /MediaBox [0 0 ${f(p.w)} ${f(p.h)}] /Resources ${res} 0 R /Contents ${cid} 0 R >>`);
      kids.push(`${pid} 0 R`);
    }
    const pgs = add(`<< /Type /Pages /Kids [${kids.join(' ')}] /Count ${this.pages.length} >>`);
    const cat = add(`<< /Type /Catalog /Pages ${pgs} 0 R >>`);

    let out = Buffer.from('%PDF-1.4\n%\xe2\xe3\xcf\xd3\n', 'latin1');
    const offsets = [];
    for (let i = 0; i < objs.length; i++) {
      offsets.push(out.length);
      let body;
      if (typeof objs[i] === 'object') {
        const s = Buffer.from(objs[i].stream, 'latin1');
        body = Buffer.concat([
          Buffer.from(`${i + 1} 0 obj\n<< /Length ${s.length} >>\nstream\n`, 'latin1'),
          s,
          Buffer.from('\nendstream\nendobj\n', 'latin1')
        ]);
      } else {
        body = Buffer.from(`${i + 1} 0 obj\n${objs[i]}\nendobj\n`, 'latin1');
      }
      out = Buffer.concat([out, body]);
    }
    const xref = out.length;
    let x = `xref\n0 ${objs.length + 1}\n0000000000 65535 f \n`;
    for (const o of offsets) x += String(o).padStart(10, '0') + ' 00000 n \n';
    x += `trailer\n<< /Size ${objs.length + 1} /Root ${cat} 0 R >>\nstartxref\n${xref}\n%%EOF\n`;
    return Buffer.concat([out, Buffer.from(x, 'latin1')]);
  }
}

module.exports = { Doc, widthOf };
