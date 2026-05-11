package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.dto.Horario;
import co.sena.cimm.adso.saludboyaca.model.Conexion;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * HorarioDAO — Horarios de médicos y disponibilidad de horas
 *
 * LECCIÓN — horasDisponibles():
 *   Este método es la clave del BONUS C (select dinámico).
 *   Dado un médico y una fecha, retorna solo las horas que:
 *     1. Están dentro del horario del médico ese día de la semana
 *     2. NO tienen ya una cita confirmada en esa fecha+hora
 *   Así el recepcionista no puede agendar en horas ocupadas.
 */
public class HorarioDAO {

    /**
     * Retorna los horarios de un médico (todos sus días/franjas).
     * Usado en la vista de horarios (solo lectura).
     */
    public List<Horario> listarPorMedico(int idMedico) {
        final String SQL =
            "SELECT h.id, h.id_medico, h.dia_semana, h.hora_inicio, h.hora_fin, " +
            "h.max_citas, CONCAT(u.nombres,' ',u.apellidos) AS nombre_medico " +
            "FROM horarios h " +
            "JOIN usuarios u ON u.id = h.id_medico " +
            "WHERE h.id_medico = ? ORDER BY h.dia_semana, h.hora_inicio";

        List<Horario> lista = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = Conexion.getConnection();
            ps   = conn.prepareStatement(SQL);
            ps.setInt(1, idMedico);
            rs   = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException ex) {
            System.err.println("[HorarioDAO] listarPorMedico: " + ex.getMessage());
        } finally { cerrar(conn, ps, rs); }
        return lista;
    }

    /**
     * BONUS C — Horas disponibles para agendar.
     *
     * Estrategia:
     *   1. Obtener el horario del médico para ese día de semana
     *   2. Generar slots de 30 minutos entre hora_inicio y hora_fin
     *   3. Filtrar los slots que YA tienen cita ese día (no CANCELADA)
     *   4. Retornar solo los slots libres
     *
     * @param idMedico ID del médico
     * @param fecha    Fecha de la cita (para calcular día de semana)
     * @return Lista de horas disponibles como Strings "HH:mm"
     */
    public List<String> horasDisponibles(int idMedico, LocalDate fecha) {
        // dia_semana en MySQL: DAYOFWEEK() → 1=Dom, 2=Lun ... 7=Sáb
        // En nuestro esquema: 1=Lun ... 5=Vie (ISO)
        // DayOfWeek de Java: MONDAY=1 ... FRIDAY=5
        int diaSemana = fecha.getDayOfWeek().getValue(); // 1=Lunes

        // Obtener franja horaria del médico para ese día
        final String SQL_HORARIO =
            "SELECT hora_inicio, hora_fin FROM horarios " +
            "WHERE id_medico = ? AND dia_semana = ?";

        // Obtener horas ya ocupadas ese día
        final String SQL_OCUPADAS =
            "SELECT hora_cita FROM citas " +
            "WHERE id_medico = ? AND fecha_cita = ? AND estado != 'CANCELADA'";

        List<String> disponibles = new ArrayList<>();
        Connection conn = null;
        try {
            conn = Conexion.getConnection();

            // ① Obtener franja horaria
            LocalTime inicio = null, fin = null;
            try (PreparedStatement ps = conn.prepareStatement(SQL_HORARIO)) {
                ps.setInt(1, idMedico);
                ps.setInt(2, diaSemana);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    inicio = rs.getTime("hora_inicio").toLocalTime();
                    fin    = rs.getTime("hora_fin").toLocalTime();
                }
                rs.close();
            }

            if (inicio == null) return disponibles; // Médico no trabaja ese día

            // ② Obtener horas ocupadas
            List<String> ocupadas = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(SQL_OCUPADAS)) {
                ps.setInt(1, idMedico);
                ps.setString(2, fecha.toString());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    // Formato "HH:mm" para comparar con los slots generados
                    ocupadas.add(rs.getTime("hora_cita").toLocalTime()
                                   .toString().substring(0, 5));
                }
                rs.close();
            }

            // ③ Generar slots de 30 minutos y filtrar los ocupados
            LocalTime slot = inicio;
            while (slot.isBefore(fin)) {
                String slotStr = slot.toString().substring(0, 5); // "09:00"
                if (!ocupadas.contains(slotStr)) {
                    disponibles.add(slotStr);
                }
                slot = slot.plusMinutes(30);
            }

        } catch (SQLException ex) {
            System.err.println("[HorarioDAO] horasDisponibles: " + ex.getMessage());
        } finally { cerrar(conn, null, null); }

        return disponibles;
    }

    private Horario mapear(ResultSet rs) throws SQLException {
        Horario h = new Horario();
        h.setId(rs.getInt("id"));
        h.setIdMedico(rs.getInt("id_medico"));
        h.setDiaSemana(rs.getInt("dia_semana"));
        h.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
        h.setHoraFin(rs.getTime("hora_fin").toLocalTime());
        h.setMaxCitas(rs.getInt("max_citas"));
        try { h.setNombreMedico(rs.getString("nombre_medico")); }
        catch (SQLException ignored) {}
        return h;
    }

    private void cerrar(Connection c, PreparedStatement p, ResultSet r) {
        try { if (r != null) r.close(); } catch (SQLException ignored) {}
        try { if (p != null) p.close(); } catch (SQLException ignored) {}
        try { if (c != null) c.close(); } catch (SQLException ignored) {}
    }
        /**
     * Busca el horario de un médico para un día específico de la semana
     * (Usado por CitaServlet para generar slots)
     */
    public Horario findByMedicoYDia(int idMedico, int diaSemana) {
        final String SQL = """
            SELECT id, id_medico, dia_semana, hora_inicio, hora_fin, max_citas 
            FROM horarios 
            WHERE id_medico = ? AND dia_semana = ? AND activo = 1
            LIMIT 1
            """;
        
        Connection conn = null; 
        PreparedStatement ps = null; 
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            ps = conn.prepareStatement(SQL);
            ps.setInt(1, idMedico);
            ps.setInt(2, diaSemana);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapear(rs);
            }
        } catch (SQLException ex) {
            System.err.println("[HorarioDAO] findByMedicoYDia: " + ex.getMessage());
        } finally {
            cerrar(conn, ps, rs);
        }
        return null;
    }
}
