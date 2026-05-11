package co.sena.cimm.adso.saludboyaca.dto;

public class Notificacion {

    private int id;
    private int idUsuario;
    private String titulo;
    private String mensaje;
    private String tipo;
    private boolean leida;
    private int idCita;
    private String createdAt;

    public Notificacion() {}
    
    public int getId() {
        return id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int v) {
        this.idUsuario = v;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String v) {
        this.titulo = v;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String v) {
        this.mensaje = v;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String v) {
        this.tipo = v;
    }

    public boolean isLeida() {
        return leida;
    }

    public void setLeida(boolean v) {
        this.leida = v;
    }

    public int getIdCita() {
        return idCita;
    }

    public void setIdCita(int v) {
        this.idCita = v;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String v) {
        this.createdAt = v;
    }
}
