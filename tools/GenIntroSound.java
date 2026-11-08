import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import java.io.ByteArrayInputStream;
import java.io.File;

/**
 * Genera el sonido de entrada de SkillSwap: res/raw/intro_skillswap.wav
 *
 * Son dos voces que se cruzan, igual que las flechas del logo: una sube
 * (Do - Sol - Do agudo) y otra baja al mismo tiempo. Timbre de campana
 * (fundamental + dos armonicos) con caida exponencial.
 *
 * Se genera por codigo a proposito: asi no depende de ningun audio con
 * licencia de terceros.
 *
 *   javac -d <out> GenIntroSound.java && java -cp <out> GenIntroSound <destino.wav>
 */
public final class GenIntroSound {

    private static final float SAMPLE_RATE = 44100f;
    private static final double DURATION   = 1.25;   // segundos
    private static final double MASTER     = 0.42;   // volumen general (0-1)

    public static void main(String[] args) throws Exception {
        String destino = args.length > 0 ? args[0] : "intro_skillswap.wav";

        int total = (int) (SAMPLE_RATE * DURATION);
        double[] mezcla = new double[total];

        // Voz que sube: Do5 - Sol5 - Do6
        nota(mezcla, 523.25, 0.00, 0.85);
        nota(mezcla, 783.99, 0.14, 0.80);
        nota(mezcla, 1046.50, 0.28, 0.95);

        // Voz que baja, mas suave: Do6 - Mi5
        nota(mezcla, 1046.50, 0.00, 0.30);
        nota(mezcla, 659.25, 0.16, 0.34);

        // Acorde final que sostiene un poco mas
        nota(mezcla, 1318.51, 0.42, 0.45);

        normalizar(mezcla);
        fundidoFinal(mezcla, 0.18);

        byte[] pcm = aPcm16(mezcla);

        AudioFormat formato = new AudioFormat(SAMPLE_RATE, 16, 1, true, false);
        AudioInputStream in = new AudioInputStream(
                new ByteArrayInputStream(pcm), formato, pcm.length / 2);
        File f = new File(destino);
        AudioSystem.write(in, AudioFileFormat.Type.WAVE, f);

        System.out.printf("OK  %s  (%.2f s, %d KB)%n",
                f.getName(), DURATION, f.length() / 1024);
    }

    /** Anade una nota con timbre de campana en el instante indicado. */
    private static void nota(double[] buf, double freq, double inicio, double amp) {
        int desde = (int) (inicio * SAMPLE_RATE);
        double decaimiento = 3.2;                 // cuanto mas alto, mas corta

        for (int i = desde; i < buf.length; i++) {
            double t = (i - desde) / SAMPLE_RATE;
            double env = Math.exp(-decaimiento * t);
            if (env < 0.0005) break;

            // Ataque muy corto para que no "chasquee" al empezar.
            double ataque = Math.min(1.0, t / 0.008);

            double onda =
                      Math.sin(2 * Math.PI * freq * t)
                    + 0.38 * Math.sin(2 * Math.PI * freq * 2 * t)
                    + 0.14 * Math.sin(2 * Math.PI * freq * 3.01 * t);

            buf[i] += amp * ataque * env * onda;
        }
    }

    private static void normalizar(double[] buf) {
        double max = 0;
        for (double v : buf) max = Math.max(max, Math.abs(v));
        if (max == 0) return;
        double factor = MASTER / max;
        for (int i = 0; i < buf.length; i++) buf[i] *= factor;
    }

    /** Fundido de salida para que no corte en seco. */
    private static void fundidoFinal(double[] buf, double segundos) {
        int n = (int) (segundos * SAMPLE_RATE);
        int desde = buf.length - n;
        for (int i = Math.max(0, desde); i < buf.length; i++) {
            double k = (double) (buf.length - i) / n;
            buf[i] *= k * k;
        }
    }

    private static byte[] aPcm16(double[] buf) {
        byte[] out = new byte[buf.length * 2];
        for (int i = 0; i < buf.length; i++) {
            int s = (int) Math.round(Math.max(-1.0, Math.min(1.0, buf[i])) * 32767);
            out[i * 2]     = (byte) (s & 0xFF);
            out[i * 2 + 1] = (byte) ((s >> 8) & 0xFF);
        }
        return out;
    }

    private GenIntroSound() {
    }
}
