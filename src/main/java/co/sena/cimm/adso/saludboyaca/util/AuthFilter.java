package co.sena.cimm.adso.saludboyaca.util;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter — Protege rutas que requieren sesión activa.
 * Rutas exentas: /login, /registro, /otp, /landing, /consulta-cita,
 *                /resources/*, /views/error/*
 */
public class AuthFilter implements Filter {

    private static final String[] RUTAS_LIBRES = {
        "/login", "/registro", "/otp", "/home", "/landing.jsp",
        "/consulta-cita", "/resources/", "/views/error/"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI().substring(req.getContextPath().length());

        // Permitir rutas libres
        for (String libre : RUTAS_LIBRES) {
            if (uri.startsWith(libre)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Verificar sesión
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Si OTP no verificado, solo puede acceder a /otp
        Boolean otpVerificado = (Boolean) session.getAttribute("otpVerificado");
        if (otpVerificado == null || !otpVerificado) {
            resp.sendRedirect(req.getContextPath() + "/otp");
            return;
        }

        // Verificar acceso a /admin solo para ADMIN
        if (uri.startsWith("/admin/")) {
            String rol = (String) session.getAttribute("usuarioRol");
            if (!"ADMIN".equals(rol)) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}