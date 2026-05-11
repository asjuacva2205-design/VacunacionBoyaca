package co.sena.cimm.adso.saludboyaca.servlet;

import co.sena.cimm.adso.saludboyaca.dao.EspecialidadDAO;
import co.sena.cimm.adso.saludboyaca.dao.UsuarioDAO;
import co.sena.cimm.adso.saludboyaca.dto.Usuario;
import com.google.gson.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.*;
import java.util.*;

@WebServlet("/admin/usuarios")
public class AdminUsuarioServlet extends HttpServlet {

    private final UsuarioDAO      usuarioDAO = new UsuarioDAO();
    private final EspecialidadDAO espDAO     = new EspecialidadDAO();
    private static final int PAGE_SIZE = 20;

    /* ══════════════════════════════════════════════════════════════
       GSON SEGURO — registra adaptadores para TODOS los tipos de
       fecha/hora que usan LocalDate, java.sql.Date, Time, Timestamp.
       Esto corrige el error:
         "Failed making field 'java.time.LocalDate#year' accessible"
       ══════════════════════════════════════════════════════════════ */
    private static final Gson GSON = new GsonBuilder()

        // ── java.time.LocalDate ──────────────────────────────────
        .registerTypeAdapter(LocalDate.class, new JsonSerializer<LocalDate>() {
            @Override
            public JsonElement serialize(LocalDate src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })
        .registerTypeAdapter(LocalDate.class, new JsonDeserializer<LocalDate>() {
            @Override
            public LocalDate deserialize(JsonElement j, Type t, JsonDeserializationContext ctx) {
                return j.isJsonNull() ? null : LocalDate.parse(j.getAsString());
            }
        })

        // ── java.time.LocalDateTime ──────────────────────────────
        .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
            @Override
            public JsonElement serialize(LocalDateTime src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        // ── java.time.LocalTime ──────────────────────────────────
        .registerTypeAdapter(LocalTime.class, new JsonSerializer<LocalTime>() {
            @Override
            public JsonElement serialize(LocalTime src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        // ── java.sql.Date ────────────────────────────────────────
        .registerTypeAdapter(Date.class, new JsonSerializer<Date>() {
            @Override
            public JsonElement serialize(Date src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        // ── java.sql.Time ────────────────────────────────────────
        .registerTypeAdapter(Time.class, new JsonSerializer<Time>() {
            @Override
            public JsonElement serialize(Time src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        // ── java.sql.Timestamp ───────────────────────────────────
        .registerTypeAdapter(Timestamp.class, new JsonSerializer<Timestamp>() {
            @Override
            public JsonElement serialize(Timestamp src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        // ── java.util.Date ───────────────────────────────────────
        .registerTypeAdapter(java.util.Date.class, new JsonSerializer<java.util.Date>() {
            @Override
            public JsonElement serialize(java.util.Date src, Type t, JsonSerializationContext ctx) {
                return src == null ? JsonNull.INSTANCE : new JsonPrimitive(src.toString());
            }
        })

        .serializeNulls()          // incluir campos null como null en JSON
        .create();

    /* ══════════════════════════════════════════════════════════════
       GET — lista usuarios / devuelve datos de uno / toggle / eliminar
       ══════════════════════════════════════════════════════════════ */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Verificar que sea ADMIN
        String rol = (String) req.getSession().getAttribute("usuarioRol");
        if (!"ADMIN".equals(rol)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String accion = req.getParameter("accion");

        /* ── Devuelve JSON de un usuario para el modal editar ── */
        if ("datos".equals(accion)) {
            int id = parseIntSafe(req.getParameter("id"));
            Usuario u = usuarioDAO.findById(id);

            resp.setContentType("application/json;charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");

            // GSON maneja todos los tipos fecha/hora sin lanzar excepción
            resp.getWriter().write(GSON.toJson(u));
            return;
        }

        /* ── Toggle activo/inactivo ── */
        if ("toggleActivo".equals(accion)) {
            int id = parseIntSafe(req.getParameter("id"));
            usuarioDAO.toggleActivo(id);
            resp.sendRedirect(req.getContextPath() + "/admin/usuarios?op=ok");
            return;
        }

        /* ── Eliminar usuario ── */
        if ("eliminar".equals(accion)) {
            int id      = parseIntSafe(req.getParameter("id"));
            int adminId = getSessionInt(req, "usuarioId");
            if (id == adminId) {
                resp.sendRedirect(req.getContextPath()
                        + "/admin/usuarios?op=err&msg=No+puedes+eliminarte+a+ti+mismo");
                return;
            }
            usuarioDAO.eliminar(id);
            resp.sendRedirect(req.getContextPath() + "/admin/usuarios?op=ok");
            return;
        }

        /* ── Lista paginada con filtros ── */
        int     page       = Math.max(1, parseIntSafe(req.getParameter("page")));
        String  q          = safe(req.getParameter("q"));
        String  rolFilt    = safe(req.getParameter("rol"));
        String  activoStr  = req.getParameter("activo");
        Boolean activoFilt = "1".equals(activoStr) ? Boolean.TRUE
                           : "0".equals(activoStr) ? Boolean.FALSE
                           : null;

        int         total    = usuarioDAO.contarFiltrado(q, rolFilt, activoFilt);
        List<Usuario> lista  = usuarioDAO.listarFiltrado(q, rolFilt, activoFilt, page, PAGE_SIZE);
        int         totalPag = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("usuarios",       lista);
        req.setAttribute("totalUsuarios",  total);
        req.setAttribute("paginaActual",   page);
        req.setAttribute("totalPaginas",   totalPag);
        req.setAttribute("roles",          usuarioDAO.listarRoles());
        req.setAttribute("especialidades", espDAO.listarActivas());

        // Parámetros de filtro para repoblar el formulario
        req.setAttribute("filtroQ",      q);
        req.setAttribute("filtroRol",    rolFilt);
        req.setAttribute("filtroActivo", activoStr);

        req.getRequestDispatcher("/views/admin/usuarios.jsp")
           .forward(req, resp);
    }

    /* ══════════════════════════════════════════════════════════════
       POST — crear / editar usuario
       ══════════════════════════════════════════════════════════════ */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rol = (String) req.getSession().getAttribute("usuarioRol");
        if (!"ADMIN".equals(rol)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        // Construir objeto Usuario desde los parámetros del formulario
        Usuario u = new Usuario();
        u.setId            (parseIntSafe(req.getParameter("id")));
        u.setNombres       (safe(req.getParameter("nombres")));
        u.setApellidos     (safe(req.getParameter("apellidos")));
        u.setDocumento     (safe(req.getParameter("documento")).replaceAll("\\D", ""));
        u.setEmail         (safe(req.getParameter("email")).toLowerCase());
        u.setUsername      (safe(req.getParameter("username")).toLowerCase());
        u.setRolId         (parseIntSafe(req.getParameter("rolId")));
        u.setIdEspecialidad(parseIntOrNull(req.getParameter("idEspecialidad")));
        u.setTelefono      (safe(req.getParameter("telefono")));
        u.setActivo        ("1".equals(req.getParameter("activo")));

        // Validaciones básicas en servidor
        String docLimpio = u.getDocumento();
        if (docLimpio.length() < 9 || docLimpio.length() > 10) {
            resp.sendRedirect(req.getContextPath()
                    + "/admin/usuarios?op=err&msg=El+documento+debe+tener+9+o+10+digitos");
            return;
        }

        String pass = req.getParameter("password");
        boolean tienePass = pass != null && !pass.trim().isEmpty();

        try {
            if ("crear".equals(accion)) {
                if (!tienePass) {
                    resp.sendRedirect(req.getContextPath()
                            + "/admin/usuarios?op=err&msg=La+contrasena+es+obligatoria+para+nuevo+usuario");
                    return;
                }
                u.setPassword(pass.trim());
                u.setEmailVerificado(true);  // admin crea usuarios ya verificados
                usuarioDAO.crear(u);
                resp.sendRedirect(req.getContextPath() + "/admin/usuarios?op=ok&msg=Usuario+creado+correctamente");

            } else if ("editar".equals(accion)) {
                if (tienePass) {
                    u.setPassword(pass.trim());
                }
                usuarioDAO.actualizar(u);
                resp.sendRedirect(req.getContextPath() + "/admin/usuarios?op=ok&msg=Usuario+actualizado+correctamente");

            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/usuarios");
            }

        } catch (Exception e) {
            String msg = e.getMessage() != null
                    ? e.getMessage().replace("Duplicate entry", "Dato duplicado:")
                    : "Error desconocido";
            resp.sendRedirect(req.getContextPath()
                    + "/admin/usuarios?op=err&msg="
                    + java.net.URLEncoder.encode(msg, "UTF-8"));
        }
    }

    /* ══════════════════════════════════════════════════════════════
       MÉTODOS AUXILIARES
       ══════════════════════════════════════════════════════════════ */
    private int parseIntSafe(String s) {
        if (s == null || s.isBlank()) return 0;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return 0; }
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            int v = Integer.parseInt(s.trim());
            return v <= 0 ? null : v;
        } catch (NumberFormatException e) { return null; }
    }

    private String safe(String s) {
        return s == null ? "" : s.trim();
    }

    private int getSessionInt(HttpServletRequest req, String attr) {
        Object v = req.getSession().getAttribute(attr);
        if (v instanceof Integer i) return i;
        if (v instanceof String  s) return parseIntSafe(s);
        return 0;
    }
}