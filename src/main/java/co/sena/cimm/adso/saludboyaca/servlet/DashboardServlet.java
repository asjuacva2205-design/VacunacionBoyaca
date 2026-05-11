package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.*;
import co.sena.cimm.adso.saludboyaca.dto.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * DashboardServlet — Carga las estadísticas y citas del día según el rol.
 */
@WebServlet({"/dashboard", "/index.jsp", "/"})
public class DashboardServlet extends HttpServlet {

    private final CitaDAO    citaDAO    = new CitaDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int    usuarioId = (int) session.getAttribute("usuarioId");
        String rol       = (String) session.getAttribute("usuarioRol");

        // ── Estadísticas según rol ─────────────────────────────
        Integer filtroMedico   = "MEDICO".equals(rol)   ? usuarioId : null;
        Integer filtroPaciente = "PACIENTE".equals(rol) ? usuarioId : null;

        int statCitasHoy  = citaDAO.contarCitasHoy(filtroMedico, filtroPaciente);
        int statPendientes = citaDAO.contarPorEstado("PENDIENTE", filtroMedico, filtroPaciente);
        int statCitasMes  = citaDAO.contarCitasMes(filtroMedico, filtroPaciente);
        int statPacientes = "PACIENTE".equals(rol) ? 0 : usuarioDAO.contarPacientesActivos();

        req.setAttribute("statCitasHoy",   statCitasHoy);
        req.setAttribute("statPendientes", statPendientes);
        req.setAttribute("statCitasMes",   statCitasMes);
        req.setAttribute("statPacientes",  statPacientes);

        // ── Citas del día ───────────────────────────────────────
        List<Cita> proximasCitas = citaDAO.listarHoy(filtroMedico, filtroPaciente);
        req.setAttribute("proximasCitas", proximasCitas);

        // ── Notificaciones para admin ───────────────────────────
        if ("ADMIN".equals(rol)) {
            List<Notificacion> notifs = citaDAO.listarNotificacionesSinLeer(usuarioId, 10);
            int notifCount = citaDAO.contarNotificacionesSinLeer(usuarioId);
            req.setAttribute("notificacionesPendientes", notifs);
            req.setAttribute("notificaciones",           notifs);
            req.setAttribute("notifCount",               notifCount);
        }

        // ── Mensaje de la sesión (éxito/error) ─────────────────
        transferirAtrib(session, req, "mensajeExito");
        transferirAtrib(session, req, "mensajeError");

        req.getRequestDispatcher("/views/dashboard.jsp").forward(req, resp);
    }

    private void transferirAtrib(HttpSession session, HttpServletRequest req, String key) {
        Object val = session.getAttribute(key);
        if (val != null) {
            req.setAttribute(key, val);
            session.removeAttribute(key);
        }
    }
}
