# ============================================================================
#  Completa el Informe de Proyecto Final de SkillSwap.
#
#  TODO el texto con tildes vive en tools/informe_contenido.txt y se lee como
#  UTF-8. Este archivo debe seguir siendo ASCII: PowerShell 5.1 lee los .ps1
#  en ANSI y se come las tildes.
#
#  Lecciones de Word COM que costaron varias pasadas (no repetir):
#   - Selection.TypeText dentro de un parrafo con texto lo desgarra. Aqui se
#     crean parrafos vacios y se rellenan.
#   - Buscar anclas con StartsWith encuentra antes la linea del INDICE que el
#     encabezado real. Se compara por igualdad exacta y solo en el cuerpo.
#   - Trim() elimina los tabuladores: al reescribir una linea de indice se
#     perdian los puntos guia. Solo se toca la cifra final.
#
#  No toca el original: escribe en un archivo NUEVO.
# ============================================================================
param(
  [string]$Destino = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_COMPLETO.docx"
)
$ErrorActionPreference = "Stop"

$PRIMERA_FIGURA = 7                 # el informe ya usa las Figuras 1 a 6
$RAIZ      = "C:\Users\ricra\AndroidStudioProjects\PROYECTOAPLICACIONESMOVILES"
$origen    = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_Metodologia (3).docx"
$caps      = Join-Path $RAIZ "capturas"
$contenido = Join-Path $RAIZ "tools\informe_contenido.txt"
$resultados = Join-Path $RAIZ "app\build\test-results\testDebugUnitTest"
$SEP = [string][char]0x00A6         # separador de columnas/campos en el contenido
$TAB = [string][char]9

# ----------------------------------------------- recuento REAL de pruebas
# Si hay algun fallo, se aborta: no se escribira "todas aprobadas" en falso.
$porClase = [ordered]@{}
$total = 0; $fallos = 0
foreach ($f in (Get-ChildItem $resultados -Filter "TEST-*.xml" | Sort-Object Name)) {
  $x = [xml](Get-Content $f.FullName -Encoding UTF8)
  $s = $x.testsuite
  $nombre = ($s.name -split '\.')[-1]
  $porClase[$nombre] = [int]$s.tests
  $total += [int]$s.tests
  $fallos += [int]$s.failures + [int]$s.errors
}
if ($total -eq 0) { throw "No hay resultados de pruebas en $resultados. Ejecuta gradlew testDebugUnitTest." }
if ($fallos -gt 0) { throw "Hay $fallos pruebas fallidas: no se genera el informe." }
$partes = @($porClase.Keys | ForEach-Object { "$_ ($($porClase[$_]))" })
$desglose = if ($partes.Count -gt 1) { ($partes[0..($partes.Count-2)] -join ', ') + ' y ' + $partes[-1] } else { $partes[0] }
Write-Output "Pruebas: $total en $($porClase.Count) clases, 0 fallos"

function Sustituir([string]$t) {
  return $t.Replace('{PRUEBAS}', "$total").Replace('{NCLASES}', "$($porClase.Count)").Replace('{DESGLOSE}', $desglose)
}

# ------------------------------------------------------ leer el contenido
$modelos = @{}; $figuras = @(); $notaFig = ''; $ops = @()
$lin = Get-Content $contenido -Encoding UTF8
$k = 0
while ($k -lt $lin.Count) {
  $l = $lin[$k]; $k++
  if ($l.StartsWith('#') -or $l.Trim() -eq '') { continue }
  if ($l.StartsWith('MODELO|'))  { $p = $l.Split('|', 3); $modelos[$p[1]] = $p[2]; continue }
  if ($l.StartsWith('NOTAFIG|')) { $notaFig = $l.Substring(8); continue }
  if ($l.StartsWith('FIG|'))     { $p = $l.Substring(4).Split('|'); $figuras += @{ img=$p[0]; sprint=$p[1]; pantalla=$p[2]; desc=$p[3] }; continue }
  if ($l.StartsWith('DEL>>>'))   { $ops += @{ tipo='DEL'; prefijo=$l.Substring(6) }; continue }
  if ($l.StartsWith('PRE>>>'))   { $p = $l.Substring(6).Split($SEP, 2); $ops += @{ tipo='PRE'; prefijo=$p[0]; texto=$p[1] }; continue }
  foreach ($tipo in @('REP','INS','IDX')) {
    if ($l.StartsWith("$tipo>>>")) {
      $arg = $l.Substring(6); $cuerpo = @()
      while ($k -lt $lin.Count -and -not $lin[$k].StartsWith("<<<$tipo")) {
        if ($lin[$k].Trim() -ne '') { $cuerpo += $lin[$k] }
        $k++
      }
      $k++
      $ops += @{ tipo=$tipo; arg=$arg; lineas=$cuerpo }
      break
    }
  }
}
foreach ($f in $figuras) {
  if (-not (Test-Path (Join-Path $caps $f.img))) { throw "Falta la captura: $($f.img)" }
}
Write-Output ("Contenido: {0} figuras, {1} operaciones" -f $figuras.Count, $ops.Count)

Copy-Item $origen $Destino -Force

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $null

# ------------------------------------------------------------- utilidades
function TextoDe($p) { return ($p.Range.Text -replace "[\r\a]", "") }

# Indice del primer parrafo cuyo texto (recortado) coincide con $spec:
#   "=texto"  igualdad exacta      "^texto"  empieza por
# Solo se busca desde $desde, para no confundir el indice con el cuerpo.
function Buscar($doc, [string]$spec, [int]$desde = 1) {
  $n = $doc.Paragraphs.Count
  $exacto = $spec.StartsWith('=')
  $valor = $spec.Substring(1)
  for ($i = $desde; $i -le $n; $i++) {
    $t = (TextoDe $doc.Paragraphs.Item($i)).Trim()
    if ($exacto) { if ($t -eq $valor) { return $i } }
    else { if ($t.StartsWith($valor)) { return $i } }
  }
  return 0
}

function InicioCuerpo($doc) {
  $i = Buscar $doc '=I. RESUMEN'
  if ($i -eq 0) { throw "No se encontro el encabezado I. RESUMEN." }
  return $i
}

# Escribe en un parrafo SIN tocar su marca de fin (hacerlo fusiona parrafos).
function PonerTexto($p, [string]$texto) {
  $r = $p.Range
  if (($r.End - $r.Start) -gt 0) { $r.MoveEnd(1, -1) | Out-Null }
  $r.Text = $texto
}

# Inserta un parrafo nuevo ANTES del que esta en $iDestino, con el formato
# completo del parrafo $iModelo (se copia con FormattedText), y le pone texto.
function InsertarClon($doc, [int]$iDestino, [int]$iModelo, [string]$texto) {
  $doc.Paragraphs.Item($iDestino).Range.InsertParagraphBefore()
  if ($iModelo -ge $iDestino) { $iModelo++ }
  $doc.Paragraphs.Item($iDestino).Range.FormattedText = $doc.Paragraphs.Item($iModelo).Range.FormattedText
  PonerTexto $doc.Paragraphs.Item($iDestino) $texto
}

function Reemplazar($doc, [string]$prefijo, $parrafos) {
  $ini = InicioCuerpo $doc
  $n = $doc.Paragraphs.Count
  for ($i = $ini; $i -le $n; $i++) {
    if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith($prefijo)) {
      PonerTexto $doc.Paragraphs.Item($i) (($parrafos | ForEach-Object { Sustituir $_ }) -join [string][char]13)
      return
    }
  }
  Write-Output ("  AVISO: no se encontro: " + $prefijo.Substring(0, [Math]::Min(45, $prefijo.Length)))
}

# Resuelve un modelo (clave -> indice de parrafo).
function IndiceModelo($doc, $modelos, [string]$clave) {
  $spec = $modelos[$clave]
  if (-not $spec) { throw "Modelo desconocido: $clave" }
  $i = Buscar $doc $spec (InicioCuerpo $doc)
  if ($i -eq 0) { throw "No se encontro el modelo '$clave' ($spec)." }
  return $i
}

# Crea una tabla antes del ancla, con el aspecto de la Tabla 12 del informe.
function CrearTabla($doc, [string]$anclaSpec, $anchos, $filas) {
  $iA = Buscar $doc $anclaSpec (InicioCuerpo $doc)
  if ($iA -eq 0) { throw "Ancla no encontrada: $anclaSpec" }
  $doc.Paragraphs.Item($iA).Range.InsertParagraphBefore()
  $vacio = $doc.Paragraphs.Item($iA)
  $vacio.Range.ParagraphFormat.Reset()
  $vacio.Range.Font.Reset()
  try { $vacio.Style = "Normal" } catch {}

  $ncols = $anchos.Count
  $r = $vacio.Range
  $r.Collapse(1) | Out-Null
  $tbl = $doc.Tables.Add($r, $filas.Count, $ncols)

  $tbl.Borders.Enable = $true
  $tbl.AllowAutoFit = $false
  $tbl.Range.Font.Name = "Arial"
  $tbl.Range.Font.Size = 10
  $tbl.Range.Font.Bold = 0
  $tbl.Range.Font.Italic = 0
  $pf = $tbl.Range.ParagraphFormat
  $pf.Alignment = 0; $pf.SpaceBefore = 2; $pf.SpaceAfter = 2
  $pf.FirstLineIndent = 0; $pf.LeftIndent = 0; $pf.LineSpacingRule = 0

  $suma = 0.0; foreach ($a in $anchos) { $suma += [double]$a }
  for ($c = 1; $c -le $ncols; $c++) {
    $tbl.Columns.Item($c).Width = 451.3 * ([double]$anchos[$c-1] / $suma)
  }

  for ($f = 0; $f -lt $filas.Count; $f++) {
    $celdas = $filas[$f].Split($SEP)
    for ($c = 0; $c -lt $ncols; $c++) {
      $texto = if ($c -lt $celdas.Count) { $celdas[$c] } else { '' }
      $tbl.Cell($f + 1, $c + 1).Range.Text = $texto
    }
  }
  $enc = $tbl.Rows.Item(1)
  $enc.Range.Font.Bold = 1
  $enc.Shading.BackgroundPatternColor = 15983321     # el mismo tono que la Tabla 12
  $enc.HeadingFormat = $true
  $tbl.Rows.AllowBreakAcrossPages = $false
}

try {
  $doc = $word.Documents.Open($Destino)

  # ================================================================ TABLA 12
  $t = $doc.Tables.Item(12)
  if (($t.Cell(1,1).Range.Text -replace "[\r\a]","") -ne 'Sprint') { throw "Tabla 12 inesperada." }
  $t.Cell(1,4).Range.Text = 'Figura'
  while (($t.Rows.Count - 1) -lt $figuras.Count) { $t.Rows.Add() | Out-Null }
  for ($i = 0; $i -lt $figuras.Count; $i++) {
    $fila = $i + 2
    $t.Cell($fila,1).Range.Text = $figuras[$i].sprint
    $t.Cell($fila,2).Range.Text = $figuras[$i].pantalla
    $t.Cell($fila,3).Range.Text = $figuras[$i].desc
    $t.Cell($fila,4).Range.Text = ("Figura {0}" -f ($i + $PRIMERA_FIGURA))
  }
  Write-Output "Tabla 12 actualizada"

  # ================================================================= FIGURAS
  # Cada figura son 4 parrafos (rotulo, titulo, imagen, nota) insertados justo
  # antes del encabezado real "7.2. Repositorios".
  function NuevoParrafoAntesDeRepos($doc) {
    $i = Buscar $doc '=7.2. Repositorios' (InicioCuerpo $doc)
    if ($i -eq 0) { throw "No se encontro el ancla '7.2. Repositorios'." }
    $doc.Paragraphs.Item($i).Range.InsertParagraphBefore()
    return $doc.Paragraphs.Item($i)
  }
  for ($i = 0; $i -lt $figuras.Count; $i++) {
    $n = $i + $PRIMERA_FIGURA
    $fig = $figuras[$i]

    $p1 = NuevoParrafoAntesDeRepos $doc
    PonerTexto $p1 "Figura $n"
    try { $p1.Style = "Normal" } catch {}
    $p1.Alignment = 0; $p1.SpaceBefore = 14; $p1.SpaceAfter = 0; $p1.KeepWithNext = $true
    $p1.Range.Font.Bold = $true; $p1.Range.Font.Italic = $false

    $p2 = NuevoParrafoAntesDeRepos $doc
    PonerTexto $p2 $fig.pantalla
    try { $p2.Style = "Normal" } catch {}
    $p2.Alignment = 0; $p2.SpaceBefore = 0; $p2.SpaceAfter = 4; $p2.KeepWithNext = $true
    $p2.Range.Font.Bold = $false; $p2.Range.Font.Italic = $true

    $p3 = NuevoParrafoAntesDeRepos $doc
    try { $p3.Style = "Normal" } catch {}
    $p3.Alignment = 1; $p3.SpaceBefore = 0; $p3.SpaceAfter = 0; $p3.KeepWithNext = $true
    $shape = $p3.Range.InlineShapes.AddPicture((Join-Path $caps $fig.img), $false, $true)
    $shape.LockAspectRatio = $true
    $shape.Width = 150

    $p4 = NuevoParrafoAntesDeRepos $doc
    PonerTexto $p4 ("Nota. " + $fig.desc + " " + $notaFig)
    try { $p4.Style = "Normal" } catch {}
    $p4.Alignment = 0; $p4.SpaceBefore = 4; $p4.SpaceAfter = 12; $p4.KeepWithNext = $false
    $p4.Range.Font.Bold = $false; $p4.Range.Font.Italic = $true
  }
  Write-Output "Figuras $PRIMERA_FIGURA a $($figuras.Count + $PRIMERA_FIGURA - 1) insertadas"

  # ============================================== OPERACIONES DEL CONTENIDO
  $contadores = @{ REP=0; DEL=0; PRE=0; INS=0; IDX=0 }
  foreach ($op in $ops) {
    switch ($op.tipo) {

      'REP' {
        Reemplazar $doc $op.arg $op.lineas
        $contadores.REP++
      }

      'DEL' {
        $ini = InicioCuerpo $doc
        $n = $doc.Paragraphs.Count
        $hecho = $false
        for ($i = $ini; $i -le $n; $i++) {
          if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith($op.prefijo)) {
            $doc.Paragraphs.Item($i).Range.Delete() | Out-Null
            $hecho = $true; break
          }
        }
        if (-not $hecho) { Write-Output ("  AVISO: DEL sin encontrar: " + $op.prefijo) }
        $contadores.DEL++
      }

      'PRE' {
        $ini = InicioCuerpo $doc
        $n = $doc.Paragraphs.Count
        $hecho = $false
        for ($i = $ini; $i -le $n; $i++) {
          if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith($op.prefijo)) {
            $r = $doc.Paragraphs.Item($i).Range
            $r.Collapse(1) | Out-Null
            $r.InsertBefore($op.texto)
            $hecho = $true; break
          }
        }
        if (-not $hecho) { Write-Output ("  AVISO: PRE sin encontrar: " + $op.prefijo) }
        $contadores.PRE++
      }

      'INS' {
        $ancla = $op.arg
        $pendiente = @()          # filas de una tabla en construccion
        $anchosTabla = @()
        foreach ($linea in $op.lineas) {
          $clave = $linea.Substring(0, $linea.IndexOf('|'))
          $resto = $linea.Substring($linea.IndexOf('|') + 1)

          if ($clave -eq 'R') { $pendiente += $resto; continue }
          if ($pendiente.Count -gt 0) {
            CrearTabla $doc $ancla $anchosTabla $pendiente
            $pendiente = @()
          }

          if ($clave -eq 'TW') { $anchosTabla = $resto.Split(','); continue }

          $iAncla = Buscar $doc $ancla (InicioCuerpo $doc)
          if ($iAncla -eq 0) { throw "Ancla no encontrada: $ancla" }

          if ($clave -eq 'CAP') {
            $pp = $resto.Split('|', 2)
            InsertarClon $doc $iAncla (IndiceModelo $doc $modelos 'CN') $pp[0]
            $iAncla = Buscar $doc $ancla (InicioCuerpo $doc)
            InsertarClon $doc $iAncla (IndiceModelo $doc $modelos 'CT') $pp[1]
          }
          else {
            if (-not $modelos.ContainsKey($clave)) { throw "Clave de bloque desconocida: $clave" }
            InsertarClon $doc $iAncla (IndiceModelo $doc $modelos $clave) (Sustituir $resto)
          }
        }
        if ($pendiente.Count -gt 0) { CrearTabla $doc $ancla $anchosTabla $pendiente }
        $contadores.INS++
      }

      'IDX' {
        $ini = InicioCuerpo $doc
        $iAn = 0
        for ($i = 1; $i -lt $ini; $i++) {
          if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith($op.arg)) { $iAn = $i; break }
        }
        if ($iAn -eq 0) { Write-Output ("  AVISO: linea de indice no encontrada: " + $op.arg); continue }

        foreach ($linea in $op.lineas) {
          $pp = $linea.Substring(2).Split($SEP, 2)       # quita el "M:"
          $iMod = 0
          $ini = InicioCuerpo $doc
          for ($i = 1; $i -lt $ini; $i++) {
            if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith($pp[0])) { $iMod = $i; break }
          }
          if ($iMod -eq 0) { Write-Output ("  AVISO: modelo de indice no encontrado: " + $pp[0]); continue }
          # el "0" final es un marcador: lo sustituira la pagina real
          InsertarClon $doc ($iAn + 1) $iMod ($pp[1] + $TAB + "0")
          $iAn++
        }
        $contadores.IDX++
      }
    }
  }
  Write-Output ("Operaciones: REP={0} DEL={1} PRE={2} INS={3} IDX={4}" -f $contadores.REP, $contadores.DEL, $contadores.PRE, $contadores.INS, $contadores.IDX)

  # ============================ INDICE DE FIGURAS: las nuevas, con su tabulador
  $ini = InicioCuerpo $doc
  $iF6 = 0
  for ($i = 1; $i -lt $ini; $i++) {
    if ((TextoDe $doc.Paragraphs.Item($i)).StartsWith('Figura 6. Diagrama de despliegue')) { $iF6 = $i; break }
  }
  if ($iF6 -eq 0) { Write-Output "  AVISO: no se encontro la entrada de la Figura 6 en el indice" }
  else {
    $pos = $iF6
    for ($j = 0; $j -lt $figuras.Count; $j++) {
      InsertarClon $doc ($pos + 1) $pos ("Figura {0}. {1}{2}0" -f ($j + $PRIMERA_FIGURA), $figuras[$j].pantalla, $TAB)
      $pos++
    }
    Write-Output "Indice de figuras: $($figuras.Count) entradas"
  }

  # ======================= NUMEROS DE PAGINA DE LOS INDICES (conservando tab)
  $doc.Repaginate()
  $ini = InicioCuerpo $doc

  $entradas = @()
  $necesarios = @{}
  for ($i = 1; $i -lt $ini; $i++) {
    $txt = TextoDe $doc.Paragraphs.Item($i)
    if ($txt -match '^(.*?)\t(\d+)$') {
      $titulo = $matches[1].Trim()
      $dig = $matches[2]
      $claveIdx = $titulo
      if ($titulo -match '^((?:Tabla|Figura|Anexo)\s+\S+?)\.\s') { $claveIdx = $matches[1] }
      $entradas += @{ i = $i; clave = $claveIdx; titulo = $titulo; dig = $dig }
      $necesarios[$claveIdx] = $true
      $necesarios[$titulo] = $true       # respaldo: anexos llevan rotulo y titulo en un solo parrafo
    }
  }

  # Ultima aparicion en el cuerpo: asi "Figura 7" resuelve al rotulo de la
  # figura y no a la celda de la Tabla 12 que tambien lo menciona.
  $paginas = @{}
  for ($i = $doc.Paragraphs.Count; $i -ge $ini; $i--) {
    $c = (TextoDe $doc.Paragraphs.Item($i)).Trim()
    if ($necesarios.ContainsKey($c) -and -not $paginas.ContainsKey($c)) {
      # wdActiveEndAdjustedPageNumber: la que imprime el pie de pagina
      $paginas[$c] = $doc.Paragraphs.Item($i).Range.Information(1)
    }
  }

  $corregidas = 0; $sinMapa = @()
  foreach ($e in $entradas) {
    $llave = $null
    if ($paginas.ContainsKey($e.clave)) { $llave = $e.clave }
    elseif ($paginas.ContainsKey($e.titulo)) { $llave = $e.titulo }
    if ($llave -eq $null) { $sinMapa += $e.clave; continue }
    $nueva = [string]$paginas[$llave]
    if ($nueva -ne $e.dig) {
      $r = $doc.Paragraphs.Item($e.i).Range
      $r.MoveEnd(1, -1) | Out-Null
      $r.SetRange($r.End - $e.dig.Length, $r.End)      # solo las cifras; el tab se conserva
      $r.Text = $nueva
      $corregidas++
    }
  }
  Write-Output ("Indices: {0} entradas, {1} numeros corregidos, {2} sin coincidencia" -f $entradas.Count, $corregidas, $sinMapa.Count)
  foreach ($s in $sinMapa) { Write-Output ("     sin coincidencia: " + $s) }

  # ============== RESALTAR EN AMARILLO LOS MARCADORES QUE DEBE REVISAR EL EQUIPO
  $rng = $doc.Content
  $fd = $rng.Find
  $fd.ClearFormatting()
  $fd.Text = '\[[VPC][!\]]@\]'
  $fd.MatchWildcards = $true
  $fd.Forward = $true
  $fd.Wrap = 0
  $marcados = 0
  while ($fd.Execute()) {
    $rng.HighlightColorIndex = 7
    $marcados++
    $rng.Collapse(0) | Out-Null
  }
  Write-Output "Marcadores resaltados en amarillo: $marcados"

  $doc.Save()
  Write-Output "GUARDADO: $Destino"
}
finally {
  if ($doc) { try { $doc.Close($true) } catch {} }
  try { $word.Quit() } catch {}
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
  [GC]::Collect()
}
