package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.dto.Paciente;
import co.sena.cimm.adso.saludboyaca.model.Conexion;
import java.sql.*;
import java.util.*;

/**
 * PacienteDAO - Totalmente adaptado a tabla 'usuarios' + rol PACIENTE (id=4)
 */
public class PacienteDAO {

    private static final int ROL_PACIENTE = 4;

    // ====================== BUSCAR POR DOCUMENTO ======================
    public Paciente buscarPorDocumento(String documento) {
        String sql = """
            SELECT id, nombres, apellidos, documento, email, username, telefono,
                   fecha_nacimiento, eps, vereda_barrio, foto, activo,
                   created_at, updated_at
            FROM usuarios
            WHERE documento = ? AND rol_id = ? AND activo = 1
            """;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, documento);
            ps.setInt(2, ROL_PACIENTE);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[PacienteDAO] buscarPorDocumento: " + e.getMessage());
        }
        return null;
    }

    // ====================== LISTAR PACIENTES ======================
    public List<Paciente> listarTodos() {
        List<Paciente> lista = new ArrayList<>();
        String sql = """
            SELECT id, nombres, apellidos, documento, email, username, telefono,
                   fecha_nacimiento, eps, vereda_barrio, foto, activo,
                   created_at, updated_at
            FROM usuarios
            WHERE rol_id = ? AND activo = 1
            ORDER BY apellidos, nombres
            """;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, ROL_PACIENTE);
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

    // ====================== BUSCAR POR ID ======================
    public Paciente buscarPorId(int id) {
        String sql = """
            SELECT id, nombres, apellidos, documento, email, username, telefono,
                   fecha_nacimiento, eps, vereda_barrio, foto, activo,
                   created_at, updated_at
            FROM usuarios
            WHERE id = ? AND rol_id = ? AND activo = 1
            """;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, ROL_PACIENTE);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[PacienteDAO] buscarPorId: " + e.getMessage());
        }
        return null;
    }

    // ====================== BUSCAR POR NOMBRE ======================
    public List<Paciente> buscarPorNombre(String termino) {
        List<Paciente> lista = new ArrayList<>();
        String sql = """
            SELECT id, nombres, apellidos, documento, email, username, telefono,
                   fecha_nacimiento, eps, vereda_barrio, foto, activo,
                   created_at, updated_at
            FROM usuarios
            WHERE rol_id = ? AND activo = 1
              AND (nombres LIKE ? OR apellidos LIKE ? OR documento LIKE ?)
            ORDER BY apellidos, nombres 
            LIMIT 20
            """;

        String patron = "%" + termino + "%";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, ROL_PACIENTE);
            ps.setString(2, patron);
            ps.setString(3, patron);
            ps.setString(4, patron);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PacienteDAO] buscarPorNombre: " + e.getMessage());
        }
        return lista;
    }

    // ====================== CONTAR TOTAL ======================
    public int contarTotal() {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE rol_id = ? AND activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, ROL_PACIENTE);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[PacienteDAO] contarTotal: " + e.getMessage());
        }
        return 0;
    }

    // ====================== INSERTAR ======================
    public int insertar(Paciente p) {
        String sql = """
            INSERT INTO usuarios 
            (nombres, apellidos, documento, email, username, password, rol_id,
             telefono, fecha_nacimiento, eps, vereda_barrio, activo)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getNombres());
            ps.setString(2, p.getApellidos());
            ps.setString(3, p.getDocumento());
            ps.setString(4, p.getEmail());
            ps.setString(5, p.getUsername() != null ? p.getUsername() : "pac_" + p.getDocumento());
            ps.setString(6, "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.QnMN5/U8jCgk4xhZCG"); // adm1234
            ps.setInt(7, ROL_PACIENTE);
            ps.setString(8, p.getTelefono());

            if (p.getFechaNacimiento() != null) {
                ps.setDate(9, java.sql.Date.valueOf(p.getFechaNacimiento()));
            } else {
                ps.setNull(9, Types.DATE);
            }

            ps.setString(10, p.getEps());
            ps.setString(11, p.getVeredaBarrio());
            ps.setBoolean(12, true);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) return -1; // Duplicado
            System.err.println("[PacienteDAO] insertar: " + e.getMessage());
            return -2;
        }
        return -2;
    }

    // ====================== ACTUALIZAR ======================
    public boolean actualizar(Paciente p) {
        String sql = """
            UPDATE usuarios 
            SET nombres=?, apellidos=?, email=?, telefono=?, 
                fecha_nacimiento=?, eps=?, vereda_barrio=?, foto=?
            WHERE id=? AND rol_id=?
            """;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getNombres());
            ps.setString(2, p.getApellidos());
            ps.setString(3, p.getEmail());
            ps.setString(4, p.getTelefono());

            if (p.getFechaNacimiento() != null) {
                ps.setDate(5, java.sql.Date.valueOf(p.getFechaNacimiento()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setString(6, p.getEps());
            ps.setString(7, p.getVeredaBarrio());
            ps.setString(8, p.getFoto());
            ps.setInt(9, p.getId());
            ps.setInt(10, ROL_PACIENTE);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PacienteDAO] actualizar: " + e.getMessage());
            return false;
        }
    }

    // ====================== ELIMINAR ======================
    public boolean eliminar(int id) {
        String sql = "DELETE FROM usuarios WHERE id = ? AND rol_id = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, ROL_PACIENTE);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            if (e.getErrorCode() == 1451) {
                System.err.println("[PacienteDAO] No se puede eliminar: tiene citas asociadas.");
            } else {
                System.err.println("[PacienteDAO] eliminar: " + e.getMessage());
            }
            return false;
        }
    }

    // ====================== MAPROW (Principal) ======================
    private Paciente mapRow(ResultSet rs) throws SQLException {
        Paciente p = new Paciente();

        p.setId(rs.getInt("id"));
        p.setNombres(rs.getString("nombres"));
        p.setApellidos(rs.getString("apellidos"));
        p.setDocumento(rs.getString("documento"));
        p.setEmail(rs.getString("email"));
        p.setUsername(rs.getString("username"));
        p.setTelefono(rs.getString("telefono"));

        java.sql.Date sqlDate = rs.getDate("fecha_nacimiento");
        if (sqlDate != null) {
            p.setFechaNacimiento(sqlDate.toLocalDate());
        }

        p.setEps(rs.getString("eps"));
        p.setVeredaBarrio(rs.getString("vereda_barrio"));
        p.setFoto(rs.getString("foto"));
        p.setActivo(rs.getBoolean("activo"));

        if (rs.getTimestamp("created_at") != null) {
            p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            p.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }

        return p;
    }
}