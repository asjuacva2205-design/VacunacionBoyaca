package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.HorarioDAO;
import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Horario;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * HorarioServlet — Visualización de horarios por médico
 *
 * Solo lectura: MÉDICO ve sus propios horarios;
 * RECEPCIONISTA ve los de todos los médicos.
 * ENFERMERO no accede a este módulo (AuthFilter + menú condicional).
 */
@WebServlet(name = "HorarioServlet", urlPatterns = {"/horarios", "/horarios/*"})
public class HorarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String rol = (String) session.getAttribute("usuarioRol");
        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");

        HorarioDAO dao    = new HorarioDAO();
        UsuarioDAO usrDao = new UsuarioDAO();

        List<Horario> horarios = new ArrayList<>();

        if ("MEDICO".equals(rol)) {
            // El médico ve SOLO sus propios horarios
            horarios = dao.listarPorMedico(usuarioActual.getId());
        } else {
            // RECEPCIONISTA ve horarios de todos los médicos
            List<Usuario> medicos = usrDao.listarMedicos();
            for (Usuario m : medicos) {
                horarios.addAll(dao.listarPorMedico(m.getId()));
            }
        }

        req.setAttribute("horarios", horarios);
        req.getRequestDispatcher("/views/horarios/lista.jsp").forward(req, res);
    }
}
