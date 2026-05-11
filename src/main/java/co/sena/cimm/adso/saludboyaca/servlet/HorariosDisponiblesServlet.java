package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.HorarioDAO;
import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

/**
 * HorariosDisponiblesServlet — API JSON para el formulario de citas
 *
 * LECCIÓN — ¿Qué es una API JSON desde un Servlet?
 *   En vez de redirigir a un JSP (HTML), este Servlet retorna
 *   texto en formato JSON. El navegador lo recibe con fetch()
 *   y lo usa para llenar el select de horas dinámicamente.
 *
 *   ENDPOINT 1: GET /api/horarios-disponibles?idMedico=1&fecha=2026-04-28
 *   Respuesta:  ["08:00","08:30","09:00","10:30"]
 *
 *   ENDPOINT 2: GET /api/medicos?idEspecialidad=1
 *   Respuesta:  [{"id":1,"nombres":"Carlos","apellidos":"Pedraza"}]
 *
 * RUTA PÚBLICA:
 *   Excluida del AuthFilter porque el formulario de citas la llama
 *   desde el navegador sin petición al servidor (AJAX).
 *   El AuthFilter protege /citas (la página), no /api/* (los datos JSON).
 */
@WebServlet(name = "ApiServlet", urlPatterns = {"/api/horarios-disponibles", "/api/medicos"})
public class HorariosDisponiblesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Configurar respuesta como JSON UTF-8
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        // Evitar que el navegador cachée los resultados (disponibilidad cambia)
        res.setHeader("Cache-Control", "no-cache, no-store");

        String path = req.getServletPath();
        PrintWriter out = res.getWriter();

        if ("/api/horarios-disponibles".equals(path)) {
            responderHorasDisponibles(req, out);
        } else if ("/api/medicos".equals(path)) {
            responderMedicos(req, out);
        } else {
            out.print("[]");
        }
    }

    /**
     * Retorna horas disponibles para un médico en una fecha dada.
     * Ejemplo: ["08:00","08:30","09:30","11:00"]
     */
    private void responderHorasDisponibles(HttpServletRequest req, PrintWriter out) {
        String idMedicoStr = req.getParameter("idMedico");
        String fechaStr    = req.getParameter("fecha");

        if (idMedicoStr == null || fechaStr == null) {
            out.print("[]");
            return;
        }

        try {
            int       idMedico = Integer.parseInt(idMedicoStr);
            LocalDate fecha    = LocalDate.parse(fechaStr);

            HorarioDAO dao = new HorarioDAO();
            List<String> horas = dao.horasDisponibles(idMedico, fecha);

            // Construir JSON manualmente (sin librería externa)
            // Para proyectos grandes usar Gson o Jackson
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < horas.size(); i++) {
                json.append("\"").append(horas.get(i)).append("\"");
                if (i < horas.size() - 1) json.append(",");
            }
            json.append("]");
            out.print(json);

        } catch (Exception ex) {
            System.err.println("[ApiServlet] horasDisponibles: " + ex.getMessage());
            out.print("[]");
        }
    }

    /**
     * Retorna médicos filtrados por especialidad.
     * Ejemplo: [{"id":1,"nombres":"Carlos","apellidos":"Pedraza"}]
     */
    private void responderMedicos(HttpServletRequest req, PrintWriter out) {
        String idEspStr = req.getParameter("idEspecialidad");

        if (idEspStr == null) {
            out.print("[]");
            return;
        }

        try {
            // Para el BONUS C, por simplicidad retornamos todos los médicos.
            // En una implementación real filtrarías por especialidad con JOIN.
            UsuarioDAO dao = new UsuarioDAO();
            List<Usuario> medicos = dao.listarMedicos();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < medicos.size(); i++) {
                Usuario m = medicos.get(i);
                json.append("{")
                    .append("\"id\":").append(m.getId()).append(",")
                    .append("\"nombres\":\"").append(escaparJson(m.getNombres())).append("\",")
                    .append("\"apellidos\":\"").append(escaparJson(m.getApellidos())).append("\"")
                    .append("}");
                if (i < medicos.size() - 1) json.append(",");
            }
            json.append("]");
            out.print(json);

        } catch (Exception ex) {
            System.err.println("[ApiServlet] medicos: " + ex.getMessage());
            out.print("[]");
        }
    }

    /**
     * Escapa caracteres especiales para JSON seguro.
     * Evita que nombres con comillas rompan el JSON.
     * Ejemplo: O'Brien → O\'Brien
     */
    private String escaparJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
