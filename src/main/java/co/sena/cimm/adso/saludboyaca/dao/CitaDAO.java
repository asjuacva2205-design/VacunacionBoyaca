package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.dto.Cita;
import co.sena.cimm.adso.saludboyaca.dto.Notificacion;
import co.sena.cimm.adso.saludboyaca.model.Conexion;
import java.sql.*;
import java.util.*;
import java.util.Date;

/**
 * CitaDAO v3 — Acceso a datos para citas médicas. Usa PreparedStatement para
 * prevenir inyección SQL. Joins correctos para traer todos los datos
 * relacionados.
 */
public class CitaDAO {

    // ── SELECT base con todos los JOINs ──────────────────────
    private static final String SQL_SELECT_BASE = """
        SELECT
          c.id, c.id_paciente, c.id_medico, c.id_especialidad,
          c.fecha_cita, c.hora_cita, c.motivo, c.estado,
          c.observaciones, c.motivo_rechazo, c.id_registrado_por,
          c.fecha_registro, c.updated_at,
          CONCAT(p.nombres,' ',p.apellidos)   AS nombre_paciente,
          p.email                             AS email_paciente,
          p.telefono                          AS telefono_paciente,
          p.documento                         AS documento_paciente,
          CONCAT(m.nombres,' ',m.apellidos)   AS nombre_medico,
          e.nombre                            AS nombre_especialidad,
          e.icono                             AS icono_especialidad
        FROM citas c
        JOIN usuarios p      ON c.id_paciente    = p.id
        JOIN usuarios m      ON c.id_medico      = m.id
        JOIN especialidades e ON c.id_especialidad = e.id
        """;

    // ══════════════════════════════════════════════════════════
    //  LISTAR con filtros y paginación
    // ══════════════════════════════════════════════════════════
    public List<Cita> listar(String q, String estado, String fecha,
            Integer idPaciente, Integer idMedico,
            int page, int pageSize) {
        List<Cita> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SQL_SELECT_BASE + " WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isEmpty()) {
            sql.append(" AND (CONCAT(p.nombres,' ',p.apellidos) LIKE ? OR CONCAT(m.nombres,' ',m.apellidos) LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append(" AND c.estado = ? ");
            params.add(estado);
        }
        if (fecha != null && !fecha.isEmpty()) {
            sql.append(" AND c.fecha_cita = ? ");
            params.add(fecha);
        }
        if (idPaciente != null) {
            sql.append(" AND c.id_paciente = ? ");
            params.add(idPaciente);
        }
        if (idMedico != null) {
            sql.append(" AND c.id_medico = ? ");
            params.add(idMedico);
        }
        sql.append(" ORDER BY c.fecha_cita DESC, c.hora_cita ASC");
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = prepareStatement(con, sql.toString(), params); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public int contar(String q, String estado, String fecha,
            Integer idPaciente, Integer idMedico) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM citas c "
                + "JOIN usuarios p ON c.id_paciente = p.id "
                + "JOIN usuarios m ON c.id_medico = m.id "
                + "JOIN especialidades e ON c.id_especialidad = e.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isEmpty()) {
            sql.append(" AND (CONCAT(p.nombres,' ',p.apellidos) LIKE ? OR CONCAT(m.nombres,' ',m.apellidos) LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append(" AND c.estado = ? ");
            params.add(estado);
        }
        if (fecha != null && !fecha.isEmpty()) {
            sql.append(" AND c.fecha_cita = ? ");
            params.add(fecha);
        }
        if (idPaciente != null) {
            sql.append(" AND c.id_paciente = ? ");
            params.add(idPaciente);
        }
        if (idMedico != null) {
            sql.append(" AND c.id_medico = ? ");
            params.add(idMedico);
        }
        return contarQuery(sql.toString(), params);
    }

    // ══════════════════════════════════════════════════════════
    //  CITAS DE HOY
    // ══════════════════════════════════════════════════════════
    public List<Cita> listarHoy(Integer idMedico, Integer idPaciente) {
        StringBuilder sql = new StringBuilder(SQL_SELECT_BASE
                + " WHERE c.fecha_cita = CURDATE() ");
        List<Object> params = new ArrayList<>();
        if (idMedico != null) {
            sql.append(" AND c.id_medico = ? ");
            params.add(idMedico);
        }
        if (idPaciente != null) {
            sql.append(" AND c.id_paciente = ? ");
            params.add(idPaciente);
        }
        sql.append(" ORDER BY c.hora_cita ASC LIMIT 20");
        return ejecutarLista(sql.toString(), params);
    }

    public int contarCitasHoy(Integer idMedico, Integer idPaciente) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM citas c WHERE fecha_cita = CURDATE() ");
        List<Object> params = new ArrayList<>();
        if (idMedico != null) {
            sql.append(" AND id_medico = ? ");
            params.add(idMedico);
        }
        if (idPaciente != null) {
            sql.append(" AND id_paciente = ? ");
            params.add(idPaciente);
        }
        return contarQuery(sql.toString(), params);
    }

    public int contarPorEstado(String estado, Integer idMedico, Integer idPaciente) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM citas c WHERE estado = ? ");
        List<Object> params = new ArrayList<>();
        params.add(estado);
        if (idMedico != null) {
            sql.append(" AND id_medico = ? ");
            params.add(idMedico);
        }
        if (idPaciente != null) {
            sql.append(" AND id_paciente = ? ");
            params.add(idPaciente);
        }
        return contarQuery(sql.toString(), params);
    }

    public int contarCitasMes(Integer idMedico, Integer idPaciente) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM citas c WHERE MONTH(fecha_cita) = MONTH(CURDATE()) AND YEAR(fecha_cita) = YEAR(CURDATE()) ");
        List<Object> params = new ArrayList<>();
        if (idMedico != null) {
            sql.append(" AND id_medico = ? ");
            params.add(idMedico);
        }
        if (idPaciente != null) {
            sql.append(" AND id_paciente = ? ");
            params.add(idPaciente);
        }
        return contarQuery(sql.toString(), params);
    }

    // ══════════════════════════════════════════════════════════
    //  FIND BY ID
    // ══════════════════════════════════════════════════════════
    public Cita findByIdCompleto(int id) {
        String sql = SQL_SELECT_BASE + " WHERE c.id = ? ";
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
    //  CREAR
    // ══════════════════════════════════════════════════════════
    public int crear(Cita c) {
        String sql = """
            INSERT INTO citas
              (id_paciente, id_medico, id_especialidad, fecha_cita, hora_cita,
               motivo, estado, id_registrado_por)
            VALUES (?,?,?,?,?,?,?,?)
            """;
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getIdPaciente());
            ps.setInt(2, c.getIdMedico());
            ps.setInt(3, c.getIdEspecialidad());
            if (c.getFechaCita() != null) {
                ps.setDate(4, java.sql.Date.valueOf(c.getFechaCita()));  // LocalDate → sql.Date
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setString(5, c.getHoraCita());
            ps.setString(6, c.getMotivo());
            ps.setString(7, c.getEstado() != null ? c.getEstado() : "PENDIENTE");
            ps.setInt(8, c.getIdRegistradoPor());
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
    //  CAMBIAR ESTADO
    // ══════════════════════════════════════════════════════════
    public boolean cambiarEstado(int id, String estado) {
        String sql = "UPDATE citas SET estado = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean rechazar(int id, String motivo) {
        String sql = "UPDATE citas SET estado = 'RECHAZADA', motivo_rechazo = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, motivo);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  SLOT OCUPADO
    // ══════════════════════════════════════════════════════════
    public boolean slotOcupado(int idMedico, String fecha, String hora) {
        String sql = """
            SELECT COUNT(*) FROM citas
            WHERE id_medico = ? AND fecha_cita = ? AND hora_cita = ?
            AND estado NOT IN ('CANCELADA','RECHAZADA')
            """;
        return contarQuery(sql, List.of(idMedico, fecha, hora)) > 0;
    }

    public List<String> horasOcupadas(int idMedico, String fecha) {
        List<String> horas = new ArrayList<>();
        String sql = """
            SELECT TIME_FORMAT(hora_cita,'%H:%i') AS hora FROM citas
            WHERE id_medico = ? AND fecha_cita = ?
            AND estado NOT IN ('CANCELADA','RECHAZADA')
            """;
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idMedico);
            ps.setString(2, fecha);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    horas.add(rs.getString("hora"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return horas;
    }

    // ══════════════════════════════════════════════════════════
    //  NOTIFICACIONES
    // ══════════════════════════════════════════════════════════
    public void crearNotificacion(int idUsuario, String titulo, String mensaje,
            String tipo, int idCita) {
        String sql = "INSERT INTO notificaciones (id_usuario, titulo, mensaje, tipo, id_cita) VALUES (?,?,?,?,?)";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, titulo);
            ps.setString(3, mensaje);
            ps.setString(4, tipo);
            ps.setInt(5, idCita);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Notificacion> listarNotificacionesSinLeer(int idUsuario, int limite) {
        List<Notificacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM notificaciones WHERE id_usuario = ? AND leida = 0 ORDER BY created_at DESC LIMIT ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notificacion n = new Notificacion();
                    n.setId(rs.getInt("id"));
                    n.setIdUsuario(rs.getInt("id_usuario"));
                    n.setTitulo(rs.getString("titulo"));
                    n.setMensaje(rs.getString("mensaje"));
                    n.setTipo(rs.getString("tipo"));
                    n.setLeida(rs.getBoolean("leida"));
                    n.setCreatedAt(rs.getString("created_at"));
                    lista.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public int contarNotificacionesSinLeer(int idUsuario) {
        return contarQuery("SELECT COUNT(*) FROM notificaciones WHERE id_usuario = ? AND leida = 0",
                List.of(idUsuario));
    }

    // ══════════════════════════════════════════════════════════
    //  HELPERS
    // ══════════════════════════════════════════════════════════
    private Cita mapRow(ResultSet rs) throws SQLException {
    Cita c = new Cita();

    c.setId(rs.getInt("id"));
    c.setIdPaciente(rs.getInt("id_paciente"));
    c.setIdMedico(rs.getInt("id_medico"));
    c.setIdEspecialidad(rs.getInt("id_especialidad"));

    // Fecha de la cita
    java.sql.Date fc = rs.getDate("fecha_cita");
    if (fc != null) {
        c.setFechaCita(fc.toLocalDate());
    }

    c.setHoraCita(rs.getString("hora_cita"));
    c.setMotivo(rs.getString("motivo"));
    c.setEstado(rs.getString("estado"));
    c.setObservaciones(rs.getString("observaciones"));
    c.setMotivoRechazo(rs.getString("motivo_rechazo"));
    c.setIdRegistradoPor(rs.getInt("id_registrado_por"));

    // Fecha de registro
    java.sql.Timestamp fr = rs.getTimestamp("fecha_registro");
    if (fr != null) {
        c.setFechaRegistro(fr.toLocalDateTime());
    }

    // Datos adicionales del JOIN
    c.setNombrePaciente(rs.getString("nombre_paciente"));
    c.setEmailPaciente(rs.getString("email_paciente"));
    c.setNombreMedico(rs.getString("nombre_medico"));
    c.setNombreEspecialidad(rs.getString("nombre_especialidad"));
    c.setIconoEspecialidad(rs.getString("icono_especialidad"));

    return c;
}

    private List<Cita> ejecutarLista(String sql, List<Object> params) {
        List<Cita> lista = new ArrayList<>();
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = prepareStatement(con, sql, params); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
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
            } else {
                ps.setObject(i + 1, p);
            }
        }
        return ps;
    }

    /**
     * Busca una cita por ID (usado para generar PDF en consulta pública)
     */
    public Cita buscarPorId(int id) {
        String sql = SQL_SELECT_BASE + " WHERE c.id = ?";
        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CitaDAO] buscarPorId: " + e.getMessage());
        }
        return null;
    }

    /**
     * Lista las citas de un paciente por documento (usado en consulta pública)
     */
    public List<Cita> listarPorDocumentoPaciente(String documento) {
        List<Cita> lista = new ArrayList<>();
        String sql = SQL_SELECT_BASE
                + " WHERE p.documento = ? "
                + " ORDER BY c.fecha_cita DESC, c.hora_cita DESC";

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, documento);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[CitaDAO] listarPorDocumentoPaciente: " + e.getMessage());
        }
        return lista;
    }
}
