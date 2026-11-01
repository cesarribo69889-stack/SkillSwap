// Genera el HTML del Product Backlog; Word lo convierte despues a .docx.
const fs = require('fs');
const { EPICS, STORIES, SPRINTS, WONT, M, S, C } = require('./backlog_data');

const e = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const epicName = (code) => (EPICS.find((x) => x[0] === code) || [, code])[1];

// --- comprobaciones de consistencia --------------------------------------
const ids = STORIES.map((s) => s.id);
if (new Set(ids).size !== ids.length) throw new Error('IDs de historia duplicados');
for (const st of STORIES) {
  if (!EPICS.some((x) => x[0] === st.e)) throw new Error('Epica inexistente en ' + st.id);
  if (![1, 2, 3, 5, 8].includes(st.pt)) throw new Error('Estimacion fuera de escala en ' + st.id);
  if (st.sp < 1 || st.sp > SPRINTS.length) throw new Error('Sprint invalido en ' + st.id);
}

const total = STORIES.length;
const pts = STORIES.reduce((a, s) => a + s.pt, 0);
const byPrio = [M, S, C].map((p) => [p, STORIES.filter((s) => s.pr === p)]);
const bySprint = SPRINTS.map((_, i) => STORIES.filter((s) => s.sp === i + 1));

// Word descarta el "background" de un div al importar HTML, pero si respeta
// el atributo bgcolor de una celda; por eso la barra es una tabla anidada.
const bar = (n, max, color) => {
  const w = Math.max(4, Math.round(n / max * 230));
  return `<table style="border-collapse:collapse;width:${w}pt;margin:0"><tr>` +
         `<td bgcolor="${color}" style="border:none;padding:0;width:${w}pt">` +
         `<span style="font-size:8pt">&nbsp;</span></td></tr></table>`;
};

let h = `<!doctype html><html><head><meta charset="utf-8">
<style>
@page WordSection1 { size:21cm 29.7cm; margin:2.2cm 2cm 2.2cm 2.5cm; }
div.WordSection1 { page:WordSection1; }
body { font-family:Arial,sans-serif; font-size:11pt; color:#1f1f28; line-height:1.4; }
h1 { font-size:18pt; margin:0 0 4pt 0; }
h2 { font-size:13pt; margin:20pt 0 6pt 0; border-bottom:1.2pt solid #6C4DF6; padding-bottom:3pt; }
h3 { font-size:11pt; margin:14pt 0 4pt 0; color:#6C4DF6; }
p  { margin:0 0 7pt 0; text-align:justify; }
table { border-collapse:collapse; width:100%; margin:6pt 0 10pt 0; }
th { background:#6C4DF6; color:#fff; font-size:9pt; padding:4pt 5pt; border:0.5pt solid #b9b9c4; text-align:left; }
td { font-size:9pt; padding:4pt 5pt; border:0.5pt solid #b9b9c4; vertical-align:top; }
tr.alt td { background:#f4f3fb; }
.c { text-align:center; }
.small { font-size:8.5pt; color:#55555f; }
ul { margin:0 0 7pt 16pt; padding:0; }
li { font-size:10pt; margin-bottom:2pt; }
.cover { text-align:center; margin-top:90pt; }
.cover p { text-align:center; }
.pb { page-break-before:always; }
.tag { font-size:8.5pt; font-weight:bold; }
</style></head><body><div class="WordSection1">`;

// ------------------------------------------------------------- portada ---
h += `<div class="cover">
<p style="font-size:10pt;letter-spacing:2pt;margin-bottom:24pt">UNIVERSIDAD PRIVADA DEL NORTE<br>
FACULTAD DE INGENIERÍA · INGENIERÍA DE SISTEMAS COMPUTACIONALES</p>
<h1 style="font-size:30pt;color:#6C4DF6">SkillSwap</h1>
<p style="font-size:12pt;margin-bottom:26pt">Intercambia habilidades, no dinero</p>
<h1 style="font-size:20pt">PRODUCT BACKLOG</h1>
<p style="font-size:11pt">Historias de usuario · Priorización MoSCoW · Planificación por sprints</p>
<p style="margin-top:34pt;font-size:11pt"><b>Curso:</b> Desarrollo de Aplicaciones Móviles<br>
<b>Proyecto:</b> SkillSwap, aplicativo móvil para el intercambio de habilidades<br>
entre estudiantes universitarios, 2026<br>
<b>Periodo:</b> 2026-2</p>
<p style="margin-top:22pt;font-size:11pt"><b>Integrantes</b><br>
Lagos Sedano, José Alfredo<br>Ricra Boza, César Andrés<br>
Leguía Medina, Marcelo Zacarías<br>Decurt Bendezú, Dennis Fabián</p>
<p style="margin-top:30pt" class="small">${total} historias de usuario · ${pts} puntos de historia · ${SPRINTS.length} sprints de 2 semanas</p>
</div>`;

// --------------------------------------------------------------- marco ---
h += `<div class="pb"><h2>1. Marco de trabajo</h2>
<p>El proyecto se desarrolló bajo <b>Scrum</b>. El Product Backlog reúne las ${total} historias de usuario
que describen el producto desde el punto de vista del estudiante que lo usa. Cada historia está priorizada,
estimada, asignada a un sprint y trazada tanto a la pantalla del wireframe como al archivo del repositorio
que la implementa.</p>

<h3>1.1. Roles</h3>
<table>
<tr><th style="width:4.5cm">Rol</th><th style="width:5cm">Responsable</th><th>Responsabilidad</th></tr>
<tr><td>Product Owner</td><td>Ricra Boza, César Andrés</td><td>Mantiene y prioriza el backlog; decide qué entra en cada sprint.</td></tr>
<tr class="alt"><td>Scrum Master</td><td>Lagos Sedano, José Alfredo</td><td>Facilita las ceremonias y retira los impedimentos del equipo.</td></tr>
<tr><td>Equipo de desarrollo</td><td>Los cuatro integrantes</td><td>Analiza, construye y prueba el incremento de cada sprint.</td></tr>
</table>

<h3>1.2. Formato de las historias</h3>
<p>Todas las historias siguen la plantilla <i>Como [rol], quiero [acción] para [beneficio]</i>, y cuentan con
criterios de aceptación verificables (sección 5).</p>

<h3>1.3. Priorización MoSCoW</h3>
<table>
<tr><th style="width:3.6cm">Prioridad</th><th style="width:2cm" class="c">Historias</th><th>Significado</th></tr>
<tr><td><b>Debe tener</b></td><td class="c">${byPrio[0][1].length}</td><td>Sin esta funcionalidad el aplicativo no cumple su propósito: no habría intercambio.</td></tr>
<tr class="alt"><td><b>Debería tener</b></td><td class="c">${byPrio[1][1].length}</td><td>Importante para la calidad del producto, pero una primera versión funciona sin ella.</td></tr>
<tr><td><b>Podría tener</b></td><td class="c">${byPrio[2][1].length}</td><td>Mejora la experiencia y diferencia al producto; se construye si hay capacidad en el sprint.</td></tr>
<tr class="alt"><td><b>No tendrá por ahora</b></td><td class="c">—</td><td>Fuera del alcance de esta versión (detalle en la sección 6).</td></tr>
</table>

<h3>1.4. Escala de estimación</h3>
<p>Se estimó en puntos de historia con una escala de Fibonacci reducida. La referencia fue HU02
(iniciar sesión) = 2 puntos.</p>
<table>
<tr><th style="width:2cm" class="c">Puntos</th><th>Equivalencia aproximada</th></tr>
<tr><td class="c">1</td><td>Cambio puntual en una pantalla ya existente.</td></tr>
<tr class="alt"><td class="c">2</td><td>Una pantalla sencilla contra un servicio ya integrado.</td></tr>
<tr><td class="c">3</td><td>Una pantalla con validaciones y escritura en Firestore.</td></tr>
<tr class="alt"><td class="c">5</td><td>Pantalla más repositorio nuevo, o cambio que afecta a varias colecciones.</td></tr>
<tr><td class="c">8</td><td>Lógica de dominio propia que exige pruebas unitarias (motor SkillMatch).</td></tr>
</table>

<h3>1.5. Definición de terminado</h3>
<ul>
<li>El proyecto compila sin errores con <i>gradlew assembleDebug</i>.</li>
<li>Existen reglas de seguridad en Firestore o Storage para toda colección nueva.</li>
<li>La lógica de dominio está cubierta por pruebas unitarias con JUnit.</li>
<li>Android Lint no reporta errores.</li>
<li>La historia fue probada en emulador y en un dispositivo físico con Android 7.0 o superior.</li>
<li>Otro integrante del equipo revisó el código antes de integrarlo.</li>
</ul></div>`;

// --------------------------------------------------------------- epicas ---
h += `<div class="pb"><h2>2. Épicas</h2>
<p>Las historias se agrupan en diez épicas que siguen el recorrido real del estudiante dentro del producto.</p>
<table>
<tr><th style="width:1.5cm" class="c">Código</th><th style="width:4.2cm">Épica</th><th>Objetivo</th><th style="width:1.6cm" class="c">Historias</th><th style="width:1.3cm" class="c">Pts</th></tr>`;
EPICS.forEach(([code, name, obj], i) => {
  const list = STORIES.filter((s) => s.e === code);
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td class="c"><b>${code}</b></td><td>${e(name)}</td><td>${e(obj)}</td>` +
       `<td class="c">${list.length}</td><td class="c">${list.reduce((a, s) => a + s.pt, 0)}</td></tr>`;
});
h += `<tr><td colspan="3" style="text-align:right"><b>Total</b></td><td class="c"><b>${total}</b></td><td class="c"><b>${pts}</b></td></tr></table></div>`;

// -------------------------------------------------------------- backlog ---
h += `<div class="pb"><h2>3. Product Backlog</h2>
<p>Historias ordenadas por épica. La columna <i>Pantalla</i> remite al código del wireframe entregado junto
a este documento y la columna <i>Sprint</i> indica la iteración en la que se construyó.</p>
<table>
<tr><th style="width:1.4cm" class="c">ID</th><th style="width:2.4cm">Épica</th><th>Historia de usuario</th>
<th style="width:2.2cm">Prioridad</th><th style="width:1cm" class="c">Pts</th><th style="width:1.1cm" class="c">Spr.</th><th style="width:1.7cm" class="c">Pantalla</th></tr>`;
STORIES.forEach((s, i) => {
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td class="c"><b>${s.id}</b></td><td>${e(epicName(s.e))}</td>` +
       `<td>${e(s.t)}</td><td>${e(s.pr)}</td><td class="c">${s.pt}</td><td class="c">${s.sp}</td>` +
       `<td class="c">${e(s.sc)}</td></tr>`;
});
h += `<tr><td colspan="4" style="text-align:right"><b>Total del backlog</b></td><td class="c"><b>${pts}</b></td><td colspan="2"></td></tr></table></div>`;

// --------------------------------------------------------------- sprints ---
h += `<div class="pb"><h2>4. Planificación por sprints</h2>
<p>El desarrollo se organizó en ${SPRINTS.length} sprints de dos semanas. Las semanas son relativas al inicio
del ciclo 2026-2. La velocidad crece de forma progresiva porque el equipo resolvió en el Sprint 1 la
configuración del proyecto, de Firebase y de las reglas de seguridad.</p>
<table>
<tr><th style="width:2cm">Sprint</th><th style="width:2.4cm">Periodo</th><th>Objetivo del sprint</th>
<th style="width:1.5cm" class="c">Hist.</th><th style="width:1.2cm" class="c">Pts</th></tr>`;
SPRINTS.forEach(([name, weeks, , goal], i) => {
  const list = bySprint[i];
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td><b>${name}</b></td><td>${weeks}</td><td>${e(goal)}</td>` +
       `<td class="c">${list.length}</td><td class="c">${list.reduce((a, s) => a + s.pt, 0)}</td></tr>`;
});
h += `<tr><td colspan="3" style="text-align:right"><b>Total</b></td><td class="c"><b>${total}</b></td><td class="c"><b>${pts}</b></td></tr></table>`;

SPRINTS.forEach(([name, weeks, title], i) => {
  const list = bySprint[i];
  h += `<h3>4.${i + 1}. ${name} · ${weeks} · ${e(title)}</h3><table>
  <tr><th style="width:1.4cm" class="c">ID</th><th>Historia</th><th style="width:2.2cm">Prioridad</th><th style="width:1cm" class="c">Pts</th></tr>`;
  list.forEach((s, k) => {
    h += `<tr${k % 2 ? ' class="alt"' : ''}><td class="c"><b>${s.id}</b></td><td>${e(s.t)}</td>` +
         `<td>${e(s.pr)}</td><td class="c">${s.pt}</td></tr>`;
  });
  h += `<tr><td colspan="3" style="text-align:right"><b>Compromiso del sprint</b></td>` +
       `<td class="c"><b>${list.reduce((a, s) => a + s.pt, 0)}</b></td></tr></table>`;
});
h += `</div>`;

// -------------------------------------------------------------- criterios ---
h += `<div class="pb"><h2>5. Criterios de aceptación</h2>
<p>Condiciones verificables que debían cumplirse para dar cada historia por terminada.</p>
<table>
<tr><th style="width:1.4cm" class="c">ID</th><th>Criterios de aceptación</th></tr>`;
STORIES.forEach((s, i) => {
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td class="c"><b>${s.id}</b></td><td><ul style="margin-left:12pt">` +
       s.ac.map((a) => `<li style="font-size:9pt">${e(a)}</li>`).join('') + `</ul></td></tr>`;
});
h += `</table></div>`;

// ------------------------------------------------------------------ wont ---
h += `<div class="pb"><h2>6. Fuera del alcance de esta versión</h2>
<p>Elementos clasificados como <i>No tendrá por ahora</i>. Se dejan registrados para no perderlos y para
delimitar con claridad lo que el producto entregado sí hace.</p><ul>`;
WONT.forEach((w) => { h += `<li>${e(w)}</li>`; });
h += `</ul>`;

// -------------------------------------------------------------- resumen ---
const maxP = Math.max(...byPrio.map((x) => x[1].length));
const sprintPts = bySprint.map((x) => x.reduce((a, s) => a + s.pt, 0));
const maxS = Math.max(...sprintPts);
h += `<h2>7. Resumen del backlog</h2>
<h3>7.1. Distribución por prioridad</h3><table>
<tr><th style="width:3.6cm">Prioridad</th><th style="width:1.6cm" class="c">Hist.</th><th style="width:1.4cm" class="c">%</th><th style="width:1.2cm" class="c">Pts</th><th>Distribución</th></tr>`;
byPrio.forEach(([p, list], i) => {
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td>${p}</td><td class="c">${list.length}</td>` +
       `<td class="c">${Math.round(list.length / total * 100)} %</td>` +
       `<td class="c">${list.reduce((a, s) => a + s.pt, 0)}</td>` +
       `<td>${bar(list.length, maxP, '#6C4DF6')}</td></tr>`;
});
h += `</table>

<h3>7.2. Distribución por sprint (velocidad)</h3><table>
<tr><th style="width:3.6cm">Sprint</th><th style="width:1.6cm" class="c">Hist.</th><th style="width:1.2cm" class="c">Pts</th><th>Velocidad</th></tr>`;
bySprint.forEach((list, i) => {
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td>${SPRINTS[i][0]}</td><td class="c">${list.length}</td>` +
       `<td class="c">${sprintPts[i]}</td>` +
       `<td>${bar(sprintPts[i], maxS, '#00D2B8')}</td></tr>`;
});
h += `</table>

<h3>7.3. Trazabilidad historia · pantalla · código</h3>
<p>Correspondencia entre cada historia, el wireframe que la representa y el archivo principal que la
implementa en el repositorio.</p><table>
<tr><th style="width:1.4cm" class="c">ID</th><th style="width:1.8cm" class="c">Pantalla</th><th>Archivo principal en el repositorio</th></tr>`;
STORIES.forEach((s, i) => {
  h += `<tr${i % 2 ? ' class="alt"' : ''}><td class="c"><b>${s.id}</b></td><td class="c">${e(s.sc)}</td><td>${e(s.f)}</td></tr>`;
});
h += `</table>
<p class="small" style="margin-top:14pt">El Pasaporte de Habilidades y el registro de evidencia reflejan actividad
entre pares dentro de SkillSwap: no constituyen una certificación académica ni un título oficial. Los SkillPoints
son puntos de reconocimiento dentro de la aplicación y no representan dinero ni tienen valor monetario.</p>
</div></div></body></html>`;

const out = 'C:/Users/ricra/AppData/Local/Temp/backlog.html';
fs.writeFileSync(out, h, 'utf8');
console.log('OK ->', out, '|', total, 'historias,', pts, 'puntos');
