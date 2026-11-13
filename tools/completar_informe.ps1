# ============================================================================
#  Completa el Informe de Proyecto Final de SkillSwap.
#
#    - Tabla 12 con las pantallas reales y referencia a cada figura
#    - Figuras 6 en adelante, con capturas tomadas del emulador
#    - Corrige afirmaciones que ya no son ciertas (ksoap2, numero de pruebas)
#    - Capitulos VIII (con huecos marcados), IX, X y XI
#
#  NO toca el capitulo I (Resumen).
#  Escribe en un archivo NUEVO; el original queda intacto.
# ============================================================================
$ErrorActionPreference = 'Stop'

$origen  = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_Metodologia (3).docx"
$destino = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_COMPLETO.docx"
$caps    = "C:\Users\ricra\AndroidStudioProjects\PROYECTOAPLICACIONESMOVILES\capturas"

$figuras = @(
  @{ s='1'; p='Introduccion (P02)';                q='Las tres pantallas de bienvenida, con indicador de posicion y boton Omitir.';            i='00_onboarding.png' },
  @{ s='1'; p='Inicio de sesion (P04)';            q='Acceso con correo y contrasena, con enlace de recuperacion.';                            i='01_login.png' },
  @{ s='1'; p='Perfil academico (P21)';            q='Universidad, carrera, ciclo, reputacion, intercambios y SkillPoints.';                   i='60_perfil_top.png' },
  @{ s='2'; p='Mis habilidades (P22, P23)';        q='Habilidades que se ensenan y que se quieren aprender, con su nivel.';                    i='61_habilidades.png' },
  @{ s='2'; p='Explorar (P07)';                    q='Estudiantes compatibles ordenados por el porcentaje del SkillMatch.';                    i='50_explorar.png' },
  @{ s='2'; p='Perfil publico y SkillMatch (P09)'; q='Criterios del match, horarios en comun e indice de confiabilidad.';                      i='53_confiabilidad.png' },
  @{ s='3'; p='Solicitudes recibidas (P10)';       q='Solicitudes pendientes con las acciones de aceptar y rechazar.';                          i='75_solicitudes.png' },
  @{ s='3'; p='Chat en tiempo real (P17)';         q='Conversacion entre los dos estudiantes del intercambio.';                                i='63_chat.png' },
  @{ s='3'; p='Servicios web REST y SOAP (RC2)';   q='Universidades sugeridas por el servicio REST y pais e idioma obtenidos por SOAP.';       i='71_rest_universidades.png' },
  @{ s='4'; p='Firma de la aceptacion (RC3)';      q='Resumen de lo aceptado, terminos y lienzo de firma con el trazo dibujado.';              i='77_firma_dibujada.png' },
  @{ s='4'; p='Geolocalizacion (RC4)';             q='Permiso de ubicacion APROXIMADA, solicitado al activar Cercanos.';                        i='73_permiso_ubicacion.png' },
  @{ s='4'; p='Contrato de aprendizaje';           q='Acuerdo aceptado por ambos; el intercambio pasa a EN PROCESO.';                          i='19_acuerdo_activo.png' },
  @{ s='4'; p='Sesion en vivo';                    q='Cronometro de la sesion contra la duracion firmada en el contrato.';                     i='48_cronometro.png' },
  @{ s='4'; p='SkillPoints y nivel (P25)';         q='Puntos acumulados, nivel y barra de avance hacia el siguiente.';                         i='21_skillpoints.png' },
  @{ s='4'; p='Tabla de lideres';                  q='Ranking por SkillPoints; los empates comparten posicion.';                               i='43_tabla.png' },
  @{ s='4'; p='Rutas de aprendizaje';              q='Prerrequisitos ordenados y avance tomado del Pasaporte de Habilidades.';                 i='52_rutas_arreglado.png' }
)

foreach ($f in $figuras) {
  if (-not (Test-Path (Join-Path $caps $f.i))) { throw "Falta la captura: $($f.i)" }
}
Write-Output "Capturas verificadas: $($figuras.Count)"

Copy-Item $origen $destino -Force

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $null

# Reemplaza el parrafo que empieza por $prefijo. Varios parrafos se separan
# con Chr(13), que Word interpreta como marca de parrafo nueva.
function Reemplazar($doc, $prefijo, $nuevos) {
  for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
    $p = $doc.Paragraphs.Item($i)
    $t = $p.Range.Text
    if ($t -and $t.StartsWith($prefijo)) {
      $r = $p.Range
      $r.MoveEnd(1, -1) | Out-Null     # wdCharacter: excluir la marca final
      $r.Text = ($nuevos -join [string][char]13)
      return $true
    }
  }
  Write-Output "  AVISO: no se encontro '$($prefijo.Substring(0, [Math]::Min(45, $prefijo.Length)))...'"
  return $false
}

try {
  $doc = $word.Documents.Open($destino)

  # ============================================================ 1. TABLA 12
  $t = $doc.Tables.Item(12)
  if (($t.Cell(1,1).Range.Text -replace "[\r\a]","") -ne 'Sprint') { throw "Tabla 12 inesperada." }

  $t.Cell(1,4).Range.Text = 'Figura'
  while (($t.Rows.Count - 1) -lt $figuras.Count) { $t.Rows.Add() | Out-Null }

  for ($i = 0; $i -lt $figuras.Count; $i++) {
    $fila = $i + 2
    $t.Cell($fila,1).Range.Text = $figuras[$i].s
    $t.Cell($fila,2).Range.Text = $figuras[$i].p
    $t.Cell($fila,3).Range.Text = $figuras[$i].q
    $t.Cell($fila,4).Range.Text = ("Figura {0}" -f ($i + 6))
  }
  Write-Output "Tabla 12: $($figuras.Count) filas"

  # ============================================== 2. CORRECCIONES PUNTUALES
  Write-Output "Correcciones:"

  Reemplazar $doc "Sobre SOAP armado con ksoap2-android" @(
    "Sobre SOAP (Envelope y Body) construido con HttpURLConnection y lectura del XML de respuesta."
  ) | Out-Null

  Reemplazar $doc "ksoap2-android permite consumir servicios SOAP" @(
    "El sobre XML se arma con HttpURLConnection, sin librerias externas."
  ) | Out-Null

  Reemplazar $doc "Se ejecutaron 67 pruebas unitarias" @(
    ("Se ejecutaron 96 pruebas unitarias con JUnit 4, todas aprobadas y sin fallos, " +
     "repartidas en cinco clases: CoreLogicTest (29), GamificationEngineTest (11), " +
     "SkillMatchEngineTest (10), InnovacionesTest (32) y RequisitosCursoTest (14). " +
     "Las dos ultimas cubren las innovaciones 7 a 12 y los requisitos del curso RC2, " +
     "RC3 y RC4, que son logica pura y por tanto verificable sin dispositivo. " +
     "El analisis estatico (gradlew lintDebug) termina con 0 errores.")
  ) | Out-Null

  Reemplazar $doc "Alcance y limitaciones. Las pruebas no se ejecutaron" @(
    ("Alcance y limitaciones. Ademas de las pruebas unitarias, la aplicacion se " +
     "verifico ejecutandola sobre un emulador Android (API 36) contra el proyecto " +
     "real de Firebase, y las capturas del apartado 7.1.6 proceden de esa ejecucion. " +
     "Durante esa verificacion se detectaron y corrigieron tres defectos que las " +
     "pruebas unitarias no podian revelar: la consulta de solicitudes se rechazaba " +
     "con PERMISSION_DENIED porque filtraba por un campo distinto al que autoriza la " +
     "regla de seguridad, el reproductor del sonido de entrada no aplicaba sus " +
     "atributos de audio, y la ruta de aprendizaje marcaba mas de un paso como actual. " +
     "Queda pendiente publicar en la consola de Firebase las reglas de la coleccion " +
     "signatures (RC3) y comprobar la geolocalizacion en un dispositivo fisico, porque " +
     "el emulador no entrega una posicion valida.")
  ) | Out-Null

  # ====================================================== 3. CAPITULO VIII
  Reemplazar $doc "Se incluye en la entrega final: captura de la participacion" @(
    "[PENDIENTE: insertar aqui la captura de la participacion en los debates del aula virtual y de los avances presentados.]"
  ) | Out-Null
  Reemplazar $doc "Se incluye en la entrega final: captura de la participación" @(
    "[PENDIENTE: insertar aqui la captura de la participacion en los debates del aula virtual y de los avances presentados.]"
  ) | Out-Null
  Reemplazar $doc "Se incluye en la entrega final: enlace al video" @(
    "[PENDIENTE: pegar aqui el enlace al video de presentacion, de maximo 10 minutos, alojado en Office 365.]"
  ) | Out-Null
  Reemplazar $doc "Se incluye en la entrega final: captura de la carátula" @(
    "[PENDIENTE: insertar aqui la captura de la caratula de la presentacion usada en la sustentacion.]"
  ) | Out-Null
  Reemplazar $doc "Se incluye en la entrega final: captura de la caratula" @(
    "[PENDIENTE: insertar aqui la captura de la caratula de la presentacion usada en la sustentacion.]"
  ) | Out-Null

  # ======================================================== 4. CAPITULO IX
  Reemplazar $doc "Se presentan en la entrega final, un resultado" @(
    ("Objetivo general. Se construyo y puso en funcionamiento un aplicativo movil " +
     "nativo que permite el intercambio de habilidades entre estudiantes universitarios " +
     "sin dinero de por medio. El producto implementa las 48 historias de usuario del " +
     "Product Backlog, los cuatro requisitos del curso (cache local con SQLite, consumo " +
     "de servicios REST y SOAP, firma de la aceptacion y geolocalizacion aproximada) y " +
     "doce innovaciones propias. La verificacion tecnica arroja 96 pruebas unitarias " +
     "aprobadas sin fallos, 0 errores de analisis estatico y una prueba de extremo a " +
     "extremo de 37 comprobaciones contra el Firebase real, incluidos seis intentos de " +
     "acceso indebido que las reglas bloquearon correctamente."),

    ("Resultado del Oe1 (conexion entre estudiantes con habilidades complementarias). " +
     "El SkillMatch calcula la compatibilidad con un modelo ponderado sobre 100 puntos " +
     "que combina coincidencia de habilidades (45), nivel de quien ensena (20), " +
     "disponibilidad (13), modalidad (12) y reputacion (10). No interviene el azar: una " +
     "prueba unitaria ejecuta el calculo 25 veces y comprueba que el resultado no varia, " +
     "y si no existe ninguna habilidad complementaria el puntaje es 0 y no se ofrece el " +
     "intercambio. Entre las dos cuentas reales del equipo el resultado es 99 %, y la " +
     "pantalla explica en texto cada criterio que sumo. A esto se anadieron dos " +
     "innovaciones que ayudan a decidir antes de escribir: las franjas horarias en comun " +
     "y un indice de confiabilidad calculado a partir de intercambios terminados, " +
     "puntualidad y contratos firmados."),

    ("Resultado del Oe2 (aprendizaje de nuevas habilidades). El intercambio no empieza " +
     "hasta que ambos estudiantes firman un Contrato de Aprendizaje con objetivo, numero " +
     "de sesiones, duracion y actividad final; se comprobo que la unica via para que un " +
     "intercambio pase a EN PROCESO es la aceptacion de ese contrato por las dos partes. " +
     "Sobre esa base, el Modo Sesion en Vivo cronometra cada sesion contra la duracion " +
     "acordada y solo permite registrarla al superar el 50 % del tiempo, la Validacion " +
     "del Aprendizaje exige describir la actividad realizada con una autoevaluacion, y el " +
     "Pasaporte de Habilidades acumula esa actividad por habilidad y alimenta las Rutas " +
     "de Aprendizaje."),

    ("Alcance de estos resultados. Lo medido es el funcionamiento del producto, no su " +
     "efecto en las personas. El proyecto no incluyo un estudio con usuarios reales, por " +
     "lo que no se puede afirmar que la aplicacion haya influido de forma medible en el " +
     "aprendizaje de los estudiantes: esa comprobacion requiere un trabajo de campo " +
     "posterior con una muestra y un instrumento validado.")
  ) | Out-Null

  Reemplazar $doc "Se redacta en la entrega final, comparando la postura" @(
    ("Los antecedentes revisados en el apartado 3.1 respaldan las decisiones de diseno " +
     "del proyecto. Erazo Moreno et al. (2022) encontraron una relacion directa y alta " +
     "(Rho de Spearman = 0,892) entre el uso de plataformas virtuales educativas y el " +
     "aprendizaje colaborativo en una universidad publica de Lima; SkillSwap se situa en " +
     "esa linea, aunque con una diferencia importante: aquel es un estudio correlacional " +
     "con usuarios y este es un proyecto de desarrollo, de modo que los resultados no " +
     "son comparables de forma directa."),

    ("Jadhav et al. (2025), con SkillMesh, y Rossi y Valenti (2022) coinciden en que el " +
     "emparejamiento por compatibilidad de habilidades y disponibilidad horaria favorece " +
     "el compromiso entre pares. SkillSwap llega a la misma conclusion de diseno y anade " +
     "un elemento que esos trabajos no describen: el acuerdo explicito previo. En las " +
     "plataformas revisadas el contacto se produce y el intercambio queda librado a la " +
     "buena voluntad; aqui el intercambio no arranca sin un contrato firmado por ambos. " +
     "Esa decision responde al problema de los intercambios que se abandonan a medias, y " +
     "es tambien la que sostiene el indice de confiabilidad."),

    ("Looi et al. (2021) con MENTOR y Chen et al. (2022) destacan el valor de la " +
     "horizontalidad y la seguridad psicologica en la tutoria entre pares. De ahi viene " +
     "que SkillSwap no distinga entre tutor y alumno: todos ensenan y aprenden a la vez, " +
     "y la reputacion se separa deliberadamente de la confiabilidad, porque ensenar bien " +
     "y cumplir lo acordado son cosas distintas. Al-Rahmi et al. (2023) justifican " +
     "incorporar canales de comunicacion dentro de la propia herramienta, de donde sale " +
     "el chat en tiempo real."),

    ("Sanchez-Prieto et al. (2021) advierten que la adopcion del aprendizaje movil " +
     "depende de la utilidad percibida y de la facilidad de uso. Esa advertencia explica " +
     "decisiones concretas del producto: el perfil se completa con ayuda de un servicio " +
     "REST que sugiere la universidad, los permisos se piden solo cuando se usan y la " +
     "aplicacion funciona sin conexion gracias a la cache local."),

    ("Limitacion principal de la discusion. Al no haber medicion con usuarios, lo que " +
     "aqui se compara son decisiones de diseno frente a hallazgos de la literatura, no " +
     "resultados frente a resultados.")
  ) | Out-Null

  # ========================================================= 5. CAPITULO X
  Reemplazar $doc "Se redactan en la entrega final, una por cada objetivo" @(
    ("Conclusion general. Es viable construir, con herramientas gratuitas y en cuatro " +
     "sprints de una semana, un aplicativo movil nativo que soporte el intercambio de " +
     "habilidades entre estudiantes universitarios sin dinero de por medio. El resultado " +
     "no es un prototipo de pantallas: es una aplicacion que compila, se instala, se " +
     "conecta a un backend real y cuyas reglas de seguridad bloquean los accesos " +
     "indebidos que se probaron."),

    ("Conclusion sobre el Oe1. Calcular la compatibilidad con un modelo de reglas " +
     "ponderadas y explicarlo en pantalla es suficiente para conectar estudiantes con " +
     "habilidades complementarias, y no hace falta aprendizaje automatico. La ventaja de " +
     "este enfoque es que el porcentaje se puede justificar criterio por criterio, cosa " +
     "que un modelo entrenado no permitiria con la misma claridad."),

    ("Conclusion sobre el Oe2. Exigir un acuerdo firmado antes de empezar cambia la " +
     "naturaleza del intercambio: pasa de ser una intencion a ser un compromiso con " +
     "objetivo, numero de sesiones y entregable. Todo lo que vino despues (cronometro de " +
     "sesion, evidencia, pasaporte) se apoya en que ese acuerdo exista."),

    ("Recomendacion 1. Hacer una prueba con usuarios reales. Es lo que falta para pasar " +
     "de 'la aplicacion funciona' a 'la aplicacion sirve', y permitiria contrastar los " +
     "resultados con los antecedentes del apartado 3.1."),

    ("Recomendacion 2. Reforzar las reglas de skillPoints. Hoy cualquier usuario " +
     "autenticado puede modificar su saldo de puntos; conviene moverlo a una Cloud " +
     "Function antes de publicar."),

    ("Recomendacion 3. Exigir el ciclo academico en el perfil y excluir de los " +
     "resultados de busqueda los perfiles incompletos, que son los dos hallazgos " +
     "abiertos de la Tabla 10."),

    ("Recomendacion 4. Sustituir la cache de imagenes incrustadas por Cloud Storage " +
     "cuando el proyecto pase al plan Blaze, y revisar el limite de 5 MB en la propia " +
     "aplicacion antes de subir el archivo.")
  ) | Out-Null

  # ======================================================== 6. CAPITULO XI
  Reemplazar $doc "Se completa en la entrega final, en formato APA" @(
    ("Nota para el equipo: las referencias de los antecedentes se listan con los datos " +
     "disponibles en el apartado 3.1. Hay que completar revista, volumen, numero, " +
     "paginas y DOI de cada una antes de la entrega final; los campos por completar " +
     "estan marcados entre corchetes."),
    "",
    "Al-Rahmi, W., Yahaya, N. y Alamri, M. (2023). Integrando el aprendizaje movil y las redes sociales para el aprendizaje colaborativo: impacto en el desempeno y la participacion academica de los estudiantes en universidades asiaticas. [Completar: revista, vol.(num.), pp., DOI].",
    "Alami, A. y Chafiq, N. (2020). Diseno e implementacion de una aplicacion movil basada en P2P para el aprendizaje colaborativo en educacion superior. [Completar: revista, vol.(num.), pp., DOI].",
    "Carrion, J. y Sulca, R. (2021). Aplicacion movil para estudiantes universitarios [Tesis de licenciatura, Universidad Cesar Vallejo]. [Completar: repositorio y URL].",
    "Chen, L., Wang, Y. y Zhang, H. (2022). Disenando y evaluando una aplicacion de tutoria entre pares para educacion superior usando la teoria de la actividad historico-cultural. [Completar: revista, vol.(num.), pp., DOI].",
    "Echeverria Macedo, J. (2024). Gamificacion y habilidades blandas en estudiantes de una universidad privada de Lambayeque. [Completar: tipo de documento, institucion y URL].",
    "Erazo Moreno, E., Guizado Oscco, F., Huachara Martinez, J., Nina-Cuchillo, E. y Nina-Cuchillo, J. (2022). Plataformas virtuales educativas y aprendizaje colaborativo en estudiantes de una universidad publica de Lima. [Completar: revista, vol.(num.), pp., DOI].",
    "Google. (s. f.). Firebase Documentation. https://firebase.google.com/docs",
    "Google. (s. f.). Guide to app architecture. Android Developers. https://developer.android.com/topic/architecture",
    "Jadhav, S., Ray, A., Awale, P., Patil, S., Latpate, R. y Patil, V. (2025). SkillMesh: plataforma de emparejamiento de estudiantes por compatibilidad de habilidades y disponibilidad. Pimpri Chinchwad College of Engineering and Research. [Completar: revista o congreso, pp., DOI].",
    "Kruchten, P. (2003). The Rational Unified Process: An Introduction (3.a ed.). Addison-Wesley.",
    "LearnXChange: Peer-to-Peer Skill Exchange Platform. (2026). [Completar: autores, revista o congreso, pp., DOI].",
    "Looi, C. K., Cheung, W. S., Chung, T. y Lim, S. (2021). MENTOR: una aplicacion movil de tutoria entre pares universitarios. Nanyang Technological University. [Completar: revista, vol.(num.), pp., DOI].",
    "Rossi, M. y Valenti, S. (2022). Plataformas digitales entre pares para educacion informal e intercambio de habilidades en campus europeos. [Completar: revista, vol.(num.), pp., DOI].",
    "Sanchez-Prieto, J. C., Olmos-Miguelanez, S. y Garcia-Penalvo, F. J. (2021). Tecnologias moviles en entornos educativos: evaluando los factores que influyen en la adopcion del aprendizaje movil entre estudiantes universitarios. [Completar: revista, vol.(num.), pp., DOI].",
    "Schwaber, K. y Sutherland, J. (2020). La Guia de Scrum. Scrum.org. https://scrumguides.org"
  ) | Out-Null

  # ====================================================== 7. FIGURAS
  $sel = $word.Selection
  $sel.HomeKey(6) | Out-Null
  $f = $sel.Find
  $f.ClearFormatting()
  $f.Text = '7.2. Repositorios'
  $f.Forward = $true
  $f.Wrap = 0
  if (-not $f.Execute()) { throw "No se encontro el apartado 7.2." }

  $sel.Collapse(1) | Out-Null
  $sel.InsertParagraphBefore()
  $sel.MoveUp(4,1) | Out-Null

  for ($i = 0; $i -lt $figuras.Count; $i++) {
    $n = $i + 6
    $fig = $figuras[$i]

    $sel.Style = $doc.Styles.Item('Normal')
    $sel.ParagraphFormat.Alignment = 0
    $sel.Font.Bold = $true
    $sel.TypeText("Figura $n")
    $sel.TypeParagraph()

    $sel.Font.Bold = $false
    $sel.Font.Italic = $true
    $sel.TypeText($fig.p + '. ' + $fig.q)
    $sel.TypeParagraph()
    $sel.Font.Italic = $false

    $shape = $sel.InlineShapes.AddPicture((Join-Path $caps $fig.i), $false, $true)
    $shape.LockAspectRatio = $true
    $shape.Width = 135
    $sel.MoveRight(1,1) | Out-Null
    $sel.TypeParagraph()

    $sel.Font.Italic = $true
    $sel.TypeText('Nota. Captura tomada de la aplicacion en ejecucion sobre el emulador Android (API 36) conectado al proyecto real de Firebase.')
    $sel.Font.Italic = $false
    $sel.TypeParagraph()
  }
  Write-Output "Figuras 6 a $($figuras.Count + 5) insertadas"

  $doc.Save()
  Write-Output "GUARDADO: $destino"
}
finally {
  if ($doc) { try { $doc.Close($true) } catch {} }
  try { $word.Quit() } catch {}
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
  [GC]::Collect()
}
