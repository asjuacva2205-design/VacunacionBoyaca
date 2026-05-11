package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.dto.*;
import co.sena.cimm.adso.saludboyaca.model.Conexion;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;
import java.util.*;

/**
 * UsuarioDAO v3 — Acceso a datos de usuarios con PreparedStatement.
 */
public class UsuarioDAO {

    private static final String SQL_SELECT_BASE = """
        SELECT u.*, r.nombre AS rol_nombre, e.nombre AS nombre_especialidad
        FROM usuarios u
        JOIN roles r ON u.rol_id = r.id
        LEFT JOIN especialidades e ON u.id_especialidad = e.id
        """;

    // ══════════════════════════════════════════════════════════
    //  AUTENTICACIÓN
    // ══════════════════════════════════════════════════════════
    public Usuario autenticar(String usernameOrEmail, String password) {
        String sql = SQL_SELECT_BASE
                + " WHERE (u.username = ? OR u.email = ?) AND u.activo = 1";

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hashAlmacenado = rs.getString("password");

                    System.out.println("🔑 Hash encontrado en BD: "
                            + (hashAlmacenado != null && hashAlmacenado.length() > 30
                            ? hashAlmacenado.substring(0, 30) + "..."
                            : hashAlmacenado));

                    if (hashAlmacenado == null || hashAlmacenado.trim().isEmpty()) {
                        System.out.println("❌ Hash vacío en la base de datos");
                        return null;
                    }

                    String hashLimpio = hashAlmacenado.trim();
                    boolean coincide = false;

                    // $2y$ es el prefijo usado por PHP; jbcrypt solo acepta $2a$/$2b$
                    String hashParaVerificar = hashLimpio;
                    if (hashLimpio.startsWith("$2y$")) {
                        hashParaVerificar = "$2a$" + hashLimpio.substring(4);
                    }
                    if (hashParaVerificar.startsWith("$2a$") || hashParaVerificar.startsWith("$2b$")) {
                        coincide = BCrypt.checkpw(password.trim(), hashParaVerificar);
                    } else {
                        // Contraseña en texto plano — comparación directa y migración automática a BCrypt
                        coincide = hashLimpio.equals(password.trim());
                        if (coincide) {
                            String nuevoHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(10));
                            try (java.sql.PreparedStatement upd = con.prepareStatement(
                                    "UPDATE usuarios SET password=? WHERE id=?")) {
                                upd.setString(1, nuevoHash);
                                upd.setInt(2, rs.getInt("id"));
                                upd.executeUpdate();
                                System.out.println("\uD83D\uDD04 Contrasena migrada a BCrypt para: " + usernameOrEmail);
                            } catch (java.sql.SQLException ignored) {
                            }
                        }
                        System.out.println("\u26A0\uFE0F Password en texto plano, coincide: " + coincide);
                    }
                    System.out.println("🔐 Comparación BCrypt: " + coincide);

                    if (coincide) {
                        System.out.println("✅ LOGIN EXITOSO para: " + usernameOrEmail + " | Rol: " + rs.getString("rol_nombre"));
                        return mapRow(rs);
                    } else {
                        System.out.println("❌ Contraseña incorrecta para: " + usernameOrEmail);
                    }
                } else {
                    System.out.println("❌ Usuario no encontrado: " + usernameOrEmail);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error SQL en autenticar: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ══════════════════════════════════════════════════════════
    //  FIND BY ID
    // ══════════════════════════════════════════════════════════
    public Usuario findById(int id) {
        String sql = SQL_SELECT_BASE + " WHERE u.id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ══════════════════════════════════════════════════════════
    //  LISTAR con filtros y paginación (admin)
    // ══════════════════════════════════════════════════════════
    public List<Usuario> listarFiltrado(String q, String rol, Boolean activo, int page, int size) {
        List<Usuario> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SQL_SELECT_BASE + " WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFiltros(sql, params, q, rol, activo);
        sql.append(" ORDER BY u.rol_id ASC, u.nombres ASC LIMIT ? OFFSET ?");
        params.add(size);
        params.add((page - 1) * size);

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = prepareStatement(con, sql.toString(), params); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public int contarFiltrado(String q, String rol, Boolean activo) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM usuarios u JOIN roles r ON u.rol_id = r.id "
                + "LEFT JOIN especialidades e ON u.id_especialidad = e.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFiltros(sql, params, q, rol, activo);
        return contarQuery(sql.toString(), params);
    }

    private void appendFiltros(StringBuilder sql, List<Object> params,
            String q, String rol, Boolean activo) {
        if (q != null && !q.isEmpty()) {
            sql.append(" AND (CONCAT(u.nombres,' ',u.apellidos) LIKE ? OR u.documento LIKE ? OR u.email LIKE ?) ");
            String like = "%" + q + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (rol != null && !rol.isEmpty()) {
            sql.append(" AND r.nombre = ? ");
            params.add(rol);
        }
        if (activo != null) {
            sql.append(" AND u.activo = ? ");
            params.add(activo ? 1 : 0);
        }
    }

    // ══════════════════════════════════════════════════════════
    //  LISTAS ESPECÍFICAS
    // ══════════════════════════════════════════════════════════
    public List<Usuario> listarMedicosPorEspecialidad(int idEspecialidad) {
        List<Usuario> lista = new ArrayList<>();
        String sql = SQL_SELECT_BASE
                + " WHERE u.rol_id = 2 AND u.id_especialidad = ? AND u.activo = 1 ORDER BY u.nombres";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idEspecialidad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<Usuario> listarPacientesActivos() {
        List<Usuario> lista = new ArrayList<>();
        String sql = SQL_SELECT_BASE
                + " WHERE u.rol_id = 4 AND u.activo = 1 ORDER BY u.nombres ASC";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public int contarPacientesActivos() {
        return contarQuery("SELECT COUNT(*) FROM usuarios WHERE rol_id = 4 AND activo = 1", List.of());
    }

    public List<Object> listarRoles() {
        List<Object> lista = new ArrayList<>();
        String sql = "SELECT * FROM roles ORDER BY id";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("nombre", rs.getString("nombre"));
                m.put("descripcion", rs.getString("descripcion"));
                lista.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // ══════════════════════════════════════════════════════════
    //  CREAR
    // ══════════════════════════════════════════════════════════
    public int crear(Usuario u) {
        String sql = """
            INSERT INTO usuarios
              (nombres, apellidos, documento, email, username, password, rol_id,
               id_especialidad, telefono, fecha_nacimiento, eps, vereda_barrio,
               activo, email_verificado)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            """;
        String hash = BCrypt.hashpw(u.getPassword(), BCrypt.gensalt(10));
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, u.getNombres());
            ps.setString(2, u.getApellidos());
            ps.setString(3, u.getDocumento());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getUsername());
            ps.setString(6, hash);
            ps.setInt(7, u.getRolId());
            if (u.getIdEspecialidad() != null) {
                ps.setInt(8, u.getIdEspecialidad());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            ps.setString(9, u.getTelefono());
            ps.setString(10, u.getFechaNacimiento() != null ? u.getFechaNacimiento().toString() : null);
            ps.setString(11, u.getEps());
            ps.setString(12, u.getVeredaBarrio());
            ps.setBoolean(13, u.isActivo());
            ps.setBoolean(14, u.isEmailVerificado());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ══════════════════════════════════════════════════════════
    //  ACTUALIZAR
    // ══════════════════════════════════════════════════════════
    public boolean actualizar(Usuario u) {
        boolean conPass = u.getPassword() != null && !u.getPassword().isEmpty();
        String sql;
        if (conPass) {
            sql = "UPDATE usuarios SET nombres=?, apellidos=?, email=?, username=?, password=?, "
                    + "rol_id=?, id_especialidad=?, telefono=?, activo=? WHERE id=?";
        } else {
            sql = "UPDATE usuarios SET nombres=?, apellidos=?, email=?, username=?, "
                    + "rol_id=?, id_especialidad=?, telefono=?, activo=? WHERE id=?";
        }
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, u.getNombres());
            ps.setString(i++, u.getApellidos());
            ps.setString(i++, u.getEmail());
            ps.setString(i++, u.getUsername());
            if (conPass) {
                ps.setString(i++, BCrypt.hashpw(u.getPassword(), BCrypt.gensalt(10)));
            }
            ps.setInt(i++, u.getRolId());
            if (u.getIdEspecialidad() != null) {
                ps.setInt(i++, u.getIdEspecialidad());
            } else {
                ps.setNull(i++, Types.INTEGER);
            }
            ps.setString(i++, u.getTelefono());
            ps.setBoolean(i++, u.isActivo());
            ps.setInt(i, u.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleActivo(int id) {
        String sql = "UPDATE usuarios SET activo = NOT activo WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean eliminar(int id) {
        String sql = "DELETE FROM usuarios WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean marcarEmailVerificado(int id) {
        String sql = "UPDATE usuarios SET email_verificado = 1, activo = 1 WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  VERIFICACIONES DE UNICIDAD
    // ══════════════════════════════════════════════════════════
    public boolean existeDocumento(String documento) {
        return contarQuery("SELECT COUNT(*) FROM usuarios WHERE documento = ?", List.of(documento)) > 0;
    }

    public boolean existeEmail(String email) {
        return contarQuery("SELECT COUNT(*) FROM usuarios WHERE email = ?", List.of(email)) > 0;
    }

    public boolean existeUsername(String username) {
        return contarQuery("SELECT COUNT(*) FROM usuarios WHERE username = ?", List.of(username)) > 0;
    }

    // ══════════════════════════════════════════════════════════
    //  PERFIL
    // ══════════════════════════════════════════════════════════
    public boolean actualizarPerfil(int id, String nombres, String apellidos,
            String telefono, String eps, String veredaBarrio,
            String foto, String lang) {
        String sql = """
            UPDATE usuarios SET nombres=?, apellidos=?, telefono=?,
            eps=?, vereda_barrio=?, foto=?, lang_preferido=? WHERE id=?
            """;
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombres);
            ps.setString(2, apellidos);
            ps.setString(3, telefono);
            ps.setString(4, eps);
            ps.setString(5, veredaBarrio);
            ps.setString(6, foto);
            ps.setString(7, lang);
            ps.setInt(8, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cambiarPassword(int id, String passwordActual, String nuevaPassword) {
        Usuario u = findById(id);
        if (u == null) {
            return false;
        }
        if (!BCrypt.checkpw(passwordActual, u.getPassword())) {
            return false;
        }
        String sql = "UPDATE usuarios SET password = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, BCrypt.hashpw(nuevaPassword, BCrypt.gensalt(10)));
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  HELPERS
    // ══════════════════════════════════════════════════════════
    private Usuario mapRow(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setId(rs.getInt("id"));
        u.setNombres(rs.getString("nombres"));
        u.setApellidos(rs.getString("apellidos"));
        u.setDocumento(rs.getString("documento"));
        u.setEmail(rs.getString("email"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setRolId(rs.getInt("rol_id"));
        u.setTelefono(rs.getString("telefono"));
        u.setEps(rs.getString("eps"));
        u.setVeredaBarrio(rs.getString("vereda_barrio"));
        u.setFoto(rs.getString("foto"));
        u.setActivo(rs.getBoolean("activo"));
        u.setEmailVerificado(rs.getBoolean("email_verificado"));
        u.setLangPreferido(rs.getString("lang_preferido"));
        u.setCreatedAt(rs.getString("created_at"));
        // Joins
        u.setRol(rs.getString("rol_nombre"));
        try {
            u.setNombreEspecialidad(rs.getString("nombre_especialidad"));
        } catch (SQLException ignored) {
        }
        try {
            int idEsp = rs.getInt("id_especialidad");
            if (!rs.wasNull()) {
                u.setIdEspecialidad(idEsp);
            }
        } catch (SQLException ignored) {
        }
        return u;
    }

    private int contarQuery(String sql, List<Object> params) {
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = prepareStatement(con, sql, params); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private PreparedStatement prepareStatement(Connection con, String sql, List<Object> params) throws SQLException {
        PreparedStatement ps = con.prepareStatement(sql);
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof String s) {
                ps.setString(i + 1, s);
            } else if (p instanceof Integer ig) {
                ps.setInt(i + 1, ig);
            } else if (p instanceof Boolean b) {
                ps.setBoolean(i + 1, b);
            } else {
                ps.setObject(i + 1, p);
            }
        }
        return ps;
    }

    /**
     * Método para compatibilidad con LoginServlet Valida usuario y contraseña
     */
    public Usuario validarLogin(String usernameOrEmail, String password) {
        return autenticar(usernameOrEmail, password);
    }

    /**
     * Lista todos los médicos activos (para el formulario de citas)
     */
    public List<Usuario> listarMedicos() {
        List<Usuario> lista = new ArrayList<>();
        String sql = SQL_SELECT_BASE
                + " WHERE u.rol_id = 2 AND u.activo = 1 ORDER BY u.nombres, u.apellidos";

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] listarMedicos: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    /**
     * Cambiar contraseña con verificación (para perfil de usuario)
     */
    public boolean cambiarPasswordConOTP(int idUsuario, String nuevaPassword) {
        String sql = "UPDATE usuarios SET password = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            String hash = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt(10));
            ps.setString(1, hash);
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Actualizar perfil completo (usado desde Perfil del usuario)
     */
    public boolean actualizarPerfilCompleto(int id, String nombres, String apellidos,
            String email, String username, String telefono, String eps,
            String veredaBarrio, String foto, Integer idEspecialidad) {

        String sql = """
        UPDATE usuarios 
        SET nombres = ?, apellidos = ?, email = ?, username = ?, 
            telefono = ?, eps = ?, vereda_barrio = ?, foto = ?,
            id_especialidad = ?
        WHERE id = ?
        """;

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nombres);
            ps.setString(2, apellidos);
            ps.setString(3, email);
            ps.setString(4, username);
            ps.setString(5, telefono);
            ps.setString(6, eps);
            ps.setString(7, veredaBarrio);
            ps.setString(8, foto);

            if (idEspecialidad != null) {
                ps.setInt(9, idEspecialidad);
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            ps.setInt(10, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
