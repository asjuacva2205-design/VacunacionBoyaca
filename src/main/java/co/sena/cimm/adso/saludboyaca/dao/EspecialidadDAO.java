package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.dto.Especialidad;
import co.sena.cimm.adso.saludboyaca.model.Conexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * EspecialidadDAO — Catálogo de especialidades médicas Solo lectura — las
 * especialidades las gestiona el administrador directamente en la BD (son pocas
 * y cambian raramente).
 */
public class EspecialidadDAO {

    public List<Especialidad> listarTodas() {
        final String SQL
                = "SELECT id, nombre, descripcion, activa "
                + "FROM especialidades WHERE activa = 1 ORDER BY nombre";

        List<Especialidad> lista = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = Conexion.getConnection();
            ps = conn.prepareStatement(SQL);
            rs = ps.executeQuery();
            while (rs.next()) {
                Especialidad e = new Especialidad();
                e.setId(rs.getInt("id"));
                e.setNombre(rs.getString("nombre"));
                e.setDescripcion(rs.getString("descripcion"));
                e.setActiva(rs.getBoolean("activa"));
                lista.add(e);
            }
        } catch (SQLException ex) {
            System.err.println("[EspecialidadDAO] listarTodas: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ignored) {
            }
        }
        return lista;
    }

    /**
     * Lista todas las especialidades activas (Método agregado para
     * compatibilidad con los servlets)
     */
    public List<Especialidad> listarActivas() {
        final String SQL
                = "SELECT id, nombre, descripcion, activa "
                + "FROM especialidades WHERE activa = 1 ORDER BY nombre";

        List<Especialidad> lista = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = Conexion.getConnection();
            ps = conn.prepareStatement(SQL);
            rs = ps.executeQuery();

            while (rs.next()) {
                Especialidad e = new Especialidad();
                e.setId(rs.getInt("id"));
                e.setNombre(rs.getString("nombre"));
                e.setDescripcion(rs.getString("descripcion"));
                e.setActiva(rs.getBoolean("activa"));
                lista.add(e);
            }
        } catch (SQLException ex) {
            System.err.println("[EspecialidadDAO] listarActivas: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ignored) {
            }
        }
        return lista;
    }

    public Especialidad buscarPorId(int id) {
        final String SQL = "SELECT id, nombre, descripcion, activa FROM especialidades WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = Conexion.getConnection();
            ps = conn.prepareStatement(SQL);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Especialidad e = new Especialidad();
                e.setId(rs.getInt("id"));
                e.setNombre(rs.getString("nombre"));
                e.setDescripcion(rs.getString("descripcion"));
                e.setActiva(rs.getBoolean("activa"));
                return e;
            }
        } catch (SQLException ex) {
            System.err.println("[EspecialidadDAO] buscarPorId: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ignored) {
            }
        }
        return null;
    }
}
