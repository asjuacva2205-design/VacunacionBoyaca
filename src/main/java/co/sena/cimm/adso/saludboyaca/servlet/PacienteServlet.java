package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.PacienteDAO;
import co.sena.cimm.adso.saludboyaca.dto.Paciente;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Locale;
import java.util.ResourceBundle;

/**
 * PacienteServlet — CRUD de pacientes
 *
 * LECCIÓN: Patrón exactamente igual al CitaServlet.
 * Una vez que dominas este patrón switch/acción,
 * puedes construir CUALQUIER módulo CRUD en minutos.
 *
 * Permisos:
 *   - MÉDICO y RECEPCIONISTA: CRUD completo
 *   - ENFERMERO: solo listar y ver
 */
@WebServlet(name = "PacienteServlet", urlPatterns = {"/pacientes", "/pacientes/*"})
public class PacienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "listar"  -> listar(req, res);
            case "nuevo"   -> mostrarFormulario(req, res, null);
            case "editar"  -> mostrarFormulario(req, res,
                                 Integer.parseInt(req.getParameter("id")));
            case "buscar"  -> buscar(req, res);
            default        -> listar(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Verificar permiso para escritura
        HttpSession session = req.getSession(false);
        String rol = (String) session.getAttribute("usuarioRol");

        String accion = req.getParameter("accion");
        if (accion == null) accion = "guardar";

        if ("ENFERMERO".equals(rol) && !"listar".equals(accion)) {
            res.sendRedirect(req.getContextPath() + "/pacientes?error=sinPermiso");
            return;
        }

        switch (accion) {
            case "guardar"  -> guardar(req, res);
            case "eliminar" -> eliminar(req, res);
            default         -> listar(req, res);
        }
    }

    // ── LISTAR ────────────────────────────────────────────────────────
    private void listar(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        PacienteDAO dao = new PacienteDAO();
        req.setAttribute("pacientes", dao.listarTodos());
        req.setAttribute("totalPacientes", dao.contarTotal());
        req.getRequestDispatcher("/views/pacientes/lista.jsp").forward(req, res);
    }

    // ── FORMULARIO ────────────────────────────────────────────────────
    private void mostrarFormulario(HttpServletRequest req, HttpServletResponse res,
                                   Integer id)
            throws ServletException, IOException {
        if (id != null) {
            Paciente p = new PacienteDAO().buscarPorId(id);
            req.setAttribute("paciente", p);
            req.setAttribute("modoEditar", true);
        }
        req.getRequestDispatcher("/views/pacientes/formulario.jsp").forward(req, res);
    }

    // ── BUSCAR (para el campo de búsqueda en el formulario de citas) ─
    private void buscar(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String termino = req.getParameter("q");
        if (termino != null && !termino.isBlank()) {
            req.setAttribute("pacientes", new PacienteDAO().buscarPorNombre(termino));
        }
        listar(req, res);
    }

    // ── GUARDAR (insertar o actualizar) ───────────────────────────────
    private void guardar(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String lang = (String) session.getAttribute("lang");
        if (lang == null) lang = "es";
        ResourceBundle rb = ResourceBundle.getBundle("messages", new Locale(lang));

        try {
            Paciente p = new Paciente();
            String idStr = req.getParameter("id");

            p.setNombres(req.getParameter("nombres"));
            p.setApellidos(req.getParameter("apellidos"));
            p.setDocumento(req.getParameter("documento"));
            p.setFechaNacimiento(LocalDate.parse(req.getParameter("fechaNacimiento")));
            p.setTelefono(req.getParameter("telefono"));
            p.setEmail(req.getParameter("email"));
            p.setEps(req.getParameter("eps"));
            p.setVeredaBarrio(req.getParameter("veredaBarrio"));

            PacienteDAO dao = new PacienteDAO();
            boolean exito;

            if (idStr != null && !idStr.isBlank()) {
                // ACTUALIZAR
                p.setId(Integer.parseInt(idStr));
                exito = dao.actualizar(p);
            } else {
                // INSERTAR
                int resultado = dao.insertar(p);
                exito = resultado > 0;

                if (resultado == -1) {
                    // Documento duplicado
                    req.setAttribute("error",
                        "El documento " + p.getDocumento() + " ya está registrado.");
                    mostrarFormulario(req, res, null);
                    return;
                }
            }

            if (exito) {
                res.sendRedirect(req.getContextPath() + "/pacientes?exito=1");
            } else {
                req.setAttribute("error", rb.getString("error.servidor"));
                mostrarFormulario(req, res, null);
            }

        } catch (Exception ex) {
            System.err.println("[PacienteServlet] guardar: " + ex.getMessage());
            req.setAttribute("error", "Error procesando el formulario: " + ex.getMessage());
            mostrarFormulario(req, res, null);
        }
    }

    // ── ELIMINAR ──────────────────────────────────────────────────────
    private void eliminar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean ok = new PacienteDAO().eliminar(id);
        if (ok) {
            res.sendRedirect(req.getContextPath() + "/pacientes?exito=eliminado");
        } else {
            res.sendRedirect(req.getContextPath() +
                "/pacientes?error=No se puede eliminar: tiene citas asociadas.");
        }
    }
}
