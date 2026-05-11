package co.sena.cimm.adso.saludboyaca.util;

import co.sena.cimm.adso.saludboyaca.model.Conexion;
import java.security.SecureRandom;
import java.sql.*;
import java.time.LocalDateTime;

/**
 * OTPService — Gestión de códigos de verificación de un solo uso.
 */
public class OTPService {

    private static final int    OTP_LENGTH   = 6;
    private static final int    EXPIRY_MIN   = 10;
    private static final int    MAX_INTENTOS = 5;

    /** Genera y guarda un OTP de 6 dígitos para el usuario */
    public static String generarOTP(int idUsuario) {
        invalidarAnteriores(idUsuario);
        String codigo = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        String sql = """
            INSERT INTO otp_tokens (id_usuario, token, tipo, expira_en)
            VALUES (?, ?, 'REGISTRO', ?)
            """;
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, codigo);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusMinutes(EXPIRY_MIN)));
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return codigo;
    }

    /**
     * Valida el OTP ingresado.
     * @return true si válido, false si inválido/expirado/usado
     */
    public static boolean validar(int idUsuario, String tokenIngresado) {
        String sql = """
            SELECT id, token, usado, intentos, expira_en
            FROM otp_tokens
            WHERE id_usuario = ?
              AND tipo = 'REGISTRO'
              AND usado = 0
            ORDER BY created_at DESC
            LIMIT 1
            """;
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;

                int     otpId    = rs.getInt("id");
                String  token    = rs.getString("token");
                int     intentos = rs.getInt("intentos");
                Timestamp expira = rs.getTimestamp("expira_en");

                // Verificar expiración
                if (expira.toLocalDateTime().isBefore(LocalDateTime.now())) {
                    marcarUsado(otpId);
                    return false;
                }

                // Incrementar intentos
                incrementarIntentos(otpId);

                if (intentos + 1 >= MAX_INTENTOS) {
                    marcarUsado(otpId);
                    return false;
                }

                // Comparar
                if (token.equals(tokenIngresado.trim())) {
                    marcarUsado(otpId);
                    return true;
                }
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // Tiempo de expiración del OTP en milisegundos (5 minutos)
    public static final long OTP_EXPIRA_MS = 5 * 60 * 1000;  // 300000 ms

    /** Cuántos minutos quedan para expirar el OTP */
    public static int minutosRestantes(int idUsuario) {
        String sql = """
            SELECT TIMESTAMPDIFF(SECOND, NOW(), expira_en) AS segundos
            FROM otp_tokens
            WHERE id_usuario = ? AND usado = 0 AND tipo = 'REGISTRO'
            ORDER BY created_at DESC LIMIT 1
            """;
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Math.max(0, rs.getInt("segundos"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // Helpers privados
    private static void marcarUsado(int otpId) {
        ejecutar("UPDATE otp_tokens SET usado = 1 WHERE id = ?", otpId);
    }
    private static void incrementarIntentos(int otpId) {
        ejecutar("UPDATE otp_tokens SET intentos = intentos + 1 WHERE id = ?", otpId);
    }
    private static void invalidarAnteriores(int idUsuario) {
        ejecutar("UPDATE otp_tokens SET usado = 1 WHERE id_usuario = ? AND usado = 0", idUsuario);
    }
    private static void ejecutar(String sql, int param) {
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
        /**
     * Enmascara un email para mostrarlo de forma segura (privacidad)
     * Ej: juan.perez@gmail.com → ju******@gmail.com
     */
    public static String enmascararEmail(String email) {
        if (email == null || email.trim().isEmpty() || !email.contains("@")) {
            return "******@******";
        }
        
        String[] partes = email.split("@");
        String usuario = partes[0];
        String dominio = partes[1];
        
        if (usuario.length() <= 3) {
            return "***@" + dominio;
        }
        
        String visible = usuario.substring(0, Math.min(3, usuario.length()));
        String oculto = "*".repeat(usuario.length() - visible.length());
        
        return visible + oculto + "@" + dominio;
    }

    /**
     * Valida el OTP usando los datos guardados en la sesión
     * (Usado por OTPServlet)
     */
    public static boolean esValido(String codigoIngresado, String codigoSesion, long timestampGeneracion) {
        if (codigoIngresado == null || codigoSesion == null) {
            return false;
        }

        // Verificar si expiró
        long tiempoTranscurrido = System.currentTimeMillis() - timestampGeneracion;
        if (tiempoTranscurrido > OTP_EXPIRA_MS) {
            return false; // OTP expirado
        }

        // Comparación segura
        return codigoIngresado.trim().equals(codigoSesion.trim());
    }
    
        /**
     * Genera OTP de 6 dígitos (versión para LoginServlet - sin guardar en BD)
     */
    public static String generarOTP() {
        return String.format("%06d", new SecureRandom().nextInt(1_000_000));
    }

    /**
     * Envía OTP por correo (versión para desarrollo)
     */
    public static void enviarOTP(String email, String asunto, String cuerpo) {
        System.out.println("=".repeat(70));
        System.out.println("📧 OTP SERVICE - ENVÍO DE CORREO");
        System.out.println("Para      : " + email);
        System.out.println("Asunto    : " + asunto);
        System.out.println("Código OTP: " + cuerpo);
        System.out.println("=".repeat(70));
        
        // TODO: Aquí más adelante pondrás el envío real con JavaMail
    }
}
