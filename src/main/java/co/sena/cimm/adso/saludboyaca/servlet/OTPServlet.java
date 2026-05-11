package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.util.OTPService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Locale;
import java.util.ResourceBundle;

/**
 * OTPServlet — Verificación del código de un solo uso
 *
 * FLUJO:
 *   GET  /otp → mostrar otp_verificacion.jsp con email enmascarado
 *   POST /otp → validar código:
 *               ✅ válido → session(otpVerificado=true) → /dashboard
 *               ❌ inválido → error + contador de intentos
 *               🔒 3 intentos fallidos → invalidar sesión → /login
 *
 * BONUS B implementado:
 *   Bloqueo automático tras 3 intentos fallidos.
 *   Esto dificulta ataques de fuerza bruta (aunque con 6 dígitos
 *   y 5 min de expiración el riesgo ya es muy bajo: 1/1.000.000
 *   de probabilidad de acertar en el primer intento).
 */
@WebServlet(name = "OTPServlet", urlPatterns = {"/otp"})
public class OTPServlet extends HttpServlet {

    private static final int MAX_INTENTOS = 3;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Si no hay código OTP en sesión → no pasó por el login → redirigir
        if (session == null || session.getAttribute("otpCodigo") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Pasar email enmascarado a la vista (privacidad)
        String email = (String) session.getAttribute("otpEmail");
        request.setAttribute("emailMasked", OTPService.enmascararEmail(email));

        // Pasar intentos fallidos (para el indicador visual)
        Integer intentos = (Integer) session.getAttribute("otpIntentos");
        request.setAttribute("intentosFallidos", intentos != null ? intentos : 0);

        request.getRequestDispatcher("/views/otp_verificacion.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Protección: si no hay sesión activa, volver al login
        if (session == null || session.getAttribute("otpCodigo") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String codigoIngresado = request.getParameter("otpCodigo");
        String codigoSesion    = (String) session.getAttribute("otpCodigo");
        long   timestamp       = (Long)   session.getAttribute("otpTimestamp");

        // Obtener y actualizar contador de intentos fallidos
        Integer intentos = (Integer) session.getAttribute("otpIntentos");
        if (intentos == null) intentos = 0;

        // Validar código
        if (OTPService.esValido(codigoIngresado, codigoSesion, timestamp)) {
            // ✅ OTP CORRECTO
            session.setAttribute("otpVerificado", true);
            session.removeAttribute("otpCodigo");      // Limpiar para no reutilizar
            session.removeAttribute("otpTimestamp");
            session.removeAttribute("otpIntentos");
            session.removeAttribute("otpEmail");

            // Redirigir al dashboard (AuthFilter ya encontrará otpVerificado=true)
            response.sendRedirect(request.getContextPath() + "/dashboard");

        } else {
            // ❌ OTP INCORRECTO O EXPIRADO
            intentos++;
            session.setAttribute("otpIntentos", intentos);

            String lang = (String) session.getAttribute("lang");
            if (lang == null) lang = "es";
            ResourceBundle rb = ResourceBundle.getBundle("messages", new Locale(lang));

            // 🔒 Bloqueo tras MAX_INTENTOS intentos (BONUS B)
            if (intentos >= MAX_INTENTOS) {
                session.invalidate(); // Destruir toda la sesión
                response.sendRedirect(request.getContextPath() +
                        "/login?error=bloqueado");
                return;
            }

            // Mostrar error con intentos restantes
            String email = (String) session.getAttribute("otpEmail");
            request.setAttribute("emailMasked", OTPService.enmascararEmail(email));
            request.setAttribute("error", rb.getString("otp.error"));
            request.setAttribute("intentosFallidos", intentos);

            request.getRequestDispatcher("/views/otp_verificacion.jsp")
                   .forward(request, response);
        }
    }
}
