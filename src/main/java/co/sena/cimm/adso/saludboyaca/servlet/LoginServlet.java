package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;
import co.sena.cimm.adso.saludboyaca.util.OTPService;
import co.sena.cimm.adso.saludboyaca.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Locale;
import java.util.ResourceBundle;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("🔐 Intento de login - Username: " + username); // LOG PARA DEBUG

        if (username == null || password == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Usuario y contraseña son obligatorios");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        

        Usuario usuario = usuarioDAO.validarLogin(username.trim(), password);

        if (usuario != null) {
            System.out.println("✅ Usuario encontrado: " + usuario.getUsername() + " | Activo: " + usuario.isActivo());

            if (!usuario.isActivo()) {
                request.setAttribute("error", "Tu cuenta está desactivada");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return;
            }

            // === LOGIN EXITOSO ===
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("usuarioRol", usuario.getRol());
            session.setAttribute("usuarioNombre", usuario.getNombreCompleto());

            // Generar y enviar OTP
            String otp = OTPService.generarOTP(usuario.getId());
            long timestamp = System.currentTimeMillis();

            session.setAttribute("otpCodigo", otp);
            session.setAttribute("otpTimestamp", timestamp);
            session.setAttribute("otpEmail", usuario.getEmail());
            session.setAttribute("otpVerificado", false);

            // Enviar OTP por correo real
            final String otpFinal = otp;
            final String emailFinal = usuario.getEmail();
            final String nombreFinal = usuario.getNombreCompleto();
            new Thread(() -> {
                try {
                    EmailService.enviarOTP(emailFinal, nombreFinal, otpFinal);
                    System.out.println("📧 OTP enviado a: " + emailFinal);
                } catch (Exception e) {
                    System.err.println("❌ Error enviando OTP: " + e.getMessage());
                }
            }).start();

            response.sendRedirect(request.getContextPath() + "/otp");

        } else {
            System.out.println("❌ Credenciales inválidas para: " + username);
            request.setAttribute("error", "Usuario o contraseña incorrectos");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}