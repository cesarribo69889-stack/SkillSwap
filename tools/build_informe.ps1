$ErrorActionPreference = 'Stop'

$src  = 'C:\Users\ricra\Downloads\Informe_Proyecto_Final_SkillSwap (3).docx'
$dst  = 'C:\Users\ricra\Downloads\T1_Informe_SkillSwap.docx'
$json = 'C:\Users\ricra\AndroidStudioProjects\PROYECTOAPLICACIONESMOVILES\tools\informe_edits.json'

Copy-Item -LiteralPath $src -Destination $dst -Force

$cfg = [System.IO.File]::ReadAllText($json, [System.Text.Encoding]::UTF8) | ConvertFrom-Json

$w = New-Object -ComObject Word.Application
$w.Visible = $false
$w.DisplayAlerts = 0
foreach ($opt in 'AutoFormatAsYouTypeReplaceQuotes',
                 'AutoFormatAsYouTypeApplyBulletedLists',
                 'AutoFormatAsYouTypeApplyNumberedLists',
                 'AutoFormatAsYouTypeFormatListItemBeginning') {
    try { $w.Options.$opt = $false } catch {}
}

$d = $w.Documents.Open($dst)

function Set-ParaText($doc, $idx, $text) {
    $r = $doc.Paragraphs.Item($idx).Range
    $r.MoveEnd(1, -1) | Out-Null        # wdCharacter, drop the paragraph mark
    $r.Text = $text
}

$log = @()

foreach ($op in $cfg.ops) {
    switch ($op.type) {

        'setText' {
            $before = ($d.Paragraphs.Item($op.idx).Range.Text -replace "[\r\a\x07]", '').Trim()
            Set-ParaText $d $op.idx $op.text
            $log += "setText #$($op.idx)  was: $($before.Substring(0, [Math]::Min(55, $before.Length)))"
        }

        'insertAfter' {
            # Se anexan dentro del parrafo ancla (antes de su marca de parrafo)
            # para que los nuevos parrafos hereden SU estilo y vinetas, y no
            # los del parrafo siguiente.
            $lines = @($op.lines)
            $r = $d.Paragraphs.Item($op.idx).Range
            $r.MoveEnd(1, -1) | Out-Null
            $r.InsertAfter("`r" + ($lines -join "`r"))
            $log += "insertAfter #$($op.idx)  +$($lines.Count) parrafos"
        }

        'delete' {
            $before = ($d.Paragraphs.Item($op.idx).Range.Text -replace "[\r\a\x07]", '').Trim()
            $d.Paragraphs.Item($op.idx).Range.Delete() | Out-Null
            $log += "delete #$($op.idx)  was: $before"
        }

        'cell' {
            $d.Tables.Item($op.table).Cell($op.row, $op.col).Range.Text = $op.text
            $log += "cell T$($op.table)[$($op.row),$($op.col)]"
        }

        'tableFill' {
            $t = $d.Tables.Item($op.table)
            while ($t.Rows.Count -lt $op.rows) { $t.Rows.Add() | Out-Null }
            for ($r = 0; $r -lt $op.cells.Count; $r++) {
                $row = @($op.cells[$r])
                for ($c = 0; $c -lt $row.Count; $c++) {
                    $t.Cell($r + 1, $c + 1).Range.Text = $row[$c]
                }
            }
            $t.Rows.Item(1).HeadingFormat = $true
            $log += "tableFill T$($op.table)  $($t.Rows.Count) filas"
        }
    }
}

# ---------------------------------------------------------------------------
# Segunda pasada: los subtitulos del documento eran texto plano, por lo que el
# indice los perdia al actualizarse. Se les fija el nivel de esquema (el campo
# TOC usa \u) sin tocar el estilo, para no perder la numeracion automatica.
# ---------------------------------------------------------------------------
$lvl2 = @(
    'Descripcion de la problematica', 'Descripcion del proyecto',
    'Antecedentes', 'Identificacion y formulacion del problema',
    'Propuestas', 'Definicion de objetivos',
    '5.1. Comparacion de metodologias de ingenieria: Scrum vs. RUP',
    '5.2. Seleccion de herramientas hardware y software',
    '5.3. Herramientas para recoleccion, analisis y procesamiento de datos',
    '5.4. Requisitos de usuario final y de servidor',
    '5.5. Marco teorico (referencial)',
    'Evaluacion de tecnologias de aplicaciones moviles',
    'Aplicacion movil', 'Repositorios',
    'Evidencia de Participacion', 'Video de presentacion del proyecto (Link)',
    'PPT sustentacion',
    'Link del repositorio donde se encuentran los proyectos (codigo)',
    'Resultados en base a los objetivos del proyecto', 'Discusion de resultados'
)
$lvl3 = @(
    'Antecedentes nacionales (Peru)', 'Antecedentes internacionales',
    'Objetivo general', 'Objetivos especificos', 'Evidencias del funcionamiento'
)

# Comparacion sin tildes para que el match no dependa de la acentuacion
function Norm($s) {
    $n = [Text.NormalizationForm]::FormD
    $x = ($s.Normalize($n).ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark'
    }) -join ''
    return $x.Trim()
}

$applied = 0
for ($i = 1; $i -le $d.Paragraphs.Count; $i++) {
    $p = $d.Paragraphs.Item($i)
    $t = Norm (($p.Range.Text -replace "[\r\a\x07]", '').Trim())
    if ($t -eq '') { continue }

    if ($lvl2 -contains $t) {
        $p.OutlineLevel = 2; $applied++
        if ($t -like '5.1.*') { $p.Range.ListFormat.RemoveNumbers() | Out-Null }
    }
    elseif ($lvl3 -contains $t -or $t -match '^Propuesta 0[123]:') {
        $p.OutlineLevel = 3; $applied++
    }
}
$log += "outlineLevel aplicado a $applied subtitulos"

# Los subtitulos de la seccion II se autonumeraban en romano (II.1, II.2) a
# diferencia del resto del informe (3.1, 5.1...). Se pasan a numeracion
# arabica literal para seguir el modelo UPN.
$renum = @{ 'Descripcion de la problematica' = '2.1. '; 'Descripcion del proyecto' = '2.2. ' }
for ($i = 1; $i -le $d.Paragraphs.Count; $i++) {
    $p = $d.Paragraphs.Item($i)
    $t = Norm (($p.Range.Text -replace "[\r\a\x07]", '').Trim())
    if ($renum.ContainsKey($t)) {
        $p.Range.ListFormat.RemoveNumbers() | Out-Null
        $p.Range.InsertBefore($renum[$t])
        $log += "renumerado -> $($renum[$t])$t"
    }
}

# Refrescar indice / TOC
foreach ($toc in $d.TablesOfContents) { $toc.Update() }
$d.Fields.Update() | Out-Null

$d.Save()
$d.Close(0)

$log | ForEach-Object { $_ }
"`nOK -> $dst"
