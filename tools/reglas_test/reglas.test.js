// Prueba de las reglas de seguridad de Firestore contra el emulador local.
//   cd tools/reglas_test && npm install
//   npx firebase-tools emulators:exec --only firestore --project demo-skillswap "npm test"
// (necesita Java; no toca el proyecto real de Firebase).
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment, assertSucceeds, assertFails,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, updateDoc, deleteDoc, serverTimestamp } = require('firebase/firestore');

let env, pasaron = 0, fallaron = 0;

async function caso(nombre, promesa) {
  try { await promesa; pasaron++; console.log('  OK   ' + nombre); }
  catch (e) { fallaron++; console.log('  FALLA ' + nombre + ' -> ' + String(e.message).split('\n')[0]); }
}

(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-skillswap',
    firestore: { rules: fs.readFileSync(path.join(__dirname, '..', '..', 'firestore.rules'), 'utf8'),
                 host: '127.0.0.1', port: 8080 },
  });

  // Datos base, escritos sin reglas.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'exchanges/ex1'), { participants: ['ana', 'beto'], status: 'PROXIMO', progress: 0 });
    await setDoc(doc(db, 'chats/c1'), {
      participants: ['ana', 'beto'], exchangeId: 'ex1', enabled: true, blocked: false, blockedBy: '',
    });
    await setDoc(doc(db, 'skillPoints/ana'), { userId: 'ana', points: 50 });
    await setDoc(doc(db, 'users/ana'), {
      uid: 'ana', reputation: 0, totalRatings: 0, exchangesCount: 0, skillPoints: 50,
    });
  });

  const ana = env.authenticatedContext('ana').firestore();
  const beto = env.authenticatedContext('beto').firestore();
  const luis = env.authenticatedContext('luis').firestore();

  console.log('Reportes');
  await caso('ana reporta a beto', assertSucceeds(setDoc(doc(ana, 'reports/r1'), {
    id: 'r1', reporterId: 'ana', reportedId: 'beto', chatId: 'c1', reason: 'Acoso',
    details: 'x', status: 'PENDIENTE', createdAt: 1 })));
  await caso('no se puede reportar en nombre de otro', assertFails(setDoc(doc(ana, 'reports/r2'), {
    id: 'r2', reporterId: 'luis', reportedId: 'beto', chatId: 'c1', reason: 'Acoso',
    details: '', status: 'PENDIENTE', createdAt: 1 })));
  await caso('no se puede reportarse a si mismo', assertFails(setDoc(doc(ana, 'reports/r3'), {
    id: 'r3', reporterId: 'ana', reportedId: 'ana', chatId: 'c1', reason: 'Acoso',
    details: '', status: 'PENDIENTE', createdAt: 1 })));
  await caso('el reportante lee su reporte', assertSucceeds(getDoc(doc(ana, 'reports/r1'))));
  await caso('el reportado NO lee el reporte', assertFails(getDoc(doc(beto, 'reports/r1'))));
  await caso('un reporte no se edita', assertFails(updateDoc(doc(ana, 'reports/r1'), { status: 'OK' })));

  console.log('Bloqueos');
  await caso('ana crea su bloqueo con id correcto', assertSucceeds(setDoc(doc(ana, 'blocks/ana__beto'), {
    blockerId: 'ana', blockedId: 'beto', createdAt: 1 })));
  await caso('id de bloqueo incorrecto', assertFails(setDoc(doc(ana, 'blocks/cualquiera'), {
    blockerId: 'ana', blockedId: 'luis', createdAt: 1 })));
  await caso('el bloqueado NO ve el bloqueo', assertFails(getDoc(doc(beto, 'blocks/ana__beto'))));
  await caso('el que bloquea lo ve', assertSucceeds(getDoc(doc(ana, 'blocks/ana__beto'))));
  await caso('el bloqueado no borra el bloqueo', assertFails(deleteDoc(doc(beto, 'blocks/ana__beto'))));

  console.log('Chat bloqueado');
  const msg = (sender, texto) => ({ senderId: sender, text: texto, type: 'TEXT', createdAt: 1, readBy: [sender] });
  await caso('antes de bloquear, beto escribe', assertSucceeds(setDoc(doc(beto, 'chats/c1/messages/m1'), msg('beto', 'hola'))));
  await caso('mensaje de bienvenida del sistema', assertSucceeds(setDoc(doc(ana, 'chats/c1/messages/m0'), {
    senderId: 'system', text: 'Chat habilitado', type: 'SYSTEM', createdAt: 1, readBy: [] })));
  await caso('un mensaje de usuario no puede hacerse pasar por sistema', assertFails(setDoc(doc(ana, 'chats/c1/messages/m00'), {
    senderId: 'system', text: 'x', type: 'TEXT', createdAt: 1, readBy: [] })));
  await caso('ana bloquea el chat', assertSucceeds(updateDoc(doc(ana, 'chats/c1'), { blocked: true, blockedBy: 'ana' })));
  await caso('con chat bloqueado, beto NO escribe', assertFails(setDoc(doc(beto, 'chats/c1/messages/m2'), msg('beto', 'hola?'))));
  await caso('con chat bloqueado, ana NO escribe', assertFails(setDoc(doc(ana, 'chats/c1/messages/m3'), msg('ana', 'hola'))));
  await caso('beto NO puede desbloquear', assertFails(updateDoc(doc(beto, 'chats/c1'), { blocked: false, blockedBy: '' })));
  await caso('beto NO puede ponerse como quien bloqueo', assertFails(updateDoc(doc(beto, 'chats/c1'), { blockedBy: 'beto' })));
  await caso('un tercero no toca el chat', assertFails(updateDoc(doc(luis, 'chats/c1'), { blocked: false, blockedBy: '' })));
  await caso('ana desbloquea', assertSucceeds(updateDoc(doc(ana, 'chats/c1'), { blocked: false, blockedBy: '' })));
  await caso('tras desbloquear, beto vuelve a escribir', assertSucceeds(setDoc(doc(beto, 'chats/c1/messages/m4'), msg('beto', 'gracias'))));
  await caso('no se puede firmar como otro', assertFails(setDoc(doc(beto, 'chats/c1/messages/m5'), msg('ana', 'suplanto'))));

  console.log('Puntos');
  await caso('ana sube su saldo hasta el libro (50)', assertSucceeds(updateDoc(doc(ana, 'users/ana'), { skillPoints: 50 })));
  await caso('ana NO se pone 99999 puntos', assertFails(updateDoc(doc(ana, 'users/ana'), { skillPoints: 99999 })));
  await caso('ana NO edita su reputacion', assertFails(updateDoc(doc(ana, 'users/ana'), { reputation: 5 })));
  await caso('premio inicial de 25 permitido', assertSucceeds(setDoc(doc(luis, 'skillPoints/luis'), { userId: 'luis', points: 25 })));
  await caso('premio inicial de 9999 rechazado', assertFails(setDoc(doc(luis, 'skillPoints/luis2'), { userId: 'luis2', points: 9999 })));
  await caso('el libro sube +25', assertSucceeds(updateDoc(doc(beto, 'skillPoints/ana'), { userId: 'ana', points: 75 })));
  await caso('el libro NO sube +1000', assertFails(updateDoc(doc(beto, 'skillPoints/ana'), { userId: 'ana', points: 1075 })));
  await caso('el libro NO baja', assertFails(updateDoc(doc(beto, 'skillPoints/ana'), { userId: 'ana', points: 10 })));

  console.log(`\n${pasaron} correctos, ${fallaron} fallidos`);
  await env.cleanup();
  process.exit(fallaron === 0 ? 0 : 1);
})();
