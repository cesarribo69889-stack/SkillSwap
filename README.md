# SkillSwap — Intercambio de habilidades entre estudiantes

Aplicación móvil Android que permite a estudiantes universitarios **intercambiar
conocimientos sin dinero de por medio**. Si César enseña Java y quiere aprender
Diseño, y Ana enseña Diseño y quiere aprender Java, SkillSwap detecta la
compatibilidad, calcula un porcentaje real de match y les permite coordinar el
intercambio de principio a fin.

> **100 % Java + XML.** Sin Kotlin, sin Jetpack Compose, sin Coroutines, sin StateFlow.

---

## 1. Stack técnico

| Área | Tecnología |
|---|---|
| Lenguaje | Java 11 |
| UI | XML + Material Design 3 + ViewBinding |
| Arquitectura | MVVM + Repository Pattern |
| Estado | `ViewModel` + `LiveData` (`Resource<T>` como envoltorio) |
| Autenticación | Firebase Authentication (email/contraseña) |
| Base de datos | Cloud Firestore (tiempo real) |
| Archivos | Firebase Storage |
| Push | Firebase Cloud Messaging |
| Imágenes | Glide + CircleImageView |
| Listas | RecyclerView + MaterialCardView |
| Navegación | `BottomNavigationView` + Fragments (`show`/`hide`) |

---

## 2. Arquitectura

```
com.skillswap
├── SkillSwapApp.java           Application: canales de notificación + seed del catálogo
├── model/          (21)        POJOs de Firestore + Resource<T>
├── repository/     (16)        Acceso a datos, una clase por dominio
├── viewmodel/      (15)        Estado de UI observable
├── view/                       Activities y Fragments
│   ├── auth/                   Splash · Onboarding · Login · Registro · Recuperar
│   ├── home/                   HomeFragment
│   ├── matches/                ExploreFragment · FiltersSheet · MatchDetailActivity
│   ├── profile/                ProfileFragment · EditProfile · UserProfile
│   ├── skills/                 MySkills · SkillCatalog · AddSkillSheet
│   ├── exchange/               Exchanges · Requests · SendRequest · Detail · Evidence
│   ├── chat/                   ChatsFragment · ChatActivity
│   ├── ratings/                RateExchange · History
│   ├── notifications/          NotificationsActivity
│   ├── passport/               Passport · SkillPoints
│   ├── contracts/              ContractActivity
│   └── challenges/             Challenges · Detail · Create
├── adapter/        (20)        RecyclerView adapters
├── firebase/       (2)         FirebaseManager · FirestoreCollections
├── notifications/  (2)         NotificationHelper · SkillSwapMessagingService
└── utils/          (10)        SkillMatchEngine, GamificationEngine, SkillCatalog,
                                Validators, DateUtils, ChipFactory, UiUtils…
```

**Flujo de datos**

```
View (Activity/Fragment)
   ↕ LiveData / eventos
ViewModel
   ↕ RepoCallback<T>
Repository  →  FirestoreCollections  →  Cloud Firestore
```

Los repositorios son *singletons* sin estado de UI; los `ViewModel` mantienen
las `ListenerRegistration` de Firestore y las liberan en `onCleared()`.

---

## 3. Flujo principal de la app

```
REGISTRO → CREAR PERFIL → HABILIDADES QUE ENSEÑA → HABILIDADES QUE QUIERE APRENDER
   → BUSCAR COINCIDENCIAS → SKILLMATCH → VER PERFIL → ENVIAR SOLICITUD
   → ACEPTAR SOLICITUD → CREAR INTERCAMBIO → CHAT → REALIZAR INTERCAMBIO
   → MARCAR COMO COMPLETADO → CALIFICAR → REGISTRAR EN HISTORIAL
```

El **chat se crea automáticamente** al aceptar una solicitud
(`ExchangeRequestRepository.accept()` → `ExchangeRepository.createFromRequest()`
→ `ChatRepository.createChat()`) y no existe antes de ese momento.

Al cerrar un intercambio (ambos confirman) se disparan en cadena:
+20 SkillPoints a cada uno, actualización del Pasaporte de Habilidades,
incremento del contador de intercambios, insignia «Primer intercambio» y
notificación para calificar.

---

## 4. Innovaciones

### 4.1 SkillMatch inteligente — `utils/SkillMatchEngine.java`

El porcentaje **no es aleatorio**: es un modelo ponderado sobre 100 puntos.

| Peso | Criterio | Regla |
|---:|---|---|
| **45** | Coincidencia de habilidades | 22.5 pts por dirección. Cobertura: 0 coincidencias → 0; 1 → 0.9; 2+ → 1.0 |
| **20** | Nivel de quien enseña | 10 pts por dirección · Avanzado 1.0 · Intermedio 0.8 · Básico 0.55 |
| **12** | Modalidad | Compatible o alguna «Ambas» → 12 · sin definir → 7.2 · distintas → 0 |
| **13** | Disponibilidad | `13 × (bloques compartidos / min(bloques A, bloques B))` · sin datos → 6.5 |
| **10** | Reputación | `10 × (reputación / 5)` · sin calificaciones → 6 |

Si **no hay ninguna habilidad complementaria en ninguna dirección, el
resultado es 0 %** y no se ofrece el intercambio.

El motor devuelve además una lista de `MatchReason` que se muestra literalmente
en pantalla:

```
95 % compatible
✓ Ana enseña Diseño
✓ Tú buscas Diseño
✓ Tú enseñas Java
✓ Ana busca Java
✓ Horarios compatibles (3 bloques)
✓ Modalidad compatible (Virtual)
```

Se explica la fórmula completa dentro de la app en `MatchDetailActivity`.

### 4.2 Skill Passport — colección `skillPassport`

Una entrada por (usuario, habilidad, rol). Acumula intercambios, sesiones,
promedio de calificación y un progreso 0–100. El nivel se deriva de la
actividad real: `<2` intercambios → Básico · `2–4` → Intermedio · `5+` → Avanzado.

```
JAVA
Nivel: Intermedio · 5 intercambios · ⭐ 4.8
```

> El pasaporte refleja actividad dentro de SkillSwap.
> **No constituye una certificación académica ni un título oficial.**

### 4.3 Contrato de aprendizaje — colección `learningContracts`

Antes de iniciar, ambos definen objetivo, número de sesiones (1–20), duración
por sesión (15–240 min), modalidad, meta y actividad final.
**Los dos deben aceptar**; al hacerlo el intercambio pasa a `EN_PROCESO`.
Las reglas de Firestore impiden aceptar en nombre del otro.

### 4.4 SkillPoints — colección `skillPoints`

| Acción | Puntos |
|---|---:|
| Intercambio completado | +20 |
| Buena calificación (≥ 4) | +5 |
| Perfil completado | +10 |
| Contrato aceptado | +8 |
| Unirse a un reto | +10 |
| Registrar evidencia | +5 |

Niveles: **Principiante** (0–99) · **Colaborador** (100–299) ·
**Mentor** (300–699) · **SkillMaster** (700+).
Ocho insignias desbloqueables (`GamificationEngine.catalog()`).

> Los SkillPoints son puntos de reconocimiento dentro de la app.
> **No son dinero ni tienen valor monetario.**

### 4.5 Skill Challenges — colecciones `challenges` / `challengeParticipants`

Retos colaborativos con objetivo, habilidades requeridas, cupo, fecha límite y
progreso. Los estudiantes se postulan indicando con qué habilidad aportan y el
creador acepta o rechaza.

```
RETO: Crear una página web en 7 días
Se necesita: Programador · Diseñador · Redactor
2 de 4 participantes · 40 % de avance · 5 días restantes
```

### 4.6 Validación práctica del aprendizaje — colección `learningEvidence`

Al cerrar un intercambio se registra: actividad realizada, si se cumplió el
objetivo, evidencia opcional (imagen en Storage) y autoevaluación 1–5.

> Es una autoevaluación entre pares.
> **No equivale a una certificación académica.**

---

## 5. Modelo de datos (Cloud Firestore)

### `users/{uid}`
| Campo | Tipo | Descripción |
|---|---|---|
| `uid` | string | Igual al UID de Firebase Auth |
| `firstName`, `lastName` | string | Nombres y apellidos |
| `email` | string | Correo de la cuenta |
| `photoUrl` | string | URL en Storage (`avatars/{uid}.jpg`) |
| `university`, `career`, `cycle` | string | Datos académicos |
| `description` | string | Presentación (máx. 280) |
| `modality` | string | `Presencial` · `Virtual` · `Ambas` |
| `availability` | array\<string\> | Bloques horarios seleccionados |
| `teachSkills` | array\<UserSkill\> | Habilidades que enseña (embebidas) |
| `learnSkills` | array\<UserSkill\> | Habilidades que quiere aprender |
| `teachSkillKeys` | array\<string\> | Nombres en minúscula → `whereArrayContains` |
| `learnSkillKeys` | array\<string\> | Ídem para lo que busca |
| `searchKeywords` | array\<string\> | Tokens de nombre/carrera/universidad |
| `reputation` | number | Promedio 0–5 |
| `totalRatings` | number | Calificaciones recibidas |
| `exchangesCount` | number | Intercambios completados |
| `skillPoints` | number | Copia denormalizada del saldo |
| `gamificationLevel` | string | Principiante · Colaborador · Mentor · SkillMaster |
| `fcmToken` | string | Token de Cloud Messaging |
| `profileCompleted`, `active` | boolean | Flags de estado |
| `createdAt`, `updatedAt` | number | Epoch millis |

**`UserSkill` (objeto embebido)**
`skillId` · `name` · `category` · `level` (`Básico`/`Intermedio`/`Avanzado`) ·
`type` (`TEACH`/`LEARN`) · `note` · `addedAt`

### `skills/{slug}` — catálogo global
`id` · `name` · `category` · `iconKey` · `popularity`

Categorías sembradas: **Programación** (Java, Python, JavaScript, SQL, HTML/CSS) ·
**Diseño** (Photoshop, Illustrator, Figma, Canva) · **Idiomas** (Inglés,
Portugués, Francés) · **Académico** (Matemática, Física, Estadística) ·
**Multimedia** (Edición de video, Fotografía, Animación) ·
**Otros** (Excel, Oratoria, Marketing, Música).

### `matches/{uidA_uidB}`
`id` · `userAId` · `userBId` · `participants[]` · `score` (0–100) ·
`mutual` · `reasonTexts[]` · `createdAt`

### `exchangeRequests/{autoId}`
`id` · `fromUserId` / `fromUserName` / `fromUserPhoto` ·
`toUserId` / `toUserName` / `toUserPhoto` · `participants[]` ·
`skillWanted` (lo que el emisor quiere aprender) ·
`skillOffered` (lo que el emisor enseña) · `message` · `modality` · `schedule` ·
`status` (`PENDIENTE`·`ACEPTADA`·`RECHAZADA`·`CANCELADA`·`EN_PROCESO`·`COMPLETADA`) ·
`matchScore` · `exchangeId` · `createdAt` · `updatedAt`

### `exchanges/{autoId}`
`id` · `requestId` · `chatId` · `contractId` ·
`userAId`/`userAName`/`userAPhoto` · `userBId`/`userBName`/`userBPhoto` ·
`participants[]` · `skillFromA` (A enseña) · `skillFromB` (B enseña) ·
`modality` · `schedule` ·
`status` (`PROXIMO`·`EN_PROCESO`·`COMPLETADO`·`CANCELADO`) ·
`progress` (0–100) · `sessionsTotal` · `sessionsDone` ·
`completedByA` · `completedByB` · `ratedByA` · `ratedByB` ·
`startDate` · `endDate` · `createdAt` · `updatedAt`

### `chats/{exchangeId}`
`id` · `exchangeId` · `participants[]` · `names{uid:nombre}` ·
`photos{uid:url}` · `unread{uid:count}` · `lastMessage` · `lastSenderId` ·
`lastMessageAt` · `enabled` · `createdAt`

### `chats/{chatId}/messages/{autoId}`
`id` · `chatId` · `senderId` · `senderName` · `senderPhoto` · `text` ·
`type` (`TEXT`·`SYSTEM`·`IMAGE`) · `imageUrl` · `timestamp` · `readBy[]`

### `ratings/{autoId}`
`id` · `exchangeId` · `fromUserId`/`fromUserName`/`fromUserPhoto` ·
`toUserId` · `skillTaught` · `stars` · `punctuality` · `communication` ·
`teaching` · `comment` · `createdAt`
La reputación se recalcula en una transacción sobre `users/{toUserId}`.

### `notifications/{autoId}`
`id` · `userId` · `type` · `title` · `body` · `referenceId` · `read` · `createdAt`
Tipos: `NEW_REQUEST` · `REQUEST_ACCEPTED` · `REQUEST_REJECTED` ·
`NEW_MESSAGE` · `NEW_MATCH` · `EXCHANGE_COMPLETED` · `NEW_RATING` ·
`BADGE` · `CHALLENGE`

### `skillPassport/{uid__skill__rol}`
`id` · `userId` · `skillName` · `category` ·
`role` (`ENSENADA`·`APRENDIDA`·`PRACTICADA`) · `level` ·
`exchangesCount` · `sessionsCount` · `averageRating` · `ratingsCount` ·
`progress` · `lastActivity` · `createdAt`

### `learningContracts/{exchangeId}`
`id` · `exchangeId` · `participants[]` · `userAId` · `userBId` · `createdBy` ·
`objective` · `sessions` · `sessionDuration` · `modality` · `goal` ·
`finalActivity` · `acceptedByA` · `acceptedByB` ·
`status` (`BORRADOR`·`PENDIENTE`·`ACTIVO`·`CERRADO`) · `createdAt` · `updatedAt`

### `skillPoints/{uid}`
`userId` · `points` · `level` · `levelIndex` · `pointsForNextLevel` ·
`completedExchanges` · `badgesUnlocked` · `updatedAt`

### `skillPoints/{uid}/history/{autoId}`
`id` · `userId` · `points` · `reason` · `referenceId` · `createdAt`

### `badges/{uid__CODE}`
`id` · `userId` · `code` · `name` · `description` · `iconKey` · `colorKey` ·
`unlocked` · `unlockedAt`

### `challenges/{autoId}`
`id` · `title` · `description` · `objective` · `category` ·
`requiredSkills[]` · `participantIds[]` · `creatorId`/`creatorName`/`creatorPhoto` ·
`maxParticipants` · `participantsCount` · `durationDays` · `progress` ·
`status` (`ABIERTO`·`EN_PROCESO`·`FINALIZADO`) · `deadline` · `createdAt`

### `challengeParticipants/{challengeId__uid}`
`id` · `challengeId` · `userId` · `userName` · `userPhoto` · `skill` ·
`role` · `message` · `status` (`PENDIENTE`·`ACEPTADO`·`RECHAZADO`) · `joinedAt`

### `learningEvidence/{autoId}`
`id` · `exchangeId` · `userId` · `partnerId` · `skillName` · `activity` ·
`notes` · `evidenceUrl` · `objectiveAchieved` · `selfAssessment` · `createdAt`

---

## 6. Seguridad

Las reglas completas están en **`firestore.rules`** y **`storage.rules`**.
En ningún caso se usa `allow read, write: if true`.

Garantías implementadas:

- Un usuario **solo edita su propio documento** y no puede tocar su
  `reputation` ni `totalRatings` directamente.
- Las habilidades viven embebidas en el documento del usuario → solo el dueño
  las administra.
- `exchanges`, `chats`, `learningContracts` y `matches` exigen que
  `request.auth.uid` esté dentro de `participants`.
- Los mensajes solo pueden crearse con `senderId == uid`, con el chat
  habilitado y con texto de 1–2000 caracteres. No se editan, solo se marca
  `readBy`.
- **Solo se puede calificar** un intercambio en el que participaste y que esté
  en estado `COMPLETADO`; no puedes calificarte a ti mismo; las calificaciones
  son inmutables.
- En `learningContracts` nadie puede modificar el campo `acceptedBy*` del otro.
- En `challenges` solo el creador administra el reto; el resto únicamente puede
  ser añadido a `participantIds` / `participantsCount`.
- Storage: `avatars/` solo acepta un archivo cuyo nombre sea el propio UID,
  imagen y menor a 5 MB.
- Cierre por defecto: `match /{document=**} { allow read, write: if false; }`

Despliegue:

```bash
firebase deploy --only firestore:rules,storage:rules
```

---

## 7. Puesta en marcha

### 7.1 Requisitos
- Android Studio (AGP 9.3.3 / Gradle 9.5)
- JDK 11+
- Un proyecto de Firebase

### 7.2 Configurar Firebase

Hay dos caminos. El **A** es el más corto si nunca has usado la consola.

#### Camino A — Consola web

1. Crea el proyecto en <https://console.firebase.google.com>.
2. Añade una app **Android** con el package exacto `com.skillswap`.
3. Descarga `google-services.json` y guárdalo como `app/google-services.json`.

   > Ese archivo **no está en el repositorio**: lleva la clave de API y el id
   > del proyecto Firebase, así que está en `.gitignore`. En su lugar
   > encontrarás `app/google-services.json.example`, que muestra la estructura
   > esperada. Sin el archivo real la app compila pero no pasa del login.
4. Habilita en la consola:
   - **Authentication** → proveedor *Correo electrónico/contraseña*
   - **Cloud Firestore** → crear base de datos (modo producción)
   - **Storage** → crear bucket
   - **Cloud Messaging** → queda activo automáticamente
5. Pega el contenido de `firestore.rules` en
   *Firestore → Reglas* y el de `storage.rules` en *Storage → Reglas*.
   Pulsa **Publicar** en cada una.

#### Camino B — Firebase CLI

El repo ya trae `firebase.json` (apunta a ambos archivos de reglas y deja
configurados los emuladores) y `.firebaserc`.

```bash
npm install -g firebase-tools     # si aún no lo tienes
firebase login                    # abre el navegador: solo tú puedes hacerlo

# Opción 1: crear el proyecto desde cero
firebase projects:create skillswap-<algo-unico>

# Opción 2: usar uno existente (escribe el ID en .firebaserc o usa:)
firebase use --add

# Registrar la app Android y bajar el google-services.json real
firebase apps:create ANDROID SkillSwap --package-name com.skillswap
firebase apps:sdkconfig ANDROID --out app/google-services.json

# Publicar las reglas
firebase deploy --only firestore:rules,storage:rules
```

> `Authentication` (email/contraseña), `Firestore` y `Storage` aún deben
> activarse una vez desde la consola web: la CLI no puede habilitarlos.

Para desarrollar sin tocar datos reales:

```bash
firebase emulators:start        # UI en http://localhost:4000
```

### 7.3 Compilar y verificar

```bash
./gradlew assembleDebug        # APK en app/build/outputs/apk/debug/
./gradlew installDebug         # instalar en el dispositivo conectado
./gradlew testDebugUnitTest    # 50 tests unitarios
./gradlew lintDebug            # análisis estático (0 errores)
```

**Tests incluidos** (`app/src/test/java/com/skillswap/`):

| Clase | Tests | Qué demuestra |
|---|---:|---|
| `SkillMatchEngineTest` | 10 | El match es determinista y con reglas reales; el caso César/Ana da **96 %** |
| `GamificationEngineTest` | 11 | Umbrales de nivel, progreso y catálogo de insignias |
| `CoreLogicTest` | 29 | Catálogo, validaciones, filtros, pasaporte y modelos |

El test `esDeterminista_noUsaAzar` ejecuta el algoritmo 25 veces con las mismas
entradas y comprueba que siempre devuelve el mismo número: es la prueba de que
el porcentaje **no es aleatorio**.

### 7.4 Índices de Firestore

**No se requiere ningún índice compuesto.** Todas las consultas usan un único
campo (`whereEqualTo` o `whereArrayContains`) y el ordenamiento se hace en
memoria dentro de los repositorios, precisamente para evitar la fricción de
crear índices manualmente.

### 7.5 Enviar notificaciones push

El servicio `SkillSwapMessagingService` espera un payload de datos:

```json
{
  "to": "<fcmToken del usuario>",
  "data": {
    "type": "NEW_MESSAGE",
    "title": "Nuevo mensaje de Ana",
    "body": "¿Nos vemos el sábado?",
    "referenceId": "<chatId>"
  }
}
```

El centro interno de notificaciones (colección `notifications`) funciona
siempre, incluso sin configurar el envío push desde un servidor.

---

## 8. Diseño de interfaz

- **Paleta:** violeta `#6C4DF6` (primario), turquesa `#00D2B8` (secundario),
  coral `#FF6B6B` (acento), amarillo `#FFC93C`.
- Tema **Material 3** con soporte completo de modo claro y oscuro
  (`values/themes.xml` y `values-night/themes.xml`).
- 61 layouts XML, 57 iconos vectoriales propios, 33 fondos y degradados.
- Componentes usados: `ConstraintLayout`, `LinearLayout`, `FrameLayout`,
  `CoordinatorLayout`, `NestedScrollView`, `RecyclerView`, `MaterialCardView`,
  `TextInputLayout` / `TextInputEditText`, `MaterialButton`, `Chip` /
  `ChipGroup`, `BottomNavigationView`, `MaterialToolbar`, `TabLayout`,
  `FloatingActionButton`, `ExtendedFloatingActionButton`, `ProgressIndicator`,
  `SwipeRefreshLayout`, `Slider`, `MaterialSwitch`, `RatingBar`,
  `BottomSheetDialogFragment`, `MaterialAlertDialogBuilder`, `ViewPager2`.

---

## 9. Avisos importantes

- El **Pasaporte de Habilidades** y la **validación práctica del aprendizaje**
  reflejan actividad entre pares dentro de la aplicación.
  **No son certificaciones académicas ni títulos oficiales.**
- Los **SkillPoints** son puntos de reconocimiento dentro de la app.
  **No representan dinero ni tienen valor monetario.**
- SkillSwap no gestiona pagos de ningún tipo: todo intercambio es de
  conocimiento por conocimiento.

---

## 10. Scripts de generación

La carpeta `tools/` contiene los scripts Bash con los que se generó el proyecto
(iconos, shapes, modelos, repositorios, ViewModels, adapters, layouts y vistas).
No forman parte del APK; puedes eliminarlos sin afectar la compilación.
