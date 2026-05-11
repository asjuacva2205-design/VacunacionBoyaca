package co.sena.cimm.adso.saludboyaca.model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class Conexion {
    private static final String URL
            = System.getenv("DB_URL") != null
            ? System.getenv("DB_URL")
            : "jdbc:mysql://sql10.freesqldatabase.com:3306/sql10826089?useSSL=false&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
    private static final String USER
            = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "sql10826089";
    private static final String PASS
            = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "1Gcset2ivZ";

    /**
     * Obtiene una conexión a la BD. Cada llamada abre una nueva conexión — en
     * producción real usarías un Connection Pool (HikariCP, c3p0) para
     * reutilizar conexiones y no saturar el servidor MySQL.
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException ex) {
            throw new SQLException("Error al cargar el driver de MySQL", ex);
        }
    }

    /**
     * Cierra la conexión de forma segura. Siempre llamar en el bloque finally
     * del DAO: Connection conn = null; try { conn = Conexion.getConnection();
     * // ... queries } finally { Conexion.closeConnection(conn); }
     */
    public static void closeConnection(Connection connection) {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            System.err.println("Error al cerrar la conexión: " + ex.getMessage());
        }
    }

    private static String getEnv(String nombre, String defecto) {
        String valor = System.getenv(nombre);
        return (valor != null && !valor.isBlank()) ? valor : defecto;
    }

//    
//}
}
