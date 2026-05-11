package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.EspecialidadDAO;
import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Especialidad;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;
import co.sena.cimm.adso.saludboyaca.util.EmailService;
import co.sena.cimm.adso.saludboyaca.util.OTPService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/perfil")
public class PerfilServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final EspecialidadDAO especialidadDAO = new EspecialidadDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer userId = (Integer) req.getSession().getAttribute("usuarioId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario usuario = usuarioDAO.findById(userId);
        req.setAttribute("usuario", usuario);
        
        // Cargar especialidades si es medico o enfermero
        String rol = (String) req.getSession().getAttribute("usuarioRol");
        if ("MEDICO".equals(rol) || "ENFERMERO".equals(rol)) {
            List<Especialidad> especialidades = especialidadDAO.listarActivas();
            req.setAttribute("especialidades", especialidades);
        }
        
        req.getRequestDispatcher("/views/perfil.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer userId = (Integer) req.getSession().getAttribute("usuarioId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String accion = req.getParameter("accion");

        if ("actualizarPerfil".equals(accion)) {
            // Datos editables
            String nombres = req.getParameter("nombres");
            String apellidos = req.getParameter("apellidos");
            String email = req.getParameter("email");
            String username = req.getParameter("username");
            String telefono = req.getParameter("telefono");
            String eps = req.getParameter("eps");
            String veredaBarrio = req.getParameter("veredaBarrio");
            String foto = req.getParameter("foto");
            Integer idEspecialidad = null;

            // Medicos y enfermeros pueden editar especialidad
            String rol = (String) req.getSession().getAttribute("usuarioRol");
            if ("MEDICO".equals(rol) || "ENFERMERO".equals(rol)) {
                String espStr = req.getParameter("idEspecialidad");
                if (espStr != null && !espStr.isEmpty()) {
                    idEspecialidad = Integer.parseInt(espStr);
                }
            }

            boolean ok = usuarioDAO.actualizarPerfilCompleto(userId, nombres, apellidos, 
                email, username, telefono, eps, veredaBarrio, foto, idEspecialidad);

            if (ok) {
                req.setAttribute("mensaje", "✅ Perfil actualizado correctamente");
            } else {
                req.setAttribute("error", "❌ Error al actualizar el perfil");
            }

        } else if ("enviarOTP".equals(accion)) {
            String otp = OTPService.generarOTP(userId);
            HttpSession session = req.getSession();
            session.setAttribute("otpCodigo", otp);
            session.setAttribute("otpTimestamp", System.currentTimeMillis());

            Usuario u = usuarioDAO.findById(userId);
            if (u != null) {
                EmailService.enviarOTP(u.getEmail(), u.getNombres(), otp);
                req.setAttribute("mensaje", "✅ Código OTP enviado a tu correo");
            }
        }

        doGet(req, resp); // Recargar página
    }
}
