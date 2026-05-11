package co.sena.cimm.adso.saludboyaca.util;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.security.SecureRandom;
import javax.imageio.ImageIO;

/**
 * CaptchaGenerator — Generador de CAPTCHA gráfico
 *
 * LECCIÓN: ¿Dónde se usa?
 *   SOLO en /consulta-cita (módulo público sin cuenta de usuario).
 *   El login NO usa CAPTCHA — usa OTP.
 *   Ver sección 2 de la guía del taller para la justificación completa.
 *
 * IMPLEMENTACIÓN:
 *   Dibuja texto aleatorio sobre un BufferedImage con:
 *   - Líneas de ruido (dificultan OCR automático)
 *   - Rotación aleatoria de caracteres
 *   - Fondo degradado
 *   - Fuente bold con anti-aliasing
 */
public class CaptchaGenerator {

    private static final String CARACTERES =
        "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Sin caracteres ambiguos (0,O,1,I)

    private static final SecureRandom RND = new SecureRandom();

    /**
     * Genera una cadena aleatoria para el CAPTCHA.
     * @param longitud Número de caracteres (5 es el estándar)
     */
    public static String generarTextoCaptcha(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(CARACTERES.charAt(RND.nextInt(CARACTERES.length())));
        }
        return sb.toString();
    }

    /**
     * Genera la imagen PNG del CAPTCHA y la escribe en el OutputStream.
     * @param texto     El texto a renderizar (de generarTextoCaptcha)
     * @param out       El OutputStream donde escribir la imagen (response)
     */
    public static void generarImagenCaptcha(String texto, OutputStream out)
            throws IOException {

        int ancho  = 160;
        int alto   = 50;

        BufferedImage imagen = new BufferedImage(ancho, alto,
                                                 BufferedImage.TYPE_INT_RGB);
        Graphics2D g = imagen.createGraphics();

        // Anti-aliasing para texto más legible
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
                           RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

        // Fondo degradado azul muy claro → blanco
        GradientPaint fondo = new GradientPaint(
            0, 0, new Color(214, 234, 248),
            ancho, alto, new Color(255, 255, 255));
        g.setPaint(fondo);
        g.fillRect(0, 0, ancho, alto);

        // Líneas de ruido (dificultan OCR)
        g.setStroke(new BasicStroke(1.2f));
        for (int i = 0; i < 6; i++) {
            g.setColor(new Color(
                RND.nextInt(100) + 100,
                RND.nextInt(100) + 100,
                RND.nextInt(100) + 100));
            g.drawLine(RND.nextInt(ancho), RND.nextInt(alto),
                       RND.nextInt(ancho), RND.nextInt(alto));
        }

        // Texto del CAPTCHA con rotación aleatoria por carácter
        Font fuente = new Font("Arial", Font.BOLD, 28);
        g.setFont(fuente);

        int x = 15;
        for (char c : texto.toCharArray()) {
            // Rotación aleatoria entre -20° y +20°
            double angulo = Math.toRadians(RND.nextInt(40) - 20);
            g.setColor(new Color(
                RND.nextInt(50) + 20,       // Rojo oscuro
                RND.nextInt(50) + 20,       // Verde oscuro
                RND.nextInt(80) + 80));     // Azul medio-oscuro

            Graphics2D g2 = (Graphics2D) g.create();
            g2.translate(x + 10, alto / 2 + 8);
            g2.rotate(angulo);
            g2.drawString(String.valueOf(c), 0, 0);
            g2.dispose();

            x += 28;
        }

        // Puntos de ruido adicionales
        for (int i = 0; i < 50; i++) {
            g.setColor(new Color(
                RND.nextInt(150),
                RND.nextInt(150),
                RND.nextInt(200)));
            g.fillOval(RND.nextInt(ancho), RND.nextInt(alto), 2, 2);
        }

        g.dispose();
        ImageIO.write(imagen, "PNG", out);
    }
}
