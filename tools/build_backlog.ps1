$ErrorActionPreference = 'Stop'

$html = 'C:\Users\ricra\AppData\Local\Temp\backlog.html'
$dst  = 'C:\Users\ricra\Downloads\T1_Product_Backlog_SkillSwap.docx'
if (Test-Path $dst) { Remove-Item $dst -Force }

$w = New-Object -ComObject Word.Application
$w.Visible = $false
$w.DisplayAlerts = 0

$d = $w.Documents.Open($html, $false, $false)

# Tamano de pagina y margenes (Word no siempre respeta @page al importar HTML)
$ps = $d.PageSetup
$ps.PageWidth  = $w.CentimetersToPoints(21)
$ps.PageHeight = $w.CentimetersToPoints(29.7)
$ps.TopMargin    = $w.CentimetersToPoints(2.2)
$ps.BottomMargin = $w.CentimetersToPoints(2.2)
$ps.LeftMargin   = $w.CentimetersToPoints(2.5)
$ps.RightMargin  = $w.CentimetersToPoints(2.0)

# Pie de pagina con numeracion
foreach ($sec in $d.Sections) {
    $f = $sec.Footers.Item(1)   # wdHeaderFooterPrimary
    $r = $f.Range
    $r.Text = "SkillSwap - Product Backlog   |   Desarrollo de Aplicaciones Moviles - UPN 2026-2   |   "
    $r.Font.Size = 8
    $r.Font.Color = 8421504
    $r.Collapse(0) | Out-Null
    $r.Fields.Add($r, 33) | Out-Null    # wdFieldPage
    $f.Range.ParagraphFormat.Alignment = 2   # derecha
}

# Encabezado de tabla repetido en cada pagina y filas sin partir
foreach ($t in $d.Tables) {
    try { $t.Rows.Item(1).HeadingFormat = $true } catch {}
    try { $t.Rows.AllowBreakAcrossPages = $false } catch {}
}

$d.SaveAs2($dst, 16)   # wdFormatDocumentDefault (.docx)
"paginas: " + $d.ComputeStatistics(2)
"tablas:  " + $d.Tables.Count
$d.Close(0)

"OK -> $dst"
