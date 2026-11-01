// Backend SVG con la misma API que pdfkit_mini, usado solo para revisar
// visualmente los wireframes antes de generar el PDF definitivo.
const { widthOf } = require('./pdfkit_mini');

const col = (c) => `rgb(${Math.round(c[0] * 255)},${Math.round(c[1] * 255)},${Math.round(c[2] * 255)})`;
const xml = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

class Page {
  constructor(w, h) { this.w = w; this.h = h; this.ops = []; }

  _paint(o) {
    const fill = o.fill ? col(o.fill) : 'none';
    const stroke = o.stroke ? col(o.stroke) : 'none';
    return `fill="${fill}" stroke="${stroke}" stroke-width="${o.lw || 0.5}"`;
  }

  rect(x, y, w, h, o = {}) { this.ops.push(`<rect x="${x}" y="${y}" width="${w}" height="${h}" ${this._paint(o)}/>`); }
  roundRect(x, y, w, h, r, o = {}) { this.ops.push(`<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" ${this._paint(o)}/>`); }
  circle(cx, cy, r, o = {}) { this.ops.push(`<circle cx="${cx}" cy="${cy}" r="${r}" ${this._paint(o)}/>`); }

  line(x1, y1, x2, y2, o = {}) {
    this.ops.push(`<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${col(o.color || [0, 0, 0])}" stroke-width="${o.lw || 0.5}"/>`);
  }

  text(x, y, str, o = {}) {
    const anchor = o.align === 'center' ? 'middle' : o.align === 'right' ? 'end' : 'start';
    this.ops.push(`<text x="${x}" y="${y}" font-family="Helvetica,Arial,sans-serif" font-size="${o.size || 8}"` +
      `${o.bold ? ' font-weight="bold"' : ''} text-anchor="${anchor}" fill="${col(o.color || [0, 0, 0])}">${xml(str)}</text>`);
  }

  width(str, size, bold) { return widthOf(str, size, bold); }

  clip(str, size, bold, maxW) {
    if (widthOf(str, size, bold) <= maxW) return str;
    let s = str;
    while (s.length > 1 && widthOf(s + '…', size, bold) > maxW) s = s.slice(0, -1);
    return s + '…';
  }

  wrap(str, size, bold, maxW) {
    const words = str.split(' ');
    const lines = []; let cur = '';
    for (const wd of words) {
      const test = cur ? cur + ' ' + wd : wd;
      if (widthOf(test, size, bold) > maxW && cur) { lines.push(cur); cur = wd; }
      else cur = test;
    }
    if (cur) lines.push(cur);
    return lines;
  }

  toSvg() {
    return `<svg xmlns="http://www.w3.org/2000/svg" width="${this.w}" height="${this.h}" viewBox="0 0 ${this.w} ${this.h}">` +
      `<rect width="100%" height="100%" fill="white"/>${this.ops.join('')}</svg>`;
  }
}

class Doc {
  constructor() { this.pages = []; }
  addPage(w = 842, h = 595) { const p = new Page(w, h); this.pages.push(p); return p; }
  build() {
    const body = this.pages.map((p, i) =>
      `<div class="pg"><div class="n">pagina ${i + 1}</div>${p.toSvg()}</div>`).join('');
    return Buffer.from(
      `<!doctype html><meta charset="utf-8"><style>
       body{margin:0;background:#666;font-family:Arial}
       .pg{margin:14px auto;width:842px}
       .n{color:#fff;font-size:11px;padding:2px}
       svg{display:block;box-shadow:0 2px 8px rgba(0,0,0,.4)}
       </style>${body}`, 'utf8');
  }
}

module.exports = { Doc };
