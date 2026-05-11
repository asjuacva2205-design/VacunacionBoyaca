package co.sena.cimm.adso.saludboyaca.dto;

import java.time.LocalTime;


public class Horario {

    private int       id;
    private int       idMedico;
    private String    nombreMedico;    // Campo JOIN
    private int       diaSemana;      // 1=Lun ... 5=Vie... 7=Dom
    private LocalTime horaInicio;
    private LocalTime horaFin;
    private int       maxCitas;
    private boolean activo;
    
    public Horario() {}

    /** Retorna el nombre del día en español */
    public String getDiaNombre() {
        return switch (diaSemana) {
            case 1 -> "Lunes";
            case 2 -> "Martes";
            case 3 -> "Miércoles";
            case 4 -> "Jueves";
            case 5 -> "Viernes";
            case 6 -> "Sabado";
            case 7 -> "Domingo";    
            default -> "Desconocido";
        };
    }

    /** Retorna el nombre del día en inglés (para i18n) */
    public String getDiaNombreEn() {
        return switch (diaSemana) {
            case 1 -> "Monday";
            case 2 -> "Tuesday";
            case 3 -> "Wednesday";
            case 4 -> "Thursday";
            case 5 -> "Friday";
            case 6 -> "Sabado";
            case 7 -> "Domingo";
            default -> "Unknown";
        };
    }

    /** Descripción del horario: "Lunes 08:00 - 12:00 (máx. 8 citas)" */
    public String getDescripcion() {
        return getDiaNombre() + " " + horaInicio + " - " + horaFin +
               " (máx " + maxCitas + " citas)"+ activo + " ";
    }

    // ── GETTERS Y SETTERS ────────────────────────────────────────────
    public int       getId()               { return id; }
    public void      setId(int id)         { this.id = id; }

    public int       getIdMedico()         { return idMedico; }
    public void      setIdMedico(int v)    { this.idMedico = v; }

    public String    getNombreMedico()     { return nombreMedico; }
    public void      setNombreMedico(String v) { this.nombreMedico = v; }

    public int       getDiaSemana()        { return diaSemana; }
    public void      setDiaSemana(int v)   { this.diaSemana = v; }

    public LocalTime getHoraInicio()       { return horaInicio; }
    public void      setHoraInicio(LocalTime v) { this.horaInicio = v; }

    public LocalTime getHoraFin()          { return horaFin; }
    public void      setHoraFin(LocalTime v)    { this.horaFin = v; }

    public int       getMaxCitas()         { return maxCitas; }
    public void      setMaxCitas(int v)    { this.maxCitas = v; }
    
    public boolean isActivo()             { return activo; }
    public void    setActivo(boolean v)   { this.activo = v; }
}
