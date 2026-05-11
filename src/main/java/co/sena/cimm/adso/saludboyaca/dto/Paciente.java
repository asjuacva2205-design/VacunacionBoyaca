package co.sena.cimm.adso.saludboyaca.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;

public class Paciente {

    private int id;
    private String nombres;
    private String apellidos;
    private String documento;
    private String email;
    private String username;
    private String telefono;
    private LocalDate fechaNacimiento;
    private String eps;
    private String veredaBarrio;
    private String foto;
    private boolean activo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Paciente() {}

    // Constructor útil
    public Paciente(String nombres, String apellidos, String documento, 
                    LocalDate fechaNacimiento, String email, String telefono) {
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.documento = documento;
        this.fechaNacimiento = fechaNacimiento;
        this.email = email;
        this.telefono = telefono;
    }

    // ── MÉTODOS DE UTILIDAD ──────────────────────────────────────────
    public String getNombreCompleto() {
        return (nombres != null ? nombres.trim() : "") + " " + 
               (apellidos != null ? apellidos.trim() : "");
    }

    public int calcularEdad() {
        if (fechaNacimiento == null) return 0;
        return Period.between(fechaNacimiento, LocalDate.now()).getYears();
    }

    public String getNombreConEdad() {
        String nombre = getNombreCompleto().trim();
        return nombre.isEmpty() ? "Sin nombre" : nombre + " (" + calcularEdad() + " años)";
    }

    // ── GETTERS Y SETTERS ────────────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getDocumento() { return documento; }
    public void setDocumento(String documento) { this.documento = documento; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public LocalDate getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(LocalDate fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }

    public String getEps() { return eps; }
    public void setEps(String eps) { this.eps = eps; }

    public String getVeredaBarrio() { return veredaBarrio; }
    public void setVeredaBarrio(String veredaBarrio) { this.veredaBarrio = veredaBarrio; }

    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Paciente{" +
                "id=" + id +
                ", documento='" + documento + '\'' +
                ", nombre='" + getNombreCompleto() + '\'' +
                ", edad=" + calcularEdad() +
                '}';
    }
}