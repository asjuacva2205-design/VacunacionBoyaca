package co.sena.cimm.adso.saludboyaca.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * LogoutServlet — Cierra la sesión de forma segura
 *
 * LECCIÓN: session.invalidate() vs session.removeAttribute()
 *   removeAttribute("usuario") → quita UN atributo, la sesión sigue.
 *   invalidate() → destruye TODA la sesión y su ID de cookie.
 *
 *   ¿Por qué invalidate() es más seguro?
 *   Porque si alguien interceptó el JSESSIONID (cookie de sesión),
 *   con invalidate() ese ID ya no sirve para nada.
 *   Con solo removeAttribute, la cookie sigue siendo "válida"
 *   aunque no tenga usuario. Podría usarse para ataques de
 *   sesión fija (session fixation).
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Destruir toda la sesión
        }

        // Redirigir al login
        response.sendRedirect(request.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res); // POST también cierra sesión (formulario con botón)
    }
}
