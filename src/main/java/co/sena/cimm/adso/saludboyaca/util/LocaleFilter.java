package co.sena.cimm.adso.saludboyaca.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

/**
 * LocaleFilter — Internacionalización (i18n)
 *
 * ¿QUÉ HACE?
 *   Intercepta CADA petición HTTP antes de llegar al Servlet.
 *   Si la URL trae ?lang=XX, guarda ese idioma en la sesión.
 *   Los JSP luego leen session.lang con <fmt:setLocale>.
 *
 * ¿POR QUÉ @WebFilter("/*")?
 *   El "/*" significa que intercepta TODAS las rutas.
 *   Si usáramos @WebFilter("/dashboard/*") solo funcionaría
 *   en esa sección, y el login no tendría i18n.
 *
 * ¿POR QUÉ antes del Servlet y no dentro?
 *   Porque la MISMA lógica de idioma la necesitan TODOS los
 *   Servlets. Ponerla aquí evita repetir código en 8 clases.
 *   → Principio DRY (Don't Repeat Yourself).
 *
 * IDIOMAS SOPORTADOS:
 *   es (Español), en (English), fr (Français), it (Italiano),
 *   zh (中文), ja (日本語), ko (한국어)
 */
@WebFilter(filterName = "LocaleFilter", urlPatterns = {"/*"})
public class LocaleFilter implements Filter {

    // Set de idiomas válidos — si llega ?lang=ar lo ignoramos
    private static final Set<String> IDIOMAS_VALIDOS =
            Set.of("es", "en", "fr", "it", "zh", "ja", "ko");

    private static final String IDIOMA_DEFAULT = "es";

    @Override
    public void doFilter(ServletRequest req, ServletResponse res,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        // ① Leer el parámetro ?lang= de la URL
        String langParam = request.getParameter("lang");

        // ② Si es un idioma válido, guardarlo en sesión
        if (langParam != null && IDIOMAS_VALIDOS.contains(langParam)) {
            HttpSession session = request.getSession(true);
            session.setAttribute("lang", langParam);
        }

        // ③ Si la sesión no tiene idioma aún, poner el default
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("lang") == null) {
            session.setAttribute("lang", IDIOMA_DEFAULT);
        }

        // ④ Continuar con la cadena de filtros → llega al Servlet
        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
