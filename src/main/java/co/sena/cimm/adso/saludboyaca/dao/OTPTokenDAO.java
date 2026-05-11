package co.sena.cimm.adso.saludboyaca.dao;

import co.sena.cimm.adso.saludboyaca.model.Conexion;
import co.sena.cimm.adso.saludboyaca.util.OTPService;

import java.sql.*;
import java.time.LocalDateTime;

/**
 * OTPTokenDAO — Persistencia de tokens OTP en la tabla otp_tokens
 *
 * LECCIÓN — ¿Por qué guardar OTP en BD además de en sesión?
 *
 *   Solo en sesión HTTP:
 *   - Si el servidor se reinicia → sesión perdida → usuario no puede entrar
 *   - No hay trazabilidad de intentos de acceso
 *   - No se puede invalidar remotamente
 *
 *   También en BD:
 *   - El servidor puede reiniciarse; el token sigue válido
 *   - Puedes ver en log_accesos quién intentó cuántas veces
 *   - Un admin puede invalidar tokens de una cuenta comprometida
 *   - Puedes limpiar tokens expirados con un job nocturno
 *
 *   SEGURIDAD EXTRA: limpiarExpirados() debería llamarse periódicamente
 *   para no acumular miles de registros usados en la tabla.
 */
public class OTPTokenDAO {

    /**
     * Inserta un nuevo token OTP en la BD.
     * Expira en 5 minutos (OTPService.OTP_EXPIRA_MS).
     *
     * @param idUsuario ID del usuario que inicia sesión
     * @param codigo    Código OTP de 6 dígitos generado
     * @param ipOrigen  IP del cliente (para auditoría)
     * @return true si se insertó correctamente
     */
    public boolean insertar(int idUsuario, String codigo, String ipOrigen) {
        // Primero invalidar cualquier token pendiente del mismo usuario
        invalidarPendientes(idUsuario);

        final String SQL =
            "INSERT INTO otp_tokens (id_usuario, codigo, expira_en, ip_origen) " +
            "VALUES (?, ?, ?, ?)";

        // Calcular timestamp de expiración (ahora + 5 minutos)
        LocalDateTime expira = LocalDateTime.now()
            .plusSeconds(OTPService.OTP_EXPIRA_MS / 1000);

        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = Conexion.getConnection();
            ps   = conn.prepareStatement(SQL);
            ps.setInt(1, idUsuario);
            ps.setString(2, codigo);
            ps.setObject(3, expira);        // LocalDateTime → DATETIME en MySQL
            ps.setString(4, ipOrigen);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.err.println("[OTPTokenDAO] insertar: " + ex.getMessage());
        } finally { cerrar(conn, ps, null); }
        return false;
    }

    /**
     * Valida un token OTP.
     * Un token es válido si:
     *   - Pertenece al usuario
     *   - El código coincide
     *   - No ha expirado (expira_en > NOW())
     *   - No ha sido usado previamente
     *
     * @return true si el token es válido
     */
    public boolean validar(int idUsuario, String codigoIngresado) {
        final String SQL =
            "SELECT id FROM otp_tokens " +
            "WHERE id_usuario = ? AND codigo = ? " +
            "  AND expira_en > NOW() AND usado = 0 " +
            "ORDER BY fecha_gen DESC LIMIT 1";

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = Conexion.getConnection();
            ps   = conn.prepareStatement(SQL);
            ps.setInt(1, idUsuario);
            ps.setString(2, codigoIngresado.trim());
            rs   = ps.executeQuery();

            if (rs.next()) {
                int idToken = rs.getInt("id");
                // Marcar como usado INMEDIATAMENTE para evitar reutilización
                marcarUsado(idToken, conn);
                return true;
            }
        } catch (SQLException ex) {
            System.err.println("[OTPTokenDAO] validar: " + ex.getMessage());
        } finally { cerrar(conn, ps, rs); }
        return false;
    }

    /**
     * Marca un token como usado (no puede volver a usarse).
     * Reutiliza la misma conexión abierta para evitar dos round-trips a la BD.
     */
    private void marcarUsado(int idToken, Connection conn) {
        final String SQL = "UPDATE otp_tokens SET usado = 1 WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(SQL)) {
            ps.setInt(1, idToken);
            ps.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("[OTPTokenDAO] marcarUsado: " + ex.getMessage());
        }
    }

    /**
     * Invalida todos los tokens pendientes (no usados) de un usuario.
     * Se llama antes de insertar uno nuevo para evitar tokens duplicados.
     */
    private void invalidarPendientes(int idUsuario) {
        final String SQL =
            "UPDATE otp_tokens SET usado = 1 " +
            "WHERE id_usuario = ? AND usado = 0";

        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = Conexion.getConnection();
            ps   = conn.prepareStatement(SQL);
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("[OTPTokenDAO] invalidarPendientes: " + ex.getMessage());
        } finally { cerrar(conn, ps, null); }
    }

    /**
     * Elimina tokens expirados de la tabla.
     * Llamar desde un job de mantenimiento (cada noche, por ejemplo).
     * Evita que la tabla crezca indefinidamente.
     */
    public int limpiarExpirados() {
        final String SQL =
            "DELETE FROM otp_tokens WHERE expira_en < NOW() AND usado = 1";

        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = Conexion.getConnection();
            ps   = conn.prepareStatement(SQL);
            return ps.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("[OTPTokenDAO] limpiarExpirados: " + ex.getMessage());
        } finally { cerrar(conn, ps, null); }
        return 0;
    }

    private void cerrar(Connection c, PreparedStatement p, ResultSet r) {
        try { if (r != null) r.close(); } catch (SQLException ignored) {}
        try { if (p != null) p.close(); } catch (SQLException ignored) {}
        try { if (c != null) c.close(); } catch (SQLException ignored) {}
    }
}
