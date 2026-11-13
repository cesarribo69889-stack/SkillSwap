# ============================================================================
#  Completa el Informe de Proyecto Final de SkillSwap.
#
#  El texto va en tools/informe_contenido.txt y se lee como UTF-8: si se
#  escribiera aqui, PowerShell 5.1 leeria el .ps1 en ANSI y se comerian las
#  tildes.
#
#  Las figuras se anclan a la Tabla 12, NO a una busqueda de texto: buscar
#  "7.2. Repositorios" encontraba antes la entrada del indice y las imagenes
#  acababan en la pagina 3.
#
#  No toca el capitulo I (Resumen). Escribe en un archivo NUEVO.
# ============================================================================
$ErrorActionPreference = "Stop"

# El informe ya usa las Figuras 1 a 6; las nuevas empiezan en la 7.
$PRIMERA_FIGURA = 7

$origen    = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_Metodologia (3).docx"
$destino   = "C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap_COMPLETO.docx"
$caps      = "C:\Users\ricra\AndroidStudioProjects\PROYECTOAPLICACIONESMOVILES\capturas"
$contenido = "C:\Users\ricra\AndroidStudioProjects\PROYECTOAPLICACIONESMOVILES\tools\informe_contenido.txt"

# ------------------------------------------------------- leer el contenido
$lineas  = Get-Content $contenido -Encoding UTF8
$figuras = @()
$reemplazos = @()
$prefijoActual = $null
$buffer = @()

$notaFig = ''

foreach ($l in $lineas) {
  if ($l.StartsWith('#')) { continue }
  if ($l.StartsWith('NOTAFIG|')) { $notaFig = $l.Substring(8); continue }
  if ($l.StartsWith('FIG|')) {
    $p = $l.Substring(4).Split('|')
    $figuras += @{ img = $p[0]; sprint = $p[1]; pantalla = $p[2]; desc = $p[3] }
  }
  elseif ($l.StartsWith('REP>>>')) {
    $prefijoActual = $l.Substring(6); $buffer = @()
  }
  elseif ($l.StartsWith('<<<REP')) {
    $reemplazos += @{ prefijo = $prefijoActual; parrafos = $buffer }
    $prefijoActual = $null
  }
  elseif ($prefijoActual -ne $null -and $l.Trim() -ne '') {
    $buffer += $l
  }
}

foreach ($f in $figuras) {
  if (-not (Test-Path (Join-Path $caps $f.img))) { throw "Falta la captura: $($f.img)" }
}
Write-Output "Figuras: $($figuras.Count)   Reemplazos: $($reemplazos.Count)"

Copy-Item $origen $destino -Force

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $null

# Escribe en un parrafo SIN tocar su marca de fin. Asignar Range.Text tal cual
# reemplaza tambien el caracter de parrafo, lo que fusiona parrafos y desplaza
# todos los indices posteriores.
function PonerTexto($p, $texto) {
  $r = $p.Range
  if (($r.End - $r.Start) -gt 0) { $r.MoveEnd(1, -1) | Out-Null }
  $r.Text = $texto
}

function Reemplazar($doc, $prefijo, $nuevos) {
  for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
    $t = $doc.Paragraphs.Item($i).Range.Text
    if ($t -and $t.StartsWith($prefijo)) {
      $r = $doc.Paragraphs.Item($i).Range
      $r.MoveEnd(1, -1) | Out-Null
      $r.Text = ($nuevos -join [string][char]13)
      return $true
    }
  }
  Write-Output ("  AVISO sin encontrar: " + $prefijo.Substring(0, [Math]::Min(40, $prefijo.Length)))
  return $false
}

try {
  $doc = $word.Documents.Open($destino)

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

  # ============================================================ REEMPLAZOS
  foreach ($r in $reemplazos) { Reemplazar $doc $r.prefijo $r.parrafos | Out-Null }
  Write-Output "Reemplazos aplicados"

  # =============================================================== FIGURAS
  # Cada figura ocupa 4 parrafos: rotulo, titulo, imagen y nota.
  #
  # Se inserta SIEMPRE justo antes del encabezado "7.2. Repositorios", que se
  # vuelve a localizar en cada paso. Ese encabezado hace de ancla fija y el
  # texto nuevo cae siempre en un parrafo recien creado y vacio.
  #
  # Los dos intentos anteriores fallaron: escribir con Selection.TypeText
  # desgarraba el encabezado, y crear los 64 parrafos de golpe con el rango de
  # la tabla los dejaba descolocados porque ese rango se queda obsoleto.
  function NuevoParrafoAntesDelAncla($doc) {
    for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
      # Igualdad EXACTA, no StartsWith: en el indice hay una linea
      # "7.2. Repositorios32" (con el numero de pagina pegado) que se
      # encuentra antes que el encabezado real del cuerpo.
      $txt = ($doc.Paragraphs.Item($i).Range.Text -replace "[\r\a]", "").Trim()
      if ($txt -eq '7.2. Repositorios') {
        $doc.Paragraphs.Item($i).Range.InsertParagraphBefore()
        return $doc.Paragraphs.Item($i)
      }
    }
    throw "No se encontro el ancla '7.2. Repositorios'."
  }

  for ($i = 0; $i -lt $figuras.Count; $i++) {
    $n = $i + $PRIMERA_FIGURA
    $fig = $figuras[$i]

    # 1. Rotulo "Figura N", en negrita y en su propia linea (estilo APA)
    $p1 = NuevoParrafoAntesDelAncla $doc
    PonerTexto $p1 "Figura $n"
    try { $p1.Style = "Normal" } catch {}
    $p1.Alignment = 0
    $p1.SpaceBefore = 14
    $p1.SpaceAfter = 0
    $p1.KeepWithNext = $true
    $p1.Range.Font.Bold = $true
    $p1.Range.Font.Italic = $false

    # 2. Titulo descriptivo, en cursiva
    $p2 = NuevoParrafoAntesDelAncla $doc
    PonerTexto $p2 $fig.pantalla
    try { $p2.Style = "Normal" } catch {}
    $p2.Alignment = 0
    $p2.SpaceBefore = 0
    $p2.SpaceAfter = 4
    $p2.KeepWithNext = $true
    $p2.Range.Font.Bold = $false
    $p2.Range.Font.Italic = $true

    # 3. La imagen, centrada
    $p3 = NuevoParrafoAntesDelAncla $doc
    try { $p3.Style = "Normal" } catch {}
    $p3.Alignment = 1
    $p3.SpaceBefore = 0
    $p3.SpaceAfter = 0
    $p3.KeepWithNext = $true
    $shape = $p3.Range.InlineShapes.AddPicture((Join-Path $caps $fig.img), $false, $true)
    $shape.LockAspectRatio = $true
    $shape.Width = 150                          # ~333 pt de alto

    # 4. Nota al pie
    $p4 = NuevoParrafoAntesDelAncla $doc
    PonerTexto $p4 ("Nota. " + $fig.desc + " " + $notaFig)
    try { $p4.Style = "Normal" } catch {}
    $p4.Alignment = 0
    $p4.SpaceBefore = 4
    $p4.SpaceAfter = 12
    $p4.KeepWithNext = $false
    $p4.Range.Font.Bold = $false
    $p4.Range.Font.Italic = $true
  }
  Write-Output "Figuras $PRIMERA_FIGURA a $($figuras.Count + $PRIMERA_FIGURA - 1) insertadas tras la Tabla 12"

  # ============================ INDICE DE FIGURAS: anadir las nuevas
  # Se insertan tras la ultima figura numerada del original (la 6).
  for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
    $txt = $doc.Paragraphs.Item($i).Range.Text
    if ($txt -and $txt.StartsWith('Figura 6. Diagrama de despliegue')) {
      $nuevas = @()
      for ($k = 0; $k -lt $figuras.Count; $k++) {
        # El 0 del final es un marcador: el recalculo posterior solo mira
        # lineas que acaban en digito, y lo sustituira por la pagina real.
        $nuevas += ("Figura {0}. {1}0" -f ($k + $PRIMERA_FIGURA), $figuras[$k].pantalla)
      }
      $r = $doc.Paragraphs.Item($i).Range
      $r.InsertParagraphAfter()
      $r2 = $doc.Paragraphs.Item($i + 1).Range
      $r2.MoveEnd(1, -1) | Out-Null
      $r2.Text = ($nuevas -join [string][char]13)
      Write-Output "Indice de figuras: $($figuras.Count) entradas anadidas"
      break
    }
  }

  # ================= NUMEROS DE PAGINA DE LOS INDICES
  # No son campos de Word, son texto escrito a mano, asi que al crecer el
  # documento quedaron desfasados. Se recalculan buscando cada titulo en el
  # cuerpo y preguntando a Word en que pagina cayo.
  $doc.Repaginate()

  # Mapa titulo -> pagina, recorriendo el cuerpo de atras hacia delante para
  # quedarnos con la aparicion real y no con la linea del indice.
  $paginas = @{}
  for ($i = $doc.Paragraphs.Count; $i -ge 1; $i--) {
    $p = $doc.Paragraphs.Item($i)
    $clave = ($p.Range.Text -replace "[\r\a]", "").Trim()
    if ($clave.Length -lt 4 -or $clave.Length -gt 120) { continue }
    if (-not $paginas.ContainsKey($clave)) {
      $paginas[$clave] = $p.Range.Information(3)   # wdActiveEndPageNumber
    }
  }

  $corregidos = 0
  $sinMapa = 0
  for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
    $p = $doc.Paragraphs.Item($i)
    $txt = ($p.Range.Text -replace "[\r\a]", "")
    # Solo lineas de indice: terminan en digitos y estan en las primeras paginas.
    # El primer grupo es perezoso; si fuera glotón se comeria la primera cifra
    # del numero de pagina.
    if ($txt -notmatch '^(.+?)(\d+)$') { continue }
    if ($p.Range.Information(3) -gt 5) { continue }

    $titulo = $matches[1].Trim()
    $pagina = $null

    if ($paginas.ContainsKey($titulo)) {
      $pagina = $paginas[$titulo]
    }
    elseif ($titulo -match '^((?:Tabla|Figura|Anexo)\s+\S+?)\.\s') {
      # Los rotulos de tablas y figuras estan partidos en dos parrafos:
      # "Tabla 12" en uno y su titulo en el siguiente. Se busca el rotulo.
      $rotulo = $matches[1]
      if ($paginas.ContainsKey($rotulo)) { $pagina = $paginas[$rotulo] }
    }

    if ($pagina -eq $null) { $sinMapa++; continue }

    $nuevo = $titulo + $pagina
    if ($nuevo -ne $txt) {
      $r = $p.Range
      $r.MoveEnd(1, -1) | Out-Null
      $r.Text = $nuevo
      $corregidos++
    }
  }
  Write-Output "Indices: $corregidos numeros de pagina corregidos, $sinMapa sin coincidencia"

  $doc.Save()
  Write-Output "GUARDADO: $destino"
}
finally {
  if ($doc) { try { $doc.Close($true) } catch {} }
  try { $word.Quit() } catch {}
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
  [GC]::Collect()
}
