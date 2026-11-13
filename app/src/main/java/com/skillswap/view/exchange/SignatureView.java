package com.skillswap.view.exchange;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.Nullable;

/**
 * RC3 - Lienzo para firmar con el dedo.
 *
 * Dibuja el trazo con Path y lo conserva en un Bitmap propio, para que la
 * firma sobreviva a un giro de pantalla o a que la vista se vuelva a dibujar.
 *
 * ALCANCE: es una firma manuscrita digitalizada que deja constancia de la
 * aceptacion. NO es una firma digital con certificado ni tiene su validez
 * legal, y la aplicacion no la presenta como tal.
 */
public class SignatureView extends View {

    public interface OnFirmaListener {
        void onCambio(boolean hayFirma);
    }

    private final Path trazo = new Path();
    private final Paint lapiz = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint fondo = new Paint();

    private Bitmap lienzo;
    private Canvas lienzoCanvas;

    private float ultimoX, ultimoY;
    private boolean hayFirma = false;
    private OnFirmaListener listener;

    /** Distancia minima para registrar un punto nuevo; suaviza el trazo. */
    private static final float TOLERANCIA = 4f;

    public SignatureView(Context context) {
        this(context, null);
    }

    public SignatureView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        lapiz.setColor(Color.parseColor("#1B1533"));
        lapiz.setStyle(Paint.Style.STROKE);
        lapiz.setStrokeJoin(Paint.Join.ROUND);
        lapiz.setStrokeCap(Paint.Cap.ROUND);
        lapiz.setStrokeWidth(6f);
        fondo.setColor(Color.WHITE);
    }

    public void setOnFirmaListener(OnFirmaListener l) {
        this.listener = l;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        super.onSizeChanged(w, h, oldW, oldH);
        if (w <= 0 || h <= 0) return;
        lienzo = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        lienzoCanvas = new Canvas(lienzo);
        lienzoCanvas.drawRect(0, 0, w, h, fondo);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (lienzo != null) canvas.drawBitmap(lienzo, 0, 0, null);
        canvas.drawPath(trazo, lapiz);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                trazo.moveTo(x, y);
                ultimoX = x;
                ultimoY = y;
                // Sin esto, el padre (el ScrollView) se roba el gesto
                // y no se puede firmar.
                getParent().requestDisallowInterceptTouchEvent(true);
                avisar(true);
                return true;

            case MotionEvent.ACTION_MOVE:
                float dx = Math.abs(x - ultimoX);
                float dy = Math.abs(y - ultimoY);
                if (dx >= TOLERANCIA || dy >= TOLERANCIA) {
                    // Curva suave entre el punto anterior y el actual.
                    trazo.quadTo(ultimoX, ultimoY, (x + ultimoX) / 2, (y + ultimoY) / 2);
                    ultimoX = x;
                    ultimoY = y;
                }
                invalidate();
                return true;

            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                trazo.lineTo(ultimoX, ultimoY);
                if (lienzoCanvas != null) lienzoCanvas.drawPath(trazo, lapiz);
                trazo.reset();
                getParent().requestDisallowInterceptTouchEvent(false);
                invalidate();
                return true;

            default:
                return super.onTouchEvent(event);
        }
    }

    private void avisar(boolean valor) {
        if (hayFirma == valor) return;
        hayFirma = valor;
        if (listener != null) listener.onCambio(valor);
    }

    public boolean tieneFirma() {
        return hayFirma;
    }

    public void limpiar() {
        trazo.reset();
        if (lienzo != null && lienzoCanvas != null) {
            lienzoCanvas.drawRect(0, 0, lienzo.getWidth(), lienzo.getHeight(), fondo);
        }
        avisar(false);
        invalidate();
    }

    /** La firma como imagen, o null si todavia no se dibujo nada. */
    @Nullable
    public Bitmap obtenerFirma() {
        if (!hayFirma || lienzo == null) return null;
        return lienzo;
    }
}
