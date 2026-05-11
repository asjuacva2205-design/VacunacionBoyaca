package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.*;
import co.sena.cimm.adso.saludboyaca.dto.*;
import co.sena.cimm.adso.saludboyaca.util.EmailService;
import co.sena.cimm.adso.saludboyaca.util.EmailService.DatosCita;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * CitaServlet — CRUD de citas + slots + detalle JSON. GET /citas → lista
 * filtrada GET /citas?accion=medicos&idEsp=X → JSON médicos GET
 * /citas?accion=slots&idMedico=X&fecha=Y → JSON slots GET
 * /citas?accion=detalle&id=X → JSON detalle GET
 * /citas?accion=estado&id=X&estado=Y → cambiar estado POST /citas accion=crear
 * → nueva cita POST /citas accion=rechazar → rechazar con motivo
 */
@WebServlet("/citas")
public class CitaServlet extends HttpServlet {

    private final CitaDAO citaDAO = new CitaDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final EspecialidadDAO espDAO = new EspecialidadDAO();
    private static final int PAGE_SIZE = 15;
    private static final Gson GSON = new Gson();
    private static final DateTimeFormatter FMT_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FMT_TIME = DateTimeFormatter.ofPattern("HH:mm");

    // ══════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String accion = nullOrEmpty(req.getParameter("accion"));
        int usuarioId = (int) session.getAttribute("usuarioId");
        String rol = (String) session.getAttribute("usuarioRol");

        // ── JSON: médicos por especialidad ────────────────────
        if ("medicos".equals(accion)) {
            int idEsp = parseInt(req.getParameter("idEspecialidad"));
            List<Usuario> medicos = usuarioDAO.listarMedicosPorEspecialidad(idEsp);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(GSON.toJson(medicos));
            return;
        }

        // ── JSON: slots disponibles ───────────────────────────
        if ("slots".equals(accion)) {
            int idMedico = parseInt(req.getParameter("idMedico"));
            String fechaStr = req.getParameter("fecha");
            List<Map<String, Object>> slots = generarSlots(idMedico, fechaStr);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(GSON.toJson(slots));
            return;
        }

        // ── JSON: detalle de una cita ─────────────────────────
        if ("detalle".equals(accion)) {
            int id = parseInt(req.getParameter("id"));
            Cita c = citaDAO.findByIdCompleto(id);
            if (c == null || !puedeVerCita(c, usuarioId, rol)) {
                resp.setStatus(403);
                return;
            }
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(GSON.toJson(c));
            return;
        }

        // ── Cambiar estado (confirmar/atender/cancelar) ───────
        if ("estado".equals(accion)) {
            int id = parseInt(req.getParameter("id"));
            String estado = req.getParameter("estado");
            cambiarEstadoCita(req, resp, id, estado, usuarioId, rol);
            return;
        }

        // ── LISTA de citas ────────────────────────────────────
        int page = Math.max(1, parseInt(req.getParameter("page")));
        String q = nullOrEmpty(req.getParameter("q"));
        String estadoF = nullOrEmpty(req.getParameter("estado"));
        String fechaF = nullOrEmpty(req.getParameter("fecha"));

        // Pacientes solo ven sus citas
        Integer filtroIdPaciente = "PACIENTE".equals(rol) ? usuarioId : null;
        // Médicos solo ven sus citas
        Integer filtroIdMedico = "MEDICO".equals(rol) ? usuarioId : null;

        int total = citaDAO.contar(q, estadoF, fechaF, filtroIdPaciente, filtroIdMedico);
        List<Cita> citas = citaDAO.listar(q, estadoF, fechaF, filtroIdPaciente, filtroIdMedico, page, PAGE_SIZE);

        req.setAttribute("citas", citas);
        req.setAttribute("totalCitas", total);
        req.setAttribute("paginaActual", page);
        req.setAttribute("totalPaginas", (int) Math.ceil((double) total / PAGE_SIZE));

        // Para el formulario de nueva cita
        req.setAttribute("especialidades", espDAO.listarActivas());
        req.setAttribute("pacientes", usuarioDAO.listarPacientesActivos());

        req.getRequestDispatcher("/views/citas/lista.jsp").forward(req, resp);
    }

    // ══════════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String accion = req.getParameter("accion");
        int usuarioId = (int) session.getAttribute("usuarioId");
        String rol = (String) session.getAttribute("usuarioRol");

        // ── Crear nueva cita ──────────────────────────────────
        if ("crear".equals(accion)) {
            crearCita(req, resp, usuarioId, rol);
            return;
        }

        // ── Rechazar cita con motivo ──────────────────────────
        if ("rechazar".equals(accion)) {
            if (!"ADMIN".equals(rol) && !"RECEPCIONISTA".equals(rol)) {
                resp.sendRedirect(req.getContextPath() + "/citas");
                return;
            }
            int id = parseInt(req.getParameter("id"));
            String motivoRechazo = req.getParameter("motivoRechazo");
            citaDAO.rechazar(id, motivoRechazo);

            // Notificar al paciente
            Cita c = citaDAO.findByIdCompleto(id);
            if (c != null) {
                notificarPaciente(c, EmailService.TipoEmail.CITA_RECHAZADA, motivoRechazo);
            }
            req.getSession().setAttribute("mensajeExito", "Cita rechazada correctamente.");
            resp.sendRedirect(req.getContextPath() + "/citas");
        }
    }

    // ══ CREAR CITA ════════════════════════════════════════════
    private void crearCita(HttpServletRequest req, HttpServletResponse resp,
            int usuarioId, String rol) throws IOException, ServletException {

        int idEsp = parseInt(req.getParameter("idEspecialidad"));
        int idMedico = parseInt(req.getParameter("idMedico"));
        String fechaStr = req.getParameter("fechaCita");
        String horaStr = req.getParameter("horaCita");
        String motivo = req.getParameter("motivo");
        int idPaciente;

        if ("PACIENTE".equals(rol)) {
            idPaciente = usuarioId;
        } else {
            idPaciente = parseInt(req.getParameter("idPaciente"));
            if (idPaciente == 0) {
                req.getSession().setAttribute("mensajeError", "Selecciona un paciente.");
                resp.sendRedirect(req.getContextPath() + "/citas");
                return;
            }
        }

        // Validar fecha no pasada
        LocalDate fecha;
        try {
            fecha = LocalDate.parse(fechaStr);
            if (fecha.isBefore(LocalDate.now())) {
                req.getSession().setAttribute("mensajeError", "❌ Fecha no permitida: no puedes agendar en fechas pasadas.");
                resp.sendRedirect(req.getContextPath() + "/citas");
                return;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("mensajeError", "Fecha inválida.");
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }

        // Validar que el slot no esté ocupado
        if (citaDAO.slotOcupado(idMedico, fechaStr, horaStr)) {
            req.getSession().setAttribute("mensajeError", "⚠️ La fecha y hora seleccionadas ya no están disponibles con ese médico.");
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }

        // Crear la cita
        Cita c = new Cita();
        c.setIdPaciente(idPaciente);
        c.setIdMedico(idMedico);
        c.setIdEspecialidad(idEsp);
        c.setFechaCita(fecha);
        c.setHoraCita(horaStr);
        c.setMotivo(motivo);
        c.setEstado("PENDIENTE");
        c.setIdRegistradoPor(usuarioId);

        int nuevaCitaId = citaDAO.crear(c);
        if (nuevaCitaId <= 0) {
            req.getSession().setAttribute("mensajeError", "Error al registrar la cita. Intente de nuevo.");
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }

        // Notificaciones asíncronas
        Cita citaCompleta = citaDAO.findByIdCompleto(nuevaCitaId);
        if (citaCompleta != null) {
            new Thread(() -> {
                notificarPaciente(citaCompleta, EmailService.TipoEmail.CITA_NUEVA, null);
                // Notificar admin
                String adminEmail = System.getenv().getOrDefault("ADMIN_EMAIL", "admin@saludboyaca.gov.co");
                DatosCita dc = toDatosCita(citaCompleta);
                EmailService.notificarAdminNuevaCita(adminEmail, dc);
                // Notificación interna
                citaDAO.crearNotificacion(1, "Nueva cita pendiente",
                        citaCompleta.getNombrePaciente() + " agendó cita para el "
                        + citaCompleta.getFechaCita() + " a las " + citaCompleta.getHoraCita(),
                        "CITA_NUEVA", nuevaCitaId);
            }).start();
        }

        req.getSession().setAttribute("mensajeExito", "✅ Cita agendada exitosamente. Quedó en estado PENDIENTE.");
        resp.sendRedirect(req.getContextPath() + "/citas");
    }

    // ══ CAMBIAR ESTADO ════════════════════════════════════════
    private void cambiarEstadoCita(HttpServletRequest req, HttpServletResponse resp,
            int id, String estado, int usuarioId, String rol)
            throws IOException {

        // Permisos por rol
        boolean puedeAdmin = "ADMIN".equals(rol) || "RECEPCIONISTA".equals(rol);
        boolean puedeMedico = "MEDICO".equals(rol);
        boolean esPaciente = "PACIENTE".equals(rol);

        if ("CONFIRMADA".equals(estado) && !puedeAdmin) {
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }
        if ("ATENDIDA".equals(estado) && !puedeMedico && !puedeAdmin) {
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }
        if ("CANCELADA".equals(estado) && !esPaciente && !puedeAdmin) {
            resp.sendRedirect(req.getContextPath() + "/citas");
            return;
        }

        citaDAO.cambiarEstado(id, estado);

        // Notificar al paciente
        Cita c = citaDAO.findByIdCompleto(id);
        if (c != null) {
            EmailService.TipoEmail tipo = switch (estado) {
                case "CONFIRMADA" ->
                    EmailService.TipoEmail.CITA_CONFIRMADA;
                case "CANCELADA" ->
                    EmailService.TipoEmail.CITA_CANCELADA;
                default ->
                    null;
            };
            if (tipo != null) {
                final EmailService.TipoEmail tipoFinal = tipo;
                new Thread(() -> notificarPaciente(c, tipoFinal, null)).start();
            }
        }

        req.getSession().setAttribute("mensajeExito", "Estado de la cita actualizado correctamente.");
        resp.sendRedirect(req.getContextPath() + "/citas");
    }

    // ══ GENERAR SLOTS ═════════════════════════════════════════
    private List<Map<String, Object>> generarSlots(int idMedico, String fechaStr) {
        List<Map<String, Object>> slots = new ArrayList<>();
        try {
            LocalDate fecha = LocalDate.parse(fechaStr);
            // Obtener horario del médico para ese día de semana
            int diaSemana = fecha.getDayOfWeek().getValue(); // 1=Lun..5=Vie
            if (diaSemana > 5) {
                return slots; // fin de semana
            }
            HorarioDAO horarioDAO = new HorarioDAO();
            Horario h = horarioDAO.findByMedicoYDia(idMedico, diaSemana);
            if (h == null) {
                return slots;
            }

            // Generar slots de 30 minutos
            LocalTime actual = h.getHoraInicio();
            LocalTime fin = h.getHoraFin();
            Set<String> ocupadas = new HashSet<>(citaDAO.horasOcupadas(idMedico, fechaStr));

            while (actual.isBefore(fin)) {
                String horaStr = actual.format(FMT_TIME);
                Map<String, Object> slot = new HashMap<>();
                slot.put("hora", horaStr);
                slot.put("ocupado", ocupadas.contains(horaStr));
                slots.add(slot);
                actual = actual.plusMinutes(30);
            }
        } catch (Exception e) {
            // retorna lista vacía
        }
        return slots;
    }

    // ══ HELPERS ════════════════════════════════════════════════
    private boolean puedeVerCita(Cita c, int usuarioId, String rol) {
        if ("ADMIN".equals(rol) || "RECEPCIONISTA".equals(rol) || "ENFERMERO".equals(rol)) {
            return true;
        }
        if ("MEDICO".equals(rol)) {
            return c.getIdMedico() == usuarioId;
        }
        if ("PACIENTE".equals(rol)) {
            return c.getIdPaciente() == usuarioId;
        }
        return false;
    }

    private void notificarPaciente(Cita c, EmailService.TipoEmail tipo, String motivoRechazo) {
        try {
            Usuario paciente = new UsuarioDAO().findById(c.getIdPaciente());
            if (paciente == null) {
                return;
            }
            DatosCita dc = toDatosCita(c);
            switch (tipo) {
                case CITA_NUEVA ->
                    EmailService.notificarCitaNueva(paciente.getEmail(), paciente.getNombres(), dc);
                case CITA_CONFIRMADA ->
                    EmailService.notificarCitaConfirmada(paciente.getEmail(), paciente.getNombres(), dc);
                case CITA_CANCELADA ->
                    EmailService.notificarCitaCancelada(paciente.getEmail(), paciente.getNombres(), dc);
                case CITA_RECHAZADA ->
                    EmailService.notificarCitaRechazada(paciente.getEmail(), paciente.getNombres(), dc, motivoRechazo);
                default -> {
                }
            }
        } catch (Exception e) {
            System.err.println("[CitaServlet] Error al notificar paciente: " + e.getMessage());
        }
    }

    private DatosCita toDatosCita(Cita c) {
        String fechaFormateada = "";
        if (c.getFechaCita() != null) {
            fechaFormateada = c.getFechaCita()
                    .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        }

        return new DatosCita(
                c.getNombreEspecialidad(),
                c.getNombreMedico(),
                c.getEmailPaciente() != null ? c.getEmailPaciente() : "",
                fechaFormateada,
                c.getHoraCita() != null ? c.getHoraCita() : "",
                c.getNombrePaciente() != null ? c.getNombrePaciente() : ""
        // Se quitó el motivo porque el constructor solo recibe 6 parámetros
        );
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }

    private String nullOrEmpty(String s) {
        return s == null ? "" : s.trim();
    }
}
