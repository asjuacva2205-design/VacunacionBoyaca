package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.CitaDAO;
import co.sena.cimm.adso.saludboyaca.dao.PacienteDAO;
import co.sena.cimm.adso.saludboyaca.dto.Cita;
import co.sena.cimm.adso.saludboyaca.dto.Paciente;
import co.sena.cimm.adso.saludboyaca.util.CaptchaGenerator;
import co.sena.cimm.adso.saludboyaca.util.PDFGenerator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;

/**
 * ConsultaCitaServlet — Módulo PÚBLICO de consulta de citas
 *
 * ¿POR QUÉ CAPTCHA aquí y NO OTP?
 *   El ciudadano que consulta su cita NO tiene cuenta en el sistema.
 *   Sin cuenta → sin email registrado → imposible enviar OTP.
 *   El CAPTCHA es el ÚNICO mecanismo anti-bot posible aquí.
 *   Esta es exactamente la lógica que explica la guía del taller.
 *
 * RUTAS:
 *   GET  /consulta-cita          → formulario + CAPTCHA
 *   GET  /consulta-cita?captcha  → imagen CAPTCHA (img src)
 *   POST /consulta-cita          → validar CAPTCHA + buscar citas
 *   GET  /consulta-cita?pdf=ID   → descargar comprobante PDF
 *
 * NO requiere autenticación — excluida del AuthFilter.
 */
@WebServlet(name = "ConsultaCitaServlet",
            urlPatterns = {"/consulta-cita", "/consulta-cita/*"})
public class ConsultaCitaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // ── Servir imagen CAPTCHA ─────────────────────────────────────
        if (req.getParameter("captcha") != null) {
            servirImagenCaptcha(req, res);
            return;
        }

        // ── Descargar PDF de una cita ─────────────────────────────────
        String pdfParam = req.getParameter("pdf");
        if (pdfParam != null) {
            descargarPDF(req, res, Integer.parseInt(pdfParam));
            return;
        }

        // ── Mostrar formulario de consulta ────────────────────────────
        generarCaptcha(req);
        req.getRequestDispatcher("/views/consulta_cita.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(true);
        String lang = (String) session.getAttribute("lang");
        if (lang == null) lang = "es";
        ResourceBundle rb = ResourceBundle.getBundle("messages", new Locale(lang));

        String documento       = req.getParameter("documento");
        String captchaIngresado = req.getParameter("captcha");
        String captchaGuardado  = (String) session.getAttribute("captchaText");

        // ── Validar CAPTCHA ───────────────────────────────────────────
        if (captchaGuardado == null ||
            !captchaIngresado.trim().equalsIgnoreCase(captchaGuardado)) {

            req.setAttribute("error", rb.getString("consulta.captcha.error"));
            generarCaptcha(req); // Nuevo CAPTCHA tras fallo
            req.getRequestDispatcher("/views/consulta_cita.jsp").forward(req, res);
            return;
        }

        // ── CAPTCHA correcto → buscar citas ───────────────────────────
        session.removeAttribute("captchaText"); // Invalidar después de usar

        PacienteDAO pacDAO  = new PacienteDAO();
        CitaDAO     citaDAO = new CitaDAO();

        Paciente paciente = pacDAO.buscarPorDocumento(documento);

        if (paciente == null) {
            req.setAttribute("error", rb.getString("consulta.no.encontrado"));
            generarCaptcha(req);
            req.getRequestDispatcher("/views/consulta_cita.jsp").forward(req, res);
            return;
        }

        List<Cita> citas = citaDAO.listarPorDocumentoPaciente(documento);

        req.setAttribute("paciente", paciente);
        req.setAttribute("citas", citas);
        req.setAttribute("documento", documento);

        if (citas.isEmpty()) {
            req.setAttribute("sinCitas", true);
        }

        generarCaptcha(req); // Nuevo CAPTCHA para posible siguiente búsqueda
        req.getRequestDispatcher("/views/consulta_cita.jsp").forward(req, res);
    }

    // ── MÉTODOS PRIVADOS ──────────────────────────────────────────────

    /** Genera un nuevo CAPTCHA y lo guarda en sesión */
    private void generarCaptcha(HttpServletRequest req) {
        String texto = CaptchaGenerator.generarTextoCaptcha(5);
        req.getSession(true).setAttribute("captchaText", texto);
    }

    /**
     * Genera y envía la imagen CAPTCHA como respuesta HTTP.
     * El JSP la incluye con: <img src="/consulta-cita?captcha">
     */
    private void servirImagenCaptcha(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String texto = (String) req.getSession(true).getAttribute("captchaText");
        if (texto == null) {
            texto = CaptchaGenerator.generarTextoCaptcha(5);
            req.getSession().setAttribute("captchaText", texto);
        }
        res.setContentType("image/png");
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        CaptchaGenerator.generarImagenCaptcha(texto, res.getOutputStream());
    }

    /** Descarga el comprobante PDF de una cita específica */
    private void descargarPDF(HttpServletRequest req, HttpServletResponse res, int idCita)
            throws IOException, ServletException {
        Cita cita = new CitaDAO().buscarPorId(idCita);
        if (cita == null) {
            res.sendRedirect(req.getContextPath() + "/consulta-cita");
            return;
        }
        try {
            PDFGenerator.generarComprobante(cita, res);
        } catch (Exception ex) {
            System.err.println("[ConsultaCitaServlet] PDF error: " + ex.getMessage());
            res.sendRedirect(req.getContextPath() + "/consulta-cita");
        }
    }
}
