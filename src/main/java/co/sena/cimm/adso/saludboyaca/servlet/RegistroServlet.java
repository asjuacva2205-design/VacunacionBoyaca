package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;
import co.sena.cimm.adso.saludboyaca.util.EmailService;
import co.sena.cimm.adso.saludboyaca.util.OTPService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * RegistroServlet — Registro de nuevos pacientes con validación y OTP.
 */
@WebServlet("/registro")
public class RegistroServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Calcular fecha máxima de nacimiento (mayores de 0 años - cualquier fecha pasada)
        req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
        req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String nombres         = trim(req.getParameter("nombres"));
        String apellidos       = trim(req.getParameter("apellidos"));
        String documento       = trim(req.getParameter("documento"));
        String email           = trim(req.getParameter("email"));
        String username        = trim(req.getParameter("username"));
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String telefono        = trim(req.getParameter("telefono"));
        String eps             = trim(req.getParameter("eps"));
        String veredaBarrio    = trim(req.getParameter("veredaBarrio"));
        String fechaNacStr     = trim(req.getParameter("fechaNacimiento"));

        // ── Validaciones ──────────────────────────────────────
        String error = validar(nombres, apellidos, documento, email, username,
                                password, confirmPassword, telefono, fechaNacStr);
        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
            req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
            return;
        }

        // Unicidad
        if (usuarioDAO.existeDocumento(documento)) {
            req.setAttribute("error", "El número de documento ya está registrado.");
            req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
            req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
            return;
        }
        if (usuarioDAO.existeEmail(email)) {
            req.setAttribute("error", "El correo electrónico ya está registrado.");
            req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
            req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
            return;
        }
        if (usuarioDAO.existeUsername(username)) {
            req.setAttribute("error", "El nombre de usuario ya está en uso.");
            req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
            req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
            return;
        }

        // ── Crear usuario ──────────────────────────────────────
        Usuario u = new Usuario();
        u.setNombres(nombres); u.setApellidos(apellidos);
        u.setDocumento(documento); u.setEmail(email); u.setUsername(username);
        u.setPassword(password);  // El DAO hashea con BCrypt
        u.setRolId(4);            // PACIENTE
        u.setTelefono(telefono);
        u.setEps(eps); u.setVeredaBarrio(veredaBarrio);
        u.setActivo(true);
        u.setEmailVerificado(false);
        try { u.setFechaNacimiento(LocalDate.parse(fechaNacStr)); }
        catch (DateTimeParseException e) { /* ignorar */ }

        int nuevoId = usuarioDAO.crear(u);
        if (nuevoId <= 0) {
            req.setAttribute("error", "Error al crear la cuenta. Intenta de nuevo.");
            req.setAttribute("fechaMaxNacimiento", LocalDate.now().toString());
            req.getRequestDispatcher("/views/registro.jsp").forward(req, resp);
            return;
        }

        // ── Generar y enviar OTP ───────────────────────────────
        String otp = OTPService.generarOTP(nuevoId);
        new Thread(() -> {
            EmailService.enviarOTP(email, nombres, otp);
            String adminEmail = System.getenv().getOrDefault("ADMIN_EMAIL", "admin@saludboyaca.gov.co");
            EmailService.enviarBienvenida(email, nombres);
        }).start();

        // Guardar en sesión para el OTP
        HttpSession session = req.getSession();
        session.setAttribute("otpUsuarioId",    nuevoId);
        session.setAttribute("otpUsuarioEmail", email);
        session.setAttribute("otpNombre",       nombres);
        session.setAttribute("otpRedirect",     "/login?registro=ok");

        resp.sendRedirect(req.getContextPath() + "/otp");
    }

    // ── Helpers ────────────────────────────────────────────────
    private String validar(String nombres, String apellidos, String documento,
                            String email, String username, String password,
                            String confirmPassword, String telefono, String fechaNac) {
        if (isEmpty(nombres) || isEmpty(apellidos)) return "Nombres y apellidos son obligatorios.";
        if (isEmpty(documento) || !documento.matches("[0-9]{9,10}")) return "El documento debe tener 9 o 10 dígitos numéricos.";
        if (isEmpty(email) || !email.matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$")) return "Correo electrónico inválido.";
        if (isEmpty(username) || username.length() < 4) return "El nombre de usuario debe tener al menos 4 caracteres.";
        if (!username.matches("[a-zA-Z0-9._]+")) return "El nombre de usuario solo puede contener letras, números, puntos y guion bajo.";
        if (isEmpty(password) || password.length() < 8) return "La contraseña debe tener al menos 8 caracteres.";
        if (!password.equals(confirmPassword)) return "Las contraseñas no coinciden.";
        if (!isEmpty(telefono) && !telefono.matches("[0-9]{10}")) return "El teléfono debe tener 10 dígitos numéricos.";
        if (isEmpty(fechaNac)) return "La fecha de nacimiento es obligatoria.";
        return null;
    }

    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }
    private String  trim(String s)    { return s == null ? "" : s.trim(); }
}
