package com.skillswap.view.digest;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

/**
 * Grafico de barras minimo para el resumen semanal (INNOVACION 12).
 *
 * Se dibuja a mano en vez de añadir una libreria de graficos: son 7 barras,
 * y una dependencia externa pesaria mas que este archivo.
 */
public class BarChartView extends View {

    private int[] valores = new int[0];
    private String[] etiquetas = new String[0];

    private final Paint pBarra = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint pFondo = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint pTexto = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint pValor = new Paint(Paint.ANTI_ALIAS_FLAG);

    private int colorBarra = Color.parseColor("#6C4DF6");
    private int colorFondo = Color.parseColor("#E9E3FF");

    public BarChartView(Context context) {
        this(context, null);
    }

    public BarChartView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        pBarra.setColor(colorBarra);
        pFondo.setColor(colorFondo);

        pTexto.setColor(Color.parseColor("#6E6A85"));
        pTexto.setTextSize(sp(11));
        pTexto.setTextAlign(Paint.Align.CENTER);

        pValor.setColor(colorBarra);
        pValor.setTextSize(sp(11));
        pValor.setFakeBoldText(true);
        pValor.setTextAlign(Paint.Align.CENTER);
    }

    /** Colores del tema; se llaman desde la Activity para respetar modo oscuro. */
    public void setColores(int barra, int fondo, int texto) {
        this.colorBarra = barra;
        this.colorFondo = fondo;
        pBarra.setColor(barra);
        pFondo.setColor(fondo);
        pValor.setColor(barra);
        pTexto.setColor(texto);
        invalidate();
    }

    public void setDatos(int[] valores, String[] etiquetas) {
        this.valores = valores == null ? new int[0] : valores;
        this.etiquetas = etiquetas == null ? new String[0] : etiquetas;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (valores.length == 0) return;

        int n = valores.length;
        float alturaEtiqueta = sp(16);
        float alturaValor = sp(14);
        float areaBarras = getHeight() - alturaEtiqueta - alturaValor;
        if (areaBarras <= 0) return;

        float ancho = getWidth() / (float) n;
        float anchoBarra = Math.min(dp(28), ancho * 0.55f);
        float radio = anchoBarra / 2f;

        int max = 1;
        for (int v : valores) max = Math.max(max, v);

        for (int i = 0; i < n; i++) {
            float centro = ancho * i + ancho / 2f;
            float izq = centro - anchoBarra / 2f;
            float der = centro + anchoBarra / 2f;
            float abajo = alturaValor + areaBarras;

            // Carril de fondo: da referencia visual de la escala.
            canvas.drawRoundRect(new RectF(izq, alturaValor, der, abajo),
                    radio, radio, pFondo);

            if (valores[i] > 0) {
                float alto = areaBarras * (valores[i] / (float) max);
                // Minimo visible para que un valor pequeño no desaparezca.
                alto = Math.max(alto, dp(6));
                canvas.drawRoundRect(new RectF(izq, abajo - alto, der, abajo),
                        radio, radio, pBarra);

                canvas.drawText(String.valueOf(valores[i]), centro,
                        abajo - alto - dp(4), pValor);
            }

            if (i < etiquetas.length) {
                canvas.drawText(etiquetas[i], centro,
                        getHeight() - dp(2), pTexto);
            }
        }
    }

    private float dp(float v) {
        return v * getResources().getDisplayMetrics().density;
    }

    private float sp(float v) {
        return v * getResources().getDisplayMetrics().scaledDensity;
    }
}
