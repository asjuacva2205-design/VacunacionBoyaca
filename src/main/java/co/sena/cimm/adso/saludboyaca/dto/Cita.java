package co.sena.cimm.adso.saludboyaca.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Cita DTO v3 — Incluye campos de joins (nombre paciente, médico, especialidad)
 */
public class Cita {
    private int    id;
    private int    idPaciente;
    private int    idMedico;
    private int    idEspecialidad;
    private LocalDate fechaCita;
    private String horaCita;
    private String motivo;
    private String estado;
    private String observaciones;
    private String motivoRechazo;
    private int    idRegistradoPor;
    private LocalDateTime fechaRegistro;
    private String updatedAt;
    // Campos de JOINs
    private String nombrePaciente;
    private String emailPaciente;
    private String telefonoPaciente;
    private String documentoPaciente;
    private String nombreMedico;
    private String nombreEspecialidad;
    private String iconoEspecialidad;

    // Getters y Setters

    public Cita() {}
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdPaciente() {
        return idPaciente;
    }

    public void setIdPaciente(int idPaciente) {
        this.idPaciente = idPaciente;
    }

    public int getIdMedico() {
        return idMedico;
    }

    public void setIdMedico(int idMedico) {
        this.idMedico = idMedico;
    }

    public int getIdEspecialidad() {
        return idEspecialidad;
    }

    public void setIdEspecialidad(int idEspecialidad) {
        this.idEspecialidad = idEspecialidad;
    }

    public LocalDate getFechaCita() {
        return fechaCita;
    }

    public void setFechaCita(LocalDate fechaCita) {
        this.fechaCita = fechaCita;
    }

    public String getHoraCita() {
        return horaCita;
    }

    public void setHoraCita(String horaCita) {
        this.horaCita = horaCita;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getMotivoRechazo() {
        return motivoRechazo;
    }

    public void setMotivoRechazo(String motivoRechazo) {
        this.motivoRechazo = motivoRechazo;
    }

    public int getIdRegistradoPor() {
        return idRegistradoPor;
    }

    public void setIdRegistradoPor(int idRegistradoPor) {
        this.idRegistradoPor = idRegistradoPor;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getNombrePaciente() {
        return nombrePaciente;
    }

    public void setNombrePaciente(String nombrePaciente) {
        this.nombrePaciente = nombrePaciente;
    }

    public String getEmailPaciente() {
        return emailPaciente;
    }

    public void setEmailPaciente(String emailPaciente) {
        this.emailPaciente = emailPaciente;
    }

    public String getTelefonoPaciente() {
        return telefonoPaciente;
    }

    public void setTelefonoPaciente(String telefonoPaciente) {
        this.telefonoPaciente = telefonoPaciente;
    }

    public String getDocumentoPaciente() {
        return documentoPaciente;
    }

    public void setDocumentoPaciente(String documentoPaciente) {
        this.documentoPaciente = documentoPaciente;
    }

    public String getNombreMedico() {
        return nombreMedico;
    }

    public void setNombreMedico(String nombreMedico) {
        this.nombreMedico = nombreMedico;
    }

    public String getNombreEspecialidad() {
        return nombreEspecialidad;
    }

    public void setNombreEspecialidad(String nombreEspecialidad) {
        this.nombreEspecialidad = nombreEspecialidad;
    }

    public String getIconoEspecialidad() {
        return iconoEspecialidad;
    }

    public void setIconoEspecialidad(String iconoEspecialidad) {
        this.iconoEspecialidad = iconoEspecialidad;
    }    
}
